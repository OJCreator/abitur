import 'package:abitur/services/notification_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:abitur/utils/enums/subject_type.dart';
import 'package:abitur/utils/extensions/lists/int_iterable_extension.dart';
import 'package:sqflite/sqflite.dart';

import '../../sqlite/entities/evaluation/evaluation.dart';
import '../../sqlite/entities/evaluation/evaluation_date.dart';
import '../../sqlite/entities/evaluation/evaluation_type.dart';
import '../../sqlite/entities/performance.dart';
import '../../sqlite/entities/subject.dart';
import '../../sqlite/sqlite_storage.dart';
import 'evaluation_date_service.dart';


class EvaluationService {
  static Database get db => SqliteStorage.database;

  // ---------------------------------------------------------
  // Lade-Methoden
  // ---------------------------------------------------------
  static Future<List<Evaluation>> findAll() async {
    final result = await db.query('evaluations');
    final evaluations = result.map((e) => Evaluation.fromJson(e)).toList();

    final evaluationDates = await EvaluationDateService.findAllByEvaluationIds(evaluations.map((e) => e.id).toList());

    evaluations.sort((a, b) =>
        (evaluationDates[a.id]?.firstOrNull?.date ?? DateTime(3000))
            .compareTo(
            evaluationDates[b.id]?.firstOrNull?.date ?? DateTime(3000)));
    return evaluations;
  }

  static Future<Map<String, Evaluation>> findAllAsMap() async {
    final result = await db.query('evaluations');
    final evaluations = result.map((e) => Evaluation.fromJson(e)).toList();

    final evaluationDates = await EvaluationDateService.findAllByEvaluationIds(
      evaluations.map((e) => e.id).toList(),
    );

    evaluations.sort((a, b) =>
        (evaluationDates[a.id]?.firstOrNull?.date ?? DateTime(3000))
            .compareTo(evaluationDates[b.id]?.firstOrNull?.date ?? DateTime(3000)));

    return {for (var e in evaluations) e.id: e};
  }


  static Future<Evaluation?> findById(String evaluationId) async {
    final result = await db.query(
      'evaluations',
      where: 'id = ?',
      whereArgs: [evaluationId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Evaluation.fromJson(result.first);
  }

  static Future<Map<String, Evaluation?>> findAllById(List<String> evaluationIds) async {
    if (evaluationIds.isEmpty) return {};

    final placeholders = List.filled(evaluationIds.length, '?').join(', ');
    final result = await db.query(
      'evaluations',
      where: 'id IN ($placeholders)',
      whereArgs: evaluationIds,
    );

    final Map<String, Evaluation?> evaluations = {};
    for (final row in result) {
      final evaluation = Evaluation.fromJson(row);
      evaluations[evaluation.id] = evaluation;
    }

    for (final id in evaluationIds) {
      evaluations.putIfAbsent(id, () => null);
    }

    return evaluations;
  }


  static Future<List<Evaluation>> findAllByDay(DateTime day) async {
    final dates = await EvaluationDateService.findAllByDay(day);
    final ids = dates.map((d) => d.evaluationId).toSet().toList();
    if (ids.isEmpty) return [];
    final placeholders = List.filled(ids.length, '?').join(', ');
    final result = await db.query(
      'evaluations',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return result.map((e) => Evaluation.fromJson(e)).toList();
  }

  static Future<Map<DateTime, List<Evaluation>>> findAllBetweenDays(
      DateTime start,
      DateTime end,
      ) async {
    final db = SqliteStorage.database;

    // Hole alle EvaluationDates zwischen den Tagen
    final List<Map<String, dynamic>> maps = await db.query(
      'evaluation_dates',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );

    if (maps.isEmpty) return {};

    // EvaluationDates -> Evaluations auflösen
    final evaluationDates = maps.map((e) => EvaluationDate.fromJson(e)).toList();

    final ids = evaluationDates.map((d) => d.evaluationId).toSet().toList();
    final placeholders = List.filled(ids.length, '?').join(', ');
    final List<Map<String, dynamic>> evalMaps = await db.query(
      'evaluations',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );

    final evaluations = evalMaps.map((e) => Evaluation.fromJson(e)).toList();

    // Schnellzugriff per ID
    final evalById = {for (var e in evaluations) e.id: e};

    // Map nach Datum gruppieren
    final Map<DateTime, List<Evaluation>> grouped = {};

    for (final date in evaluationDates) {
      final eval = evalById[date.evaluationId];
      if (eval == null || date.date == null) continue;

      // Datum ohne Zeitanteil (für saubere Kalenderzuordnung)
      final day = DateTime(date.date!.year, date.date!.month, date.date!.day);
      grouped.putIfAbsent(day, () => []).add(eval);
    }

    return grouped;
  }


  // static Future<List<Evaluation>> findAllByQuery(String text) async {
  //   final queries = text.toLowerCase().split(' ')..removeWhere((it) => it.isEmpty);
  //   if (queries.isEmpty) return findAll();
  //
  //   final all = await findAll();
  //   return all.where((e) {
  //     return queries.every((query) =>
  //     e.name.toLowerCase().contains(query) ||
  //         e.subject.name.toLowerCase().contains(query) ||
  //         e.subject.shortName.toLowerCase().contains(query) ||
  //         (calculateNote(e) == int.tryParse(query)));
  //   }).toList();
  // }

  static Future<List<Evaluation>> findAllBySubject(Subject s) async {
    final result = await db.query(
      'evaluations',
      where: 'subjectId = ?',
      whereArgs: [s.id],
    );
    return result.map((e) => Evaluation.fromJson(e)).toList();
  }

  static Future<List<Evaluation>> findAllGraded() async {
    final result = await SqliteStorage.database.rawQuery('''
    SELECT e.*
    FROM evaluations e
    JOIN evaluation_dates d ON e.id = d.evaluationId
    WHERE d.note IS NOT NULL
    GROUP BY e.id
  ''');
    return result.map((r) => Evaluation.fromJson(r)).toList();
  }

  static Future<List<Evaluation>> findAllGradedBySubject(Subject s) async {
    final result = await SqliteStorage.database.rawQuery('''
    SELECT e.*
    FROM evaluations e
    JOIN evaluation_dates d ON e.id = d.evaluationId
    WHERE e.subjectId = ? AND d.note IS NOT NULL
    GROUP BY e.id
  ''', [s.id]);
    return result.map((r) => Evaluation.fromJson(r)).toList();
  }


  static Future<List<Evaluation>> findAllGradedBySubjectAndTerm(
      Subject s, int term) async {
    final evals = await findAllGradedBySubject(s);
    return evals.where((e) => e.term == term).toList();
  }

  static Future<List<Evaluation>> findAllBySubjectAndTerm(
      Subject subject, int term) async {
    final result = await db.query(
      'evaluations',
      where: 'subjectId = ? AND term = ?',
      whereArgs: [subject.id, term],
    );
    return result.map((e) => Evaluation.fromJson(e)).toList();
  }

  static Future<List<Evaluation>> findAllBySubjectAndTerms(
      Subject subject, List<int> terms) async {
    if (terms.isEmpty) return [];
    final placeholders = List.filled(terms.length, '?').join(', ');
    final result = await db.query(
      'evaluations',
      where: 'subjectId = ? AND term IN ($placeholders)',
      whereArgs: [subject.id, ...terms],
    );
    return result.map((e) => Evaluation.fromJson(e)).toList();
  }

  static Future<List<Evaluation>> findAllByPerformance(Performance performance) async {
    final result = await db.query(
      'evaluations',
      where: 'performanceId = ?',
      whereArgs: [performance.id],
    );
    return result.map((e) => Evaluation.fromJson(e)).toList();
  }

  // ---------------------------------------------------------
  // Erstellung und Bearbeitung
  // ---------------------------------------------------------
  static Future<Evaluation> newEvaluation(
      String subjectId,
      String performanceId,
      EvaluationType evaluationType,
      int term,
      String name,
      List<EvaluationDate> evaluationDates) async {
    return _createNewEvaluation(subjectId, performanceId, term, name, evaluationDates, evaluationType);
  }

  static Future<Evaluation> newGraduationEvaluation(Subject subject) async {
    String name = subject.subjectType == SubjectType.wSeminar ? "Seminararbeit" : "Abitur";
    EvaluationDate e = EvaluationDate(date: null);
    return _createNewEvaluation(subject.id, null, 5, name, [e], null);
  }

  static Future<Evaluation> _createNewEvaluation(
      String subjectId,
      String? performanceId,
      int term,
      String name,
      List<EvaluationDate> evaluationDates,
      EvaluationType? evaluationType) async {
    final newEval = Evaluation(
      subjectId: subjectId,
      performanceId: performanceId ?? "",
      evaluationTypeId: evaluationType?.id ?? "",
      term: term,
      name: name,
    );

    await db.insert('evaluations', newEval.toJson());

    for (final e in evaluationDates) {
      e.evaluationId = newEval.id;
      NotificationService.scheduleNotificationsForEvaluation(e);
    }

    await EvaluationDateService.saveAllEvaluationDates(evaluationDates);

    return newEval;
  }

  static Future<void> editEvaluation(
      Evaluation evaluation, {
        required String subjectId,
        required String performanceId,
        required int term,
        required String name,
        required EvaluationType evaluationType,
      }) async {
    evaluation.subjectId = subjectId;
    evaluation.performanceId = performanceId;
    evaluation.evaluationTypeId = evaluationType.id;
    evaluation.term = term;
    evaluation.name = name;


    await db.update(
      'evaluations',
      evaluation.toJson(),
      where: 'id = ?',
      whereArgs: [evaluation.id],
    );
  }

  // ---------------------------------------------------------
  // Löschfunktionen
  // ---------------------------------------------------------
  static Future<void> deleteEvaluation(Evaluation evaluation) async {
    await db.delete(
      'evaluations',
      where: 'id = ?',
      whereArgs: [evaluation.id],
    );
  }

  static Future<void> deleteAllEvaluations(List<Evaluation> evaluations) async {
    for (final e in evaluations) {
      await deleteEvaluation(e);
    }
  }

  // ---------------------------------------------------------
  // Berechnungen & Import
  // ---------------------------------------------------------
  static Future<int?> calculateNote(Evaluation evaluation) async {
    final evaluationDates = await EvaluationDateService.findAllByEvaluationIds([evaluation.id]);
    final dates = evaluationDates[evaluation.id]?.where((d) => d.note != null).toList() ?? [];
    final totalWeight = dates.map((d) => d.weight).sum().toDouble();
    if (totalWeight == 0) return null;
    final note = dates.map((d) => d.note! * d.weight).sum() / totalWeight;
    return roundNote(note);
  }

  static Future<void> buildFromJson(List<Map<String, dynamic>> jsonData) async {
    await db.delete('evaluations');
    for (final e in jsonData) {
      await db.insert('evaluations', e);
    }
  }
}
