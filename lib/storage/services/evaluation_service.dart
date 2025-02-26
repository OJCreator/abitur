import 'package:abitur/storage/entities/evaluation.dart';
import 'package:abitur/storage/storage.dart';
import 'package:abitur/utils/calender_sync.dart';
import 'package:abitur/utils/constants.dart';

import '../entities/performance.dart';
import '../entities/subject.dart';

class EvaluationService {


  static List<Evaluation> findAll() {
    List<Evaluation> evaluations = Storage.loadEvaluations();
    evaluations.sort((a,b) => a.date.compareTo(b.date));
    return evaluations;
  }
  static List<Evaluation> findAllByDay(DateTime day) {
    return findAll().where((e) => e.date.isOnSameDay(day)).toList();
  }
  static List<Evaluation> findAllByQuery(String text) {
    List<String> queries = text.toLowerCase().split(" ");
    queries.removeWhere((it) => it.isEmpty);
    return findAll().where((e) {
      return queries.every((query) =>
      e.name.toLowerCase().contains(query) ||
          e.subject.name.toLowerCase().contains(query) ||
          e.subject.shortName.toLowerCase().contains(query) ||
          (e.note != null && e.note.toString() == query)
      );
    }).toList();
  }

  static List<Evaluation> findAllBySubject(Subject s) {
    return findAll().where((e) => e.subject == s).toList();
  }
  static List<Evaluation> findAllGraded() {
    List<Evaluation> evaluations = EvaluationService.findAll();
    List<Evaluation> gradedEvaluations =  evaluations.where((e) => e.note != null).toList();
    return gradedEvaluations;
  }
  static List<Evaluation> findAllGradedBySubject(Subject s) {
    List<Evaluation> evaluationsOfSubject = EvaluationService.findAllBySubject(s);
    List<Evaluation> gradedEvaluations =  evaluationsOfSubject.where((e) => e.note != null).toList();
    return gradedEvaluations;
  }
  static List<Evaluation> findAllGradedBySubjectAndTerm(Subject s, int term) {
    List<Evaluation> evaluationsOfSubject = EvaluationService.findAllGradedBySubject(s);
    List<Evaluation> evaluationsOfTerm = evaluationsOfSubject.where((e) => e.term == term).toList();
    return evaluationsOfTerm;
  }
  static List<Evaluation> findAllBySubjectAndTerm(Subject subject, int term) {
    List<Evaluation> evaluationsOfSubject = EvaluationService.findAllBySubject(subject);
    List<Evaluation> evaluationsOfTerm = evaluationsOfSubject.where((e) => e.term == term).toList();
    return evaluationsOfTerm;
  }
  static List<Evaluation> findAllBySubjectAndTerms(Subject subject, List<int> terms) {
    List<Evaluation> evaluationsOfSubject = EvaluationService.findAllBySubject(subject);
    List<Evaluation> evaluationsOfTerms = evaluationsOfSubject.where((e) => terms.contains(e.term)).toList();
    return evaluationsOfTerms;
  }
  static List<Evaluation> findAllByPerformance(Performance performance) {
    List<Evaluation> evaluations = EvaluationService.findAll().where((e) => e.performance == performance).toList();
    return evaluations;
  }

  static Future<Evaluation> newEvaluation(Subject subject, Performance performance, int term, String name, DateTime date, int? note) async {

    Evaluation e = Evaluation(
        subjectId: subject.id,
        performanceId: performance.id,
        term: term,
        name: name,
        date: date,
        note: note
    );
    await Storage.saveEvaluation(e);
    await syncEvaluationCalendarEvent(e);
    return e;
  }

  static Future<void> editEvaluation(Evaluation evaluation, {required Subject subject, required Performance performance, required int term, required String name, required DateTime date, int? note}) async {
    evaluation.subject = subject;
    evaluation.performance = performance;
    evaluation.term = term;
    evaluation.name = name;
    evaluation.date = date;
    evaluation.note = note;
    await Storage.saveEvaluation(evaluation);
    await syncEvaluationCalendarEvent(evaluation);
  }

  static Future<void> setCalendarId(Evaluation evaluation, {required String? calendarId}) async {
    if (calendarId == null) {
      return;
    }
    evaluation.calendarId = calendarId;
    await Storage.saveEvaluation(evaluation);
  }

  static Future<void> deleteEvaluation(Evaluation evaluation) async {
    await deleteEvaluationCalendarEvent(evaluation);
    await Storage.deleteEvaluation(evaluation);
  }

  static Future<void> deleteAllEvaluations(List<Evaluation> evaluations) async {
    for (var e in evaluations) {
      deleteEvaluation(e);
    }
  }

  static Future<void> buildFromJson(List<Map<String, dynamic>> jsonData) async {
    List<Evaluation> evaluations = jsonData.map((e) => Evaluation.fromJson(e)).toList();
    for (Evaluation e in evaluations) {
      await Storage.saveEvaluation(e);
    }
  }
}