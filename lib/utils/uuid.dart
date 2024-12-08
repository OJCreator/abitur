import 'dart:math';

class Uuid {

  static String generate() {

    final random = Random();
    const hexDigits = '0123456789abcdef';

    String uuid = '';

    for (int i = 0; i < 8; i++) {
      uuid += hexDigits[random.nextInt(16)];
    }
    uuid += '-';
    for (int i = 0; i < 4; i++) {
      uuid += hexDigits[random.nextInt(16)];
    }
    uuid += '-4'; // Version 4
    for (int i = 0; i < 3; i++) {
      uuid += hexDigits[random.nextInt(16)];
    }
    uuid += '-';
    uuid += hexDigits[random.nextInt(4) + 8]; // 8, 9, A, or B
    for (int i = 0; i < 3; i++) {
      uuid += hexDigits[random.nextInt(16)];
    }
    uuid += '-';
    for (int i = 0; i < 12; i++) {
      uuid += hexDigits[random.nextInt(16)];
    }

    return uuid;
  }
}