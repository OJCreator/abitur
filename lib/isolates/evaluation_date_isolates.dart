import 'package:abitur/isolates/models/evaluation_dates/evaluation_dates_model.dart';
import 'package:abitur/isolates/models/evaluation_dates/evaluation_dates_time_model.dart';
import 'package:abitur/isolates/serializer.dart';

import '../sqlite/entities/evaluation/evaluation.dart';
import '../sqlite/entities/evaluation/evaluation_date.dart';
import '../sqlite/entities/subject.dart';
import '../utils/constants.dart';
import '../utils/pair.dart';
import 'models/evaluation_dates/evaluation_dates_evaluation_subjects_model.dart';
import 'models/evaluation_dates/evaluation_dates_history_model.dart';

class EvaluationDateIsolates {

  static EvaluationDatesModel filterFutureOrNotGraded(EvaluationDatesTimeModel model) {
    List<EvaluationDate> evaluationDates = model.evaluationDates.map((e) => EvaluationDate.fromJson(e)).toList();
    List<EvaluationDate> result = evaluationDates.where((e) => e.date != null && (e.date!.isAfter(model.now) || (e.note == null && e.weight > 0))).toList();
    result.sort((a,b) => a.compareTo(b));
    return EvaluationDatesModel(result.serialize());
  }

  // Worker combinations
  static EvaluationDatesHistoryModel getAverageHistoryForAllSubjects(EvaluationDatesEvaluationsSubjectsModel model) {
    List<EvaluationDate> evaluationDates = model.evaluationDates.map((e) => EvaluationDate.fromJson(e)).toList();
    List<Evaluation> evaluations = model.evaluations.map((e) => Evaluation.fromJson(e)).toList();
    List<Subject> subjects = model.subjects.map((e) => Subject.fromJson(e)).toList();

    final entries = subjects.map((s) => MapEntry(s.id, _computeAverageHistoryForSubject(evaluationDates, evaluations, s)));
    final data = Map.fromEntries(entries);
    return EvaluationDatesHistoryModel(data);
  }
  static List<Pair<DateTime, double>> _computeAverageHistoryForSubject(List<EvaluationDate> evaluationDates, List<Evaluation> evaluations, Subject filterBySubject) {

    // Filtern
    final evaluationMap = {for (var ev in evaluations) ev.id: ev};
    List<EvaluationDate> filtered = evaluationDates.where((e) {
      final evaluation = evaluationMap[e.evaluationId];
      return evaluation != null && evaluation.subjectId == filterBySubject.id && e.note != null;
    }).toList();

    // Sortieren
    filtered.sort((a,b) => a.compareTo(b));

    // History generieren
    List<Pair<DateTime, double>> history = _generateHistory(filtered);

    return history;
  }
  static List<Pair<DateTime, double>> _generateHistory(List<EvaluationDate> evaluationDates) {

    List<Pair<DateTime, double>> history = [];
    List<int> allGrades = [];

    for (EvaluationDate evaluationDate in evaluationDates) {
      if (evaluationDate.note == null || evaluationDate.date == null || evaluationDate.date!.isAfter(DateTime.now())) {
        continue;
      }

      allGrades.add(evaluationDate.note!); // TODO nicht einzelne EvaluationDates mit aufnehmen, sondern immer gucken, ob die ganzen Evaluations ihre Note dadurch verändern. Diese müssen dann zudem auch noch nach den Performances gewichtet werden.
      double currentAverage = avg(allGrades)!;
      history.add(Pair(evaluationDate.date!, currentAverage));
    }

    return history;
  }
}