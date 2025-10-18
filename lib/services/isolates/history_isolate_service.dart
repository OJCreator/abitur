import 'package:abitur/isolates/serializer.dart';
import 'package:flutter/foundation.dart';

import '../../isolates/evaluation_date_isolates.dart';
import '../../isolates/models/evaluation_dates/evaluation_dates_evaluation_subjects_model.dart';
import '../../isolates/models/evaluation_dates/evaluation_dates_history_model.dart';
import '../../sqlite/entities/evaluation/evaluation.dart';
import '../../sqlite/entities/evaluation/evaluation_date.dart';
import '../../sqlite/entities/performance.dart';
import '../../sqlite/entities/subject.dart';
import '../../utils/pair.dart';
import '../database/evaluation_date_service.dart';
import '../database/evaluation_service.dart';
import '../database/performance_service.dart';
import '../database/subject_service.dart';

class HistoryIsolateService {

  static Future<Map<Subject, List<Pair<DateTime, double>>>> getAverageHistoryForAllSubjects() async {

    List<EvaluationDate> evaluationDates = await EvaluationDateService.findAll();
    List<Evaluation> evaluations = await EvaluationService.findAll();
    List<Subject> subjects = await SubjectService.findAll();
    List<Performance> performances = await PerformanceService.findAll();

    EvaluationDatesEvaluationsSubjectsModel model = EvaluationDatesEvaluationsSubjectsModel(evaluationDates.serialize(), evaluations.serialize(), subjects.serialize(), performances.serialize());

    EvaluationDatesHistoryModel historyModel = await compute(EvaluationDateIsolates.getAverageHistoryForAllSubjects, model);

    final subjectMap = { for (var s in subjects) s.id: s };
    final Map<Subject, List<Pair<DateTime, double>>> history = {
      for (var entry in historyModel.history.entries)
        if (subjectMap.containsKey(entry.key)) subjectMap[entry.key]!: entry.value
    };
    return history;
  }
}