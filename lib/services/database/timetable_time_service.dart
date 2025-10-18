import 'package:sqflite/sqflite.dart';

import '../../sqlite/entities/timetable/timetable_time.dart';
import '../../sqlite/sqlite_storage.dart';

class TimetableTimeService {

  static get db => SqliteStorage.database;

  static Future<List<TimetableTime>> findAllTimes() async {
    final List<Map<String, dynamic>> maps =
    await db.query('timetable_times', orderBy: 'slot');
    return maps.map((m) => TimetableTime.fromJson(m)).toList();
  }

  static Future<TimetableTime?> findTimeById(String id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'timetable_times',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return TimetableTime.fromJson(maps.first);
  }

  static Future<void> saveTime(TimetableTime time) async {
    await db.insert(
      'timetable_times',
      time.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteTime(String id) async {
    await db.delete(
      'timetable_times',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Alte Daten importieren
  static Future<void> buildFromJson(List<Map<String, dynamic>> jsonData) async {
    await db.delete('timetable_times');
    for (final json in jsonData) {
      final te = TimetableTime.fromJson(json);
      await db.insert('timetable_times', te.toJson());
    }
  }
}