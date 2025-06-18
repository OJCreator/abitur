import 'package:abitur/isolates/serializer.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/utils/uuid.dart';
import 'package:hive/hive.dart';

import '../services/evaluation_service.dart';
import 'evaluation.dart';

part 'evaluation_date.g.dart';

@HiveType(typeId: 7)
class EvaluationDate implements Serializable, Comparable<EvaluationDate> {

  @HiveField(0)
  String id;

  @HiveField(1)
  String _evaluationId;
  String get evaluationId => _evaluationId;
  Evaluation get evaluation => EvaluationService.findById(_evaluationId) ?? Evaluation.empty();
  set evaluation(Evaluation newEvaluation) => _evaluationId = newEvaluation.id;

  @HiveField(2)
  DateTime? date;

  @HiveField(3)
  int? note;

  @HiveField(4)
  String? calendarId;

  @HiveField(5)
  int weight;

  @HiveField(6)
  String description;

  EvaluationDate({
    required this.date,
    String evaluationId = "",
    String? id,
    this.note,
    this.calendarId,
    int? weight,
    this.description = "",
  }) : id = id ?? Uuid.generate(),
        _evaluationId = evaluationId,
        weight = weight ?? 1;

  static EvaluationDate empty() {
    return EvaluationDate(date: DateTime.now());
  }

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "evaluationId": _evaluationId,
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
  String toString() => "EvaluationDate#$id (evaluation: ${evaluation.name}, subject: ${evaluation.subject.name})";

  @override
  int compareTo(EvaluationDate other) {
    return (date ?? SettingsService.lastDayOfSchool).compareTo(other.date ?? SettingsService.lastDayOfSchool);
  }
}

extension EvaluationDateClone on EvaluationDate {
  EvaluationDate clone() {
    return EvaluationDate(
      id: id,
      evaluationId: _evaluationId,
      date: date,
      note: note,
      calendarId: calendarId,
      weight: weight,
      description: description,
    );
  }
}