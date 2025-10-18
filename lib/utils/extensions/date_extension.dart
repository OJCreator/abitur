import 'package:abitur/utils/extensions/int_extension.dart';

extension DateExtension on DateTime {
  String format() {
    if (year == DateTime.now().year) {
      return "${weekday.weekday()}, $day.$month";
    }
    return "${weekday.weekday()}, $day.$month.$year";
  }
  String formatYear() {
    return "$year";
  }

  bool isOnSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  DateTime startOfDay() {
    return DateTime(year, month, day);
  }

  DateTime endOfDay() {
    return DateTime(year, month, day, 23, 59, 59, 999, 999);
  }
}