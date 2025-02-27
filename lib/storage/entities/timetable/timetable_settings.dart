import 'package:hive/hive.dart';

part 'timetable_settings.g.dart';

@HiveType(typeId: 4)
class TimetableSettings {

  @HiveField(0)
  List<String> timetables;

  @HiveField(1)
  List<String> times;

  TimetableSettings({
    List<String>? timetables,
    List<String>? times
  }) : timetables = timetables ?? [],
        times = times ?? ["08:00 - 08:45", "08:45 - 09:30", "09:50 - 10:35", "10:35 - 11:20", "11:40 - 12:25", "12:25 - 13:10", "13:15 - 14:00", "14:00 - 14:45", "14:45 - 15:30", "15:30 - 16:15", "16:15 - 17:00"];


  Map<String, dynamic> toJson() => {
    "timetables": timetables,
    "times": times,
  };

  static TimetableSettings fromJson(Map<String, dynamic> json) {
    return TimetableSettings(
      timetables: (json["timetables"] as List).map((e) => e as String).toList(),
      times: (json["times"] as List).map((e) => e as String).toList(),
    );
  }
}