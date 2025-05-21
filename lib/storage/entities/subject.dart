import 'dart:ui';

import 'package:abitur/isolates/serializer.dart';
import 'package:abitur/storage/entities/performance.dart';
import 'package:abitur/storage/services/performance_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:hive/hive.dart';

import '../../utils/uuid.dart';
import '../services/evaluation_service.dart';
import 'evaluation.dart';

part 'subject.g.dart';

@HiveType(typeId: 2)
class Subject implements Serializable {

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String shortName;

  @HiveField(3)
  int _color;
  set color(Color newColor) => _color = newColor.toARGB32();
  Color get color => Color(_color);

  @HiveField(4)
  String _subjectType;
  SubjectType get subjectType => SubjectType.fromCode(_subjectType);
  set subjectType(SubjectType newSubjectType) => _subjectType = newSubjectType.code;

  @HiveField(5)
  List<int> _terms;

  Set<int> get terms => _terms.toSet();
  set terms(Set<int> newTerms) {
    _terms = newTerms.toList();
    _terms.sort((a,b) => a.compareTo(b));
  }

  @HiveField(6)
  int countingTermAmount;

  @HiveField(7)
  List<String> _performanceIds;
  set performances(List<Performance> newPerformances) => _performanceIds = newPerformances.map((p) => p.id).toList();
  List<Performance> get performances => _performanceIds.map((p) => PerformanceService.findById(p)!).toList();

  @HiveField(8)
  String? _graduationEvaluationId;
  Evaluation? get graduationEvaluation => _graduationEvaluationId == null ? null : EvaluationService.findById(_graduationEvaluationId!);
  set graduationEvaluation(Evaluation? e) => _graduationEvaluationId = e?.id;

  Subject({
    required this.name,
    required this.shortName,
    Color color = primaryColor,
    SubjectType subjectType = SubjectType.basic,
    Set<int>? terms,
    required this.countingTermAmount,
    List<String> performanceIds = const [],
    String? id,
    String? graduationEvaluationId,
  }) : _color = color.toARGB32(),
        id = id ?? Uuid.generate(),
        _subjectType = subjectType.code,
        _terms = terms?.toList() ?? [0,1,2,3],
        _performanceIds = performanceIds,
        _graduationEvaluationId = graduationEvaluationId;

  static Subject empty() {
    return Subject(name: "-", shortName: "", countingTermAmount: 0);
  }

  @override
  String toString() {
    return "Subject#$id (Name: '$name', Type: '${subjectType.name}')";
  }

  @override
  Map<String, dynamic> toJson() => {
    "name": name,
    "shortName": shortName,
    "color": _color,
    "subjectType": _subjectType,
    "terms": _terms,
    "countingTermAmount": countingTermAmount,
    "performanceIds": _performanceIds,
    "id": id,
    "graduationEvaluationId": _graduationEvaluationId,
  };

  static Subject fromJson(Map<String, dynamic> json) {
    return Subject(
      name: json["name"],
      shortName: json["shortName"],
      color: Color(json["color"]),
      subjectType: SubjectType.fromCode(json["subjectType"]),
      terms: (json["terms"] as List).map((e) => e as int).toSet(),
      countingTermAmount: json["countingTermAmount"] as int,
      performanceIds: (json["performanceIds"] as List).map((e) => e as String).toList(),
      id: json["id"],
      graduationEvaluationId: json["graduationEvaluationId"]
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! Subject) {
      return false;
    }
    return id == other.id;
  }

  @override
  int get hashCode => "@Subject $id".hashCode;
}

enum SubjectType {
  basic("Grundlegendes Anforderungsniveau", "gA"),
  advanced("Erhöhtes Anforderungsniveau", "eA"),
  profile("Profilfach", "Profilfach"),
  voluntary("Wahlfach", "Wahlfach"),
  seminar("W-Seminar", "W-S");

  final String name;
  final String shortName;
  String get code {
    switch (this) {
      case SubjectType.basic:
        return "basic";
      case SubjectType.advanced:
        return "advanced";
      case SubjectType.profile:
        return "profile";
      case SubjectType.voluntary:
        return "voluntary";
      case SubjectType.seminar:
        return "seminar";
    }
  }

  const SubjectType(this.name, this.shortName);

  static SubjectType fromCode(String code) {
    switch (code) {
      case "basic":
        return SubjectType.basic;
      case "advanced":
        return SubjectType.advanced;
      case "profile":
        return SubjectType.profile;
      case "voluntary":
        return SubjectType.voluntary;
      default:
        return SubjectType.seminar;
    }
  }
}
