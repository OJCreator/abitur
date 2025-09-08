// import 'package:abitur/storage/entities/graduation/graduation_evaluation.dart';
// import 'package:abitur/storage/services/graduation_service.dart';
// import 'package:hive/hive.dart';
//
// import '../../isolates/serializer.dart';
// import '../../utils/uuid.dart';
// import '../services/evaluation_date_service.dart';
// import 'evaluation_date.dart';
//
// part 'calendar_event.g.dart';
//
// @HiveType(typeId: 10)
// class CalendarEvent implements Serializable {
//
//   @HiveField(0)
//   String id;
//
//   @HiveField(1)
//   String _calendarEventType;
//   GraduationEvaluationType get calendarEventType => GraduationEvaluationType.fromCode(_calendarEventType);
//   set calendarEventType(GraduationEvaluationType newGraduationEvaluationType) => _calendarEventType = newGraduationEvaluationType.code;
//
//   @HiveField(2)
//   DateTime? from;
//
//   @HiveField(3)
//   DateTime? to;
//
//   @HiveField(4)
//   String? deviceCalendarId;
//
//   @HiveField(5)
//   String description;
//
//   @HiveField(6)
//   String? _connectedEvaluationDateId;
//   String? get connectedEvaluationDateId => _connectedEvaluationDateId;
//   EvaluationDate? get connectedEvaluationDate => _connectedEvaluationDateId == null ? null : EvaluationDateService.findById(_connectedEvaluationDateId!);
//   set connectedEvaluationDate(EvaluationDate? newEvaluationDate) => _connectedEvaluationDateId = newEvaluationDate?.id;
//
//   @HiveField(7)
//   String? _connectedGraduationEvaluationId;
//   String? get connectedGraduationEvaluationId => _connectedGraduationEvaluationId;
//   GraduationEvaluation? get connectedGraduationEvaluation => _connectedGraduationEvaluationId == null ? null : GraduationService.findEvaluationById(_connectedGraduationEvaluationId!);
//   set connectedGraduationEvaluation(GraduationEvaluation? newGraduationEvaluation) => _connectedGraduationEvaluationId = newGraduationEvaluation?.id;
//
//
//
//
//   CalendarEvent({
//     String? id,
//     CalendarEventType calendarEventType = CalendarEventType.custom,
//     this.from,
//     this.to,
//     this.deviceCalendarId,
//     this.description = "",
//     String connectedEvaluationDateId = "",
//     String connectedGraduationEvaluationId = "",
//   }) : id = id ?? Uuid.generate(),
//         _calendarEventType = calendarEventType.code,
//         _connectedEvaluationDateId = connectedEvaluationDateId,
//         _connectedGraduationEvaluationId = connectedGraduationEvaluationId;
//
//
//   static CalendarEvent empty() {
//     return CalendarEvent();
//   }
//   @override
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "calendarEventType": _calendarEventType,
//     "from": from.toString(),
//     "to": to.toString(),
//     "deviceCalendarId": deviceCalendarId,
//     "connectedEvaluationDateId": _connectedEvaluationDateId,
//     "connectedGraduationEvaluationId": _connectedGraduationEvaluationId,
//   };
//
//   static CalendarEvent fromJson(Map<String, dynamic> json) {
//     return CalendarEvent(
//       id: json["id"],
//       calendarEventType: CalendarEventType.fromCode(json["calendarEventType"]),
//       from: json["from"] == "null" ? null : DateTime.parse(json["from"]),
//       to: json["to"] == "null" ? null : DateTime.parse(json["to"]),
//       deviceCalendarId: json["deviceCalendarId"],
//       description: json["description"],
//       connectedEvaluationDateId: json["connectedEvaluationDateId"],
//       connectedGraduationEvaluationId: json["connectedGraduationEvaluationId"],
//     );
//   }
// }
//
// enum CalendarEventType {
//   evaluationDate("Prüfung"),
//   graduationEvaluation("Abschlussprüfung"),
//   holiday("Ferien"),
//   custom("Nutzerspezifisch");
//
//   final String name;
//   String get code => toString().split('.').last;
//
//   const CalendarEventType(this.name);
//
//   static CalendarEventType fromCode(String code) {
//     return CalendarEventType.values.firstWhere((type) => type.code == code,
//       orElse: () => throw ArgumentError("Invalid CalendarEventType code: $code"),
//     );
//   }
// }