import 'package:abitur/services/api_service.dart';
import 'package:abitur/services/database/evaluation_service.dart';
import 'package:abitur/services/database/evaluation_type_service.dart';
import 'package:abitur/sqlite/entities/evaluation/evaluation_type.dart';
import 'package:abitur/utils/extensions/lists/iterable_extension.dart';

import '../../isolates/models/projection/projection_model.dart';
import '../../services/database/evaluation_date_service.dart';
import '../../services/database/settings_service.dart';
import '../../services/database/subject_service.dart';
import '../../sqlite/entities/evaluation/evaluation.dart';
import '../../sqlite/entities/evaluation/evaluation_date.dart';
import '../../sqlite/entities/subject.dart';
import '../../services/projection_service.dart';
import '../../utils/enums/assessment_type.dart';
import '../../utils/pair.dart';

class ReviewData {

  late final Map<String, Subject> subjectMap;
  List<Subject> get subjects => subjectMap.values.toList();
  late final List<EvaluationDate> evaluationDates;
  late final Map<String, Evaluation?> evaluations;
  late final Map<String, EvaluationType?> evaluationTypes;

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
  late final Map<DateTime, int> evaluationsPerDay;

  // FINAL
  final Future<ProjectionModel> projection = ProjectionService.computeProjectionIsolated();

  ReviewData() {
    _fillData();
  }

  Future<void> _fillData() async {
    evaluationDates = await EvaluationDateService.findAll();
    evaluationDates.removeWhere((e) => e.note == null);
    evaluations = await EvaluationService.findAllById(evaluationDates.map((e) => e.evaluationId).toList());
    evaluationTypes = await EvaluationTypeService.findAllAsMap();
    _fillSubjectsData();
    _fillEvaluationData();
    _fillDifferencesData();
    _fillAverageData();
  }

  Future<void> _fillSubjectsData() async {

    subjectMap = await SubjectService.findAllAsMap();

    Map<String, double?> avgs = await SubjectService.getAverages(subjectMap.keys.toList());

    for (MapEntry<String, double?> e in avgs.entries) {
      if (e.value == null) continue;
      subjectAvgs.add(Pair(subjectMap[e.key]!, e.value!));
    }
    subjectAvgs.sort((a,b) => b.second.compareTo(a.second));

    for (EvaluationDate e in evaluationDates) {
      evaluationDatesPerSubject[subjectMap[evaluations[e.evaluationId]!.subjectId]!] = (evaluationDatesPerSubject[subjectMap[evaluations[e.evaluationId]!.subjectId]!] ?? 0) + 1;
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
      evaluationTypeUses[evaluationTypes[evaluations[e.evaluationId]?.evaluationTypeId]!.name] = (evaluationTypeUses[evaluationTypes[evaluations[e.evaluationId]?.evaluationTypeId]!.name] ?? 0) + 1;
    }
  }

  void _fillDifferencesData() {
    List<EvaluationDate> oral = evaluationDates.where((e) => e.note != null && evaluationTypes[evaluations[e.evaluationId]?.evaluationTypeId]!.assessmentType == AssessmentType.oral).toList();
    List<EvaluationDate> written = evaluationDates.where((e) => e.note != null && evaluationTypes[evaluations[e.evaluationId]?.evaluationTypeId]!.assessmentType == AssessmentType.written).toList();

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
    lastDate ??= await SettingsService.lastDayOfSchool();
    schoolDays = await ApiService.countSchoolDaysBetween(await SettingsService.firstDayOfSchool(), lastDate);

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
    startMonth = await SettingsService.firstDayOfSchool();
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

    evaluationsPerDay = (await EvaluationDateService.findAllMappedByDate()).map((date, list) => MapEntry(date, list.length));
  }


  int _getMonthIndex(int identifier, DateTime startMonth) {
    final idYear = identifier ~/ 1000;
    final idMonth = identifier % 1000;

    final startYear = startMonth.year % 100;
    final startMonthValue = startMonth.month;

    return (idYear - startYear) * 12 + (idMonth - startMonthValue);
  }
}