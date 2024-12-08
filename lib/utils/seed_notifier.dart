
import 'package:flutter/cupertino.dart';

import '../storage/storage.dart';

class SeedNotifier extends ChangeNotifier {
  Color _seed = Storage.loadSettings().accentColor;

  Color get seed => _seed;
  set seed(Color newSeed) {
    _seed = newSeed;
    notifyListeners();
  }
}
