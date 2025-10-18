import 'package:abitur/isolates/serializer.dart';
import 'package:flutter/material.dart';

import '../../../utils/uuid.dart';

class TimetableTime implements Serializable {

  final String id;

  int slot;
  TimeOfDay from;
  TimeOfDay to;

  TimetableTime({
    String? id,
    required this.slot,
    required this.from,
    required this.to
  }) : id = id ?? Uuid.generate();

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "slot": slot,
    "from": from.hour * 60 + from.minute,
    "to": to.hour * 60 + to.minute,
  };

  static TimetableTime fromJson(Map<String, dynamic> json) {
    return TimetableTime(
      id: json["id"],
      slot: json["slot"],
      from: TimeOfDay(hour: json["from"] ~/ 60, minute: json["from"] % 60),
      to: TimeOfDay(hour: json["to"] ~/ 60, minute: json["to"] % 60),
    );
  }
}