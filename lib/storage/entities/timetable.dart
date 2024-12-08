import 'package:abitur/storage/entities/subject.dart';
import 'package:hive/hive.dart';

part 'timetable.g.dart';

@HiveType(typeId: 4)
class Timetable {

  @HiveField(0)
  List<String?> monday;

  @HiveField(1)
  List<String?> mondayRooms;

  @HiveField(2)
  List<String?> tuesday;

  @HiveField(3)
  List<String?> tuesdayRooms;

  @HiveField(4)
  List<String?> wednesday;

  @HiveField(5)
  List<String?> wednesdayRooms;

  @HiveField(6)
  List<String?> thursday;

  @HiveField(7)
  List<String?> thursdayRooms;

  @HiveField(8)
  List<String?> friday;

  @HiveField(9)
  List<String?> fridayRooms;

  Timetable({
    List<String?>? monday,
    List<String?>? mondayRooms,
    List<String?>? tuesday,
    List<String?>? tuesdayRooms,
    List<String?>? wednesday,
    List<String?>? wednesdayRooms,
    List<String?>? thursday,
    List<String?>? thursdayRooms,
    List<String?>? friday,
    List<String?>? fridayRooms,
  }) : monday = monday ?? List.empty(growable: true),
        mondayRooms = mondayRooms ?? List.empty(growable: true),
        tuesday = tuesday ?? List.empty(growable: true),
        tuesdayRooms = tuesdayRooms ?? List.empty(growable: true),
        wednesday = wednesday ?? List.empty(growable: true),
        wednesdayRooms = wednesdayRooms ?? List.empty(growable: true),
        thursday = thursday ?? List.empty(growable: true),
        thursdayRooms = thursdayRooms ?? List.empty(growable: true),
        friday = friday ?? List.empty(growable: true),
        fridayRooms = fridayRooms ?? List.empty(growable: true);

  Map<String, dynamic> toJson() => {
    "monday": monday,
    "mondayRooms": mondayRooms,
    "tuesday": tuesday,
    "tuesdayRooms": tuesdayRooms,
    "wednesday": wednesday,
    "wednesdayRooms": wednesdayRooms,
    "thursday": thursday,
    "thursdayRooms": thursdayRooms,
    "friday": friday,
    "fridayRooms": fridayRooms,
  };

  static Timetable fromJson(Map<String, dynamic> json) {
    return Timetable(
      monday: (json["monday"] as List).map((e) => e as String?).toList(),
      mondayRooms: (json["mondayRooms"] as List).map((e) => e as String?).toList(),
      tuesday: (json["tuesday"] as List).map((e) => e as String?).toList(),
      tuesdayRooms: (json["tuesdayRooms"] as List).map((e) => e as String?).toList(),
      wednesday: (json["wednesday"] as List).map((e) => e as String?).toList(),
      wednesdayRooms: (json["wednesdayRooms"] as List).map((e) => e as String?).toList(),
      thursday: (json["thursday"] as List).map((e) => e as String?).toList(),
      thursdayRooms: (json["thursdayRooms"] as List).map((e) => e as String?).toList(),
      friday: (json["friday"] as List).map((e) => e as String?).toList(),
      fridayRooms: (json["fridayRooms"] as List).map((e) => e as String?).toList(),
    );
  }
}