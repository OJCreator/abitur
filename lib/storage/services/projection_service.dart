import 'package:abitur/isolates/models/projection/projection_model.dart';
import 'package:abitur/isolates/serializer.dart';
import 'package:abitur/storage/entities/graduation/graduation_evaluation.dart';
import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/services/performance_service.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:flutter/foundation.dart';

import '../../isolates/models/projection/evaluations_subjects_performances_evaluation_dates_model.dart';
import '../../isolates/projection/projection_isolate.dart';
import '../entities/evaluation.dart';
import '../entities/evaluation_date.dart';
import '../entities/performance.dart';
import '../entities/settings.dart';
import '../entities/subject.dart';
import 'evaluation_date_service.dart';
import 'graduation_service.dart';

class ProjectionService {

  static double get overallAvg => SubjectService.getCurrentAverage() ?? 15;

  static Future<ProjectionModel> computeProjectionIsolated() async {

    Land land = SettingsService.land;
    List<GraduationEvaluation> graduationEvaluations = GraduationService.findAllEvaluations();
    List<Evaluation> evaluations = EvaluationService.findAll();
    List<Subject> subjects = SubjectService.findAll();
    List<Performance> performances = PerformanceService.findAll();
    List<EvaluationDate> evaluationDates = EvaluationDateService.findAll();

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