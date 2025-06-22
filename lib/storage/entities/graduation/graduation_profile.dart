// import 'package:abitur/isolates/serializer.dart';
// import 'package:abitur/storage/entities/graduation/graduation_evaluation.dart';
// import 'package:abitur/storage/entities/graduation/graduation_evaluation.dart';
// import 'package:abitur/utils/uuid.dart';
// import 'package:hive/hive.dart';
//
// import '../../services/graduation_service.dart';
//
// part 'graduation_profile.g.dart';
//
// @HiveType(typeId: 10)
// class GraduationProfile implements Serializable {
//
//   @HiveField(0)
//   bool profileChosen;
//
//   @HiveField(1)
//   List<String> _writtenGraduationEvaluationIds;
//   List<String> get writtenGraduationEvaluationIds => _writtenGraduationEvaluationIds;
//   List<GraduationEvaluation> get writtenGraduationEvaluations => GraduationService.findAllEvaluationsById(_writtenGraduationEvaluationIds);
//   set writtenGraduationEvaluations(List<GraduationEvaluation> newEvaluations) => _writtenGraduationEvaluationIds = newEvaluations.map((it) => it.id).toList();
//
//   @HiveField(2)
//   List<String> _oralGraduationEvaluationIds;
//   List<String> get oralGraduationEvaluationIds => _oralGraduationEvaluationIds;
//   List<GraduationEvaluation> get oralGraduationEvaluations => GraduationService.findAllEvaluationsById(_oralGraduationEvaluationIds);
//   set oralGraduationEvaluations(List<GraduationEvaluation> newEvaluations) => _oralGraduationEvaluationIds = newEvaluations.map((it) => it.id).toList();
//
//   @HiveField(3)
//   String? _seminarGraduationEvaluationId;
//   String? get seminarGraduationEvaluationId => _seminarGraduationEvaluationId;
//   GraduationEvaluation? get seminarGraduationEvaluation => _seminarGraduationEvaluationId == null ? null : GraduationService.findEvaluationById(_seminarGraduationEvaluationId!);
//   set seminarGraduationEvaluation(GraduationEvaluation? newEvaluation) => _seminarGraduationEvaluationId = newEvaluation?.id;
//
//   GraduationProfile({
//     this.profileChosen = false,
//     List<String> writtenGraduationEvaluationIds = const [],
//     List<String> oralGraduationEvaluationIds = const [],
//     String? seminarGraduationEvaluationId,
//   }) : _writtenGraduationEvaluationIds = writtenGraduationEvaluationIds,
//         _oralGraduationEvaluationIds = oralGraduationEvaluationIds,
//         _seminarGraduationEvaluationId = seminarGraduationEvaluationId;
//
//   @override
//   Map<String, dynamic> toJson() => {
//     "profileChosen": profileChosen,
//     "writtenGraduationEvaluationIds": _writtenGraduationEvaluationIds,
//     "oralGraduationEvaluationIds": _oralGraduationEvaluationIds,
//     "seminarGraduationEvaluationId": _seminarGraduationEvaluationId,
//   };
//
//   static GraduationProfile fromJson(Map<String, dynamic> json) {
//     return GraduationProfile(
//       profileChosen: json["profileChosen"],
//       writtenGraduationEvaluationIds: (json["writtenGraduationEvaluationIds"] as List).map((e) => e as String).toList(),
//       oralGraduationEvaluationIds: (json["oralGraduationEvaluationIds"] as List).map((e) => e as String).toList(),
//       seminarGraduationEvaluationId: json["seminarGraduationEvaluationId"],
//     );
//   }
// }