import 'package:abitur/services/calendar_service.dart';
import 'package:abitur/services/database/evaluation_service.dart';
import 'package:abitur/services/notification_service.dart';
import 'package:abitur/utils/extensions/date_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../sqlite/sqlite_storage.dart';
import '../../sqlite/entities/evaluation/evaluation_date.dart';
import '../../sqlite/entities/evaluation/evaluation.dart';
import '../../sqlite/entities/subject.dart';
import '../../isolates/evaluation_date_isolates.dart';
import '../../isolates/serializer.dart';
import '../../isolates/models/evaluation_dates/evaluation_dates_time_model.dart';

class EvaluationDateService {

  static Database get db => SqliteStorage.database;

  static Future<List<EvaluationDate>> findAll() async {
    final List<Map<String, dynamic>> maps = await db.query('evaluation_dates');
    List<EvaluationDate> list = maps.map((e) => EvaluationDate.fromJson(e)).toList();
    list.sort((a, b) => a.compareTo(b));
    return list;
  }

  static Future<EvaluationDate> findById(String id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'evaluation_dates',
      where: 'id = ?',
      whereArgs: [id],
    );
    return EvaluationDate.fromJson(maps.first);
  }

  static Future<List<EvaluationDate>> findAllById(List<String> ids) async {
    if (ids.isEmpty) return [];
    final List<Map<String, dynamic>> maps = await db.query(
      'evaluation_dates',
      where: 'id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );
    return maps.map((e) => EvaluationDate.fromJson(e)).toList();
  }

  /// Gibt alle EvaluationDates für mehrere Evaluationen zurück,
  /// gruppiert nach ihrer Evaluation-ID.
  static Future<Map<String, List<EvaluationDate>>> findAllByEvaluationIds(List<String> evaluationIds,) async {
    if (evaluationIds.isEmpty) return {};

    final List<Map<String, dynamic>> maps = await db.query(
      'evaluation_dates',
      where: 'evaluationId IN (${List.filled(evaluationIds.length, '?').join(',')})',
      whereArgs: evaluationIds,
      orderBy: 'date ASC',
    );

    // Gruppierung der Ergebnisse nach evaluationId
    final Map<String, List<EvaluationDate>> grouped = {};

    for (final map in maps) {
      final date = EvaluationDate.fromJson(map);
      grouped.putIfAbsent(date.evaluationId, () => []).add(date);
    }

    return grouped;
  }


  static Future<List<EvaluationDate>> findAllByDay(DateTime day) async {
    final start = day.startOfDay();
    final end = day.endOfDay();
    final maps = await db.query(
      'evaluation_dates',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
    return maps.map(EvaluationDate.fromJson).toList();
  }

  static Future<List<EvaluationDate>> findAllGraded() async {
    final maps = await db.query('evaluation_dates', where: 'note IS NOT NULL');
    return maps.map(EvaluationDate.fromJson).toList();
  }

  static Future<List<EvaluationDate>> findAllBySubject(Subject s) async {
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT ed.* FROM evaluation_dates ed
      JOIN evaluations e ON e.id = ed.evaluationId
      WHERE e.subjectId = ?
    ''', [s.id]);
    return maps.map((e) => EvaluationDate.fromJson(e)).toList();
  }

  static Future<List<EvaluationDate>> findAllGradedBySubject(Subject s) async {
    final maps = await db.rawQuery('''
      SELECT ed.* FROM evaluation_dates ed
      JOIN evaluations e ON e.id = ed.evaluationId
      WHERE e.subjectId = ? AND ed.note IS NOT NULL
    ''', [s.id]);
    return maps.map(EvaluationDate.fromJson).toList();
  }


  static Future<List<EvaluationDate>> findAllByQuery(String text) async {
    final queries = text.toLowerCase().split(" ")..removeWhere((it) => it.isEmpty);
    if (queries.isEmpty) return findAll();

    // Baue dynamisch die WHERE-Bedingungen (eine pro Suchbegriff)
    final whereClauses = queries.map((_) =>
    '''(
        LOWER(e.name) LIKE ? OR
        LOWER(s.name) LIKE ? OR
        LOWER(s.shortName) LIKE ? OR
        (ed.note IS NOT NULL AND CAST(ed.note AS TEXT) = ?)
      )'''
    ).join(' AND ');

    // Baue die Parameterliste (für jeden Begriff 4 Parameter)
    final whereArgs = queries.expand((q) => List.filled(4, '%$q%')
      ..[3] = q // für die Note exakter Vergleich
    ).toList();

    final maps = await SqliteStorage.database.rawQuery('''
      SELECT 
        ed.*, 
        e.name AS evaluationName, 
        s.name AS subjectName, 
        s.shortName AS subjectShortName
      FROM evaluation_dates ed
      JOIN evaluations e ON e.id = ed.evaluationId
      JOIN subjects s ON s.id = e.subjectId
      WHERE $whereClauses
      ORDER BY ed.date ASC
    ''', whereArgs);


    return maps.map((m) => EvaluationDate.fromJson(m)).toList();
  }


  static Future<List<EvaluationDate>> findAllFutureOrUngradedEvaluationDatesIsolated() async {
    final all = await findAll();
    final serialized = all.serialize();
    final model = EvaluationDatesTimeModel(serialized, DateTime.now());
    final filtered = await compute(EvaluationDateIsolates.filterFutureOrNotGraded, model);
    return filtered.evaluationDates.map((e) => EvaluationDate.fromJson(e)).toList();
  }

  static Future<List<EvaluationDate>> findAllFutureOrUngraded() async {
    final now = DateTime.now().toIso8601String();
    final maps = await db.query(
      'evaluation_dates',
      where: '(date >= ? OR note IS NULL) AND weight != 0',
      whereArgs: [now],
      orderBy: 'date ASC',
    );
    return maps.map(EvaluationDate.fromJson).toList();
  }


  static Future<EvaluationDate> newEvaluationDate(Evaluation evaluation, {DateTime? date, int? note, int? weight, String? description}) async {
    final e = EvaluationDate(
      evaluationId: evaluation.id,
      date: date,
      note: note,
      weight: weight ?? 1,
      description: description ?? "",
    );

    await db.insert('evaluation_dates', e.toJson());

    await CalendarService.syncEvaluationCalendarEvent(e, evaluation);
    NotificationService.scheduleNotificationsForEvaluation(e);

    return e;
  }

  static Future<void> saveEvaluationDate(EvaluationDate e) async {
    final existing = await db.query(
      'evaluation_dates',
      where: 'id = ?',
      whereArgs: [e.id],
    );

    if (existing.isEmpty) {
      await db.insert('evaluation_dates', e.toJson());
    } else {
      await db.update(
        'evaluation_dates',
        e.toJson(),
        where: 'id = ?',
        whereArgs: [e.id],
      );
    }

    final evaluation = await EvaluationService.findById(e.evaluationId);
    if (evaluation == null) return;

    await CalendarService.syncEvaluationCalendarEvent(e, evaluation);
    NotificationService.scheduleNotificationsForEvaluation(e);
  }


  static Future<void> saveAllEvaluationDates(List<EvaluationDate> evaluationDates) async {
    for (final e in evaluationDates) {
      await saveEvaluationDate(e);
    }
  }

  static Future<void> editEvaluationDate(EvaluationDate e, {required DateTime? date, required int? note, required int weight}) async {
    e.date = date;
    e.note = note;
    e.weight = weight;
    await saveEvaluationDate(e);
  }

  static Future<void> setCalendarId(EvaluationDate e, {required String? calendarId}) async {
    if (calendarId == null) return;
    e.calendarId = calendarId;
    await saveEvaluationDate(e);
  }

  static Future<void> deleteEvaluationDate(String evaluationDateId) async {
    await CalendarService.deleteEvaluationCalendarEvent(evaluationDateId);
    await db.delete('evaluation_dates', where: 'id = ?', whereArgs: [evaluationDateId]);
    NotificationService.cancelEvaluationNotifications(evaluationDateId);
  }

  static Future<void> deleteAllEvaluationDates(List<String> evaluationDateIds) async {
    for (final id in evaluationDateIds) {
      await deleteEvaluationDate(id);
    }
  }

  static Future<void> buildFromJson(List<Map<String, dynamic>> jsonData) async {
    await db.delete('evaluation_dates');
    for (final e in jsonData) {
      await db.insert('evaluation_dates', e);
    }
  }
  static Future<Map<DateTime, List<EvaluationDate>>> findAllBetweenDays(
      DateTime start,
      DateTime end,
      ) async {

    final List<Map<String, dynamic>> maps = await db.query(
      'evaluation_dates',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );

    if (maps.isEmpty) return {};

    final evaluationDates = maps.map((e) => EvaluationDate.fromJson(e)).toList();

    final Map<DateTime, List<EvaluationDate>> map = {};

    for (final e in evaluationDates) {
      if (e.date == null) continue;
      final dateKey = DateTime(e.date!.year, e.date!.month, e.date!.day);
      map.putIfAbsent(dateKey, () => []);
      map[dateKey]!.add(e);
    }

    return map;
  }

}
