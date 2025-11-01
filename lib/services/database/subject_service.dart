import 'dart:ui';
import 'package:abitur/services/database/graduation_evaluation_service.dart';
import 'package:abitur/services/database/performance_service.dart';
import 'package:abitur/services/database/settings_service.dart';
import 'package:abitur/sqlite/sqlite_storage.dart';
import 'package:abitur/exceptions/invalid_form_input_exception.dart';
import 'package:abitur/utils/constants.dart';
import 'package:abitur/utils/enums/land.dart';
import 'package:abitur/utils/enums/subject_niveau.dart';
import 'package:abitur/utils/enums/subject_type.dart';
import 'package:abitur/utils/pair.dart';
import 'package:sqflite/sqflite.dart';

import '../../sqlite/entities/evaluation/evaluation.dart';
import '../../sqlite/entities/graduation_evaluation.dart';
import '../../sqlite/entities/performance.dart';
import '../../sqlite/entities/subject.dart';
import '../../utils/enums/graduation_evaluation_type.dart';
import 'evaluation_service.dart';

class SubjectService {

  static Database get db => SqliteStorage.database;

  /// Neues Fach anlegen
  static Future<Subject> newSubject(
      String name,
      String shortName,
      Color color,
      Set<int> terms,
      int countingTermAmount,
      SubjectNiveau subjectNiveau,
      SubjectType subjectType,
      List<Performance> performances) async {

    final existing = await findAll();

    final land = await SettingsService.land();
    final advancedCount = existing.where((s) => s.subjectNiveau == SubjectNiveau.advanced).length;
    final sameTypeCount = existing.where((s) => s.subjectType == subjectType).length;

    if ([Land.bw, Land.by, Land.rp, Land.sh, Land.th, Land.st, Land.hh].contains(land) &&
        subjectNiveau == SubjectNiveau.advanced &&
        advancedCount >= 3) {
      throw InvalidFormException("Es gibt bereits 3 Fächer auf erhöhtem Anforderungsniveau.");
    }
    if ([Land.ni, Land.he, Land.sn, Land.be, Land.bb, Land.nw, Land.mv, Land.sl, Land.hb].contains(land) &&
        subjectNiveau == SubjectNiveau.advanced &&
        advancedCount >= 2) {
      throw InvalidFormException("Es gibt bereits 2 Fächer auf erhöhtem Anforderungsniveau.");
    }
    if (subjectType.maxAmount != null && sameTypeCount >= subjectType.maxAmount!) {
      throw InvalidFormException("Es gibt bereits ${subjectType.maxAmount} Fächer vom Typ ${subjectType.displayName}.");
    }

    final s = Subject(
      name: name,
      shortName: shortName,
      color: color,
      subjectNiveau: subjectNiveau,
      subjectType: subjectType,
      terms: terms,
      countingTermAmount: countingTermAmount,
    );

    await db.insert('subjects', s.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);

    if (subjectType == SubjectType.wSeminar) {
      await GraduationEvaluationService.setGraduationEvaluation(s, GraduationEvaluationType.seminar);
    }

    for (Performance p in performances) {
      p.subjectId = s.id;
    }
    await PerformanceService.savePerformances(performances);

    return s;
  }

  static Future<List<Subject>> findGraduationSubjectsFiltered(GraduationEvaluationType filter) async {

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT s.*
    FROM subjects s
    JOIN graduation_evaluations ge ON ge.id = s.graduationEvaluationId
    WHERE ge.graduationEvaluationType = ?
  ''', [filter.name]);

    return maps
        .map((m) => Subject.fromJson(m))
        .where((s) => s.subjectType != SubjectType.wSeminar)
        .toList();
  }


  static Future<void> setGraduationSubjects(
      List<Subject?> subjectsWritten,
      List<Subject?> subjectsOral,
      ) async {
    if (subjectsWritten.contains(null) || subjectsOral.contains(null)) {
      throw InvalidFormException("Alle Prüfungen müssen belegt werden.");
    }

    final all = [...subjectsWritten, ...subjectsOral].whereType<Subject>();
    if (all.length != all.toSet().length) {
      throw InvalidFormException("Du darfst kein Fach mehrfach wählen.");
    }

    if (all.any((s) => s.subjectType == SubjectType.wSeminar)) {
      throw InvalidFormException("Subjects dürfen kein Seminarfach sein!");
    }

    final oldSubjects = await getGraduationSubjects();
    for (Subject oldSubj in oldSubjects.where((s) => !all.contains(s))) {
      if (oldSubj.graduationEvaluationId != null) {
        await db.delete(
          'graduation_evaluations',
          where: 'id = ?',
          whereArgs: [oldSubj.graduationEvaluationId],
        );
        await db.update(
          'subjects',
          {'graduationEvaluationId': null},
          where: 'id = ?',
          whereArgs: [oldSubj.id],
        );
      }
    }

    for (Subject? s in subjectsWritten) {
      await _setGraduationEvaluation(s!, GraduationEvaluationType.written);
    }
    for (Subject? s in subjectsOral) {
      await _setGraduationEvaluation(s!, GraduationEvaluationType.oral);
    }
  }

  // Hilfsmethode: GraduationEvaluation setzen
  static Future<void> _setGraduationEvaluation(
      Subject subject,
      GraduationEvaluationType type,
      ) async {
    final evaluation = GraduationEvaluation(
      id: subject.id, // optional neue ID generieren, z.B. UUID
      subjectId: subject.id,
      graduationEvaluationType: type,
      isDividedEvaluation: false,
      notePartOne: null,
      datePartOne: null,
      weightPartOne: 1,
      notePartTwo: null,
      datePartTwo: null,
      weightPartTwo: 1,
    );

    // Insert oder replace
    await db.insert(
      'graduation_evaluations',
      evaluation.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // subject mit graduationEvaluationId updaten
    await db.update(
      'subjects',
      {'graduationEvaluationId': evaluation.id},
      where: 'id = ?',
      whereArgs: [subject.id],
    );
  }

  // Hilfsmethode: aktuelle GraduationSubjects laden
  static Future<List<Subject>> getGraduationSubjects() async {
    final maps = await db.query(
      'subjects',
      where: 'graduationEvaluationId IS NOT NULL',
    );
    return maps.map((m) => Subject.fromJson(m)).toList();
  }


  /// Fach bearbeiten
  static Future<Subject> editSubject(
      Subject subject, {
        required String name,
        required String shortName,
        required Color color,
        required Set<int> terms,
        required int countingTermAmount,
        required SubjectNiveau subjectNiveau,
        required SubjectType subjectType,
        required List performances, // TODO: später zu async Performance-Objekten ändern
      }) async {

    final db = SqliteStorage.database;
    final existing = (await findAll()).where((s) => s.id != subject.id).toList();

    final land = await SettingsService.land();
    final advancedCount = existing.where((s) => s.subjectNiveau == SubjectNiveau.advanced).length;
    final sameTypeCount = existing.where((s) => s.subjectType == subjectType).length;

    if ([Land.bw, Land.by, Land.rp, Land.sh, Land.th, Land.st, Land.hh].contains(land) &&
        subjectNiveau == SubjectNiveau.advanced &&
        advancedCount >= 3) {
      throw InvalidFormException("Es gibt bereits 3 Fächer auf erhöhtem Niveau.");
    }
    if ([Land.ni, Land.he, Land.sn, Land.be, Land.bb, Land.nw, Land.mv, Land.sl, Land.hb].contains(land) &&
        subjectNiveau == SubjectNiveau.advanced &&
        advancedCount >= 2) {
      throw InvalidFormException("Es gibt bereits 2 Fächer auf erhöhtem Niveau.");
    }
    if (subjectType.maxAmount != null &&
        sameTypeCount >= subjectType.maxAmount!) {
      throw InvalidFormException(
          "Es gibt bereits ${subjectType.maxAmount} Fächer vom Typ ${subjectType.displayName}.");
    }

    subject
      ..name = name
      ..shortName = shortName
      ..color = color
      ..terms = terms
      ..countingTermAmount = countingTermAmount
      ..subjectNiveau =
      subjectType.canBeLeistungsfach ? subjectNiveau : SubjectNiveau.basic
      ..subjectType = subjectType;

    await db.update('subjects', subject.toJson(),
        where: 'id = ?', whereArgs: [subject.id]);

    if (subjectType == SubjectType.wSeminar) {
      await GraduationEvaluationService.setGraduationEvaluation(subject, GraduationEvaluationType.seminar);
    }

    return subject;
  }

  /// Fach löschen
  static Future<void> deleteSubject(String subjectId) async {

    final db = SqliteStorage.database;

    await db.delete('subjects', where: 'id = ?', whereArgs: [subjectId]);
  }

  /// Alle Fächer laden (alphabetisch)
  static Future<List<Subject>> findAll() async {
    final db = SqliteStorage.database;
    final rows = await db.query('subjects', orderBy: 'name ASC');
    return rows.map((row) => Subject.fromJson(Map<String, dynamic>.from(row))).toList();
  }
  /// Alle Fächer laden (alphabetisch) und als Map zurückgeben
  static Future<Map<String, Subject>> findAllAsMap() async {
    final db = SqliteStorage.database;
    final rows = await db.query('subjects', orderBy: 'name ASC');
    return {
      for (final row in rows)
        row['id'].toString(): Subject.fromJson(row)
    };
  }


  /// Ein Fach per ID
  static Future<Subject?> findById(String? id) async {
    if (id == null) return null;
    final db = SqliteStorage.database;
    final rows = await db.query('subjects', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Subject.fromJson(rows.first);
  }

  static Future<bool> hasSubjects() async {
    final db = SqliteStorage.database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM subjects'));
    return (count ?? 0) > 0;
  }

  static Future<List<Subject>> findAllGradable() async {
    final db = SqliteStorage.database;

    final gradableTypes = SubjectType.values.where((v) => v.gradable).map((v) => v.code).toList();

    final placeholders = List.filled(gradableTypes.length, '?').join(', ');
    final List<Map<String, dynamic>> maps = await db.query(
      'subjects',
      where: 'subjectType IN ($placeholders)',
      whereArgs: gradableTypes,
    );

    return maps.map((json) => Subject.fromJson(json)).toList();
  }

  static Future<Map<String, Subject>> findAllGradableAsMap() async {
    final db = SqliteStorage.database;

    final gradableTypes = SubjectType.values.where((v) => v.gradable).toList();
    final placeholders = List.filled(gradableTypes.length, '?').join(', ');

    final List<Map<String, dynamic>> maps = await db.query(
      'subjects',
      where: 'subjectType IN ($placeholders)',
      whereArgs: gradableTypes.map((e) => e.code).toList(),
    );

    return {
      for (final m in maps) m['id'].toString(): Subject.fromJson(m),
    };
  }



  /// Durchschnittsberechnungen (vereinfacht, TODO: Isolate)
  static Future<double?> getCurrentAverage() async {
    final subjects = await findAllGradable();
    final averages = <int>[];

    for (final s in subjects) {
      for (int term = 0; term < 4; term++) {
        final avg = roundNote(await getAverageByTerm(s, term));
        if (avg != null) averages.add(avg);
      }
    }

    return avg(averages);
  }

  static Future<double?> getAverage(String subjectId) async {
    final db = SqliteStorage.database;
    final result = await db.rawQuery(
      'SELECT AVG(grade) as avg FROM evaluations WHERE subjectId = ?',
      [subjectId],
    );
    return result.first['avg'] as double?;
  }

  static Future<Map<String, double?>> getAverages(
      List<String> subjectIds, {
        int? filterByTerm,
      }) async {

    if (subjectIds.isEmpty) return {};

    final db = SqliteStorage.database;
    final placeholders = List.filled(subjectIds.length, '?').join(', ');
    final args = <Object>[...subjectIds];

    final termFilter = filterByTerm != null ? 'AND e.term = ?' : '';
    if (filterByTerm != null) args.add(filterByTerm);

    final result = await db.rawQuery('''
    WITH evaluation_averages AS (
      SELECT 
        e.id AS evalId,
        e.subjectId,
        e.performanceId,
        e.term,
        CASE 
          WHEN SUM(CASE WHEN d.note IS NOT NULL THEN d.weight ELSE 0 END) > 0 
          THEN CAST(SUM(CASE WHEN d.note IS NOT NULL THEN d.note * d.weight ELSE 0 END) AS REAL) 
               / SUM(CASE WHEN d.note IS NOT NULL THEN d.weight ELSE 0 END)
          ELSE NULL 
        END AS evalAvg
      FROM evaluations e
      LEFT JOIN evaluation_dates d ON e.id = d.evaluationId
      WHERE e.subjectId IN ($placeholders) $termFilter
      GROUP BY e.id
    ),
    performance_averages AS (
      SELECT
        ea.subjectId,
        ea.term,
        ea.performanceId,
        CAST(SUM(ea.evalAvg * p.weighting) AS REAL)
        / CAST(SUM(CASE WHEN ea.evalAvg IS NOT NULL THEN p.weighting ELSE 0 END) AS REAL) AS performanceAvg
      FROM evaluation_averages ea
      JOIN performances p ON p.id = ea.performanceId
      GROUP BY ea.subjectId, ea.term, ea.performanceId
    ),
    term_averages AS (
      SELECT
        subjectId,
        term,
        AVG(performanceAvg) AS termAvg
      FROM performance_averages
      GROUP BY subjectId, term
    )
    SELECT subjectId, term, termAvg FROM term_averages
  ''', args);

    // --- Schritt 1: Term-Durchschnitte in Dart runden ---
    final Map<String, List<double>> subjectTerms = {};
    for (final row in result) {
      final subjectId = row['subjectId'] as String;
      final termAvg = row['termAvg'] as num?;
      if (termAvg == null) continue;

      final rounded = roundNote(termAvg.toDouble());
      subjectTerms.putIfAbsent(subjectId, () => []);
      if (rounded == null) continue;
      subjectTerms[subjectId]!.add(rounded.toDouble());
    }

    // --- Schritt 2: Durchschnitt der gerundeten Term-Noten ---
    final Map<String, double?> averages = {};
    for (final id in subjectIds) {
      final terms = subjectTerms[id];
      if (terms == null || terms.isEmpty) {
        averages[id] = null;
      } else {
        averages[id] = terms.reduce((a, b) => a + b) / terms.length;
      }
    }

    return averages;
  }









  static Future<double?> getAverageByTerm(Subject s, int term) async {
    if (!s.terms.contains(term)) return null;

    if (s.manuallyEnteredTermNotes[term] != null) {
      return s.manuallyEnteredTermNotes[term]!.toDouble();
    }

    final evaluations = await EvaluationService.findAllGradedBySubjectAndTerm(s, term);
    if (evaluations.isEmpty) return null;

    // Evaluations nach Performance gruppieren
    final Map<String, List<Evaluation>> perfs = {};
    for (final e in evaluations) {
      perfs.putIfAbsent(e.performanceId, () => []).add(e);
    }

    final weightNotePairs = <Pair<double, double?>>[];

    for (final entry in perfs.entries) {
      final performanceId = entry.key;
      final evals = entry.value;

      // Performance abrufen (für Gewicht)
      final performance = await PerformanceService.findById(performanceId);
      if (performance == null) continue;

      // Alle Noten asynchron berechnen
      final notes = <int>[];
      for (final e in evals) {
        final note = await EvaluationService.calculateNote(e);
        if (note != null) notes.add(note);
      }

      if (notes.isEmpty) continue;

      final perfAverage = avg(notes);
      final weight = performance.weighting;
      weightNotePairs.add(Pair(weight, perfAverage));
    }

    if (weightNotePairs.isEmpty) return null;

    return weightedAvg(weightNotePairs);
  }


  static Future<void> manuallyEnterTermNote(Subject s, {required int term, required int? note}) async {
    final db = SqliteStorage.database;
    s.manuallyEnteredTermNotes[term] = note;
    await db.update('subjects', s.toJson(), where: 'id = ?', whereArgs: [s.id]);
  }

  /// Alte Daten importieren
  static Future<void> buildFromJson(List<Map<String, dynamic>> jsonData) async {
    final db = SqliteStorage.database;
    await db.delete('subjects');
    for (final json in jsonData) {
      final s = Subject.fromJson(json);
      await db.insert('subjects', s.toJson());
    }
  }
}
