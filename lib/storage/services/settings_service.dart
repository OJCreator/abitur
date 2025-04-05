import 'package:abitur/storage/entities/settings.dart';
import 'package:abitur/storage/services/calendar_service.dart';
import 'package:abitur/storage/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../utils/seed_notifier.dart';

class SettingsService {

  static DateTime get firstDayOfSchool => DateTime(loadSettings().graduationYear.year - 2, 8, 1);
  static DateTime get firstDayOfTerm2 => DateTime(loadSettings().graduationYear.year - 1, 2, 15);
  static DateTime get firstDayOfTerm3 => DateTime(loadSettings().graduationYear.year - 1, 8, 1);
  static DateTime get firstDayOfTerm4 => DateTime(loadSettings().graduationYear.year, 2, 1);
  static DateTime get dayToChoseGraduationSubjects => DateTime(loadSettings().graduationYear.year-1, 3, 1); // TODO für die Hochrechnung ist eigentlich besser früher, man kann ja noch updaten...
  static DateTime get lastDayOfSchool =>  DateTime(loadSettings().graduationYear.year, 7, 31);

  static Settings loadSettings() {
    return Storage.loadSettings();
  }

  static int currentProbableTerm() {
    return probableTerm(DateTime.now());
  }

  static int probableTerm(DateTime date) {
    if (date.isAfter(firstDayOfTerm4)) {
      return 3;
    }
    if (date.isAfter(firstDayOfTerm3)) {
      return 2;
    }
    if (date.isAfter(firstDayOfTerm2)) {
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

  static bool calendarSynchronisation() {
    return loadSettings().calendarSynchronisation;
  }

  static Future<void> setAccentColor(BuildContext context, Color newAccentColor) async {
    Settings s = loadSettings();
    s.accentColor = newAccentColor;
    Provider.of<SeedNotifier>(context, listen: false).seed = newAccentColor;
    await Storage.saveSettings(s);

    await CalendarService.changeCalendarColor(newAccentColor);
  }

  static bool choseGraduationSubjectsTime() {
    return DateTime.now().isAfter(dayToChoseGraduationSubjects);
  }
}