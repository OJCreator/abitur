// import 'package:abitur/isolates/evaluation_date_isolates.dart';
// import 'package:abitur/isolates/serializer.dart';
// import 'package:abitur/storage/services/calendar_service.dart';
// import 'package:abitur/storage/services/notification_service.dart';
// import 'package:abitur/utils/constants.dart';
// import 'package:flutter/foundation.dart';
//
// import '../../isolates/models/evaluation_dates/evaluation_dates_model.dart';
// import '../../isolates/models/evaluation_dates/evaluation_dates_time_model.dart';
// import '../entities/calendar_event.dart';
// import '../entities/evaluation.dart';
// import '../entities/evaluation_date.dart';
// import '../entities/subject.dart';
// import '../storage.dart';
//
// class CalendarEventService {
//
//   static List<CalendarEvent> findAll() {
//     List<CalendarEvent> calendarEvents = Storage.loadCalendarEvents();
//     return calendarEvents;
//   }
//   static CalendarEvent? findById(String id) {
//     return Storage.loadCalendarEvent(id);
//   }
//   static List<CalendarEvent> findAllById(List<String> ids) {
//     return ids.map((id) => Storage.loadCalendarEvent(id)).whereType<CalendarEvent>().toList();
//   }
//   static List<CalendarEvent> findAllByDay(DateTime day) {
//     return findAll().where((e) => (e.from?.isBefore(day) ?? false || (e.from?.isOnSameDay(day) ?? false)) && (e.to?.isAfter(day) ?? false || (e.to?.isOnSameDay(day) ?? false))).toList();
//   }
//
//   static Future<void> buildFromJson(List<Map<String, dynamic>> jsonData) async {
//
//     deleteAllCalendarEvents(findAll());
//
//     List<CalendarEvent> events = jsonData.map((e) => CalendarEvent.fromJson(e)).toList();
//     for (CalendarEvent e in events) {
//       await Storage.saveCalendarEvent(e);
//     }
//   }
// }