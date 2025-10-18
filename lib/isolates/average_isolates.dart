import 'package:abitur/isolates/models/evaluation_dates/evaluation_dates_evaluation_subjects_model.dart';

import '../sqlite/entities/evaluation/evaluation.dart';
import '../sqlite/entities/evaluation/evaluation_date.dart';
import '../sqlite/entities/performance.dart';
import '../sqlite/entities/subject.dart';
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
    var weightedNotes = performances.values.where((p) => p.subjectId == s.id).map((performance) {
        var matchingEvals = evaluationsOfTerm.where((e) => e.performanceId == performance.id);
        var noteValues = matchingEvals.map((e) => _calculateNote(e, evaluationDates));
        var averageNote = avg(noteValues);
        var weight = performance.weighting;
        return Pair(weight, averageNote);
    });

    double? average = weightedAvg(weightedNotes);
    return roundNote(average);
  }

  static int? _calculateNote(Evaluation evaluation, Map<String, EvaluationDate> evaluationDates) {
    var eds = evaluationDates.values
        .where((ed) => ed.evaluationId == evaluation.id && ed.note != null);
    // var eds = evaluation.evaluationDateIds
    //     .map((id) => evaluationDates[id])
    //     .whereType<EvaluationDate>()
    //     .where((ed) => ed.note != null);

    var totalWeight = eds.fold<double>(0.0, (sum, ed) => sum + ed.weight);
    if (totalWeight == 0) return null;

    var weightedSum = eds.fold<double>(0.0, (sum, ed) => sum + ed.note! * ed.weight);
    return roundNote(weightedSum / totalWeight);
  }

}