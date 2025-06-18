import 'package:abitur/isolates/models/evaluation_dates/evaluation_dates_evaluation_subjects_model.dart';
import 'package:abitur/storage/entities/performance.dart';

import '../storage/entities/evaluation.dart';
import '../storage/entities/evaluation_date.dart';
import '../storage/entities/subject.dart';
import '../utils/constants.dart';
import '../utils/pair.dart';

class AverageIsolates {

  static double? computeCurrentAverage(EvaluationDatesEvaluationsSubjectsModel model) {
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

    List<int> averages = [];
    for (var s in subjects.values) {
      for (int term = 0; term < 4; term++) {
        int? average = getAverageByTerm(s, term, evaluations.values.toList(), evaluationDates, performances);
        if (average != null) {
          averages.add(average);
        }
      }
    }
    return avg(averages);
  }

  static int? getAverageByTerm(Subject s, int term, List<Evaluation> evaluations, Map<String, EvaluationDate> evaluationDates, Map<String, Performance> performances) {
    if (!s.terms.contains(term)) return null;
    if (s.manuallyEnteredTermNotes[term] != null) {
      return s.manuallyEnteredTermNotes[term]!;
    }

    // Filtere alle passenden Bewertungen
    var evaluationsOfTerm = evaluations.where(
          (e) => e.subjectId == s.id && e.term == term,
    );

    // Berechne gewichtete Noten pro Leistung
    var weightedNotes = s.performanceIds.map((performanceId) {
      var matchingEvals = evaluationsOfTerm.where((e) => e.performanceId == performanceId);
      var noteValues = matchingEvals.map((e) => _calculateNote(e, evaluationDates));
      var averageNote = avg(noteValues);
      var weight = performances[performanceId]?.weighting ?? 0.0;
      return Pair(weight, averageNote);
    });

    double? average = weightedAvg(weightedNotes);
    return roundNote(average);
  }

  static int? _calculateNote(Evaluation evaluation, Map<String, EvaluationDate> evaluationDates) {
    var eds = evaluation.evaluationDateIds
        .map((id) => evaluationDates[id])
        .whereType<EvaluationDate>()
        .where((ed) => ed.note != null);

    var totalWeight = eds.fold<double>(0.0, (sum, ed) => sum + ed.weight);
    if (totalWeight == 0) return null;

    var weightedSum = eds.fold<double>(0.0, (sum, ed) => sum + ed.note! * ed.weight);
    return roundNote(weightedSum / totalWeight);
  }

}