// import 'package:abitur/storage/entities/evaluation.dart';
// import 'package:abitur/storage/entities/evaluation_type.dart';
// import 'package:abitur/storage/services/evaluation_date_service.dart';
// import 'package:abitur/services/notification_service.dart';
// import 'package:abitur/storage/services/settings_service.dart';
// import 'package:abitur/storage/storage.dart';
// import 'package:abitur/utils/constants.dart';
// import 'package:abitur/utils/extensions/lists/int_iterable_extension.dart';
//
// import '../../utils/enums/subject_type.dart';
// import '../entities/evaluation_date.dart';
// import '../entities/performance.dart';
// import '../entities/subject.dart';
//
// class EvaluationService {
//
//   static List<Evaluation> findAll() {
//     List<Evaluation> evaluations = Storage.loadEvaluations();
//     evaluations.sort((a,b) => (a.evaluationDates.firstOrNull?.date ?? SettingsService.lastDayOfSchool).compareTo(b.evaluationDates.firstOrNull?.date ?? SettingsService.lastDayOfSchool));
//     return evaluations;
//   }
//   static Evaluation? findById(String evaluationId) {
//     for (var evaluation in findAll()) {
//       if (evaluation.id == evaluationId) {
//         return evaluation;
//       }
//     }
//     return null;
//   }
//   static List<Evaluation> findAllByDay(DateTime day) {
//     return EvaluationDateService.findAllByDay(day).map((it) => it.evaluation).toSet().toList();
//   }
//   static List<Evaluation> findAllByQuery(String text) {
//     List<String> queries = text.toLowerCase().split(" ");
//     queries.removeWhere((it) => it.isEmpty);
//     return findAll().where((e) {
//       return queries.every((query) =>
//       e.name.toLowerCase().contains(query) ||
//           e.subject.name.toLowerCase().contains(query) ||
//           e.subject.shortName.toLowerCase().contains(query) ||
//           (calculateNote(e)?.toString() == query)
//       );
//     }).toList();
//   }
//
//   static List<Evaluation> findAllBySubject(Subject s) {
//     return findAll().where((e) => e.subject == s).toList();
//   }
//   static List<Evaluation> findAllGraded() {
//     List<Evaluation> evaluations = EvaluationService.findAll();
//     List<Evaluation> gradedEvaluations =  evaluations.where((e) => calculateNote(e) != null).toList();
//     return gradedEvaluations;
//   }
//   static List<Evaluation> findAllGradedBySubject(Subject s) {
//     List<Evaluation> evaluationsOfSubject = EvaluationService.findAllBySubject(s);
//     List<Evaluation> gradedEvaluations = evaluationsOfSubject.where((e) => calculateNote(e) != null).toList();
//     return gradedEvaluations;
//   }
//   static List<Evaluation> findAllGradedBySubjectAndTerm(Subject s, int term) {
//     List<Evaluation> evaluationsOfSubject = EvaluationService.findAllGradedBySubject(s);
//     List<Evaluation> evaluationsOfTerm = evaluationsOfSubject.where((e) => e.term == term).toList();
//     return evaluationsOfTerm;
//   }
//   static List<Evaluation> findAllBySubjectAndTerm(Subject subject, int term) {
//     List<Evaluation> evaluationsOfSubject = EvaluationService.findAllBySubject(subject);
//     List<Evaluation> evaluationsOfTerm = evaluationsOfSubject.where((e) => e.term == term).toList();
//     return evaluationsOfTerm;
//   }
//   static List<Evaluation> findAllBySubjectAndTerms(Subject subject, List<int> terms) {
//     List<Evaluation> evaluationsOfSubject = EvaluationService.findAllBySubject(subject);
//     List<Evaluation> evaluationsOfTerms = evaluationsOfSubject.where((e) => terms.contains(e.term)).toList();
//     return evaluationsOfTerms;
//   }
//   static List<Evaluation> findAllByPerformance(Performance performance) {
//     List<Evaluation> evaluations = EvaluationService.findAll().where((e) => e.performance == performance).toList();
//     return evaluations;
//   }
//
//   static Future<Evaluation> newEvaluation(Subject subject, Performance performance, int term, String name, List<EvaluationDate> evaluationDates, EvaluationType evaluationType) async {
//
//     return _createNewEvaluation(subject, performance, term, name, evaluationDates, evaluationType);
//   }
//   static Future<Evaluation> newGraduationEvaluation(Subject subject) {
//     String name = subject.subjectType == SubjectType.wSeminar ? "Seminararbeit" : "Abitur";
//     EvaluationDate e = EvaluationDate(date: null);
//     return _createNewEvaluation(subject, null, 5, name, [e], null);
//   }
//
//   static Future<Evaluation> _createNewEvaluation(Subject subject, Performance? performance, int term, String name, List<EvaluationDate> evaluationDates, EvaluationType? evaluationType) async {
//
//     Evaluation newEvaluation = Evaluation(
//       subjectId: subject.id,
//       performanceId: performance?.id ?? "",
//       term: term,
//       name: name,
//       evaluationDateIds: evaluationDates.map((it) => it.id).toList(),
//       evaluationTypeId: evaluationType?.id ?? "",
//     );
//     await Storage.saveEvaluation(newEvaluation);
//
//     for (EvaluationDate e in evaluationDates) {
//       e.evaluation = newEvaluation;
//
//       NotificationService.scheduleNotificationsForEvaluation(e);
//     }
//     await EvaluationDateService.saveAllEvaluationDates(evaluationDates);
//
//     return newEvaluation;
//   }
//
//   static Future<void> editEvaluation(Evaluation evaluation, {required Subject subject, required Performance performance, required int term, required String name, required List<EvaluationDate> evaluationDates, required EvaluationType evaluationType}) async {
//     evaluation.subject = subject;
//     evaluation.performance = performance;
//     evaluation.term = term;
//     evaluation.name = name;
//     evaluation.evaluationDates = evaluationDates;
//     evaluation.evaluationType = evaluationType;
//     await Storage.saveEvaluation(evaluation);
//   }
//
//   static Future<void> deleteEvaluation(Evaluation evaluation) async {
//     await EvaluationDateService.deleteAllEvaluationDates(evaluation.evaluationDates);
//     await Storage.deleteEvaluation(evaluation);
//   }
//
//   static Future<void> deleteAllEvaluations(List<Evaluation> evaluations) async {
//     for (var e in evaluations) {
//       deleteEvaluation(e);
//     }
//   }
//
//   static int? calculateNote(Evaluation evaluation) {
//     List<EvaluationDate> evaluationDates = evaluation.evaluationDates.where((it) => it.note != null).toList();
//     double weightTotal = evaluationDates.map((it) => it.weight).sum().toDouble();
//     if (weightTotal == 0) return null;
//     double note = evaluationDates.map((it) => it.note! * it.weight).sum() / weightTotal;
//     return roundNote(note);
//   }
//
//   static Future<void> buildFromJson(List<Map<String, dynamic>> jsonData) async {
//     deleteAllEvaluations(findAll());
//     List<Evaluation> evaluations = jsonData.map((e) => Evaluation.fromJson(e)).toList();
//     for (Evaluation e in evaluations) {
//       await Storage.saveEvaluation(e);
//     }
//   }
// }