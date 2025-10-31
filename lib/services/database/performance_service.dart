import 'package:sqflite/sqflite.dart';

import '../../sqlite/entities/evaluation/evaluation.dart';
import '../../sqlite/entities/performance.dart';
import '../../sqlite/sqlite_storage.dart';
import 'evaluation_service.dart';

class PerformanceService {
  static Database get db => SqliteStorage.database;
  static const String _table = 'performances';

  /// Gibt alle Performances aus der Datenbank zurück
  static Future<List<Performance>> findAll() async {

    final List<Map<String, dynamic>> maps = await db.query(_table);

    return List.generate(maps.length, (i) => Performance.fromJson(maps[i]));
  }

  /// Gibt eine Performance anhand ihrer ID zurück
  static Future<Performance?> findById(String id) async {

    final List<Map<String, dynamic>> maps =
    await db.query(_table, where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return Performance.fromJson(maps.first);
  }

  /// Gibt alle Performances eines bestimmten Fachs zurück
  static Future<List<Performance>> findAllBySubjectId(String subjectId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      _table,
      where: 'subjectId = ?',
      whereArgs: [subjectId],
    );

    return maps.map((m) => Performance.fromJson(m)).toList();
  }


  /// Gibt alle Performances anhand ihrer IDs als Map zurück
  static Future<Map<String, Performance>> findAllByIds(List<String> performanceIds) async {
    if (performanceIds.isEmpty) return {};

    final placeholders = List.filled(performanceIds.length, '?').join(', ');
    final List<Map<String, dynamic>> maps = await SqliteStorage.database.query(
      'performances',
      where: 'id IN ($placeholders)',
      whereArgs: performanceIds,
    );

    // In eine Map<String, Performance> umwandeln
    final Map<String, Performance> result = {
      for (final map in maps) map['id'] as String: Performance.fromJson(map),
    };

    return result;
  }



  /// Erstellt eine neue Performance
  static Future<Performance> newPerformance(String name, double weighting, String subjectId) async {

    final performance = Performance(name: name, weighting: weighting, subjectId: subjectId);
    await db.insert(_table, performance.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    return performance;
  }

  /// Speichert eine Liste von Performances
  static Future<void> savePerformances(List<Performance> performances) async {
    final db = SqliteStorage.database;

    final batch = db.batch();
    for (Performance p in performances) {
      batch.insert(_table, p.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// Löscht eine Liste von Performances
  static Future<void> deletePerformances(List<Performance> performances) async {
    for (Performance p in performances) {
      await deletePerformance(p);
    }
  }

  /// Löscht eine einzelne Performance + zugehörige Evaluations
  static Future<void> deletePerformance(Performance performance) async {
    final db = SqliteStorage.database;

    // Evaluations, die zu dieser Performance gehören
    List<Evaluation> evaluationsToDelete =
    await EvaluationService.findAllByPerformance(performance);

    await EvaluationService.deleteAllEvaluations(evaluationsToDelete);

    await db.delete(_table, where: 'id = ?', whereArgs: [performance.id]);
  }

  /// Baut die Performances aus JSON neu auf
  static Future<void> buildFromJson(List<Map<String, dynamic>> jsonData) async {
    final existing = await findAll();
    print(existing);
    await deletePerformances(existing);

    List<Performance> performances = jsonData.map((e) => Performance.fromJson(e)).toList();
    await savePerformances(performances);
  }
}
