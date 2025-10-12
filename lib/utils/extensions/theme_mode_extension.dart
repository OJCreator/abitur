import 'package:flutter/material.dart';

extension ThemeModeExtension on ThemeMode {
  String get label {
    switch(this) {
      case ThemeMode.system:
        return "System";
      case ThemeMode.light:
        return "Hell";
      case ThemeMode.dark:
        return "Dunkel";
    }
  }
}