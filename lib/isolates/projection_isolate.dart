import 'dart:math';

import 'package:abitur/isolates/average_isolates.dart';
import 'package:abitur/isolates/models/projection/evaluations_subjects_performances_evaluation_dates_model.dart';
import 'package:abitur/isolates/models/projection/projection_model.dart';
import 'package:abitur/utils/constants.dart';

import '../storage/entities/evaluation.dart';
import '../storage/entities/evaluation_date.dart';
import '../storage/entities/performance.dart';
import '../storage/entities/settings.dart';
import '../storage/entities/subject.dart';
import '../utils/pair.dart';

class ProjectionIsolate {

  static ProjectionModel calculateProjection(EvaluationsSubjectsPerformancesEvaluationDatesModel model) {

    // Daten extrahieren
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

    final List<int> notes = evaluationDates.values
        .map((e) => e.note)
        .whereType<int>()
        .toList();

    final int defaultAverage = notes.isEmpty
        ? 15
        : roundNote(notes.sum() / notes.length)!;

    Map<String, int> defaultSubjectAverages = subjects.map((key, value) => MapEntry(key, _calculateSubjectAverage(subjects[key]!, evaluations, evaluationDates, performances) ?? defaultAverage));


    final Map<String, List<ProjectionTermModel>> block1 = _resultBlock1(model.land, subjects, evaluations, evaluationDates, performances, defaultSubjectAverages);
    final Map<String, ProjectionTermModel> block2 = _resultBlock2(model.land, subjects, evaluations, evaluationDates, defaultSubjectAverages);

    final int resultBlock1 = block1.values.expand((e) => e).where((model) => model.counting).toList().sumBy((model) => model.weight * (model.note ?? 0)).toInt();
    final int resultBlock2 = block2.values.where((model) => model.counting).toList().sumBy((model) => model.weight * (model.note ?? 0)).toInt();

    final double graduationAverage = abiturAvg(resultBlock1 + resultBlock2);
    final ProjectionModel result = ProjectionModel(graduationAverage, resultBlock1, resultBlock2, block1, block2);
    return result;
  }

  static Map<String, List<ProjectionTermModel>> _resultBlock1(Land land, Map<String, Subject> subjects, Map<String, Evaluation> evaluations, Map<String, EvaluationDate> evaluationDates, Map<String, Performance> performances, Map<String, int> defaultSubjectAverages) {

    Map<String, Subject> normalSubjects = Map.fromEntries(subjects.entries.where((entry) => entry.value.subjectType != SubjectType.voluntary && entry.value.subjectType != SubjectType.seminar));
    Subject? seminarSubject = subjects.values.where((value) => value.subjectType == SubjectType.seminar).firstOrNull;

    Iterable<MapEntry<String, List<ProjectionTermModel>>> graduationModels = normalSubjects.values.map((subject) => MapEntry(subject.id, _buildModelsForSubject(land, subject, evaluations, evaluationDates, performances, defaultSubjectAverages[subject.id]!)));

    final map = Map.fromEntries(graduationModels);

    List<ProjectionTermModel> allTermNotes = map.values.expandToList();

    if (land == Land.by) {
      // Optionsregel (schlechteste Note aus Nicht-Abiturfach gegen noch nicht zählende Note tauschen)
      List<ProjectionTermModel> notesWithOptionRulePossible = Map.fromEntries(map.entries.where((entry) {
        return subjects[entry.key]!.graduationEvaluationId == null &&
            entry.value.countWhere((e) => e.counting) > 1;
      }))
          .values
          .expandToList()
          .where((model) => model.note != null && model.counting)
          .toList();
      notesWithOptionRulePossible.sort((a, b) => a.note!.compareTo(b.note!));
      notesWithOptionRulePossible.firstOrNull?.counting = false;
    }

    // 40 Noten zählen lassen
    int alreadyCountingNotes = allTermNotes.countWhere((note) => note.counting);

    var nonCountingNotes = allTermNotes.where((note) => !note.counting).toList();
    nonCountingNotes.sort((a,b) => -(a.note ?? 0).compareTo(b.note ?? 0));

    int missingNotesAmount = min(((seminarSubject == null ? 40 : 36)-alreadyCountingNotes), nonCountingNotes.length);

    for (int i = 0; i < missingNotesAmount; i++) {
      nonCountingNotes[i].counting = true;
    }

    if (seminarSubject == null) {
      return map;
    }

    // W-Seminar-Arbeit
    map[seminarSubject.id] = _buildModelsForSubject(land, seminarSubject, evaluations, evaluationDates, performances, defaultSubjectAverages[seminarSubject.id]!);

    int? seminararbeitNote = evaluationDates[evaluations[seminarSubject.graduationEvaluationId]!.evaluationDateIds.first]!.note;
    map[seminarSubject.id]![3] = ProjectionTermModel(
      seminararbeitNote ?? defaultSubjectAverages[seminarSubject.id]!,
      seminararbeitNote == null,
      true,
      2,
    );

    return map;
  }
  static List<ProjectionTermModel> _buildModelsForSubject(Land land, Subject subject, Map<String, Evaluation> evaluations, Map<String, EvaluationDate> evaluationDates, Map<String, Performance> performances, int defaultAverage) {

    List<Evaluation> subjectEvaluations = evaluations.values.where((s) => s.subjectId == subject.id).toList();

    List<int?> notes = List.generate(4, (term) => AverageIsolates.getAverageByTerm(subject, term, subjectEvaluations, evaluationDates, performances));

    bool isGraduationSubject = subject.graduationEvaluationId != null && subject.subjectType != SubjectType.seminar;
    List<int> countingTerms = notes.findNLargestIndices(isGraduationSubject ? 4 : subject.countingTermAmount);

    return List.generate(4, (term) {
      if (!subject.terms.contains(term)) {
        return ProjectionTermModel(null, false, false, 0);
      }

      final termAverage = notes[term] ?? defaultAverage;
      final projection = notes[term] == null;

      return ProjectionTermModel(
        termAverage,
        projection,
        countingTerms.contains(term),
        1, // todo evtl zählen sie mehr, z.B. die Leistungsfächer in Baden-Württemberg
      );
    });
  }


  static Map<String, ProjectionTermModel> _resultBlock2(Land land, Map<String, Subject> subjects, Map<String, Evaluation> evaluations, Map<String, EvaluationDate> evaluationDates, Map<String, int> defaultSubjectAverages) {

    Iterable<Subject> graduationSubjects = subjects.values.where((s) => s.graduationEvaluationId != null && s.subjectType != SubjectType.seminar);

    Iterable<Evaluation> graduationEvaluations = graduationSubjects.map((s) => evaluations[s.graduationEvaluationId]!);

    Iterable<MapEntry<String, ProjectionTermModel>> graduationModels = graduationEvaluations.map((e) => MapEntry(e.subjectId, _buildModelFromGraduationEvaluation(land, e, evaluationDates, defaultSubjectAverages[e.subjectId]!)));
    return Map.fromEntries(graduationModels);
  }
  static ProjectionTermModel _buildModelFromGraduationEvaluation(Land land, Evaluation evaluation, Map<String, EvaluationDate> evaluationDates, int defaultAverage) {
    int note = 0;
    bool projection = true;
    int weight = 0;

    if (land == Land.by) {
      weight = 4;
      EvaluationDate e = evaluationDates[evaluation.evaluationDateIds.first]!;
      if (e.note == null) {
        note = defaultAverage;
        projection = true;
      } else {
        note = e.note!;
        projection = false;
      }
    }

    return ProjectionTermModel(note, projection, true, weight);
  }

  static int? _calculateSubjectAverage(Subject subject,  Map<String, Evaluation> evaluations, Map<String, EvaluationDate> evaluationDates, Map<String, Performance> performances) {

    List<Evaluation> subjectEvaluations = evaluations.values.where((s) => s.subjectId == subject.id).toList();
    List<int?> notes = List.generate(4, (term) => AverageIsolates.getAverageByTerm(subject, term, subjectEvaluations, evaluationDates, performances));

    List<int> nonNullNotes = notes.whereType<int>().toList();
    int? defaultSubjectAverage = nonNullNotes.isEmpty
        ? null
        : roundNote(nonNullNotes.sum() / nonNullNotes.length);

    return defaultSubjectAverage;
  }

}