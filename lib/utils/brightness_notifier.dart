import 'package:abitur/storage/storage.dart';
import 'package:flutter/material.dart';

class BrightnessNotifier extends ChangeNotifier with WidgetsBindingObserver {
  ThemeMode _themeMode = Storage.loadSettings().themeMode;

  BrightnessNotifier() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  Brightness get currentBrightness {
    switch (_themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
      // Du kannst hier evtl. mit MediaQuery arbeiten oder einen Default setzen
        return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
  }

  @override
  void didChangePlatformBrightness() {
    if (_themeMode == ThemeMode.system) {
      notifyListeners();
    }
  }
}

