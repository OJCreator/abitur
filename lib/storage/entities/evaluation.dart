import 'package:abitur/storage/entities/evaluation_type.dart';
import 'package:abitur/storage/entities/performance.dart';
import 'package:abitur/storage/entities/subject.dart';
import 'package:abitur/storage/services/performance_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/utils/uuid.dart';
import 'package:hive/hive.dart';

import '../services/evaluation_date_service.dart';
import '../services/evaluation_type_service.dart';
import 'evaluation_date.dart';

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
  String id;

  @HiveField(5)
  List<String> _evaluationDateIds;
  List<EvaluationDate> get evaluationDates => EvaluationDateService.findAllById(_evaluationDateIds);
  set evaluationDates(List<EvaluationDate> newEvaluationDates) => _evaluationDateIds = newEvaluationDates.map((it) => it.id).toList();

  @HiveField(6)
  String _evaluationTypeId;
  EvaluationType get evaluationType => EvaluationTypeService.findById(_evaluationTypeId) ?? EvaluationType.empty();
  set evaluationType(EvaluationType newEvaluationType) => _evaluationTypeId = newEvaluationType.id;

  Evaluation({
    String subjectId = "",
    String performanceId = "",
    String evaluationTypeId = "",
    List<String>? evaluationDateIds,
    required this.term,
    required this.name,
    String? id,
  }) : id = id ?? Uuid.generate(),
        _evaluationTypeId = evaluationTypeId,
        _subjectId = subjectId,
        _performanceId = performanceId,
        _evaluationDateIds = evaluationDateIds ?? List.empty();

  static Evaluation empty() {
    return Evaluation(term: 0, name: "");
  }

  @override
  String toString() {
    return "Evaluation#$id (Name: '$name')";
  }

  Map<String, dynamic> toJson() => {
    "subjectId": _subjectId,
    "performanceId": _performanceId,
    "term": term,
    "name": name,
    "id": id,
    "evaluationDateIds": _evaluationDateIds,
    "evaluationTypeId": _evaluationTypeId,
  };

  static Evaluation fromJson(Map<String, dynamic> json) {
    return Evaluation(
      subjectId: json["subjectId"],
      performanceId: json["performanceId"],
      term: json["term"],
      name: json["name"],
      id: json["id"],
      evaluationDateIds: (json["evaluationDateIds"] as List).map((e) => e as String).toList(),
      evaluationTypeId: json["evaluationTypeId"],
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