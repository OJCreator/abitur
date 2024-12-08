import 'package:abitur/storage/storage.dart';
import 'package:abitur/utils/pair.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

const Color primaryColor = Color(0xFF3C5C80);
const Color _lightGrey = Color(0xFFCCCCD4);
const Color _darkGrey = Color(0xFF333344);

Color get secondShade {
  return Storage.loadSettings().lightMode ? _lightGrey : _darkGrey;
}


extension IterableExtension<T> on Iterable<T> {
  Map<T, U> mapWith<U>(U Function(T element) transform) {
    return {for (var element in this) element: transform(element)};
  }
}
extension ListExtension<T> on List<T> {
  List<T> maxSize(int maxSize) {
    if (length <= maxSize) {
      return this;
    }
    return getRange(0, maxSize).toList();
  }
}
extension MapToIterableExtension<K, V> on Map<K, V> {
  Iterable<T> mapToIterable<T>(T Function(K key, V value) transform) {
    return entries.map((entry) => transform(entry.key, entry.value));
  }
}
extension RoundGradeExtenstion on double {
  int roundGrade() {
    return round();
  }
}
extension ColorExtension on Color {
  static Color parse(String color) {
    if (color.startsWith('#')) {
      return _parseHex(color);
    } else if (color.startsWith('rgb')) {
      return _parseRgb(color);
    }
    throw FormatException("Unsupported color format");
  }

  String toHexString({bool includeHashSign = false, bool enableAlpha = true, bool toUpperCase = true}) =>
      colorToHex(this, includeHashSign: includeHashSign, enableAlpha: enableAlpha, toUpperCase: toUpperCase);

  static Color _parseHex(String hex) {
    // Handle short format (e.g., #RGB)
    if (hex.length == 4) {
      String r = hex[1];
      String g = hex[2];
      String b = hex[3];
      hex = '#${r+r}${g+g}${b+b}'; // Convert to #RRGGBB
    }

    // Handle full format (e.g., #RRGGBB)
    if (hex.length == 7) {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    }
    throw FormatException("Invalid hex color");
  }

  static Color _parseRgb(String rgb) {
    final rgbPattern = RegExp(r'^\s*rgb\s*\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*\)\s*$');
    final match = rgbPattern.firstMatch(rgb);
    if (match != null) {
      int r = int.parse(match.group(1)!);
      int g = int.parse(match.group(2)!);
      int b = int.parse(match.group(3)!);

      return Color.fromARGB(255, r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255));
    }
    throw FormatException("Invalid RGB color format");
  }
}
extension IntExtension on int {
  String weekday() {
    switch (this) {
      case 0: return "Montag";
      case 1: return "Dienstag";
      case 2: return "Mittwoch";
      case 3: return "Donnerstag";
      case 4: return "Freitag";
      case 5: return "Samstag";
      default: return "Sonntag";
    }
  }
}
extension DateExtension on DateTime {
  String format() {
    return "${_weekday()}, $day.$month";
  }
  String formatYear() {
    return "$year";
  }

  bool isOnSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  String _weekday() {
    switch (weekday) {
      case 1: return "Mo";
      case 2: return "Di";
      case 3: return "Mi";
      case 4: return "Do";
      case 5: return "Fr";
      case 6: return "Sa";
      default: return "So";
    }
  }
}
double? avg(Iterable<int?> values) {
  Iterable<int> v = values.skipWhile((i) => i == null).cast<int>();
  if (v.isEmpty) {
    return null;
  }
  int sum = v.reduce((a, b) => a + b);
  return sum / values.length;
}
int? roundNote(double? average) {
  return average?.round();
}
double? weightedAvg(Iterable<Pair<double, double?>> weightAndValue) {

  if (weightAndValue.isEmpty) {
    return 0;
  }

  double totalWeight = 0;
  double weightedSum = 0;

  for (var pair in weightAndValue) {
    double weight = pair.first;
    double? value = pair.second;

    if (value == null) {
      continue;
    }

    weightedSum += weight * value;
    totalWeight += weight;
  }

  return totalWeight == 0 ? null : weightedSum / totalWeight;
}
Color getContrastingTextColor(Color backgroundColor) {
  double luminance = (0.299 * backgroundColor.red +
      0.587 * backgroundColor.green +
      0.114 * backgroundColor.blue) / 255;

  return luminance > 0.5 ? Colors.black : Colors.white;
}

// LIST EXTENSIONS
extension SafeAccess<T> on List<T> {
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) {
      return null;
    }
    return this[index];
  }
}
extension SafeSetList<T> on List<T?> {
  void setSafe(int index, T? value) {
    if (index >= length) {
      addAll(List<T?>.filled(index - length + 1, null));
    }
    this[index] = value;
  }
}
extension ListExtensions<T> on List<T> {
  List<int> indicesOf(T value) {
    List<int> indices = [];
    for (int i = 0; i < length; i++) {
      if (this[i] == value) {
        indices.add(i);
      }
    }
    return indices;
  }
}
