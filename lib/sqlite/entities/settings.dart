import 'package:abitur/isolates/serializer.dart';
import 'package:flutter/material.dart';
import '../../utils/enums/land.dart';
import '../../utils/constants.dart';

class Settings implements Serializable {

  DateTime graduationYear;
  ThemeMode themeMode;
  Color accentColor;
  Land land;
  bool viewedWelcomeScreen;
  bool calendarSynchronisation;
  bool calendarFullDayEvents;
  bool evaluationReminder;
  TimeOfDay evaluationReminderTime;
  bool missingGradeReminder;
  int missingGradeReminderDelayDays;
  TimeOfDay missingGradeReminderTime;

  Settings({
    required this.graduationYear,
    this.themeMode = ThemeMode.system,
    this.accentColor = primaryColor,
    this.land = Land.none,
    this.viewedWelcomeScreen = false,
    this.calendarSynchronisation = true,
    this.calendarFullDayEvents = false,
    this.evaluationReminder = false,
    this.evaluationReminderTime = const TimeOfDay(hour: 18, minute: 0),
    this.missingGradeReminder = false,
    this.missingGradeReminderDelayDays = 21,
    this.missingGradeReminderTime = const TimeOfDay(hour: 15, minute: 0),
  });

  @override
  Map<String, dynamic> toJson() => {
    'id': 0,
    'graduationYear': graduationYear.toIso8601String(),
    'themeMode': themeMode.index,
    'accentColor': accentColor.value,
    'land': land.code,
    'viewedWelcomeScreen': viewedWelcomeScreen ? 1 : 0,
    'calendarSynchronisation': calendarSynchronisation ? 1 : 0,
    'calendarFullDayEvents': calendarFullDayEvents ? 1 : 0,
    'evaluationReminder': evaluationReminder ? 1 : 0,
    // Serialize TimeOfDay → Minuten
    'evaluationReminderTimeInMinutes': evaluationReminderTime.hour * 60 + evaluationReminderTime.minute,
    'missingGradeReminder': missingGradeReminder ? 1 : 0,
    'missingGradeReminderDelayDays': missingGradeReminderDelayDays,
    'missingGradeReminderTimeInMinutes': missingGradeReminderTime.hour * 60 + missingGradeReminderTime.minute,
  };

  static Settings fromJson(Map<String, dynamic> map) {
    return Settings(
      graduationYear: DateTime.parse(map['graduationYear']),
      themeMode: ThemeMode.values[map['themeMode']],
      accentColor: Color(map['accentColor']),
      land: Land.fromCode(map['land']),
      viewedWelcomeScreen: map['viewedWelcomeScreen'] == 1,
      calendarSynchronisation: map['calendarSynchronisation'] == 1,
      calendarFullDayEvents: map['calendarFullDayEvents'] == 1,
      evaluationReminder: map['evaluationReminder'] == 1,
      // Deserialize Minuten → TimeOfDay
      evaluationReminderTime: TimeOfDay(
        hour: (map['evaluationReminderTimeInMinutes'] ?? 18 * 60) ~/ 60,
        minute: (map['evaluationReminderTimeInMinutes'] ?? 18 * 60) % 60,
      ),
      missingGradeReminder: map['missingGradeReminder'] == 1,
      missingGradeReminderDelayDays: map['missingGradeReminderDelayDays'],
      missingGradeReminderTime: TimeOfDay(
        hour: (map['missingGradeReminderTimeInMinutes'] ?? 15 * 60) ~/ 60,
        minute: (map['missingGradeReminderTimeInMinutes'] ?? 15 * 60) % 60,
      ),
    );
  }
}
