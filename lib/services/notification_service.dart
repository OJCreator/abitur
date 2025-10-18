import 'package:abitur/services/database/evaluation_service.dart';
import 'package:abitur/services/database/subject_service.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:synchronized/synchronized.dart';

import '../main.dart';
import '../pages/evaluation_pages/evaluation_input_page.dart';
import '../pages/subject_pages/subject_page.dart';
import '../sqlite/entities/evaluation/evaluation.dart';
import '../sqlite/entities/evaluation/evaluation_date.dart';
import '../sqlite/entities/settings.dart';
import '../sqlite/entities/subject.dart';
import '../utils/constants.dart';
import 'database/evaluation_date_service.dart';
import 'database/settings_service.dart';

class NotificationService {
  static final notificationsPlugin = FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;


  static Future<void> init() async {
    if (_isInitialized) return;

    const initSettingAndroid = AndroidInitializationSettings('@drawable/ic_launcher_foreground');
    const initSettingsIos = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: initSettingAndroid,
      iOS: initSettingsIos,
    );

    await notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _handleNotificationTap(response.payload!);
        }
      },
    );
    _isInitialized = true;
  }

  // Public Scheduling APIs
  static Future<void> scheduleAllNotifications() async {
    List<EvaluationDate> evaluationDates = await EvaluationDateService.findAll();
    for (EvaluationDate e in evaluationDates) {
      scheduleNotificationsForEvaluation(e);
    }
  }
  static void scheduleNotificationsForEvaluation(EvaluationDate evaluationDate) {
    _scheduleEvaluationReminder(evaluationDate);
    _scheduleMissingGradeReminder(evaluationDate);
  }
  static void cancelEvaluationNotifications(String evaluationDateId) {
    _cancelNotification(evaluationDateId, tag: "evaluationReminder");
    _cancelNotification(evaluationDateId, tag: "missingGradeReminder");
  }
  static void scheduleOnlyEvaluationReminders(List<EvaluationDate> evaluationDates) {
    for (EvaluationDate e in evaluationDates) {
      _scheduleEvaluationReminder(e);
    }
  }
  static void scheduleOnlyMissingGradeReminders(List<EvaluationDate> evaluationDates) {
    for (EvaluationDate e in evaluationDates) {
      _scheduleMissingGradeReminder(e);
    }
  }
  static void cancelOnlyEvaluationReminders(List<EvaluationDate> evaluationDates) {
    for (EvaluationDate e in evaluationDates) {
      _cancelNotification(e.id, tag: "evaluationReminder");
    }
  }
  static void cancelOnlyMissingGradeReminders(List<EvaluationDate> evaluationDates) {
    for (EvaluationDate e in evaluationDates) {
      _cancelNotification(e.id, tag: "missingGradeReminder");
    }
  }

  // Private Scheduling Helpers
  static Future<void> _scheduleEvaluationReminder(EvaluationDate evaluationDate) async {
    if (evaluationDate.date == null) return;
    Settings s = await SettingsService.loadSettings();
    Evaluation? evaluation = await EvaluationService.findById(evaluationDate.evaluationId);
    if (!s.evaluationReminder) return;
    TimeOfDay reminderTime = s.evaluationReminderTime;
    DateTime scheduledDate = _calculateScheduledTime(
      evaluationDate.date!,
      dayOffset: -1,
      timeOfDay: reminderTime,
    );
    if (scheduledDate.isBefore(DateTime.now())) return;
    await _schedule(
      id: uuidToInt("${evaluationDate.id}-evaluationReminder"),
      title: "Morgen: ${evaluation?.name ?? 'Prüfung'}",
      body: "Vergiss nicht auszuschlafen!",
      scheduled: scheduledDate,
      tag: "evaluationReminder",
      payload: "evaluationReminder:${evaluationDate.id}",
    );
  }
  static Future<void> _scheduleMissingGradeReminder(EvaluationDate evaluationDate) async {
    if (evaluationDate.date == null || evaluationDate.note != null) return;
    Settings s = await SettingsService.loadSettings();
    Evaluation? evaluation = await EvaluationService.findById(evaluationDate.evaluationId);
    if (!s.missingGradeReminder) return;
    int delayDays = s.missingGradeReminderDelayDays;
    TimeOfDay reminderTime = s.missingGradeReminderTime;
    DateTime scheduledDate = _calculateScheduledTime(
      evaluationDate.date!,
      dayOffset: delayDays,
      timeOfDay: reminderTime,
    );
    if (scheduledDate.isBefore(DateTime.now())) return;
    await _schedule(
      id: uuidToInt("${evaluationDate.id}-missingGradeReminder"),
      title: "Hast du schon ${evaluation?.name ?? 'deine Prüfung'} zurückbekommen?",
      body: "Dann trag hier deine Note ein!",
      scheduled: scheduledDate,
      tag: "missingGradeReminder",
      payload: "missingGradeReminder:${evaluationDate.id}",
    );
  }

  // Core Scheduling Functionality
  static Future<void> showInstantNotification({int id = 0, required String title, String? body}) async {
    if (!_isInitialized) return;
    await _requestNotificationPermission();
    return notificationsPlugin.show(
      id,
      title,
      body,
      _notificationDetails(),
    );
  }
  static Future<void> _schedule({int id = 0, required String title, String? body, required DateTime scheduled, String? payload, String? tag}) async {
    debugPrint("Schedule Notification for ${scheduled.toString()} with title = $title");
    if (!_isInitialized) return;
    await _requestNotificationPermission();
    final TZDateTime tzScheduled = TZDateTime.from(scheduled, local);
    return notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduled,
      _notificationDetails(tag: tag),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }
  static void _cancelNotification(String evaluationDateId, {String? tag}) {
    notificationsPlugin.cancel(uuidToInt(evaluationDateId), tag: tag);
  }

  // Permission
  static final Lock _permissionLock = Lock();
  static Future<void> _requestNotificationPermission() async {
    if (!await Permission.notification.isDenied && !await Permission.notification.isPermanentlyDenied) {
      return;
    }
    await _permissionLock.synchronized(() async {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      } else if (await Permission.notification.isPermanentlyDenied) {
        await openAppSettings();
      }
    });
  }

  // Payload Handler
  static Future<void> _handleNotificationTap(String payload) async {
    if (payload.startsWith("evaluationReminder:")) {
      String evaluationId = payload.split(":")[1];
      EvaluationDate? evaluationDate = await EvaluationDateService.findById(evaluationId);
      Evaluation? evaluation = await EvaluationService.findById(evaluationDate.evaluationId);
      if (evaluation == null) return;
      Subject? subject = await SubjectService.findById(evaluation.subjectId);
      if (subject == null) return;
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => SubjectPage(subjectId: subject.id),
        ),
      );
    }
    if (payload.startsWith("missingGradeReminder:")) {
      String evaluationId = payload.split(":")[1];
      EvaluationDate evaluationDate = await EvaluationDateService.findById(evaluationId);
      Evaluation? evaluation = await EvaluationService.findById(evaluationDate.evaluationId);
      if (evaluation == null) return;
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => EvaluationInputPage(evaluation: evaluation),
        ),
      );
    }
  }

  // Helpers
  static NotificationDetails _notificationDetails({String? tag}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        "abitur_channel_id",
        "Abitur",
        channelDescription: "Abitur Channel",
        importance: Importance.max,
        priority: Priority.high,
        tag: tag,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }
  static DateTime _calculateScheduledTime(DateTime baseDate, {int dayOffset = 0, TimeOfDay timeOfDay = const TimeOfDay(hour: 0, minute: 0)}) {
    return baseDate.add(Duration(days: dayOffset)).copyWith(
      hour: timeOfDay.hour,
      minute: timeOfDay.minute,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
  }
}