// import 'dart:ui';
//
// import 'package:abitur/isolates/serializer.dart';
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
//
// import '../../utils/enums/land.dart';
// import '../../utils/constants.dart';
//
// part 'settings.g.dart';
//
// @HiveType(typeId: 3)
// class Settings implements Serializable {
//
//   @HiveField(0)
//   DateTime graduationYear;
//
//   // @HiveField(1)
//   // bool lightMode;
//   @HiveField(1)
//   int _themeModeIndex;
//   ThemeMode get themeMode => ThemeMode.values[_themeModeIndex];
//   set themeMode(ThemeMode mode) => _themeModeIndex = mode.index;
//
//   @HiveField(2)
//   int _accentColor;
//   set accentColor(Color newAccentColor) => _accentColor = newAccentColor.toARGB32();
//   Color get accentColor => Color(_accentColor);
//
//   @HiveField(3)
//   String _land;
//   Land get land => Land.fromCode(_land);
//   set land(Land newLand) => _land = newLand.code;
//
//   @HiveField(4)
//   bool viewedWelcomeScreen;
//
//   // Kalender
//   @HiveField(5)
//   bool calendarSynchronisation; // TODO -> Zeiten anpassen (nach Stundenplan), Namensgebung
//   @HiveField(6)
//   bool calendarFullDayEvents;
//
//   // Benachrichtigungen
//   @HiveField(7)
//   bool evaluationReminder;
//   @HiveField(8)
//   int evaluationReminderTimeInMinutes;
//   TimeOfDay get evaluationReminderTime => TimeOfDay(hour: evaluationReminderTimeInMinutes~/60, minute: evaluationReminderTimeInMinutes%60);
//   @HiveField(9)
//   bool missingGradeReminder;
//   @HiveField(10)
//   int missingGradeReminderDelayDays;
//   @HiveField(11)
//   int missingGradeReminderTimeInMinutes;
//   TimeOfDay get missingGradeReminderTime => TimeOfDay(hour: missingGradeReminderTimeInMinutes~/60, minute: missingGradeReminderTimeInMinutes%60);
//
//   Settings({
//     required this.graduationYear,
//     ThemeMode themeMode = ThemeMode.system,
//     Land land = Land.none,
//     Color accentColor = primaryColor,
//     this.viewedWelcomeScreen = false,
//     this.calendarSynchronisation = true,
//     this.calendarFullDayEvents = false,
//     this.evaluationReminder = false,
//     this.evaluationReminderTimeInMinutes = 18*60,
//     this.missingGradeReminder = false,
//     this.missingGradeReminderDelayDays = 21,
//     this.missingGradeReminderTimeInMinutes = 15*60,
//   }) : _themeModeIndex = themeMode.index,
//         _accentColor = accentColor.toARGB32(),
//         _land = land.code;
//
//   @override
//   Map<String, dynamic> toJson() => {
//     "graduationYear": graduationYear.toString(),
//     "themeModeIndex": _themeModeIndex,
//     "accentColor": _accentColor,
//     "land": _land,
//     "calendarSynchronisation": calendarSynchronisation,
//     "calendarFullDayEvents": calendarFullDayEvents,
//     "evaluationReminder": evaluationReminder,
//     "evaluationReminderTimeInMinutes": evaluationReminderTimeInMinutes,
//     "missingGradeReminder": missingGradeReminder,
//     "missingGradeReminderDelayDays": missingGradeReminderDelayDays,
//     "missingGradeReminderTimeInMinutes": missingGradeReminderDelayDays,
//   };
//
//   static Settings fromJson(Map<String, dynamic> json) {
//     return Settings(
//       graduationYear: DateTime.parse(json["graduationYear"]),
//       themeMode: ThemeMode.system,//ThemeMode.values[json["themeModeIndex"]],
//       land: Land.fromCode(json["land"]),
//       accentColor: Color(json["accentColor"]),
//       calendarSynchronisation: json["calendarSynchronisation"] ?? true,
//       calendarFullDayEvents: json["calendarFullDayEvents"] ?? false,
//       evaluationReminder: json["evaluationReminder"] ?? false,
//       evaluationReminderTimeInMinutes: json["evaluationReminderTimeInMinutes"] ?? 18*60,
//       missingGradeReminder: json["missingGradeReminder"] ?? false,
//       missingGradeReminderDelayDays: json["missingGradeReminderDelayDays"] ?? 21,
//       missingGradeReminderTimeInMinutes: json["missingGradeReminderTimeInMinutes"] ?? 15*60,
//     );
//   }
// }
//
//
