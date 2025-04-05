import 'dart:ui';

import 'package:hive/hive.dart';

import '../../utils/constants.dart';

part 'settings.g.dart';

@HiveType(typeId: 3)
class Settings {

  @HiveField(0)
  DateTime graduationYear;

  @HiveField(1)
  bool lightMode;

  @HiveField(2)
  int _accentColor;
  set accentColor(Color newAccentColor) => _accentColor = newAccentColor.value;
  Color get accentColor => Color(_accentColor);

  @HiveField(3)
  String _land;
  Land get land => Land.fromCode(_land);
  set land(Land newLand) => _land = newLand.code;

  @HiveField(4)
  bool viewedWelcomeScreen;

  // Kalender
  @HiveField(5)
  bool calendarSynchronisation; // TODO -> Nur Klausuren und Tests, Zeiten anpassen (nach Stundenplan), Namensgebung
  @HiveField(6)
  bool calendarFullDayEvents;

  Settings({
    required this.graduationYear,
    this.lightMode = true,
    Land land = Land.by,
    Color accentColor = primaryColor,
    this.viewedWelcomeScreen = false,
    this.calendarSynchronisation = true,
    this.calendarFullDayEvents = false,
  }) : _accentColor = accentColor.value,
        _land = land.code;

  Map<String, dynamic> toJson() => {
    "graduationYear": graduationYear.toString(),
    "lightMode": lightMode,
    "accentColor": _accentColor,
    "land": _land,
    "calendarSynchronisation": calendarSynchronisation,
    "calendarFullDayEvents": calendarFullDayEvents,
  };

  static Settings fromJson(Map<String, dynamic> json) {
    return Settings(
      graduationYear: DateTime.parse(json["graduationYear"]),
      lightMode: json["lightMode"],
      land: Land.fromCode(json["land"]),
      accentColor: Color(json["accentColor"]),
      calendarSynchronisation: json["calendarSynchronisation"] ?? true,
      calendarFullDayEvents: json["calendarFullDayEvents"] ?? false,
    );
  }
}

enum Land {
  bw("Baden-Württemberg"),
  by("Bayern"),
  be("Berlin"),
  bb("Brandenburg"),
  hb("Bremen"),
  hh("Hamburg"),
  he("Hessen"),
  mv("Mecklenburg-Vorpommern"),
  ni("Niedersachsen"),
  nw("Nordrhein-Westfalen"),
  rp("Rheinland-Pfalz"),
  sl("Saarland"),
  sn("Sachsen"),
  st("Sachsen-Anhalt"),
  sh("Schleswig-Holstein"),
  th("Thüringen");

  final String name;

  const Land(this.name);

  String get code => toString().split('.').last;

  static Land fromCode(String code) {
    return Land.values.firstWhere((land) => land.code == code,
      orElse: () => throw ArgumentError("Invalid Land code: $code"),
    );
  }
}
