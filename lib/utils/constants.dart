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
      case 1: return "Montag";
      case 2: return "Dienstag";
      case 3: return "Mittwoch";
      case 4: return "Donnerstag";
      case 5: return "Freitag";
      case 6: return "Samstag";
      default: return "Sonntag";
    }
  }
}

double? avg(Iterable<int?> values) {
  Iterable<int> v = values.where((i) => i != null).cast<int>();
  if (v.isEmpty) {
    return null;
  }
  int sum = v.reduce((a, b) => a + b);
  return sum / v.length;
}
int? roundNote(double? average) {
  if (average != null && average < 1.0) {
    return 0;
  }
  return average?.round();
}
double abiturAvg(int points) {
  if (points >= 823) {
    return 1.0;
  } if (points >= 805) {
    return 1.1;
  } if (points >= 787) {
    return 1.2;
  } if (points >= 769) {
    return 1.3;
  } if (points >= 751) {
    return 1.4;
  } if (points >= 733) {
    return 1.5;
  } if (points >= 715) {
    return 1.6;
  } if (points >= 697) {
    return 1.7;
  } if (points >= 679) {
    return 1.8;
  } if (points >= 661) {
    return 1.9;
  } // AB 2.0
  if (points >= 643) {
    return 2.0;
  } if (points >= 625) {
    return 2.1;
  } if (points >= 607) {
    return 2.2;
  } if (points >= 589) {
    return 2.3;
  } if (points >= 571) {
    return 2.4;
  } if (points >= 553) {
    return 2.5;
  } if (points >= 535) {
    return 2.6;
  } if (points >= 517) {
    return 2.7;
  } if (points >= 499) {
    return 2.8;
  } if (points >= 481) {
    return 2.9;
  } // AB 3.0
  if (points >= 463) {
    return 3.0;
  } if (points >= 445) {
    return 3.1;
  } if (points >= 427) {
    return 3.2;
  } if (points >= 409) {
    return 3.3;
  } if (points >= 391) {
    return 3.4;
  } if (points >= 373) {
    return 3.5;
  } if (points >= 355) {
    return 3.6;
  } if (points >= 337) {
    return 3.7;
  } if (points >= 319) {
    return 3.8;
  } if (points >= 301) {
    return 3.9;
  } // AB 4.0
  if (points == 300) {
    return 4.0;
  }
  return 6.0;
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
  double luminance = (0.299 * backgroundColor.r +
      0.587 * backgroundColor.g +
      0.114 * backgroundColor.b) / 255;

  return luminance > 0.5 ? Colors.black : Colors.white;
}
// EXTENSIONS
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
}
// LIST EXTENSIONS
extension NullableListExtensions<T> on List<T?> {
  void setSafe(int index, T? value) {
    if (index < 0) {
      return;
    }
    if (index >= length) {
      addAll(List<T?>.filled(index - length + 1, null));
    }
    this[index] = value;
  }
}
extension ListExtensions<T> on List<T> {
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) {
      return null;
    }
    return this[index];
  }
  List<int> indicesOf(T value) {
    List<int> indices = [];
    for (int i = 0; i < length; i++) {
      if (this[i] == value) {
        indices.add(i);
      }
    }
    return indices;
  }
  List<int> indicesWhere(bool Function(T element) test) {
    List<int> indices = [];
    for (int i = 0; i < length; i++) {
      if (test(this[i])) {
        indices.add(i);
      }
    }
    return indices;
  }
  /// Zählt die Elemente, die der Bedingung [test] entsprechen.
  int countWhere(bool Function(T element) test) {
    return where(test).length;
  }
  /// Summiert die Werte, die durch die Transformationsfunktion [selector] bestimmt werden.
  num sumBy(num Function(T element) selector) {
    return fold(0, (previousValue, element) => previousValue + selector(element));
  }
}
extension FindNLargestIndices on List<int?> {
  List<int> findNLargestIndices(int n) {
    // Liste von Paaren (Index, Wert), wobei nur nicht-null-Werte berücksichtigt werden
    List<MapEntry<int, int>> nonNullEntries = asMap()
        .entries
        .where((entry) => entry.value != null)
        .map((entry) => MapEntry(entry.key, entry.value!))
        .toList();

    // Sortiere die nicht-null-Werte absteigend nach Wert
    nonNullEntries.sort((a, b) => b.value.compareTo(a.value));

    // Indizes der größten nicht-null-Werte
    List<int> result = nonNullEntries.take(n).map((entry) => entry.key).toList();

    // Falls wir noch weitere Indizes brauchen, füge die ersten null-Indizes hinzu
    if (result.length < n) {
      List<int> nullIndices = asMap()
          .entries
          .where((entry) => entry.value == null)
          .map((entry) => entry.key)
          .toList();

      result.addAll(nullIndices.take(n - result.length));
    }

    return result;
  }
}
extension ExpandToList<E> on Iterable<Iterable<E>> {
  /// Kombiniert verschachtelte Listen zu einer flachen Liste.
  List<E> expandToList() => expand((list) => list).toList();
}
extension Sum<E> on Iterable<num> {
  /// Summiert die Werte einer Liste an Zahlen
  num sum() {
    return toList().sumBy((i) => i);
  }
}