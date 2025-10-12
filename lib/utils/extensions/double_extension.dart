import 'dart:math';

extension DoubleExtension on double {
  String withDecimals(int decimals) {
    final factor = pow(10, decimals);
    final value = (this * factor).round() / factor;
    return value.toStringAsFixed(decimals);
  }
}