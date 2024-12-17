import 'dart:ui';

import 'package:abitur/storage/services/timetable_service.dart';
import 'package:abitur/storage/storage.dart';
import 'package:abitur/utils/constants.dart';

import '../../utils/pair.dart';
import '../entities/evaluation.dart';
import '../entities/performance.dart';
import '../entities/subject.dart';
import 'evaluation_service.dart';
import 'performance_service.dart';

class SubjectService {

  static Future<Subject> newSubject(String name, String shortName, Color color, Set<int> terms, int countingTermAmount, SubjectType subjectType, List<String> performanceIds) async {
    Subject s = Subject(
      name: name,
      shortName: shortName,
      subjectType: subjectType,
      terms: terms,
      countingTermAmount: countingTermAmount,
      performanceIds: performanceIds,
      color: color,
    );
    await Storage.saveSubject(s);
    return s;
  }

  static Future<Subject> editSubject(Subject subject, {required String name, required String shortName, required Color color, required Set<int> terms, required int countingTermAmount, required SubjectType subjectType, required List<Performance> performances}) async {

    await PerformanceService.savePerformances(performances);
    List<Performance> performancesToDelete = subject.performances.where((p) => !performances.contains(p)).toList();
    PerformanceService.deletePerformances(performancesToDelete);

    subject.name = name;
    subject.shortName = shortName;
    subject.color = color;
    subject.terms = terms;
    subject.countingTermAmount = countingTermAmount;
    subject.subjectType = subjectType;
    subject.performances = performances;
    await Storage.saveSubject(subject);
    return subject;
  }

  static Future<void> deleteSubject(Subject subject) async {
    List<Evaluation> evaluations = EvaluationService.findAllBySubject(subject);
    await EvaluationService.deleteAllEvaluations(evaluations);
    await TimetableService.deleteSubjectEntries(subject);
    await Storage.deleteSubject(subject);
  }

  static List<Subject> findAll() {
    List<Subject> subjects = Storage.loadSubjects();
    subjects.sort((a,b) => a.name.compareTo(b.name));
    return subjects;
  }

  static Subject? findById(String? id) {
    for (var subject in findAll()) {
      if (subject.id == id) {
        return subject;
      }
    }
    return null;
  }

  static bool hasSubjects() {
    return findAll().isNotEmpty;
  }

  static List<Subject> findAllGradable() {
    return findAll().where((s) => s.subjectType != SubjectType.voluntary).toList();
  }

  static double? getCurrentAverage() {
    List<Subject> subjects = findAll();
    List<int> averages = [];
    for (var s in subjects) {
      for (int term = 0; term < 4; term++) {
        int? average = roundNote(getAverageByTerm(s, term));
        if (average != null) {
          averages.add(average);
        }
      }
    }
    return avg(averages);
  }

  static List<Pair<DateTime, double>> getAverageHistory({Subject? filterBySubject}) {

    List<Evaluation> evaluations;
    if (filterBySubject == null) {
      evaluations = EvaluationService.findAllGraded();
    } else {
      evaluations = EvaluationService.findAllGradedBySubject(filterBySubject);
    }
    evaluations.sort((a, b) => a.date.compareTo(b.date));

    List<Pair<DateTime, double>> history = [];
    List<int> allGrades = [];

    for (var evaluation in evaluations) {
      if (evaluation.note == null || evaluation.date.isAfter(DateTime.now())) {
        continue;
      }

      allGrades.add(evaluation.note!);
      double currentAverage = avg(allGrades)!;
      history.add(Pair(evaluation.date, currentAverage));
    }

    return history;
  }

  static Map<Subject, List<Pair<DateTime, double>>> getAverageHistoryForAllSubjects() {
    List<Subject> subjects = findAllGradable();
    final entries = subjects.map((s) => MapEntry(s, getAverageHistory(filterBySubject: s)));
    final data = Map.fromEntries(entries);
    return data;
  }

  static double? getAverage(Subject s) {
    Set<int> terms = EvaluationService.findAllGradedBySubject(s).map((e) => e.term).toSet();
    Iterable<int?> averages = terms.map((term) => getAverageByTerm(s, term)?.roundGrade());
    double? average = avg(averages);
    return average;
  }

  static double? getAverageByTerm(Subject s, int term) {
    Iterable<Evaluation> evaluations = EvaluationService.findAllGradedBySubjectAndTerm(s, term);
    Map<Performance, Iterable<Evaluation>> performancesAndNotes = s.performances.mapWith((performance) {
      return evaluations.where((note) {
        return note.performance == performance;
      });
    });
    Iterable<Pair<double, double?>> weightAndNote = performancesAndNotes.mapToIterable((performance, value) {
      Iterable<int> noteValues = value.map((note) => note.note!);
      return Pair(performance.weighting, avg(noteValues));
    });
    double? average = weightedAvg(weightAndNote);
    return average;
  }

  static Future<void> buildFromJson(List<Map<String, dynamic>> jsonData) async {

    for (Subject s in findAll()) {
      await deleteSubject(s);
    }

    List<Subject> subjects = jsonData.map((e) => Subject.fromJson(e)).toList();
    for (Subject s in subjects) {
      await Storage.saveSubject(s);
    }
  }
}