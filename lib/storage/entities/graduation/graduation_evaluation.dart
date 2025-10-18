// import 'package:abitur/isolates/serializer.dart';
// import 'package:abitur/utils/uuid.dart';
// import 'package:hive/hive.dart';
//
// import '../../../services/database/subject_service.dart';
// import '../../../utils/enums/graduation_evaluation_type.dart';
// import '../../services/subject_service.dart';
// import '../subject.dart';
//
// part 'graduation_evaluation.g.dart';
//
// @HiveType(typeId: 10)
// class GraduationEvaluation implements Serializable {
//
//   @HiveField(0)
//   String id;
//
//   @HiveField(1)
//   String _subjectId;
//   String get subjectId => _subjectId;
//   Subject get subject => SubjectService.findById(_subjectId) ?? Subject.empty();
//   set subject(Subject newSubject) => _subjectId = newSubject.id;
//
//   @HiveField(2)
//   String _graduationEvaluationType;
//   GraduationEvaluationType get graduationEvaluationType => GraduationEvaluationType.fromCode(_graduationEvaluationType);
//   set graduationEvaluationType(GraduationEvaluationType newGraduationEvaluationType) => _graduationEvaluationType = newGraduationEvaluationType.code;
//
//   @HiveField(3)
//   bool isDividedEvaluation;
//
//   @HiveField(4)
//   int? notePartOne;
//
//   @HiveField(5)
//   DateTime? datePartOne;
//
//   @HiveField(6)
//   int weightPartOne;
//
//   @HiveField(7)
//   int? notePartTwo;
//
//   @HiveField(8)
//   DateTime? datePartTwo;
//
//   @HiveField(9)
//   int weightPartTwo;
//
//   GraduationEvaluation({
//     String? id,
//     String subjectId = "",
//     GraduationEvaluationType graduationEvaluationType = GraduationEvaluationType.written,
//     this.isDividedEvaluation = false,
//     this.notePartOne,
//     this.datePartOne,
//     this.weightPartOne = 1,
//     this.notePartTwo,
//     this.datePartTwo,
//     this.weightPartTwo = 1,
//   }) : id = id ?? Uuid.generate(),
//         _subjectId = subjectId,
//         _graduationEvaluationType = graduationEvaluationType.code;
//
//
//   static GraduationEvaluation empty() {
//     return GraduationEvaluation();
//   }
//
//   @override
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "subjectId": _subjectId,
//     "graduationEvaluationType": _graduationEvaluationType,
//     "isDividedEvaluation": isDividedEvaluation,
//     "notePartOne": notePartOne,
//     "datePartOne": datePartOne.toString(),
//     "weightPartOne": weightPartOne,
//     "notePartTwo": notePartTwo,
//     "datePartTwo": datePartTwo.toString(),
//     "weightPartTwo": weightPartTwo,
//   };
//
//   static GraduationEvaluation fromJson(Map<String, dynamic> json) {
//     return GraduationEvaluation(
//       id: json["id"],
//       subjectId: json["subjectId"],
//       graduationEvaluationType: GraduationEvaluationType.fromCode(json["graduationEvaluationType"]),
//       isDividedEvaluation: json["isDividedEvaluation"],
//       notePartOne: json["notePartOne"],
//       datePartOne: json["datePartOne"] == "null" ? null : DateTime.parse(json["datePartOne"]),
//       weightPartOne: json["weightPartOne"],
//       notePartTwo: json["notePartTwo"],
//       datePartTwo: json["datePartTwo"] == "null" ? null : DateTime.parse(json["datePartTwo"]),
//       weightPartTwo: json["weightPartTwo"],
//     );
//   }
// }