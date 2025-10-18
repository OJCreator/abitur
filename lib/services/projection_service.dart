import 'package:abitur/isolates/models/projection/projection_model.dart';
import 'package:abitur/isolates/serializer.dart';
import 'package:flutter/foundation.dart';

import '../isolates/models/projection/evaluations_subjects_performances_evaluation_dates_model.dart';
import '../isolates/projection/projection_isolate.dart';
import '../sqlite/entities/evaluation/evaluation.dart';
import '../sqlite/entities/evaluation/evaluation_date.dart';
import '../sqlite/entities/graduation_evaluation.dart';
import '../sqlite/entities/performance.dart';
import '../sqlite/entities/subject.dart';
import '../utils/enums/land.dart';
import 'database/evaluation_date_service.dart';
import 'database/evaluation_service.dart';
import 'database/graduation_evaluation_service.dart';
import 'database/performance_service.dart';
import 'database/settings_service.dart';
import 'database/subject_service.dart';

class ProjectionService {

  // static double get overallAvg => SubjectService.getCurrentAverage() ?? 15;

  static Future<ProjectionModel> computeProjectionIsolated() async {

    Land land = (await SettingsService.loadSettings()).land;
    List<GraduationEvaluation> graduationEvaluations = await GraduationEvaluationService.findAllEvaluations();
    List<Evaluation> evaluations = await EvaluationService.findAll();
    List<Subject> subjects = await SubjectService.findAll();
    List<Performance> performances = await PerformanceService.findAll();
    List<EvaluationDate> evaluationDates = await EvaluationDateService.findAll();

    EvaluationsSubjectsPerformancesEvaluationDatesModel model = EvaluationsSubjectsPerformancesEvaluationDatesModel(
      land: land,
      graduationEvaluations: graduationEvaluations.serialize(),
      evaluations: evaluations.serialize(),
      subjects: subjects.serialize(),
      performances: performances.serialize(),
      evaluationDates: evaluationDates.serialize(),
    );
    return await compute(ProjectionIsolate.calculateProjection, model);
  }
}