import 'dart:ui';

import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/services/timetable_service.dart';
import 'package:device_calendar/device_calendar.dart';

import '../storage/entities/evaluation.dart';

DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

Future<void> syncEvaluationCalendarEvent(Evaluation evaluation) async {
  return syncEvaluationCalendarEvents([evaluation]);
}

Future<void> syncEvaluationCalendarEvents(List<Evaluation> evaluations) async {

  if (!SettingsService.calendarSynchronisation()) {
    deleteAllCalendarEvents();
    return;
  }

  String calendarId = await getCalendarId();
  if (calendarId.isEmpty) {
    print("No valid calendar ID available. Maybe no calendar permission?");
    return;
  }

  for (Evaluation evaluation in evaluations) {
    await deleteEvaluationCalendarEvent(evaluation);

    DateTime start = TimetableService.getStartTime(evaluation.term, evaluation.subject, evaluation.date.weekday);
    DateTime end = TimetableService.getEndTime(evaluation.term, evaluation.subject, evaluation.date.weekday);

    Event event = Event(
        calendarId,
        eventId: null, // TODO ein Event bearbeiten, statt es immer zu löschen und neu zu generieren
        title: "${evaluation.subject.shortName} ${evaluation.name}",
        start: TZDateTime.from(evaluation.date.copyWith(hour: start.hour, minute: start.minute), getLocation("Europe/Berlin")),
        end: TZDateTime.from(evaluation.date.copyWith(hour: end.hour, minute: end.minute), getLocation("Europe/Berlin")),
        allDay: SettingsService.loadSettings().calendarFullDayEvents
    );

    var result = await _deviceCalendarPlugin.createOrUpdateEvent(event);

    await EvaluationService.setCalendarId(evaluation, calendarId: result?.data);
  }
  print("${evaluations.length} Prüfung(en) wurde(n) in den Kalender übernommen.");
}

Future<void> deleteEvaluationCalendarEvent(Evaluation evaluation) async {

  String calendarId = await getCalendarId();
  if (calendarId.isEmpty) {
    print("No valid calendar ID available. Maybe no calendar permission?");
    return;
  }
  await _deviceCalendarPlugin.deleteEvent(calendarId, evaluation.calendarId);
}

Future<void> deleteAllCalendarEvents() async {
  String calendarId = await getCalendarId();
  if (calendarId.isEmpty) {
    print("No valid calendar ID available. Maybe no calendar permission?");
    return;
  }
  var events = (await _deviceCalendarPlugin.retrieveEvents(calendarId, RetrieveEventsParams(startDate: SettingsService.firstDayOfSchool, endDate: SettingsService.lastDayOfSchool))).data;
  for (Event e in events!) {
    await _deviceCalendarPlugin.deleteEvent(calendarId, e.eventId);
  }
  print("${events.length} Prüfung(en) wurde(n) aus dem Kalender gelöscht.");
}

Future<void> changeCalendarColor(Color seed) async {

  if (!SettingsService.calendarSynchronisation()) {
    return;
  }

  try {
    await checkCalendarPermissions();
  } catch (e) {
    print(e);
    return;
  }

  final calendarResult = await _deviceCalendarPlugin.retrieveCalendars();
  final calendars = calendarResult.data ?? (throw Exception("Failed to retrieve calendars"));

  Calendar? c = calendars.where((c) => c.name == "Schule").firstOrNull;

  if (c == null) {
    await _deviceCalendarPlugin.createCalendar("Schule", calendarColor: SettingsService.loadSettings().accentColor, localAccountName: "Schule");
    return;
  }
  c.color = seed.value;
}

Future<String> getCalendarId() async {

  try {
    await checkCalendarPermissions();
  } catch (e) {
    print(e);
    return "";
  }

  final calendarResult = await _deviceCalendarPlugin.retrieveCalendars();
  final calendars = calendarResult.data ?? (throw Exception("Failed to retrieve calendars"));

  Calendar? c = calendars.where((c) => c.name == "Schule").firstOrNull;

  if (c == null) {
    final cName = await _deviceCalendarPlugin.createCalendar("Schule", calendarColor: SettingsService.loadSettings().accentColor, localAccountName: "Schule");
    return cName.data!;
  }

  return c.id!;
}

Future<void> checkCalendarPermissions() async {
  var permissionGranted = await _deviceCalendarPlugin.hasPermissions();
  if (permissionGranted.isSuccess && !permissionGranted.data!) {
    permissionGranted = await _deviceCalendarPlugin.requestPermissions();

    if (permissionGranted.isSuccess && !permissionGranted.data!) {
      throw Exception("No calendar permissions");
    }
  }
}

Future<void> printCalenderEvents() async {
  String calenderId = await getCalendarId();
  var result = await _deviceCalendarPlugin.retrieveEvents(calenderId, RetrieveEventsParams(startDate: DateTime(2000), endDate: DateTime(2050)));
  var list = result.data!;
  print(list.map((e) => "${e.title} (${e.eventId})"));
}