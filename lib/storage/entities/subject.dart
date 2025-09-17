import 'dart:ui';

import 'package:abitur/isolates/serializer.dart';
import 'package:abitur/storage/entities/performance.dart';
import 'package:abitur/storage/services/graduation_service.dart';
import 'package:abitur/storage/services/performance_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:hive/hive.dart';

import '../../utils/enums/subject_niveau.dart';
import '../../utils/enums/subject_type.dart';
import '../../utils/uuid.dart';
import 'graduation/graduation_evaluation.dart';

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
  String _subjectNiveau;
  SubjectNiveau get subjectNiveau => SubjectNiveau.fromCode(_subjectNiveau);
  set subjectNiveau(SubjectNiveau newSubjectNiveau) => _subjectNiveau = newSubjectNiveau.code;

  @HiveField(5)
  String _subjectType;
  SubjectType get subjectType => SubjectType.fromCode(_subjectType);
  set subjectType(SubjectType newSubjectType) => _subjectType = newSubjectType.code;

  @HiveField(6)
  List<int> _terms;
  Set<int> get terms => _terms.toSet();
  set terms(Set<int> newTerms) {
    _terms = newTerms.toList();
    _terms.sort((a,b) => a.compareTo(b));
  }

  @HiveField(7)
  int countingTermAmount;

  @HiveField(8)
  List<int?> manuallyEnteredTermNotes;

  @HiveField(9)
  List<String> _performanceIds;
  List<String> get performanceIds => _performanceIds;
  set performances(List<Performance> newPerformances) => _performanceIds = newPerformances.map((p) => p.id).toList();
  List<Performance> get performances => _performanceIds.map((p) => PerformanceService.findById(p)!).toList();

  @HiveField(10)
  String? _graduationEvaluationId;
  String? get graduationEvaluationId => _graduationEvaluationId;
  GraduationEvaluation? get graduationEvaluation => _graduationEvaluationId == null ? null : GraduationService.findEvaluationById(_graduationEvaluationId!);
  set graduationEvaluation(GraduationEvaluation? e) => _graduationEvaluationId = e?.id;

  Subject({
    required this.name,
    required this.shortName,
    Color color = primaryColor,
    SubjectNiveau subjectNiveau = SubjectNiveau.basic,
    SubjectType subjectType = SubjectType.standardPflichtfach,
    Set<int>? terms,
    this.manuallyEnteredTermNotes = const [null, null, null, null],
    required this.countingTermAmount,
    List<String> performanceIds = const [],
    String? id,
    String? graduationEvaluationId,
  }) : _color = color.toARGB32(),
        id = id ?? Uuid.generate(),
        _subjectNiveau = subjectNiveau.code,
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
    "subjectNiveau": _subjectNiveau,
    "subjectType": _subjectType,
    "terms": _terms,
    "countingTermAmount": countingTermAmount,
    "manuallyEnteredTermNotes": manuallyEnteredTermNotes,
    "performanceIds": _performanceIds,
    "id": id,
    "graduationEvaluationId": _graduationEvaluationId,
  };

  static Subject fromJson(Map<String, dynamic> json) {
    return Subject(
      name: json["name"],
      shortName: json["shortName"],
      color: Color(json["color"]),
      subjectNiveau: SubjectNiveau.fromCode(json["subjectNiveau"]),
      subjectType: SubjectType.fromCode(json["subjectType"]),
      terms: (json["terms"] as List).map((e) => e as int).toSet(),
      countingTermAmount: json["countingTermAmount"] as int,
      manuallyEnteredTermNotes: (json["manuallyEnteredTermNotes"] as List).map((e) => e as int?).toList(),
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