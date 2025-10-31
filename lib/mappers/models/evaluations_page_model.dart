import 'package:abitur/sqlite/entities/evaluation/evaluation_date.dart';

import '../../sqlite/entities/evaluation/evaluation.dart';
import '../../sqlite/entities/subject.dart';

class EvaluationsPageModel {

  final List<EvaluationDate> evaluationDates;
  final Map<String, Evaluation> evaluations;
  final Map<String, Subject> subjects;

  EvaluationsPageModel({required this.evaluationDates, required this.evaluations, required this.subjects});
}