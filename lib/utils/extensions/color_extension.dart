import 'package:flutter/cupertino.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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

  List<Color> generatePalette(int count) {
    final hslBase = HSLColor.fromColor(this);
    return List.generate(count, (index) {
      final lightness = 0.3 + (0.5 * index / (count - 1));
      return hslBase.withLightness(lightness).toColor();
    });
  }
}