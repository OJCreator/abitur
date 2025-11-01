import 'package:abitur/services/database/settings_service.dart';
import 'package:abitur/services/database/subject_service.dart';
import 'package:abitur/utils/enums/graduation_evaluation_type.dart';
import 'package:abitur/utils/enums/land.dart';
import 'package:abitur/utils/enums/subject_type.dart';
import 'package:sqflite/sqflite.dart';

import '../../sqlite/entities/graduation_evaluation.dart';
import '../../sqlite/entities/subject.dart';
import '../../sqlite/sqlite_storage.dart';

class GraduationEvaluationService {
  static Database get db => SqliteStorage.database;

  // ---------------------------------------------------------
  // Grundlegende Lademethoden
  // ---------------------------------------------------------
  static Future<List<GraduationEvaluation>> findAllEvaluations() async {
    final result = await db.query('graduation_evaluations');
    return result.map((e) => GraduationEvaluation.fromJson(e)).toList();
  }

  static Future<List<GraduationEvaluation>> findAllEvaluationsById(List<String> ids) async {
    if (ids.isEmpty) return [];
    final placeholders = List.filled(ids.length, '?').join(', ');
    final result = await db.query(
      'graduation_evaluations',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return result.map((e) => GraduationEvaluation.fromJson(e)).toList();
  }

  static Future<GraduationEvaluation> findEvaluationById(String id) async {
    final result = await db.query(
      'graduation_evaluations',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return GraduationEvaluation.empty();
    return GraduationEvaluation.fromJson(result.first);
  }

  static Future<GraduationEvaluation?> findEvaluationBySubject(String subjectId) async {
    final result = await db.query(
      'graduation_evaluations',
      where: 'subjectId = ?',
      whereArgs: [subjectId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return GraduationEvaluation.fromJson(result.first);
  }

  // ---------------------------------------------------------
  // Statusprüfungen
  // ---------------------------------------------------------
  static Future<bool> hasGraduationEvaluation(Subject subject) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM graduation_evaluations WHERE subjectId = ?',
      [subject.id],
    );
    return (result.first['count'] as int) > 0;
  }

  static Future<bool> isGraduationSubject(Subject subject) async {
    if (subject.subjectType == SubjectType.wSeminar) return false;
    return await hasGraduationEvaluation(subject);
  }

  static Future<List<Subject>> graduationSubjects() async {
    final result = await db.rawQuery('''
      SELECT DISTINCT s.* FROM subjects s
      JOIN graduation_evaluations g ON g.subjectId = s.id
      WHERE s.subjectType != ?
    ''', [SubjectType.wSeminar.index]);
    return result.map((e) => Subject.fromJson(e)).toList();
  }

  static Future<List<Subject>> graduationSubjectsFiltered(
      GraduationEvaluationType filter) async {
    final result = await db.rawQuery('''
      SELECT DISTINCT s.* FROM subjects s
      JOIN graduation_evaluations g ON g.subjectId = s.id
      WHERE g.graduationEvaluationType = ? AND s.subjectType != ?
    ''', [filter.index, SubjectType.wSeminar.index]);
    return result.map((e) => Subject.fromJson(e)).toList();
  }

  // ---------------------------------------------------------
  // Änderungen an Evaluationsdaten
  // ---------------------------------------------------------
  static Future<void> deleteGraduationEvaluation(Subject s) async {
    if (!canDisableGraduation(s)) {
      return;
    }
    await db.delete(
      'graduation_evaluations',
      where: 'subjectId = ?',
      whereArgs: [s.id],
    );
  }

  static Future<void> setGraduationEvaluation(Subject s, GraduationEvaluationType graduation) async {

    final existing = await findEvaluationBySubject(s.id);

    if (existing == null) {
      final g = GraduationEvaluation(
        subjectId: s.id,
        graduationEvaluationType: graduation,
      );
      await db.insert('graduation_evaluations', g.toJson());
    } else if (existing.graduationEvaluationType != graduation) {
      await db.update(
        'graduation_evaluations',
        {'graduationEvaluationType': graduation.index},
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    }
  }

  // ---------------------------------------------------------
  // Regeln und Logik
  // ---------------------------------------------------------
  static bool canDisableGraduation(Subject s) {
    if (s.subjectType == SubjectType.wSeminar) return false;
    return true;
  }

  static Future<bool> canAddSecondGraduationDate(GraduationEvaluation ge) async {
    Land land = await SettingsService.land();
    if (land == Land.by) {
      Subject? subject = await SubjectService.findById(ge.subjectId);
      return subject?.subjectType == SubjectType.wSeminar;
    }
    if ([Land.bw, Land.nw, Land.rp, Land.hh].contains(land)) {
      return ge.graduationEvaluationType == GraduationEvaluationType.written;
    }
    return false;
  }

  static double? calculateNote(GraduationEvaluation ge) {
    if (ge.notePartOne == null) {
      return ge.notePartTwo?.toDouble();
    }
    if (ge.isDividedEvaluation) {
      if (ge.notePartTwo == null) {
        return ge.notePartOne?.toDouble();
      }
      return (ge.notePartOne! * ge.weightPartOne + ge.notePartTwo! * ge.weightPartTwo) /
          (ge.weightPartOne + ge.weightPartTwo);
    }
    return ge.notePartOne?.toDouble();
  }

  // ---------------------------------------------------------
  // Import / Export / Edit
  // ---------------------------------------------------------
  static Future<void> buildFromJson(List<Map<String, dynamic>> jsonData) async {
    await db.delete('graduation_evaluations');
    for (final e in jsonData) {
      await db.insert('graduation_evaluations', e);
    }
  }

  static Future<void> editEvaluation(
      GraduationEvaluation g, {
        int? notePartOne,
        required int weightPartOne,
        DateTime? datePartOne,
        required bool divideEvaluation,
        int? notePartTwo,
        required int weightPartTwo,
        DateTime? datePartTwo,
      }) async {
    g.notePartOne = notePartOne;
    g.weightPartOne = weightPartOne;
    g.datePartOne = datePartOne;
    g.isDividedEvaluation = divideEvaluation;
    g.notePartTwo = notePartTwo;
    g.weightPartTwo = weightPartTwo;
    g.datePartTwo = datePartTwo;

    await db.update(
      'graduation_evaluations',
      g.toJson(),
      where: 'id = ?',
      whereArgs: [g.id],
    );
  }
}
