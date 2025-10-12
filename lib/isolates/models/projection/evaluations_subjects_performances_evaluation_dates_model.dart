import '../../../utils/enums/land.dart';

class EvaluationsSubjectsPerformancesEvaluationDatesModel {

  final Land land;

  final List<Map<String, dynamic>> graduationEvaluations;
  final List<Map<String, dynamic>> evaluations;
  final List<Map<String, dynamic>> subjects;
  final List<Map<String, dynamic>> performances;
  final List<Map<String, dynamic>> evaluationDates;

  EvaluationsSubjectsPerformancesEvaluationDatesModel({
    required this.land,
    required this.graduationEvaluations,
    required this.evaluations,
    required this.subjects,
    required this.performances,
    required this.evaluationDates,
  });
}