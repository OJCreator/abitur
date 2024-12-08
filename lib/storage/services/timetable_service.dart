import 'dart:math';

import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/storage/storage.dart';
import 'package:abitur/utils/constants.dart';

import '../entities/subject.dart';
import '../entities/timetable.dart';

class TimetableService {

  static List<Subject?> get _monday {
    Timetable t = loadTimetable();
    return t.monday.map((s) => SubjectService.findById(s)).toList();
  }
  static List<Subject?> get _tuesday {
    Timetable t = loadTimetable();
    return t.tuesday.map((s) => SubjectService.findById(s)).toList();
  }
  static List<Subject?> get _wednesday {
    Timetable t = loadTimetable();
    return t.wednesday.map((s) => SubjectService.findById(s)).toList();
  }
  static List<Subject?> get _thursday {
    Timetable t = loadTimetable();
    return t.thursday.map((s) => SubjectService.findById(s)).toList();
  }
  static List<Subject?> get _friday {
    Timetable t = loadTimetable();
    return t.friday.map((s) => SubjectService.findById(s)).toList();
  }

  static Timetable loadTimetable() {
    return Storage.loadTimetable();
  }

  static Future<Timetable> changeSubject(int day, int hour, Subject? s, String? room) async {
    Timetable t = loadTimetable();

    if (s == null) {
      room = null;
    }

    switch (day) {
      case 0:
        t.monday.setSafe(hour, s?.id);
        t.mondayRooms.setSafe(hour, room);
        break;
      case 1:
        t.tuesday.setSafe(hour, s?.id);
        t.tuesdayRooms.setSafe(hour, room);
        break;
      case 2:
        t.wednesday.setSafe(hour, s?.id);
        t.wednesdayRooms.setSafe(hour, room);
        break;
      case 3:
        t.thursday.setSafe(hour, s?.id);
        t.thursdayRooms.setSafe(hour, room);
        break;
      default:
        t.friday.setSafe(hour, s?.id);
        t.fridayRooms.setSafe(hour, room);
        break;
    }
    await Storage.saveTimetable(t);
    return t;
  }

  static int maxHours() {
    return max(
        _hours(_monday), max(
        _hours(_tuesday), max(
        _hours(_wednesday), max(
        _hours(_thursday), max(
        _hours(_friday), 4)))));
  }

  static int _hours(List<Subject?> day) {
    return day.lastIndexWhere((s) => s != null) + 1;
  }

  static Subject? getSubject(int day, int hour) {
    switch (day) {
      case 0:
        return _monday.elementAtOrNull(hour);
      case 1:
        return _tuesday.elementAtOrNull(hour);
      case 2:
        return _wednesday.elementAtOrNull(hour);
      case 3:
        return _thursday.elementAtOrNull(hour);
      case 4:
        return _friday.elementAtOrNull(hour);
    }
    return null;
  }

  static String? getRoom(int day, int hour) {
    Timetable timetable = loadTimetable();
    switch (day) {
      case 0:
        return timetable.mondayRooms.elementAtOrNull(hour);
      case 1:
        return timetable.tuesdayRooms.elementAtOrNull(hour);
      case 2:
        return timetable.wednesdayRooms.elementAtOrNull(hour);
      case 3:
        return timetable.thursdayRooms.elementAtOrNull(hour);
      case 4:
        return timetable.fridayRooms.elementAtOrNull(hour);
    }
    return null;
  }

  static List<List<Subject?>> buildTable() {
    return [
      _monday,
      _tuesday,
      _wednesday,
      _thursday,
      _friday
    ];
  }

  static String? knownRoom(Subject? s) {
    Timetable t = loadTimetable();
    int mondayIndex = _monday.indexOf(s);
    int tuesdayIndex = _tuesday.indexOf(s);
    int wednesdayIndex = _wednesday.indexOf(s);
    int thursdayIndex = _thursday.indexOf(s);
    int fridayIndex = _friday.indexOf(s);

    if (mondayIndex >= 0) {
      return t.mondayRooms.elementAtOrNull(mondayIndex);
    }
    if (tuesdayIndex >= 0) {
      return t.tuesdayRooms.elementAtOrNull(tuesdayIndex);
    }
    if (wednesdayIndex >= 0) {
      return t.wednesdayRooms.elementAtOrNull(wednesdayIndex);
    }
    if (thursdayIndex >= 0) {
      return t.thursdayRooms.elementAtOrNull(thursdayIndex);
    }
    if (fridayIndex >= 0) {
      return t.fridayRooms.elementAtOrNull(fridayIndex);
    }
    return null;
  }

  static Future<void> deleteSubjectEntries(Subject subject) async {
    Timetable t = loadTimetable();

    _clearSubject(t.monday, t.mondayRooms, subject);
    _clearSubject(t.tuesday, t.tuesdayRooms, subject);
    _clearSubject(t.wednesday, t.wednesdayRooms, subject);
    _clearSubject(t.thursday, t.thursdayRooms, subject);
    _clearSubject(t.friday, t.fridayRooms, subject);

    await Storage.saveTimetable(t);
  }

  static void _clearSubject(List<String?> day, List<String?> dayRooms, Subject subject) {
    List<int> indices = day.indicesOf(subject.id);
    for (int index in indices) {
      day[index] = null;
      dayRooms[index] = null;
    }
  }

  static Future<void> buildFromJson(Map<String, dynamic> jsonData) async {
    Timetable t = Timetable.fromJson(jsonData);
    await Storage.saveTimetable(t);
  }
}