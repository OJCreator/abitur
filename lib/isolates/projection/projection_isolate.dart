import 'package:abitur/isolates/projection/projection_by_transformer.dart';
import 'package:abitur/utils/constants.dart';
import 'package:flutter/cupertino.dart';

import '../../storage/entities/evaluation.dart';
import '../../storage/entities/evaluation_date.dart';
import '../../storage/entities/graduation/graduation_evaluation.dart';
import '../../storage/entities/performance.dart';
import '../../storage/entities/settings.dart';
import '../../storage/entities/subject.dart';
import '../../storage/services/graduation_service.dart';
import '../../utils/enums/subject_type.dart';
import '../average_isolates.dart';
import '../models/projection/evaluations_subjects_performances_evaluation_dates_model.dart';
import '../models/projection/projection_model.dart';

class ProjectionIsolate {

  static ProjectionModel calculateProjection(EvaluationsSubjectsPerformancesEvaluationDatesModel model) {
    try {
      return _calculateProjection(model);
    } catch (e, st) {
      print("ISOLATE ERROR (ProjectionIsolate): $e\n$st");
      return ProjectionModel(6, 0, 0, [], []);
    }
  }

  static ProjectionModel _calculateProjection(EvaluationsSubjectsPerformancesEvaluationDatesModel model) {

    ProjectionWorkModel workModel = extractData(model);

    List<ProjectionSubjectBlock1Model> block1 = _calculateBlock1(workModel);
    List<ProjectionSubjectBlock2Model> block2 = _calculateBlock2(workModel);

    final int resultBlock1 = block1.sumBy((m) => m.countingPoints()).toInt();
    final int resultBlock2 = block2.sumBy((m) => m.countingPoints()).toInt();

    final double graduationAverage = abiturAvg(resultBlock1 + resultBlock2);

    return ProjectionModel(graduationAverage, resultBlock1, resultBlock2, block1, block2);
  }

  static List<ProjectionSubjectBlock1Model> _calculateBlock1(ProjectionWorkModel workModel) {

    /// Plan:
    /// - Eine Verteilung erstellen, wo für jedes Fach so viele Noten eingebracht werden, wie es das Fach erfordert
    /// - Diese Verteilung wird je nach Land in einen speziellen Land-Transformer gefüllt
    /// - Dieser Land-Transformer setzt länderspezifische Regeln durch (z.B. Abifächer müssen komplett zählen, Mindestanzahl in naturwissenschaftlichen Fächern, Mathe VK, Optionsregel, ...)
    /// - Der fertige Plan wird zurückgegeben

    List<ProjectionSubjectBlock1Model> block1 = [];

    // Eine Verteilung erstellen, wo für jedes Fach so viele Noten eingebracht werden, wie es das Fach erfordert
    for (Subject s in workModel.subjects.values) {
      List<ProjectionTermModel> terms = List.generate(4, (term) => _buildTermModel(workModel, s, term));
      block1.add(ProjectionSubjectBlock1Model(s.id, terms));
    }

    if (workModel.land == Land.by) {
      ProjectionByTransformer.transform(block1, workModel);
    } else {
      // TODO: Hochrechnung für andere Länder
      debugPrint("TODO: Hochrechnung für andere Länder");
      throw ArgumentError("Das Bundesland kann nicht bearbeitet werden.");
    }

    return block1;
  }


  static List<ProjectionSubjectBlock2Model> _calculateBlock2(ProjectionWorkModel workModel) {
    final evals = workModel.finalGraduationEvaluations();

    return evals.map((e) {
      final avg = workModel.defaultSubjectAvg(e.subjectId);
      final model = _buildModelFromGraduationEvaluation(e, avg, evals.length);
      return ProjectionSubjectBlock2Model(e.subjectId, model);
    }).toList();
  }


  // HELPER
  static ProjectionWorkModel extractData(EvaluationsSubjectsPerformancesEvaluationDatesModel model) {

    Map<String, GraduationEvaluation> graduationEvaluations = {
      for (var e in model.graduationEvaluations) e['id']: GraduationEvaluation.fromJson(e),
    };
    Map<String, Evaluation> evaluations = {
      for (var e in model.evaluations) e['id']: Evaluation.fromJson(e),
    };
    Map<String, Subject> subjects = {
      for (var s in model.subjects) s['id']: Subject.fromJson(s),
    };
    Map<String, Performance> performances = {
      for (var p in model.performances) p['id']: Performance.fromJson(p),
    };
    Map<String, EvaluationDate> evaluationDates = {
      for (var ed in model.evaluationDates) ed['id']: EvaluationDate.fromJson(ed),
    };

    return ProjectionWorkModel(graduationEvaluations, evaluations, subjects, performances, evaluationDates, model.land);
  }


  static ProjectionTermModel _buildTermModel(ProjectionWorkModel workModel, Subject subject, int term) {
    if (!subject.terms.contains(term)) {
      return ProjectionTermModel(null, false, false, 1);
    }

    List<Evaluation> subjectEvaluations = workModel.evaluations.values.where((s) => s.subjectId == subject.id).toList();
    final average = AverageIsolates.getAverageByTerm(subject, term, subjectEvaluations, workModel.evaluationDates, workModel.performances);

    final termAverage = average ?? workModel.defaultSubjectAvg(subject.id);
    final projection = average == null;

    return ProjectionTermModel(
      termAverage,
      projection,
      false,
      1,
    );
  }


  static ProjectionTermModel _buildModelFromGraduationEvaluation(GraduationEvaluation graduationEvaluation, int defaultAverage, int graduationEvaluationAmount) {
    final baseWeight = (300 / 15 / graduationEvaluationAmount).toInt();
    final calculatedNote = GraduationService.calculateNote(graduationEvaluation);
    if (graduationEvaluation.isDividedEvaluation) {
      return _buildDividedEvaluation(calculatedNote, defaultAverage, baseWeight);
    }

    return _buildSimpleEvaluation(calculatedNote, defaultAverage, baseWeight);
  }
  static ProjectionTermModel _buildSimpleEvaluation(double? calculatedNote, int defaultAverage, int weight) {
    if (calculatedNote == null) {
      return ProjectionTermModel(defaultAverage, true, true, weight);
    }
    return ProjectionTermModel(roundNote(calculatedNote)!, false, true, weight);
  }
  static ProjectionTermModel _buildDividedEvaluation(double? calculatedNote, int defaultAverage, int baseWeight,) {
    if (calculatedNote == null) {
      return ProjectionTermModel(defaultAverage * baseWeight, true, true, 1);
    }
    return ProjectionTermModel(roundNote(calculatedNote * baseWeight)!, false, true, 1);
  }
}

/// Diese Klasse organisiert die Informationen, die für die Projection wichtig sind.
/// Zusätzlich bietet sie einige Funktionen, die man auf diesen Daten ausführen kann.
class ProjectionWorkModel {
  final Map<String, GraduationEvaluation> graduationEvaluations;
  final Map<String, Evaluation> evaluations;
  final Map<String, Subject> subjects;
  final Map<String, Performance> performances;
  final Map<String, EvaluationDate> evaluationDates;
  final Land land;

  late int _defaultAvg;
  late Map<String, int> _defaultSubjectAvgs;

  ProjectionWorkModel(
    this.graduationEvaluations,
    this.evaluations,
    this.subjects,
    this.performances,
    this.evaluationDates,
    this.land,
  ) {
    removeUnusableData();
    _defaultAvg = evaluationDates.isEmpty
        ? 15
        : roundNote(evaluationDates.values.map((e) => e.note!).sum() / evaluationDates.length)!;
    _defaultSubjectAvgs = subjects.map((key, value) => MapEntry(key, _calculateSubjectAverage(subjects[key]!) ?? _defaultAvg));
  }

  int? _calculateSubjectAverage(Subject subject) {

    List<Evaluation> subjectEvaluations = evaluations.values.where((s) => s.subjectId == subject.id).toList();
    List<int?> notes = List.generate(4, (term) => AverageIsolates.getAverageByTerm(subject, term, subjectEvaluations, evaluationDates, performances));

    List<int> nonNullNotes = notes.whereType<int>().toList();
    int? defaultSubjectAverage = nonNullNotes.isEmpty
        ? null
        : roundNote(nonNullNotes.sum() / nonNullNotes.length);

    return defaultSubjectAverage;
  }

  void removeUnusableData() {
    evaluationDates.removeWhere((key, e) => e.note == null);
    subjects.removeWhere((key, s) => s.subjectType == SubjectType.wahlfach);
  }
  int defaultAvg() {
    return _defaultAvg;
  }
  int defaultSubjectAvg(String subjectId) {
    return _defaultSubjectAvgs[subjectId]!;
  }
  List<Evaluation> evaluationDatesBySubjectId(String subjectId) {
    return evaluations.values.where((s) => s.subjectId == subjectId).toList();
  }
  List<Subject> normalSubjects() {
    return subjects.values.where((s) => s.subjectType != SubjectType.wahlfach && s.subjectType != SubjectType.wSeminar).toList();
  }
  Subject? seminarSubject() {
    return subjects.values.where((value) => value.subjectType == SubjectType.wSeminar).firstOrNull;
  }
  List<Subject> graduationSubjects() {
    return subjects.values.where((s) => s.graduationEvaluationId != null && s.subjectType != SubjectType.wSeminar).toList();
  }
  List<GraduationEvaluation> finalGraduationEvaluations() { // Abiprüfungen (ohne W-Seminar-Arbeit)
    return graduationSubjects().map((s) => graduationEvaluations[s.graduationEvaluationId]!).toList();
  }
}