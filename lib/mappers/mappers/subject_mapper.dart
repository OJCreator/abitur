import 'package:abitur/mappers/models/subject_page_term_view_model.dart';
import 'package:abitur/services/database/subject_service.dart';
import 'package:abitur/utils/extensions/lists/iterable_extension.dart';

import '../../services/database/evaluation_date_service.dart';
import '../../services/database/evaluation_service.dart';
import '../../services/database/graduation_evaluation_service.dart';
import '../../services/database/performance_service.dart';
import '../../services/database/settings_service.dart';
import '../../sqlite/entities/evaluation/evaluation.dart';
import '../../sqlite/entities/graduation_evaluation.dart';
import '../../sqlite/entities/subject.dart';
import '../models/subject_page_model.dart';
import '../models/subjects_page_model.dart';

class SubjectMapper {

  /// Model für die Subjects-Seite
  static Future<SubjectsPageModel> generateSubjectsPageModel() async {

    DateTime dayToChoseGraduationSubjects = await SettingsService.dayToChoseGraduationSubjects();
    List<Subject> subjects = await SubjectService.findAll();
    Map<Subject, bool> isGraduationSubject = {};

    for (Subject s in subjects) {
      bool graduation = await GraduationEvaluationService.isGraduationSubject(s);
      isGraduationSubject[s] = graduation;
    }

    return SubjectsPageModel(
      timeToChoseGraduationSubjects: !DateTime.now().isBefore(dayToChoseGraduationSubjects),
      subjects: subjects,
      isGraduationSubject: isGraduationSubject,
    );
  }

  /// Model für eine Subject-Seite eines bestimmten Fachs
  static Future<SubjectPageModel> generateSubjectPageModel(String subjectId) async {

    Subject? subject = await SubjectService.findById(subjectId);
    GraduationEvaluation? graduationEvaluation = subject?.graduationEvaluationId == null ? null : await GraduationEvaluationService.findEvaluationById(subject!.graduationEvaluationId!);

    return SubjectPageModel(
      subject: subject,
      graduationEvaluation: graduationEvaluation,
    );
  }

  /// Model für ein Halbjahr eines bestimmten Fachs
  static Future<SubjectPageTermViewModel> generateSubjectPageTermViewModel(Subject subject, int term) async {

    final allEvaluations = await EvaluationService.findAllBySubjectAndTerm(subject, term);
    final evaluationsMap = allEvaluations.groupBy((e) => e.performanceId);
    final performanceIds = evaluationsMap.keys;
    final evaluationIds = allEvaluations.map((e) => e.id);
    final performances = await PerformanceService.findAllByIds(performanceIds.toList());
    final evaluationDatesByEvaluationId = await EvaluationDateService.findAllByEvaluationIds(evaluationIds.toList());
    final evaluationsByPerformance = evaluationsMap.map((pId, e) => MapEntry(performances[pId]!, e));
    for (List<Evaluation> list in evaluationsByPerformance.values) {
      list.sort((a, b) => evaluationDatesByEvaluationId[a.id]!.first.compareTo(evaluationDatesByEvaluationId[b.id]!.first));
    }

    final termAverage = await SubjectService.getAverageByTerm(subject, term);
    final manualEnteredTermNote = subject.manuallyEnteredTermNotes[term] != null;
    final Map<String, int?> evaluationNotes = {};
    for (Evaluation e in allEvaluations) {
      evaluationNotes[e.id] = await EvaluationService.calculateNote(e);
    }

    return SubjectPageTermViewModel(
      evaluationsByPerformance: evaluationsByPerformance,
      evaluationDatesByEvaluationId: evaluationDatesByEvaluationId,
      termAverage: termAverage,
      manualEnteredTermNote: manualEnteredTermNote,
      evaluationNotes: evaluationNotes,
    );
  }
}