import 'dart:ui';

import 'package:abitur/exceptions/invalid_form_input_exception.dart';
import 'package:abitur/isolates/average_isolates.dart';
import 'package:abitur/isolates/evaluation_date_isolates.dart';
import 'package:abitur/isolates/models/evaluation_dates/evaluation_dates_evaluation_subjects_model.dart';
import 'package:abitur/isolates/models/evaluation_dates/evaluation_dates_history_model.dart';
import 'package:abitur/isolates/models/subject/subjects_model.dart';
import 'package:abitur/isolates/serializer.dart';
import 'package:abitur/isolates/subject_isolates.dart';
import 'package:abitur/storage/entities/subject_category.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/services/timetable_service.dart';
import 'package:abitur/storage/storage.dart';
import 'package:abitur/utils/constants.dart';
import 'package:flutter/foundation.dart';

import '../../utils/pair.dart';
import '../entities/evaluation.dart';
import '../entities/evaluation_date.dart';
import '../entities/performance.dart';
import '../entities/settings.dart';
import '../entities/subject.dart';
import 'evaluation_date_service.dart';
import 'evaluation_service.dart';
import 'performance_service.dart';

class SubjectService {

  static Future<Subject> newSubject(String name, String shortName, Color color, Set<int> terms, int countingTermAmount, SubjectType subjectType, SubjectCategory subjectCategory, List<String> performanceIds) async {

    List<Subject> existingSubjects = findAll();
    Land land = SettingsService.land;
    if ([Land.bw, Land.by].contains(land) && subjectType == SubjectType.advanced && existingSubjects.countWhere((s) => s.subjectType == SubjectType.advanced) >= 3) {
      throw InvalidFormException("Es gibt bereits 3 Fächer auf erhöhtem Anforderungsniveau. Du kannst keine weiteren hinzufügen.");
    }

    Subject s = Subject(
      name: name,
      shortName: shortName,
      subjectType: subjectType,
      subjectCategoryId: subjectCategory.id,
      terms: terms,
      countingTermAmount: countingTermAmount,
      performanceIds: performanceIds,
      color: color,
    );
    await Storage.saveSubject(s);

    if (land == Land.bw && subjectType == SubjectType.advanced) {
      setGraduationEvaluation(s);
    }
    if (subjectType == SubjectType.seminar) {
      setGraduationEvaluation(s, graduation: true);
    }

    return s;
  }

  static Future<Subject> editSubject(Subject subject, {required String name, required String shortName, required Color color, required Set<int> terms, required int countingTermAmount, required SubjectType subjectType, required SubjectCategory subjectCategory, required List<Performance> performances}) async {

    List<Subject> existingSubjects = findAll().where((s) => s != subject).toList();
    Land land = SettingsService.land;
    if ([Land.bw, Land.by].contains(land) && subjectType == SubjectType.advanced && existingSubjects.countWhere((s) => s.subjectType == SubjectType.advanced) >= 3) {
      throw InvalidFormException("Es gibt bereits 3 Fächer auf erhöhtem Anforderungsniveau. Du kannst keine weiteren hinzufügen.");
    }

    await PerformanceService.savePerformances(performances);
    List<Performance> performancesToDelete = subject.performances.where((p) => !performances.contains(p)).toList();
    PerformanceService.deletePerformances(performancesToDelete);

    subject.name = name;
    subject.shortName = shortName;
    subject.color = color;
    subject.terms = terms;
    subject.countingTermAmount = countingTermAmount;
    subject.subjectType = subjectType;
    subject.subjectCategory = subjectCategory;
    subject.performances = performances;
    await Storage.saveSubject(subject);

    if (land == Land.bw && subjectType == SubjectType.advanced) {
      await setGraduationEvaluation(subject);
    }
    if (subjectType == SubjectType.seminar) {
      await setGraduationEvaluation(subject, graduation: true);
    }

    return subject;
  }

  static Future<void> deleteSubject(Subject subject) async {
    List<Evaluation> evaluations = EvaluationService.findAllBySubject(subject);
    await EvaluationService.deleteAllEvaluations(evaluations);
    await TimetableService.deleteSubjectEntries(subject);
    await PerformanceService.deletePerformances(subject.performances);
    await Storage.deleteSubject(subject);
  }


  static Future<List<Subject>> findAllSortedIsolated() async {
    List<Subject> subjects = findAll();
    SubjectsModel model = SubjectsModel(subjects.serialize());
    SubjectsModel result = await compute(SubjectIsolates.sortSubjects, model);
    return result.subjects.map((s) => Subject.fromJson(s)).toList();
  }
  static List<Subject> findAll() {
    List<Subject> subjects = Storage.loadSubjects();
    subjects.sort((a,b) => a.name.compareTo(b.name));
    return subjects;
  }

  static Subject? findById(String? id) {
    return id != null ? Storage.loadSubject(id) : null;
  }

  static bool hasSubjects() {
    return findAll().isNotEmpty;
  }

  static List<Subject> findAllGradable() {
    return findAll().where((s) => s.subjectType != SubjectType.voluntary).toList();
  }

  static Future<double?> getCurrentAverageIsolated() async {
    List<Subject> subjects = findAll();
    List<Evaluation> evaluations = EvaluationService.findAll();
    List<EvaluationDate> evaluationDates = EvaluationDateService.findAll();
    List<Performance> performances = PerformanceService.findAll();

    EvaluationDatesEvaluationsSubjectsModel model = EvaluationDatesEvaluationsSubjectsModel(evaluationDates.serialize(), evaluations.serialize(), subjects.serialize(), performances.serialize());

    double? avg = await compute(AverageIsolates.computeCurrentAverage, model);

    return avg;
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

  static Future<Map<Subject, List<Pair<DateTime, double>>>> getAverageHistoryForAllSubjects() async {

    List<EvaluationDate> evaluationDates = EvaluationDateService.findAll();
    List<Evaluation> evaluations = EvaluationService.findAll();
    List<Subject> subjects = SubjectService.findAll();
    List<Performance> performances = PerformanceService.findAll();

    EvaluationDatesEvaluationsSubjectsModel model = EvaluationDatesEvaluationsSubjectsModel(evaluationDates.serialize(), evaluations.serialize(), subjects.serialize(), performances.serialize());

    EvaluationDatesHistoryModel historyModel = await compute(EvaluationDateIsolates.getAverageHistoryForAllSubjects, model);

    final subjectMap = { for (var s in subjects) s.id: s };
    final Map<Subject, List<Pair<DateTime, double>>> history = {
      for (var entry in historyModel.history.entries)
        if (subjectMap.containsKey(entry.key)) subjectMap[entry.key]!: entry.value
    };
    return history;
  }

  static double? getAverage(Subject s) {
    Set<int> terms = EvaluationService.findAllGradedBySubject(s).map((e) => e.term).toSet();
    Iterable<int?> averages = terms.map((term) => roundNote(getAverageByTerm(s, term)));
    double? average = avg(averages);
    return average;
  }

  static double? getAverageByTerm(Subject s, int term) {
    if (s.manuallyEnteredTermNotes[term] != null) {
      return s.manuallyEnteredTermNotes[term]!.toDouble();
    }
    Iterable<Evaluation> evaluations = EvaluationService.findAllGradedBySubjectAndTerm(s, term);
    if (!s.terms.contains(term)) {
      return null;
    }
    Map<Performance, Iterable<Evaluation>> performancesAndNotes = s.performances.mapWith((performance) {
      return evaluations.where((note) {
        return note.performance == performance;
      });
    });
    Iterable<Pair<double, double?>> weightAndNote = performancesAndNotes.mapToIterable((performance, value) {
      Iterable<int> noteValues = value.map((evaluation) => EvaluationService.calculateNote(evaluation)!);
      return Pair(performance.weighting, avg(noteValues));
    });
    double? average = weightedAvg(weightAndNote);
    return average;
  }

  static Future<void> setGraduationSubjects(List<Subject?> subjects) async {
    if (subjects.contains(null)) {
      throw Exception("Subjects dürfen nicht null sein!");
    }
    if (subjects.any((s) => s!.subjectType == SubjectType.seminar)) {
      throw Exception("Subjects dürfen kein Seminarfach sein!");
    }
    for (Subject subjectToRemove in graduationSubjects().where((s) => !subjects.contains(s))) {
      if (subjectToRemove.subjectType != SubjectType.seminar) {
        await setGraduationEvaluation(subjectToRemove, graduation: false);
      }
    }
    for (Subject? s in subjects) {
      await setGraduationEvaluation(s!, graduation: true);
    }
  }

  static Future<void> setGraduationEvaluation(Subject s, {bool graduation = true}) async {
    if (!graduation && s.graduationEvaluation != null && s.subjectType != SubjectType.seminar) {
      EvaluationService.deleteEvaluation(s.graduationEvaluation!);
      s.graduationEvaluation = null;
      Storage.saveSubject(s);
    } else if (graduation && s.graduationEvaluation == null) {
      Evaluation e = await EvaluationService.newGraduationEvaluation(s);
      s.graduationEvaluation = e;
      Storage.saveSubject(s);
    }
  }

  static Future<void> manuallyEnterTermNote(Subject s, {required int term, required int? note}) async {
    s.manuallyEnteredTermNotes[term] = note;
    await Storage.saveSubject(s);
  }

  static bool isGraduationSubject(Subject subject) {
    return subject.graduationEvaluation != null && subject.subjectType != SubjectType.seminar;
  }

  static List<Subject> graduationSubjects() {
    return findAll().where((s) => s.graduationEvaluation != null && s.subjectType != SubjectType.seminar).toList();
  }

  static List<Evaluation> graduationEvaluations() {
    return graduationSubjects().map((s) => s.graduationEvaluation!).toList();
  }

  static Future<void> buildFromJson(List<Map<String, dynamic>> jsonData) async {

    for (Subject s in findAll()) {
      await deleteSubject(s);
    }
    print("Hias");
    List<Subject> subjects = jsonData.map((e) => Subject.fromJson(e)).toList();
    for (Subject s in subjects) {
      await Storage.saveSubject(s);
    }
  }
}