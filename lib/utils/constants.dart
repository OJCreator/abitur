import 'dart:convert';

import 'package:abitur/utils/pair.dart';
import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFFB4E9FF);
const Color shimmerColor = Color(0x0D000000);

const String analyticsPageSortOptionPrefsKey = "analytics_subjects_page:sort_option";


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

int uuidToInt(String uuid) {
// Du kannst eine UUID in eine Zahl umwandeln, indem du z.B. den Hash-Code der UUID verwendest
  var bytes = utf8.encode(uuid); // UUID in Bytes umwandeln
  int hashCode = bytes.fold<int>(0, (prev, byte) => prev + byte); // Bytes zu einer Summe zusammenfassen
  return hashCode;
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
  double luminance = 0.299 * backgroundColor.r +
      0.587 * backgroundColor.g +
      0.114 * backgroundColor.b;

  return luminance > 0.5 ? Colors.black : Colors.white;
}