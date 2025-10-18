import 'package:flutter/cupertino.dart';

class SeedNotifier extends ChangeNotifier {
  Color _seed;

  SeedNotifier({required Color seed}):
        _seed = seed;

  Color get seed => _seed;
  set seed(Color newSeed) {
    _seed = newSeed;
    notifyListeners();
  }
}
