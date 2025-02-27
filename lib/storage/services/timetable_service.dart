import 'package:abitur/storage/entities/timetable/timetable_entry.dart';
import 'package:abitur/storage/entities/timetable/timetable_settings.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/storage.dart';
import 'package:abitur/utils/constants.dart';
import 'package:intl/intl.dart';

import '../entities/subject.dart';
import '../entities/timetable/timetable.dart';

class TimetableService {

  static Timetable loadTimetable(int term) {
    String termId = loadTimetableSettings().timetables[term];
    return loadTimetables().firstWhere((it) => it.id == termId);
  }

  static List<Timetable> loadTimetables() {
    return Storage.loadTimetables();
  }

  static TimetableEntry loadTimetableEntry(String id) {
    return loadTimetableEntries().firstWhere((e) => e.id == id);
  }

  static List<TimetableEntry> loadTimetableEntries() {
    return Storage.loadTimetableEntries();
  }

  static TimetableSettings loadTimetableSettings() {
    return Storage.loadTimetableSettings();
  }

  static Future<void> changeSubject(int term, int day, int hour, Subject? subject, String? room) async {
    Timetable t = loadTimetable(term);

    if (subject != null) {
      String? timetableEntryId = t.timetableEntryIds[day][hour];
      if (timetableEntryId == null) {
        TimetableEntry entry = TimetableEntry(subjectId: subject.id, room: room);
        await Storage.saveTimetableEntry(entry);
        t.timetableEntryIds[day][hour] = entry.id;
        await Storage.saveTimetable(t);
      } else {
        TimetableEntry entry = loadTimetableEntry(timetableEntryId);
        entry.subjectId = subject.id;
        entry.room = room;
        await Storage.saveTimetableEntry(entry);
      }
    } else {
      t.timetableEntryIds[day][hour] = null;
      await Storage.saveTimetable(t);
    }
  }

  static int maxHours(int term) {
    Timetable t = loadTimetable(term);
    int maxHours = 4;
    for (int i = 0; i < 5; i++) {
      int dayHours = _hours(t.timetableEntryIds[i]);
      if (dayHours > maxHours) {
        maxHours = dayHours;
      }
    }
    return maxHours;
  }

  static int _hours(List<String?> day) {
    return day.lastIndexWhere((s) => s != null) + 1;
  }

  static TimetableEntry? getTimetableEntry(int term, int day, int hour) {
    Timetable t = loadTimetable(term);
    String? entryId = t.timetableEntryIds[day][hour];
    return entryId == null ? null : loadTimetableEntry(entryId);
  }

  // static List<List<Subject?>> buildTable() {
  //   return [
  //     _monday,
  //     _tuesday,
  //     _wednesday,
  //     _thursday,
  //     _friday
  //   ];
  // }

  static String? knownRoom(Subject? s) {
    int currentTerm = SettingsService.currentProbableTerm();
    for (int i = 0; i < 4; i++) {
      Timetable t = loadTimetable((currentTerm - i) % 4);
      String? id = t.timetableEntryIds.expandToList().firstWhere(
          (entry) => entry != null && loadTimetableEntry(entry).subject == s,
          orElse: () => null);
      if (id != null) {
        return loadTimetableEntry(id).room;
      }
    }
    return null;
  }

  static Future<void> deleteSubjectEntries(Subject subject) async {
    for (int term = 0; term < 4; term++) {
      Timetable t = loadTimetable(term);
      for (int day = 0; day < t.timetableEntryIds.length; day++) {
        List<int> indicesToRemove = t.timetableEntryIds[day].indicesWhere((e) => e != null && loadTimetableEntry(e).subjectId == subject.id);

        for (var index in indicesToRemove) {
          t.timetableEntryIds[day][index] = null;
        }
      }
      Storage.saveTimetable(t);
    }
  }

  static DateTime getStartTime(int term, Subject subject, int weekday) {
    TimetableSettings timetableSettings = loadTimetableSettings();
    Timetable t = loadTimetable(term);
    var firstHour = t.timetableEntryIds[weekday-1].indexWhere((it) => it != null && loadTimetableEntry(it).subjectId == subject.id);
    String from = timetableSettings.times.elementAtOrNull(firstHour)?.split(" - ").first ?? "23:50";
    DateFormat format = DateFormat("HH:mm");
    return format.parse(from);
  }

  static DateTime getEndTime(int term, Subject subject, int weekday) {
    TimetableSettings timetableSettings = loadTimetableSettings();
    Timetable t = loadTimetable(term);
    var lastHour = t.timetableEntryIds[weekday-1].indexWhere((it) => it != null && loadTimetableEntry(it).subjectId == subject.id);
    String from = timetableSettings.times.elementAtOrNull(lastHour)?.split(" - ")[1] ?? "23:55";
    DateFormat format = DateFormat("HH:mm");
    return format.parse(from);
  }

  static Future<void> buildSettingsFromJson(Map<String, dynamic> jsonData) async {
    TimetableSettings t = TimetableSettings.fromJson(jsonData);
    await Storage.saveTimetableSettings(t);
  }

  static Future<void> buildTimetableFromJson(List<Map<String, dynamic>> jsonData) async {
    List<Timetable> timetables = jsonData.map((e) => Timetable.fromJson(e)).toList();
    for (Timetable t in timetables) {
      await Storage.saveTimetable(t);
    }
  }

  static Future<void> buildEntriesFromJson(List<Map<String, dynamic>> jsonData) async {
    List<TimetableEntry> entries = jsonData.map((e) => TimetableEntry.fromJson(e)).toList();
    for (TimetableEntry t in entries) {
      await Storage.saveTimetableEntry(t);
    }
  }
}