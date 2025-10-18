import 'dart:ui';

import 'package:abitur/services/database/evaluation_service.dart';
import 'package:abitur/services/database/evaluation_type_service.dart';
import 'package:abitur/services/database/subject_service.dart';
import 'package:abitur/sqlite/entities/evaluation/evaluation_type.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';

import '../sqlite/entities/evaluation/evaluation.dart';
import '../sqlite/entities/evaluation/evaluation_date.dart';
import '../sqlite/entities/settings.dart';
import '../sqlite/entities/subject.dart';
import 'database/evaluation_date_service.dart';
import 'database/settings_service.dart';
import 'database/timetable_entry_service.dart';

class CalendarService {
  static final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  static Future<void> syncEvaluationCalendarEvent(EvaluationDate evaluationDate, Evaluation evaluation) async {
    if (!await _shouldSyncCalendar()) return;

    final calendarId = await _getCalendarId();
    if (calendarId.isEmpty) return;

    await _syncSingleEvaluation(calendarId, evaluationDate, evaluation);

    debugPrint("Eine Prüfung wurde in den Kalender übernommen.");
  }
  static Future<void> syncAllEvaluationCalendarEvents() async {
    List<EvaluationDate> evaluationDates = await EvaluationDateService.findAll();
    if (!await _shouldSyncCalendar()) return;

    final calendarId = await _getCalendarId();
    if (calendarId.isEmpty) return;

    for (final evaluationDate in evaluationDates) {
      Evaluation? evaluation = await EvaluationService.findById(evaluationDate.id);
      if (evaluation == null) continue;
      await _syncSingleEvaluation(calendarId, evaluationDate, evaluation);
    }

    debugPrint("${evaluationDates.length} Prüfung(en) wurde(n) in den Kalender übernommen.");
  }
  static Future<bool> _shouldSyncCalendar() {
    return SettingsService.calendarSynchronisation();
  }
  static Future<void> _syncSingleEvaluation(String calendarId, EvaluationDate evaluationDate, Evaluation evaluation) async {
    await deleteEvaluationCalendarEvent(evaluationDate.id);

    if (!await _shouldCreateEvent(evaluationDate, evaluation)) return;

    final event = await _eventFromEvaluationDate(calendarId, evaluationDate, evaluation);
    final newEventId = await _deviceCalendarPlugin.createOrUpdateEvent(event);
    await EvaluationDateService.setCalendarId(evaluationDate, calendarId: newEventId?.data);
  }
  static Future<bool> _shouldCreateEvent(EvaluationDate eval, Evaluation evaluation) async {
    EvaluationType? evaluationType = await EvaluationTypeService.findById(evaluation.evaluationTypeId);
    if (evaluationType == null) return false;
    return evaluationType.showInCalendar && eval.date != null;
  }

  static Future<Event?> _eventFromEvaluationDate(String calendarId, EvaluationDate evaluationDate, Evaluation evaluation) async {

    Subject? subject = await SubjectService.findById(evaluation.subjectId);

    DateTime? start = await TimetableEntryService.getStartTime(evaluation.term, evaluation.subjectId, evaluationDate.date!.weekday);
    DateTime? end = await TimetableEntryService.getEndTime(evaluation.term, evaluation.subjectId, evaluationDate.date!.weekday);

    if (start == null || end == null) {
      return null;
    }

    Settings settings = await SettingsService.loadSettings();

    return Event(
      calendarId,
      eventId: evaluationDate.id, // TODO ein Event bearbeiten, statt es immer zu löschen und neu zu generieren
      title: "${subject?.shortName ?? 'Prüfung'} ${evaluation.name}",
      start: TZDateTime.from(evaluationDate.date!.copyWith(hour: start.hour, minute: start.minute), getLocation("Europe/Berlin")),
      end: TZDateTime.from(evaluationDate.date!.copyWith(hour: end.hour, minute: end.minute), getLocation("Europe/Berlin")),
      allDay: settings.calendarFullDayEvents,
      description: evaluationDate.description,
    );
  }

  static Future<void> deleteAllCalendarEvents() async {
    String calendarId = await _getCalendarId();
    if (calendarId.isEmpty) {
      return;
    }
    var events = (await _deviceCalendarPlugin.retrieveEvents(calendarId, RetrieveEventsParams())).data;
    for (Event e in events!) {
      await _deviceCalendarPlugin.deleteEvent(calendarId, e.eventId);
    }
    debugPrint("${events.length} Prüfung(en) wurde(n) aus dem Kalender gelöscht.");
  }

  static Future<void> deleteAllEvaluationCalendarEvents(List<EvaluationDate> evaluationDates) async {

    for (EvaluationDate eval in evaluationDates) {
      await deleteEvaluationCalendarEvent(eval.id);
    }
  }

  static Future<void> deleteEvaluationCalendarEvent(String evaluationDateId) async {

    String calendarId = await _getCalendarId();
    if (calendarId.isEmpty) {
      return;
    }
    EvaluationDate evaluationDate = await EvaluationDateService.findById(evaluationDateId);
    await _deviceCalendarPlugin.deleteEvent(calendarId, evaluationDate.calendarId);
    EvaluationDateService.setCalendarId(evaluationDate, calendarId: null);
  }

  static Future<void> changeCalendarColor(Color seed) async {

    if (!await SettingsService.calendarSynchronisation()) {
      return;
    }
    if (!await _hasCalendarPermission()) {
      return;
    }

    final calendarResult = await _deviceCalendarPlugin.retrieveCalendars();
    final calendars = calendarResult.data ?? (throw Exception("Failed to retrieve calendars"));

    Calendar? c = calendars.where((c) => c.name == "Schule").firstOrNull;
    c?.color = seed.toARGB32();
  }

  static Future<String> _getCalendarId() async {

    if (!await _hasCalendarPermission()) {
      debugPrint("Keine Kalender-Berechtigung!");
      return "";
    }

    final calendarResult = await _deviceCalendarPlugin.retrieveCalendars();
    final calendars = calendarResult.data ?? (throw Exception("Failed to retrieve calendars"));

    Calendar? c = calendars.where((c) => c.name == "Schule").firstOrNull;

    if (c == null) {
      Settings settings = await SettingsService.loadSettings();
      final cName = await _deviceCalendarPlugin.createCalendar("Schule", calendarColor: settings.accentColor, localAccountName: "Schule");
      return cName.data ?? "";
    }

    return c.id ?? "";
  }

  static Future<bool> _hasCalendarPermission() async {
    var permissionGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionGranted.isSuccess && permissionGranted.data!) {
      return true;
    }
    permissionGranted = await _deviceCalendarPlugin.requestPermissions();
    if (permissionGranted.isSuccess && permissionGranted.data!) {
      return true;
    }
    return false;
  }
}