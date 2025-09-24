import 'package:abitur/storage/services/api_service.dart';
import 'package:abitur/utils/constants.dart';

import '../../isolates/models/projection/projection_model.dart';
import '../../storage/entities/evaluation_date.dart';
import '../../storage/entities/evaluation_type.dart';
import '../../storage/entities/subject.dart';
import '../../storage/services/evaluation_date_service.dart';
import '../../storage/services/projection_service.dart';
import '../../storage/services/settings_service.dart';
import '../../storage/services/subject_service.dart';
import '../../utils/pair.dart';

class ReviewData {

  final List<Subject> subjects = SubjectService.findAll();
  final List<EvaluationDate> evaluationDates = EvaluationDateService.findAll();

  //SUBJ
  late final List<Pair<Subject, double>> subjectAvgs = [];
  late final List<Subject> subjectsSortedByEvaluationDescending;
  late final Map<Subject, int> evaluationDatesPerSubject = {};

  // EVAL
  late final List<int> noteAmounts = List.generate(16, (_) => 0);
  late final Map<String, int> evaluationTypeUses = {};

  // DIFF
  late final double difference;

  // AVG
  late final int schoolDays;
  late final List<double> weekdayAverages = List.generate(5, (_) => 0);
  late final List<double?> monthAverages = List.generate(24, (_) => null);
  late final DateTime startMonth;

  // FINAL
  final Future<ProjectionModel> projection = ProjectionService.computeProjectionIsolated();

  ReviewData() {
    _fillSubjectsData();
    _fillEvaluationData();
    _fillDifferencesData();
    _fillAverageData();
  }

  void _fillSubjectsData() {

    for (Subject s in subjects) {
      double? avg = SubjectService.getAverage(s);
      if (avg == null) continue;
      subjectAvgs.add(Pair(s, avg));
    }
    subjectAvgs.sort((a,b) => b.second.compareTo(a.second));

    for (EvaluationDate e in evaluationDates) {
      evaluationDatesPerSubject[e.evaluation.subject] = (evaluationDatesPerSubject[e.evaluation.subject] ?? 0) + 1;
    }
    subjectsSortedByEvaluationDescending = evaluationDatesPerSubject.keys.toList();
    subjectsSortedByEvaluationDescending.sort((a,b) => evaluationDatesPerSubject[b]?.compareTo(evaluationDatesPerSubject[a]!) ?? 0);
  }

  void _fillEvaluationData() {
    for (var e in evaluationDates) {
      if (e.note == null) {
        continue;
      }
      noteAmounts[e.note!]++;
      evaluationTypeUses[e.evaluation.evaluationType.name] = (evaluationTypeUses[e.evaluation.evaluationType.name] ?? 0) + 1;
    }
  }

  void _fillDifferencesData() {
    List<EvaluationDate> evaluationDates = EvaluationDateService.findAll();
    List<EvaluationDate> oral = evaluationDates.where((e) => e.note != null && e.evaluation.evaluationType.assessmentType == AssessmentType.oral).toList();
    List<EvaluationDate> written = evaluationDates.where((e) => e.note != null && e.evaluation.evaluationType.assessmentType == AssessmentType.written).toList();

    double oralAvg = oral.isEmpty
        ? 0
        : oral.map((e) => e.note).reduce((a, b) => a! + b!)! / oral.length;
    double writtenAvg = written.isEmpty
        ? 0
        : written.map((e) => e.note).reduce((a, b) => a! + b!)! / written.length;

    difference = ((oralAvg - writtenAvg) * 100).roundToDouble() / 100;
  }

  Future<void> _fillAverageData() async {

    DateTime? lastDate;
    for (final eval in evaluationDates) {
      final current = eval.date;
      if (current != null) {
        if (lastDate == null || current.isAfter(lastDate)) {
          lastDate = current;
        }
      }
    }
    lastDate ??= SettingsService.lastDayOfSchool;
    schoolDays = await ApiService.countSchoolDaysBetween(SettingsService.firstDayOfSchool, lastDate);

    final groupedEvaluationDatesByDay = evaluationDates.where((e) => e.date != null).toList().groupBy((e) => e.date!.weekday);
    groupedEvaluationDatesByDay.forEach((day, evaluationDates) {
      final notes = evaluationDates.map((e) => e.note).where((note) => note != null);
      if (notes.isEmpty) {
        weekdayAverages[day-1] = 0.0;
      } else {
        final sum = notes.fold<double>(0.0, (total, note) => total + note!);
        weekdayAverages[day-1] = sum / notes.length;
      }
    });
    final groupedEvaluationDatesByMonth = evaluationDates.where((e) => e.date != null && e.note != null).toList().groupBy((e) => (e.date!.year % 100) * 1000 + e.date!.month); // yyMM
    startMonth = SettingsService.firstDayOfSchool;
    groupedEvaluationDatesByMonth.forEach((identifier, evaluationDates) {
      final notes = evaluationDates.map((e) => e.note).where((note) => note != null);

      final index = _getMonthIndex(identifier, startMonth);
      if (index < 0 || index >= monthAverages.length) return; // ignorieren, falls außerhalb der 24 Monate

      if (notes.isEmpty) {
        monthAverages[index] = 0.0;
      } else {
        final sum = notes.fold<double>(0.0, (total, note) => total + note!);
        monthAverages[index] = sum / notes.length;
      }
    });
  }


  int _getMonthIndex(int identifier, DateTime startMonth) {
    final idYear = identifier ~/ 1000;
    final idMonth = identifier % 1000;

    final startYear = startMonth.year % 100;
    final startMonthValue = startMonth.month;

    return (idYear - startYear) * 12 + (idMonth - startMonthValue);
  }
}