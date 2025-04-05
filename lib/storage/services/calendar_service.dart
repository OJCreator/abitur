import 'dart:ui';

import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/services/timetable_service.dart';
import 'package:device_calendar/device_calendar.dart';

import '../entities/evaluation_date.dart';
import 'evaluation_date_service.dart';

class CalendarService {
  static final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  static Future<void> syncEvaluationCalendarEvent(EvaluationDate evaluationDate) async {
    if (!_shouldSyncCalendar()) return;

    final calendarId = await _getCalendarId();
    if (calendarId.isEmpty) return;

    await _syncSingleEvaluation(calendarId, evaluationDate);

    print("Eine Prüfung wurde in den Kalender übernommen.");
  }
  static Future<void> syncAllEvaluationCalendarEvents() async {
    List<EvaluationDate> evaluationDates = EvaluationDateService.findAll();
    if (!_shouldSyncCalendar()) return;

    final calendarId = await _getCalendarId();
    if (calendarId.isEmpty) return;

    for (final eval in evaluationDates) {
      await _syncSingleEvaluation(calendarId, eval);
    }

    print("${evaluationDates.length} Prüfung(en) wurde(n) in den Kalender übernommen.");
  }
  static bool _shouldSyncCalendar() {
    return SettingsService.calendarSynchronisation();
  }
  static Future<void> _syncSingleEvaluation(String calendarId, EvaluationDate eval) async {
    await deleteEvaluationCalendarEvent(eval);

    if (!_shouldCreateEvent(eval)) return;

    final event = _eventFromEvaluationDate(calendarId, eval);
    final newEventId = await _deviceCalendarPlugin.createOrUpdateEvent(event);
    await EvaluationDateService.setCalendarId(eval, calendarId: newEventId?.data);
  }
  static bool _shouldCreateEvent(EvaluationDate eval) {
    return eval.evaluation.evaluationType.showInCalendar && eval.date != null;
  }

  static Event _eventFromEvaluationDate(String calendarId, EvaluationDate evaluationDate) {
    DateTime start = TimetableService.getStartTime(evaluationDate.evaluation.term, evaluationDate.evaluation.subject, evaluationDate.date!.weekday);
    DateTime end = TimetableService.getEndTime(evaluationDate.evaluation.term, evaluationDate.evaluation.subject, evaluationDate.date!.weekday);

    return Event(
      calendarId,
      eventId: evaluationDate.id, // TODO ein Event bearbeiten, statt es immer zu löschen und neu zu generieren
      title: "${evaluationDate.evaluation.subject.shortName} ${evaluationDate.evaluation.name}",
      start: TZDateTime.from(evaluationDate.date!.copyWith(hour: start.hour, minute: start.minute), getLocation("Europe/Berlin")),
      end: TZDateTime.from(evaluationDate.date!.copyWith(hour: end.hour, minute: end.minute), getLocation("Europe/Berlin")),
      allDay: SettingsService.loadSettings().calendarFullDayEvents,
      description: evaluationDate.description,
    );
  }

  static Future<void> deleteAllCalendarEvents() async {
    String calendarId = await _getCalendarId();
    if (calendarId.isEmpty) {
      return;
    }
    var events = (await _deviceCalendarPlugin.retrieveEvents(calendarId, RetrieveEventsParams(startDate: SettingsService.firstDayOfSchool, endDate: SettingsService.lastDayOfSchool))).data;
    for (Event e in events!) {
      await _deviceCalendarPlugin.deleteEvent(calendarId, e.eventId);
    }
    print("${events.length} Prüfung(en) wurde(n) aus dem Kalender gelöscht.");
  }

  static Future<void> deleteAllEvaluationCalendarEvents(List<EvaluationDate> evaluationDates) async {

    for (EvaluationDate eval in evaluationDates) {
      await deleteEvaluationCalendarEvent(eval);
    }
  }

  static Future<void> deleteEvaluationCalendarEvent(EvaluationDate evaluationDate) async {

    String calendarId = await _getCalendarId();
    if (calendarId.isEmpty) {
      return;
    }
    await _deviceCalendarPlugin.deleteEvent(calendarId, evaluationDate.calendarId);
    EvaluationDateService.setCalendarId(evaluationDate, calendarId: null);
  }

  static Future<void> changeCalendarColor(Color seed) async {

    if (!SettingsService.calendarSynchronisation()) {
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
      print("Keine Kalender-Berechtigung!");
      return "";
    }

    final calendarResult = await _deviceCalendarPlugin.retrieveCalendars();
    final calendars = calendarResult.data ?? (throw Exception("Failed to retrieve calendars"));

    Calendar? c = calendars.where((c) => c.name == "Schule").firstOrNull;

    if (c == null) {
      final cName = await _deviceCalendarPlugin.createCalendar("Schule", calendarColor: SettingsService.loadSettings().accentColor, localAccountName: "Schule");
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