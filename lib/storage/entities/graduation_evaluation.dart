// import 'package:abitur/storage/entities/evaluation_type.dart';
// import 'package:abitur/storage/entities/performance.dart';
// import 'package:abitur/storage/entities/subject.dart';
// import 'package:abitur/storage/services/performance_service.dart';
// import 'package:abitur/storage/services/subject_service.dart';
// import 'package:abitur/utils/uuid.dart';
// import 'package:hive/hive.dart';
//
// import '../services/evaluation_date_service.dart';
// import '../services/evaluation_service.dart';
// import '../services/evaluation_type_service.dart';
// import 'evaluation.dart';
// import 'evaluation_date.dart';
//
// part 'graduation_evaluation.g.dart';
//
// @HiveType(typeId: 9)
// class GraduationEvaluation {
//
//   @HiveField(0)
//   String id;
//
//   @HiveField(1)
//   String? _graduationType; // mdl, schr, seminar
//   GraduationType? get graduationType => _graduationType == null ? null : GraduationType.fromCode(_graduationType!);
//   set graduationType(GraduationType? newType) => _graduationType = newType?.code;
//
//   @HiveField(2)
//   String _subjectId;
//   Subject get subject => SubjectService.findById(_subjectId) ?? Subject.empty();
//   set subject(Subject newSubject) => _subjectId = newSubject.id;
//
//   @HiveField(3)
//   List<String> _evaluationIds;
//   List<Evaluation> get evaluations => _evaluationIds.map((id) => EvaluationService.findById(id) ?? Evaluation.empty()).toList();
//   set evaluations(List<Evaluation> newEvaluations) => _evaluationIds = newEvaluations.map((e) => e.id).toList();
//
//   GraduationEvaluation({
//     String subjectId = "",
//     GraduationType graduationType = GraduationType.written,
//     List<String>? evaluationIds,
//     String? id,
//   }) : id = id ?? Uuid.generate(),
//         _graduationType = graduationType.code,
//         _subjectId = subjectId,
//         _evaluationIds = evaluationIds ?? [];
//
//   static GraduationEvaluation empty() {
//     return GraduationEvaluation();
//   }
//
//   @override
//   String toString() {
//     return "GraduationEvaluation#$id (Subject: '${subject.name}')";
//   }
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "graduationType": _graduationType,
//     "subjectId": _subjectId,
//     "evaluationIds": _evaluationIds,
//   };
//
//   static GraduationEvaluation fromJson(Map<String, dynamic> json) {
//     return GraduationEvaluation(
//       id: json["id"],
//       graduationType: json["graduationType"],
//       subjectId: json["subjectId"],
//       evaluationIds: (json["evaluationIds"] as List).map((e) => e as String).toList(),
//     );
//   }
//
//   @override
//   bool operator ==(Object other) {
//     if (other is! Evaluation) {
//       return false;
//     }
//     return id == other.id;
//   }
//
//   @override
//   int get hashCode => "@GraduationEvaluation $id".hashCode;
// }
//
// enum GraduationType {
//   written("Schriftlich"),
//   oral("Mündlich"),
//   seminar("Seminararbeit");
//
//   final String name;
//
//   const GraduationType(this.name);
//
//   String get code => toString().split('.').last;
//
//   static GraduationType fromCode(String code) {
//     return GraduationType.values.firstWhere((graduationType) => graduationType.code == code,
//       orElse: () => throw ArgumentError("Invalid GraduationType code: $code"),
//     );
//   }
// }