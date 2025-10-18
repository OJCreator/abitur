// import 'package:abitur/storage/services/subject_service.dart';
// import 'package:abitur/utils/uuid.dart';
// import 'package:hive/hive.dart';
//
// import '../subject.dart';
//
// part 'timetable_entry.g.dart';
//
// @HiveType(typeId: 6)
// class TimetableEntry {
//
//   @HiveField(0)
//   final String id;
//
//   @HiveField(1)
//   String subjectId;
//
//   Subject get subject => SubjectService.findById(subjectId) ?? Subject.empty();
//
//   @HiveField(2)
//   String? room;
//
//   TimetableEntry({
//     String? id,
//     required this.subjectId,
//     this.room
//   }) : id = id ?? Uuid.generate();
//
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "subjectId": subjectId,
//     "room": room,
//   };
//
//   static TimetableEntry fromJson(Map<String, dynamic> json) {
//     return TimetableEntry(
//       id: json["id"],
//       subjectId: json["subjectId"],
//       room: json["room"],
//     );
//   }
// }