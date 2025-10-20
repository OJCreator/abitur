import '../../sqlite/entities/evaluation/evaluation.dart';
import '../../sqlite/entities/evaluation/evaluation_date.dart';
import '../../sqlite/entities/performance.dart';

class SubjectPageTermViewModel {

  final Map<Performance, List<Evaluation>> evaluationsByPerformance;
  final Map<String, List<EvaluationDate>> evaluationDatesByEvaluationId;
  final double? termAverage;
  final bool manualEnteredTermNote;
  final Map<String, int?> evaluationNotes;

  SubjectPageTermViewModel({
    required this.evaluationsByPerformance,
    required this.evaluationDatesByEvaluationId,
    required this.termAverage,
    required this.manualEnteredTermNote,
    required this.evaluationNotes,
  });

}