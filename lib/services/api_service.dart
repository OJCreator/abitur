import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<List<Holiday>> loadHolidays(int year) async {
    Uri url = Uri.parse("https://ferien-api.de/api/v1/holidays/BY/$year");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final holidays =
        data.map((e) => Holiday.fromJSON(e as Map<String, dynamic>)).toList();

        // lokal speichern
        await HolidayStorage.saveHolidays(holidays, year);

        return holidays;
      } else {
        debugPrint("Fehler: ${response.statusCode}");
        return await HolidayStorage.loadHolidays(year); // Fallback offline
      }
    } catch (e) {
      debugPrint("Ein Fehler ist aufgetreten: $e");
      return await HolidayStorage.loadHolidays(year); // Fallback offline
    }
  }

  static Future<int> countSchoolDaysBetween(DateTime start, DateTime end) async {
    if (end.isBefore(start)) {
      throw ArgumentError("Enddatum darf nicht vor Startdatum liegen.");
    }

    // Alle Ferienjahre laden
    final List<Holiday> holidays = [];
    for (int year = start.year; year <= end.year; year++) {
      holidays.addAll(await loadHolidays(year));
    }

    // Alle Ferien-Tage sammeln
    final Set<DateTime> holidayDays = {};
    for (var h in holidays) {
      for (var d = h.begin;
      !d.isAfter(h.end);
      d = d.add(const Duration(days: 1))) {
        holidayDays.add(DateTime(d.year, d.month, d.day));
      }
    }

    // Zählen
    int count = 0;
    for (var d = DateTime(start.year, start.month, start.day);
    !d.isAfter(end);
    d = d.add(const Duration(days: 1))) {
      final weekday = d.weekday;
      final isWeekend = weekday == DateTime.saturday || weekday == DateTime.sunday;

      if (!isWeekend && !holidayDays.contains(d)) {
        count++;
      }
    }

    return count;
  }
}


class HolidayStorage {
  static const _key = "holidays";

  static Future<void> saveHolidays(List<Holiday> holidays, int year) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(holidays.map((h) => h.toJSON()).toList());
    await prefs.setString("${_key}_$year", data);
  }

  static Future<List<Holiday>> loadHolidays(int year) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString("${_key}_$year");
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => Holiday.fromJSON(e)).toList();
  }
}

class Holiday {
  final DateTime begin;
  final DateTime end;
  final String name;
  final String slug;
  final String stateCode;
  final int year;

  Holiday({
    required this.begin,
    required this.end,
    required this.name,
    required this.slug,
    required this.stateCode,
    required this.year,
  });

  factory Holiday.fromJSON(Map<String, dynamic> json) {
    return Holiday(
      begin: DateTime.parse(json["start"]),
      end: DateTime.parse(json["end"]),
      name: json["name"],
      slug: json["slug"],
      stateCode: json["stateCode"],
      year: json["year"],
    );
  }

  Map<String, dynamic> toJSON() => {
    "start": begin.toIso8601String(),
    "end": end.toIso8601String(),
    "name": name,
    "slug": slug,
    "stateCode": stateCode,
    "year": year,
  };
}