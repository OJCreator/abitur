import 'package:abitur/storage/storage.dart';
import 'package:flutter/material.dart';

class BrightnessNotifier extends ChangeNotifier {
  bool _isLightMode = Storage.loadSettings().lightMode;

  bool get isLightMode => _isLightMode;

  void setBrightness(bool isLightMode) {
    _isLightMode = isLightMode;
    notifyListeners();
  }

  Brightness get currentBrightness {
    return _isLightMode ? Brightness.light : Brightness.dark;
  }
}
