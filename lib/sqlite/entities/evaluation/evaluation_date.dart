import 'package:abitur/isolates/serializer.dart';
import 'package:abitur/utils/uuid.dart';

class EvaluationDate implements Serializable, Comparable<EvaluationDate> {

  String id;

  String evaluationId; // FOREIGN KEY

  DateTime? date;
  int? note;
  String? calendarId;
  int weight;
  String description;

  EvaluationDate({
    String? id,
    this.evaluationId = "",
    required this.date,
    this.note,
    this.calendarId,
    this.weight = 1,
    this.description = "",
  }) : id = id ?? Uuid.generate();

  static EvaluationDate empty() {
    return EvaluationDate(date: DateTime.now());
  }

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "evaluationId": evaluationId,
    "date": date.toString(),
    "note": note,
    "calendarId": calendarId,
    "weight": weight,
    "description": description,
  };

  static EvaluationDate fromJson(Map<String, dynamic> json) {
    return EvaluationDate(
      id: json["id"],
      evaluationId: json["evaluationId"],
      date: json["date"] == "null" ? null : DateTime.parse(json["date"]),
      note: json["note"],
      calendarId: json["calendarId"],
      weight: json["weight"],
      description: json["description"],
    );
  }

  @override
  String toString() => "EvaluationDate#$id (evaluationId: $evaluationId, date: $date)";

  @override
  int compareTo(EvaluationDate other) {
    return (date ?? DateTime(3000)).compareTo(other.date ?? DateTime(3000));
  }
}