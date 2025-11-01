import 'package:collection/collection.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';

import '../sqlite/entities/evaluation/evaluation.dart';
import '../sqlite/entities/evaluation/evaluation_date.dart';
import '../sqlite/entities/subject.dart';
import 'database/evaluation_date_service.dart';
import 'database/evaluation_service.dart';
import 'database/evaluation_type_service.dart';
import 'database/settings_service.dart';
import 'database/subject_service.dart';
import 'database/timetable_entry_service.dart';

class CalendarService {
  static final _calendar = DeviceCalendarPlugin();
  static const _calendarName = "Schule";

  // ---- Öffentliche Methoden ----

  static Future<void> syncSingle(EvaluationDate date, Evaluation evaluation) async {
    if (!await _shouldSync()) return;
    final calendarId = await _ensureCalendar();
    if (calendarId == null) return;

    final settings = await SettingsService.loadSettings();

    await _replaceEvent(calendarId, date, evaluation, fullDayEvents: settings.calendarFullDayEvents);
  }

  static Future<void> syncAll() async {
    if (!await _shouldSync()) return;
    final calendarId = await _ensureCalendar();
    if (calendarId == null) return;

    final dates = await EvaluationDateService.findAll();
    final evaluations = await EvaluationService.findAllById(
      dates.map((d) => d.evaluationId).toSet().toList(),
    );
    final subjects = await SubjectService.findAllAsMap();

    final settings = await SettingsService.loadSettings();

    int counter = 0;
    for (final date in dates) {
      final eval = evaluations[date.evaluationId];
      if (eval == null) continue;
      bool result = await _replaceEvent(calendarId, date, eval, subjects: subjects, fullDayEvents: settings.calendarFullDayEvents);
      if (result) counter++;
    }

    debugPrint("$counter Prüfung(en) synchronisiert.");
  }

  static Future<void> deleteAll() async {
    final calendarId = await _ensureCalendar();
    if (calendarId == null) return;

    final evaluationDates = await EvaluationDateService.findAll();
    int counter = 0;
    for (final e in evaluationDates) {
      final result = await _calendar.deleteEvent(calendarId, e.calendarId);
      await EvaluationDateService.setCalendarId(e, calendarId: null);
      if (result.data == true) counter++;
    }
    debugPrint("$counter Prüfung(en) gelöscht.");
  }

  static Future<void> deleteEvaluationEvent(String evaluationDateId) async {
    final calendarId = await _ensureCalendar();
    if (calendarId == null) return;

    final date = await EvaluationDateService.findById(evaluationDateId);
    if (date.calendarId == null) return;

    await _calendar.deleteEvent(calendarId, date.calendarId);
    await EvaluationDateService.setCalendarId(date, calendarId: null);
  }

  static Future<void> changeCalendarColor(Color color) async {
    if (!await _shouldSync()) return;
    if (!await _hasPermission()) return;

    final calendars = (await _calendar.retrieveCalendars()).data ?? [];
    final c = calendars.firstWhere((c) => c.name == _calendarName, orElse: () => Calendar(name: ""));
    if (c.id != null && c.id!.isNotEmpty) {
      await _calendar.createCalendar(
        _calendarName,
        calendarColor: color,
        localAccountName: _calendarName,
      );
    }
  }

  // ---- Private Hilfsmethoden ----

  static Future<bool> _replaceEvent(
      String calendarId,
      EvaluationDate date,
      Evaluation evaluation, {
        Map<String, Subject>? subjects,
        required bool fullDayEvents,
      }) async {

    await _calendar.deleteEvent(calendarId, date.calendarId);

    if (!await _shouldCreate(date, evaluation)) return false;

    final event = await _buildEvent(calendarId, date, evaluation, subjects: subjects, fullDayEvents: fullDayEvents);
    final result = await _calendar.createOrUpdateEvent(event);
    await EvaluationDateService.setCalendarId(date, calendarId: result?.data);
    return result != null;
  }

  static Future<Event?> _buildEvent(
      String calendarId,
      EvaluationDate date,
      Evaluation evaluation, {
        Map<String, Subject>? subjects,
        required bool fullDayEvents
      }) async {
    final subject = subjects != null
        ? subjects[evaluation.subjectId]
        : await SubjectService.findById(evaluation.subjectId);

    final start = await TimetableEntryService.getStartTime(
      evaluation.term,
      evaluation.subjectId,
      date.date!.weekday,
    );
    final end = await TimetableEntryService.getEndTime(
      evaluation.term,
      evaluation.subjectId,
      date.date!.weekday,
    );

    final allDay = fullDayEvents || start == null || end == null;
    final tz = getLocation("Europe/Berlin");

    final startTime = allDay
        ? TZDateTime.from(date.date!, tz)
        : TZDateTime.from(date.date!.copyWith(hour: start.hour, minute: start.minute), tz);

    final endTime = allDay
        ? TZDateTime.from(date.date!, tz)
        : TZDateTime.from(date.date!.copyWith(hour: end.hour, minute: end.minute), tz);

    return Event(
      calendarId,
      eventId: null, // date.calendarId,
      title: "${subject?.shortName ?? 'Prüfung'} ${evaluation.name}",
      start: startTime,
      end: endTime,
      allDay: allDay,
      description: date.description,
    );
  }

  static Future<bool> _shouldCreate(EvaluationDate date, Evaluation evaluation) async {
    final type = await EvaluationTypeService.findById(evaluation.evaluationTypeId);
    return type?.showInCalendar == true && date.date != null;
  }

  static Future<bool> _shouldSync() => SettingsService.calendarSynchronisation();

  static Future<bool> _hasPermission() async {
    var res = await _calendar.hasPermissions();
    if (res.isSuccess && res.data == true) return true;

    res = await _calendar.requestPermissions();
    return res.isSuccess && res.data == true;
  }

  static Future<String?> _ensureCalendar() async {
    if (!await _hasPermission()) return null;

    final result = await _calendar.retrieveCalendars();
    final calendars = result.data?.toList();
    final existing = calendars?.firstWhereOrNull((c) => c.name == _calendarName);

    if (existing != null && existing.id != null && existing.id!.isNotEmpty) return existing.id;

    final settings = await SettingsService.loadSettings();
    final created = await _calendar.createCalendar(
      _calendarName,
      calendarColor: settings.accentColor,
      localAccountName: _calendarName,
    );
    return created.data;
  }
}
