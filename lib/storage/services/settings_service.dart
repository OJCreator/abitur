import 'package:abitur/storage/entities/settings.dart';
import 'package:abitur/storage/entities/subject.dart';
import 'package:abitur/storage/services/projection_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/storage/storage.dart';
import 'package:abitur/utils/calender_sync.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../utils/seed_notifier.dart';

class SettingsService {

  static DateTime get firstDayOfSchool => DateTime(loadSettings().graduationYear.year - 2, 8, 1);
  static DateTime get lastDayOfSchool =>  DateTime(loadSettings().graduationYear.year, 7, 31);

  static Settings loadSettings() {
    return Storage.loadSettings();
  }

  static int probableTerm(DateTime date) {
    int graduationYear = loadSettings().graduationYear.year;
    if (date.isAfter(DateTime(graduationYear, 2))) {
      return 3;
    }
    if (date.isAfter(DateTime(graduationYear-1, 8))) {
      return 2;
    }
    if (date.isAfter(DateTime(graduationYear-1, 2))) {
      return 1;
    }
    return 0;
  }

  static Future<void> buildFromJson(Map<String, dynamic> jsonData) async {
    Settings s = Settings.fromJson(jsonData);
    await Storage.saveSettings(s);
  }

  static Future<void> markWelcomeScreenAsViewed() async {
    Settings s = loadSettings();
    s.viewedWelcomeScreen = true;
    await Storage.saveSettings(s);
  }

  static List<Subject?> graduationSubjects() {
    List<Subject?> graduationSubjects = loadSettings().graduationSubjectsIds.map((it) => SubjectService.findById(it)).toList();
    return graduationSubjects;
  }

  static bool isGraduationSubject(Subject subject) {
    return graduationSubjects().contains(subject);
  }

  static Future<void> setGraduationSubjects(List<Subject?> subjects) async {
    if (subjects.contains(null)) {
      throw Exception("Subjects dürfen nicht null sein!");
    }
    Settings s = loadSettings();
    s.graduationSubjectsIds = subjects.map((it) => it?.id ?? "").toList();
    await Storage.saveSettings(s);
  }

  static bool calendarSynchronisation() {
    return loadSettings().calendarSynchronisation;
  }

  static Future<void> setAccentColor(BuildContext context, Color newAccentColor) async {
    Settings s = loadSettings();
    s.accentColor = newAccentColor;
    Provider.of<SeedNotifier>(context, listen: false).seed = newAccentColor;
    await Storage.saveSettings(s);

    await changeCalendarColor(newAccentColor);
  }
}