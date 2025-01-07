import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {

  static Future<List<Holiday>> loadHolidays(int year, int month) async { // TODO Ferien lokal speichern
    String path = "https://openholidaysapi.org/SchoolHolidays?countryIsoCode=DE&validFrom=$year-${month-1}-23&validTo=$year-${month+1}-07&languageIsoCode=DE&subdivisionCode=DE-BY";
    Uri url = Uri.parse(path);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // JSON-Daten parsen
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Holiday.fromJSON(e as Map<String, dynamic>)).toList();
      } else {
        print('Fehler: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Ein Fehler ist aufgetreten: $e');
      return [];
    }
  }
}

class Holiday {
  final DateTime begin;
  final DateTime end;
  final String name;

  Holiday.fromJSON(Map<String, dynamic> json)
      : begin = DateTime.parse(json["startDate"]),
        end = DateTime.parse(json["endDate"]),
        name = json["name"][0]["text"];
}