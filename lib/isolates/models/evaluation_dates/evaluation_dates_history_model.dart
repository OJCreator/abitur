import '../../../utils/pair.dart';

class EvaluationDatesHistoryModel {
  final Map<String, List<Pair<DateTime, double>>> history;

  EvaluationDatesHistoryModel(this.history);
}