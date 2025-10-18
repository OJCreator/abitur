// import 'package:abitur/utils/uuid.dart';
// import 'package:hive/hive.dart';
//
// part 'timetable.g.dart';
//
// @HiveType(typeId: 5)
// class Timetable {
//
//   @HiveField(0)
//   final String id;
//
//   @HiveField(1)
//   final List<List<String?>> timetableEntryIds;
//
//   Timetable({
//     String? id,
//     List<List<String?>>? timetableEntryIds,
//   }) : id = id ?? Uuid.generate(),
//         timetableEntryIds = timetableEntryIds ?? List.generate(5, (i) => List.generate(14, (i) => null));
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "timetableEntryIds": timetableEntryIds,
//   };
//
//   static Timetable fromJson(Map<String, dynamic> json) {
//     return Timetable(
//       id: json["id"],
//       timetableEntryIds: (json["timetableEntryIds"] as List).map((day) => (day as List).map((hour) => hour as String?).toList()).toList(),
//     );
//   }
//
//   @override
//   bool operator ==(Object other) {
//     if (other is! Timetable) {
//       return false;
//     }
//     return id == other.id;
//   }
//
//   @override
//   int get hashCode => "@Timetable $id".hashCode;
// }