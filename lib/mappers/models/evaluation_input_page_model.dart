import 'dart:ui';

import '../../sqlite/entities/evaluation/evaluation.dart';
import '../../sqlite/entities/evaluation/evaluation_date.dart';
import '../../sqlite/entities/evaluation/evaluation_type.dart';
import '../../sqlite/entities/performance.dart';
import '../../sqlite/entities/subject.dart';

class EvaluationInputPageModel {

  final Map<String, Subject> subjects;
  final Map<String, EvaluationType> evaluationTypes;
  final List<Performance> initialPerformances;

  final Evaluation? evaluation;
  final String initialName;
  final EvaluationType initialEvaluationType;
  final String initialSubjectId;
  final String initialPerformanceId;
  final int initialTerm;
  final List<EvaluationDate> initialEvaluationDates;

  final Color seedColor;
  final bool editMode;

  EvaluationInputPageModel({
    required this.subjects,
    required this.evaluationTypes,
    required this.initialPerformances,

    required this.evaluation,
    required this.initialName,
    required this.initialEvaluationType,
    required this.initialSubjectId,
    required this.initialPerformanceId,
    required this.initialTerm,
    required this.initialEvaluationDates,

    required this.seedColor,
    required this.editMode
  });

}
