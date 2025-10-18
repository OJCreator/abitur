import 'package:abitur/isolates/serializer.dart';
import 'package:abitur/utils/uuid.dart';

class TimetableEntry implements Serializable {

  final String id;

  String subjectId; // FOREIGN KEY

  int term;
  int day;
  int hour;

  String? room;
  String? teacher;

  TimetableEntry({
    String? id,
    required this.subjectId,
    required this.term,
    required this.day,
    required this.hour,
    this.room,
    this.teacher
  }) : id = id ?? Uuid.generate();


  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "subjectId": subjectId,
    "term": term,
    "day": day,
    "hour": hour,
    "room": room,
    "teacher": teacher,
  };

  static TimetableEntry fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      id: json["id"],
      subjectId: json["subjectId"],
      term: json["term"],
      day: json["day"],
      hour: json["hour"],
      room: json["room"],
      teacher: json["teacher"],
    );
  }
}