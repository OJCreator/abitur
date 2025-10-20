import 'package:abitur/services/database/settings_service.dart';
import 'package:abitur/services/database/subject_service.dart';
import 'package:sqflite/sqflite.dart';
import '../../sqlite/entities/subject.dart';
import '../../sqlite/entities/timetable/timetable_entry.dart';
import '../../sqlite/entities/timetable/timetable_time.dart';
import '../../sqlite/sqlite_storage.dart';
import '../../utils/enums/subject_type.dart';

class TimetableEntryService {

  static Database get db => SqliteStorage.database;

  static Future<List<TimetableEntry>> findAllEntries() async {
    final List<Map<String, dynamic>> maps = await db.query(
      'timetable_entries',
      orderBy: 'term, day, hour',
    );
    return maps.map((m) => TimetableEntry.fromJson(m)).toList();
  }

  static Future<List<TimetableEntry>> findAllEntriesOfTerm(int term) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'timetable_entries',
      where: 'term = ?',
      whereArgs: [term],
      orderBy: 'term, day, hour',
    );
    return maps.map((m) => TimetableEntry.fromJson(m)).toList();
  }

  static Future<TimetableEntry?> findEntry(int term, int day, int hour) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'timetable_entries',
      where: 'term = ? AND day = ? AND hour = ?',
      whereArgs: [term, day, hour],
      limit: 1, // nur ein Ergebnis, da eindeutiger Eintrag
    );

    if (maps.isEmpty) return null;
    return TimetableEntry.fromJson(maps.first);
  }

  static Future<TimetableEntry?> findEntryById(String id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'timetable_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return TimetableEntry.fromJson(maps.first);
  }

  static Future<void> changeTimetableEntry(int term, int day, int hour, String? subjectId, String? room, String? teacher) async {
    // Prüfe, ob bereits ein Eintrag existiert
    TimetableEntry? entry = await findEntry(term, day, hour);

    if (subjectId != null) {
      if (entry != null) {
        // Existierendes Entry updaten
        entry.subjectId = subjectId;
        entry.room = room;
        entry.teacher = teacher;
        await saveEntry(entry);
      } else {
        // Neues Entry erstellen
        TimetableEntry newEntry = TimetableEntry(
          subjectId: subjectId,
          term: term,
          day: day,
          hour: hour,
          room: room,
          teacher: teacher,
        );
        await saveEntry(newEntry);
      }
    } else {
      if (entry != null) {
        await deleteEntry(entry.id);
      }
    }
  }

  static Future<void> saveEntry(TimetableEntry entry) async {
    await db.insert(
      'timetable_entries',
      entry.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteEntry(String id) async {
    await db.delete(
      'timetable_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> maxHours(int term) async {

    // Maximal belegte Stunde innerhalb des Terms
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT MAX(hour) as maxHour FROM timetable_entries WHERE term = ?',
      [term],
    );

    int maxHour = 4; // Mindestanzahl
    if (result.isNotEmpty && result.first['maxHour'] != null) {
      maxHour = (result.first['maxHour'] as int) + 1; // Stunden zählen von 0
      if (maxHour < 4) maxHour = 4;
    }

    return maxHour;
  }

  static Future<bool> timetableIsEmpty(int term) async {

    final result = await db.rawQuery(
      'SELECT 1 FROM timetable_entries WHERE term = ? LIMIT 1',
      [term],
    );

    return result.isEmpty;
  }

  static Future<String?> knownRoom(String subjectId) async {

    final result = await db.rawQuery(
      '''
    SELECT room FROM timetable_entries 
    WHERE subjectId = ? 
    ORDER BY term DESC, day DESC, hour DESC 
    LIMIT 1
    ''',
      [subjectId],
    );

    if (result.isEmpty) return null;
    return result.first['room'] as String?;
  }

  static Future<DateTime?> getStartTime(int term, String subjectId, int weekday) async {

    final result = await db.rawQuery('''
      SELECT MIN(hour) AS firstHour
      FROM timetable_entries
      WHERE term = ? AND day = ? AND subjectId = ?
    ''', [term, weekday, subjectId]);

    final firstHour = result.first['firstHour'] as int?;
    if (firstHour == null) return null;

    final timeResult = await db.query(
      'timetable_times',
      where: 'slot = ?',
      whereArgs: [firstHour],
      limit: 1,
    );

    if (timeResult.isEmpty) return null;

    final time = TimetableTime.fromJson(timeResult.first);
    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day, time.from.hour, time.from.minute);
  }

  static Future<DateTime?> getEndTime(int term, String subjectId, int weekday) async {

    final result = await db.rawQuery('''
      SELECT MAX(hour) AS lastHour
      FROM timetable_entries
      WHERE term = ? AND day = ? AND subjectId = ?
    ''', [term, weekday, subjectId]);

    final lastHour = result.first['lastHour'] as int?;
    if (lastHour == null) return null;

    final timeResult = await db.query(
      'timetable_times',
      where: 'slot = ?',
      whereArgs: [lastHour],
      limit: 1,
    );

    if (timeResult.isEmpty) return null;

    final time = TimetableTime.fromJson(timeResult.first);
    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day, time.to.hour, time.to.minute);
  }

  /// Kopiert alle TimetableEntries von einem Term in einen anderen Term
  static Future<void> copyTerm(int fromTerm, int toTerm) async {
    final entries = await findAllEntries();
    final toCopy = entries.where((e) => e.term == fromTerm);
    for (var e in toCopy) {
      TimetableEntry copy = TimetableEntry(
        subjectId: e.subjectId,
        term: toTerm,
        day: e.day,
        hour: e.hour,
        room: e.room,
        teacher: e.teacher,
      );
      await saveEntry(copy);
    }
  }

  /// Liefert das zuletzt sinnvolle (nicht Wahlfach-)Fach
  static Future<Subject> findLatestGradableSubject() async {
    final now = DateTime.now();
    final weekday = now.weekday - 1;
    final currentTerm = await SettingsService.currentProbableTerm();

    // Wochenende → beliebiges gradables Fach
    if (weekday >= 5) {
      final subjects = await SubjectService.findAllGradable();
      return subjects.first;
    }

    // aktuelle Uhrzeit in Minuten
    final currentMinutes = now.hour * 60 + now.minute;

    // Finde letzte Stunde, die bereits begonnen hat
    final result = await db.rawQuery('''
      SELECT MAX(tt.slot) AS hour
      FROM timetable_times tt
      WHERE tt."from" <= ?
    ''', [currentMinutes]);

    final hour = (result.first['hour'] as int?) ?? -1;

    // Wenn kein Slot vorliegt → erstes gradables Fach
    if (hour < 0) {
      final subjects = await SubjectService.findAllGradable();
      return subjects.first;
    }

    // Suche von dieser Stunde rückwärts das letzte nicht-Wahlfach
    for (int h = hour; h >= 0; h--) {
      final rows = await db.rawQuery('''
        SELECT s.*
        FROM timetable_entries te
        JOIN subjects s ON te.subjectId = s.id
        WHERE te.term = ? AND te.day = ? AND te.hour = ?
        LIMIT 1
      ''', [currentTerm, weekday, h]);

      if (rows.isNotEmpty) {
        final subject = Subject.fromJson(rows.first);
        if (subject.subjectType != SubjectType.wahlfach) {
          return subject;
        }
      }
    }

    // Fallback: erstes gradables Fach
    final subjects = await SubjectService.findAllGradable();
    return subjects.first;
  }

  /// Alte Daten importieren
  static Future<void> buildFromJson(List<Map<String, dynamic>> jsonData) async {
    await db.delete('timetable_entries');
    for (final json in jsonData) {
      final te = TimetableEntry.fromJson(json);
      await db.insert('timetable_entries', te.toJson());
    }
  }
}
