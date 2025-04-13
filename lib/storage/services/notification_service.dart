import 'package:abitur/pages/evaluation_pages/evaluation_edit_page.dart';
import 'package:abitur/storage/entities/settings.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart' as AppSettings;
import 'package:synchronized/synchronized.dart';

import '../../main.dart';
import '../../pages/subject_pages/subject_page.dart';
import '../../utils/constants.dart';
import '../entities/evaluation_date.dart';
import 'evaluation_date_service.dart';

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
  static void scheduleAllNotifications() {
    List<EvaluationDate> evaluationDates = EvaluationDateService.findAll();
    for (EvaluationDate e in evaluationDates) {
      scheduleNotificationsForEvaluation(e);
    }
  }
  static void scheduleNotificationsForEvaluation(EvaluationDate evaluationDate) {
    _scheduleEvaluationReminder(evaluationDate);
    _scheduleMissingGradeReminder(evaluationDate);
  }
  static void cancelEvaluationNotifications(EvaluationDate evaluationDate) {
    _cancelNotification(evaluationDate, tag: "evaluationReminder");
    _cancelNotification(evaluationDate, tag: "missingGradeReminder");
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
      _cancelNotification(e, tag: "evaluationReminder");
    }
  }
  static void cancelOnlyMissingGradeReminders(List<EvaluationDate> evaluationDates) {
    for (EvaluationDate e in evaluationDates) {
      _cancelNotification(e, tag: "missingGradeReminder");
    }
  }

  // Private Scheduling Helpers
  static Future<void> _scheduleEvaluationReminder(EvaluationDate evaluationDate) async {
    if (evaluationDate.date == null || evaluationDate.date!.isBefore(DateTime.now())) return;
    Settings s = SettingsService.loadSettings();
    if (!s.evaluationReminder) return;
    int reminderTime = s.evaluationReminderTimeInMinutes;
    DateTime scheduledDate = _calculateScheduledTime(
      evaluationDate.date!,
      dayOffset: -1,
      minutes: reminderTime,
    );
    if (scheduledDate.isBefore(DateTime.now())) return;
    await _schedule(
      id: uuidToInt("${evaluationDate.id}-evaluationReminder"),
      title: "Morgen: ${evaluationDate.evaluation.name}",
      body: "Vergiss nicht auszuschlafen!",
      scheduled: scheduledDate,
      tag: "evaluationReminder",
      payload: "evaluationReminder:${evaluationDate.id}",
    );
  }
  static Future<void> _scheduleMissingGradeReminder(EvaluationDate evaluationDate) async {
    if (evaluationDate.date == null) return;
    Settings s = SettingsService.loadSettings();
    if (!s.missingGradeReminder) return;
    int delayDays = s.missingGradeReminderDelayDays;
    int reminderTime = s.missingGradeReminderTimeInMinutes;
    DateTime scheduledDate = _calculateScheduledTime(
      evaluationDate.date!,
      dayOffset: delayDays,
      minutes: reminderTime,
    );
    if (scheduledDate.isBefore(DateTime.now())) return;
    await _schedule(
      id: uuidToInt("${evaluationDate.id}-missingGradeReminder"),
      title: "Hast du schon ${evaluationDate.evaluation.name} zurückbekommen?",
      body: "Dann trag hier deine Note ein!",
      scheduled: scheduledDate,
      tag: "missingGradeReminder",
      payload: "missingGradeReminder:${evaluationDate.id}",
    );
  }

  // Core Scheduling Functionality
  static Future<void> _showInstantNotification({int id = 0, required String title, String? body}) async {
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
  static void _cancelNotification(EvaluationDate evaluationDate, {String? tag}) {
    notificationsPlugin.cancel(uuidToInt(evaluationDate.id), tag: tag);
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
        await AppSettings.openAppSettings();
      }
    });
  }

  // Payload Handler
  static void _handleNotificationTap(String payload) {
    if (payload.startsWith("evaluationReminder:")) {
      String evaluationId = payload.split(":")[1];
      EvaluationDate? evaluationDate = EvaluationDateService.findById(evaluationId);
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => SubjectPage(subject: evaluationDate.evaluation.subject),
        ),
      );
    }
    if (payload.startsWith("missingGradeReminder:")) {
      String evaluationId = payload.split(":")[1];
      EvaluationDate evaluationDate = EvaluationDateService.findById(evaluationId);
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => EvaluationEditPage(evaluation: evaluationDate.evaluation),
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
  static DateTime _calculateScheduledTime(DateTime baseDate, {int dayOffset = 0, int minutes = 0}) {
    return baseDate.copyWith(
      hour: minutes ~/ 60,
      minute: minutes % 60,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
  }
}