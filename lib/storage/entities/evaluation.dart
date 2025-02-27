import 'package:abitur/storage/entities/performance.dart';
import 'package:abitur/storage/entities/subject.dart';
import 'package:abitur/storage/services/performance_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/utils/uuid.dart';
import 'package:hive/hive.dart';

part 'evaluation.g.dart';

@HiveType(typeId: 0)
class Evaluation {
  @HiveField(0)
  String _subjectId;
  Subject get subject => SubjectService.findById(_subjectId) ?? Subject.empty();
  set subject(Subject newSubject) => _subjectId = newSubject.id;

  @HiveField(1)
  String _performanceId;
  Performance get performance => PerformanceService.findById(_performanceId) ?? Performance.empty();
  set performance(Performance newPerformance) => _performanceId = newPerformance.id;

  @HiveField(2)
  int term;

  @HiveField(3)
  String name;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  int? note;

  @HiveField(6)
  String id;

  @HiveField(7)
  String? calendarId;

  Evaluation({
    String subjectId = "",
    String performanceId = "",
    required this.term,
    required this.name,
    required this.date,
    this.note,
    String? id,
    this.calendarId,
  }) : id = id ?? Uuid.generate(),
        _subjectId = subjectId,
        _performanceId = performanceId;

  @override
  String toString() {
    return "Evaluation#$id (Name: '$name', Note: $note)";
  }

  Map<String, dynamic> toJson() => {
    "subjectId": _subjectId,
    "performanceId": _performanceId,
    "term": term,
    "name": name,
    "date": date.toString(),
    "note": note,
    "id": id,
  };

  static Evaluation fromJson(Map<String, dynamic> json) {
    return Evaluation(
      subjectId: json["subjectId"],
      performanceId: json["performanceId"],
      term: json["term"],
      name: json["name"],
      date: DateTime.parse(json["date"]),
      note: json["note"],
      id: json["id"],
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! Evaluation) {
      return false;
    }
    return id == other.id;
  }

  @override
  int get hashCode => "@Evaluation $id".hashCode;
}