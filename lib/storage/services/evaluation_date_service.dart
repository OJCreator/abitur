import 'package:abitur/storage/services/calendar_service.dart';
import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/services/notification_service.dart';
import 'package:abitur/utils/constants.dart';

import '../entities/evaluation.dart';
import '../entities/evaluation_date.dart';
import '../entities/subject.dart';
import '../storage.dart';

class EvaluationDateService {

  static List<EvaluationDate> findAll() {
    List<EvaluationDate> evaluations = Storage.loadEvaluationDates();
    evaluations.sort((a,b) => a.compareTo(b));
    return evaluations;
  }
  static EvaluationDate findById(String id) {
    return Storage.loadEvaluationDate(id);
  }
  static List<EvaluationDate> findAllById(List<String> ids) {
    return ids.map((id) => Storage.loadEvaluationDate(id)).toList();
  }
  static List<EvaluationDate> findAllByDay(DateTime day) {
    return findAll().where((e) => e.date?.isOnSameDay(day) ?? false).toList();
  }
  static List<EvaluationDate> findAllGraded() {
    List<EvaluationDate> evaluations = findAll();
    List<EvaluationDate> gradedEvaluations = evaluations.where((e) => e.note != null).toList();
    return gradedEvaluations;
  }
  static List<EvaluationDate> findAllBySubject(Subject s) {
    return findAll().where((e) => e.evaluation.subject == s).toList();
  }
  static List<EvaluationDate> findAllGradedBySubject(Subject s) {
    List<EvaluationDate> evaluationsOfSubject = EvaluationDateService.findAllBySubject(s);
    List<EvaluationDate> gradedEvaluations = evaluationsOfSubject.where((e) => e.note != null).toList();
    return gradedEvaluations;
  }
  static List<EvaluationDate> findAllByQuery(String text) {
    List<String> queries = text.toLowerCase().split(" ");
    queries.removeWhere((it) => it.isEmpty);
    return findAll().where((e) {
      return queries.every((query) =>
      e.evaluation.name.toLowerCase().contains(query) ||
          e.evaluation.subject.name.toLowerCase().contains(query) ||
          e.evaluation.subject.shortName.toLowerCase().contains(query) ||
          (e.note != null && e.note!.toString() == query)
      );
    }).toList();
  }

  static Future<EvaluationDate> newEvaluationDate(Evaluation evaluation, {DateTime? date, int? note, int? weight, String? description}) async {

    EvaluationDate e = EvaluationDate(
      evaluationId: evaluation.id,
      date: date,
      note: note,
      weight: weight ?? 1,
      description: description ?? "",
    );
    await Storage.saveEvaluationDate(e);
    List<EvaluationDate> dateList = evaluation.evaluationDates;
    dateList.add(e);
    evaluation.evaluationDates = dateList;
    await Storage.saveEvaluation(evaluation);
    await CalendarService.syncEvaluationCalendarEvent(e);
    NotificationService.scheduleNotificationsForEvaluation(e);
    return e;
  }

  static Future<void> saveEvaluationDate(EvaluationDate evaluationDate) async {

    await Storage.saveEvaluationDate(evaluationDate);
    await CalendarService.syncEvaluationCalendarEvent(evaluationDate);
    NotificationService.scheduleNotificationsForEvaluation(evaluationDate);
  }

  static Future<void> saveAllEvaluationDates(List<EvaluationDate> evaluationDates) async {

    for (EvaluationDate e in evaluationDates) {
      await saveEvaluationDate(e);
    }
  }

  static Future<void> editEvaluationDate(EvaluationDate evaluationDate, {required DateTime? date, required int? note, required int weight}) async {
    evaluationDate.date = date;
    evaluationDate.note = note;
    evaluationDate.weight = weight;
    await Storage.saveEvaluationDate(evaluationDate);
    await CalendarService.syncEvaluationCalendarEvent(evaluationDate);
    NotificationService.scheduleNotificationsForEvaluation(evaluationDate);
  }


  static Future<void> setCalendarId(EvaluationDate evaluationDate, {required String? calendarId}) async {
    if (calendarId == null) {
      return;
    }
    evaluationDate.calendarId = calendarId;
    await Storage.saveEvaluationDate(evaluationDate);
  }

  static Future<void> deleteAllEvaluationDates(List<EvaluationDate> evaluationDates) async {
    for (EvaluationDate evaluationDate in evaluationDates) {
      await deleteEvaluationDate(evaluationDate);
    }
  }

  static Future<void> deleteEvaluationDate(EvaluationDate evaluationDate) async {

    Evaluation evaluation = evaluationDate.evaluation;
    List<EvaluationDate> dateList = evaluation.evaluationDates;
    dateList.remove(evaluationDate);
    evaluation.evaluationDates = dateList;
    await Storage.saveEvaluation(evaluation);

    await CalendarService.deleteEvaluationCalendarEvent(evaluationDate);
    await Storage.deleteEvaluationDate(evaluationDate);
    NotificationService.cancelEvaluationNotifications(evaluationDate);
  }

  static Future<void> buildFromJson(List<Map<String, dynamic>> jsonData) async {

    deleteAllEvaluationDates(findAll());

    List<EvaluationDate> evaluationDates = jsonData.map((e) => EvaluationDate.fromJson(e)).toList();
    for (EvaluationDate e in evaluationDates) {
      await Storage.saveEvaluationDate(e);
    }
  }
}