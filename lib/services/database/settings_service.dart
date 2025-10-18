import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../sqlite/entities/settings.dart';
import '../../sqlite/sqlite_storage.dart';
import '../../utils/enums/land.dart';
import '../../utils/seed_notifier.dart';
import '../calendar_service.dart';

class SettingsService {

  static Database get db => SqliteStorage.database;

  static Future<Settings> loadSettings() async {
    final result = await db.query('settings', limit: 1);
    if (result.isEmpty) {
      final defaultSettings = Settings(graduationYear: DateTime(DateTime.now().year + 2));
      await saveSettings(defaultSettings);
      return defaultSettings;
    }
    return Settings.fromJson(result.first);
  }

  static Future<void> saveSettings(Settings settings) async {
    final db = SqliteStorage.database;
    await db.insert('settings', settings.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> markWelcomeScreenAsViewed() async {
    final s = await loadSettings();
    s.viewedWelcomeScreen = true;
    await saveSettings(s);
  }

  static Future<void> setAccentColor(BuildContext context, Color newAccentColor) async {
    final s = await loadSettings();
    s.accentColor = newAccentColor;
    Provider.of<SeedNotifier>(context, listen: false).seed = newAccentColor;
    await saveSettings(s);
    await CalendarService.changeCalendarColor(newAccentColor);
  }

  static Future<void> buildFromJson(Map<String, dynamic> json) async {
    final settings = Settings.fromJson(json);
    await saveSettings(settings);
  }

  static Future<bool> calendarSynchronisation() async {
    final s = await loadSettings();
    return s.calendarSynchronisation;
  }

  static Future<int> currentProbableTerm() async {
    return probableTerm(DateTime.now());
  }

  static Future<int> probableTerm(DateTime date) async {
    final s = await loadSettings();
    final firstDayOfTerm2 = DateTime(s.graduationYear.year - 1, 2, 15);
    final firstDayOfTerm3 = DateTime(s.graduationYear.year - 1, 8, 1);
    final firstDayOfTerm4 = DateTime(s.graduationYear.year, 2, 1);
    if (date.isAfter(firstDayOfTerm4)) return 3;
    if (date.isAfter(firstDayOfTerm3)) return 2;
    if (date.isAfter(firstDayOfTerm2)) return 1;
    return 0;
  }

  static Future<Land> land() async {
    final s = await loadSettings();
    return s.land;
  }

  static Future<DateTime> firstDayOfSchool() async {
    final s = await loadSettings();
    return DateTime(s.graduationYear.year - 2, 8, 1);
  }

  static Future<DateTime> firstDayOfTerm2() async {
    final s = await loadSettings();
    return DateTime(s.graduationYear.year - 1, 2, 15);
  }

  static Future<DateTime> firstDayOfTerm3() async {
    final s = await loadSettings();
    return DateTime(s.graduationYear.year - 1, 8, 1);
  }

  static Future<DateTime> firstDayOfTerm4() async {
    final s = await loadSettings();
    return DateTime(s.graduationYear.year, 2, 1);
  }

  static Future<DateTime> dayToChoseGraduationSubjects() async {
    final s = await loadSettings();
    return DateTime(s.graduationYear.year, 3, 1);
  }

  static Future<DateTime> dayToShowReview() async {
    final s = await loadSettings();
    return DateTime(s.graduationYear.year, 7, 1);
  }

  static Future<DateTime> lastDayOfSchool() async {
    final s = await loadSettings();
    return DateTime(s.graduationYear.year, 7, 31);
  }
}
