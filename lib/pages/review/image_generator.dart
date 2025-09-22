import 'dart:math';
import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/constants.dart';

class AbiturImageData {
  final String title;
  final List<InfoCard> cards;
  final List<PieSlice> pieData;

  AbiturImageData({
    required this.title,
    required this.cards,
    required this.pieData,
  });
}

class InfoCard {
  final String title;
  final String value;
  InfoCard(this.title, this.value);
}

class PieSlice {
  final String label;
  final double value;

  PieSlice(this.label, this.value);
}

class ImageGenerator {
  static const double width = 1080;
  static const double height = 1920;

  static Future<Uint8List> generateImage(
      ColorScheme colorScheme,
      AbiturImageData data,
      ) async {
    final backgroundColor = colorScheme.surface;
    final foregroundColors = colorScheme.surface.generatePalette(4);

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    // Hintergrund
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = backgroundColor,
    );

    // Titel
    _drawText(
      canvas,
      data.title,
      offset: const Offset(width / 2, 100),
      style: TextStyle(
        fontSize: 80,
        color: getContrastingTextColor(backgroundColor),
        fontWeight: FontWeight.bold,
      ),
    );

    // Karten zeichnen (max. 4)
    _drawCards(canvas, data.cards, foregroundColors);

    // PieChart zeichnen
    _drawPieChart(canvas, data.pieData, const Offset(width / 2, 1400), 350, foregroundColors);

    // Logo
    await _drawLogo(canvas, "assets/abitur_icon.png", getContrastingTextColor(backgroundColor));

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.round(), height.round());
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static void _drawCards(Canvas canvas, List<InfoCard> cards, List<Color> colors) {
    final rectWidth = 430.0;
    final rectHeight = rectWidth * 0.7;
    final rectDistance = (width / 2 - rectWidth) / 1.5;
    final rectMarginTop = 290.0;

    for (int i = 0; i < cards.length && i < 4; i++) {
      final row = i ~/ 2;
      final col = i % 2;
      final x = (col + 1) * rectDistance + col * rectWidth;
      final y = rectMarginTop + row * (rectHeight + rectDistance);

      final card = cards[i];
      final color = colors[i % colors.length];

      _drawRoundedRect(canvas, Offset(x, y), rectWidth, rectHeight, color);

      _drawText(
        canvas,
        card.title,
        offset: Offset(x + rectWidth / 2, y + 30),
        style: TextStyle(
          color: getContrastingTextColor(color),
          fontSize: 45,
        ),
      );
      _drawText(
        canvas,
        card.value,
        offset: Offset(x + rectWidth / 2, y + (rectHeight - 30) / 2),
        style: TextStyle(
          color: getContrastingTextColor(color),
          fontSize: 70,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  static void _drawPieChart(
      Canvas canvas,
      List<PieSlice> slices,
      Offset center,
      double radius,
      List<Color> foregroundColors,
      ) {

    slices.sort((a,b) => b.value.compareTo(a.value));

    final total = slices.fold<double>(0, (sum, e) => sum + e.value);
    double startAngle = -pi / 2;

    for (int i = 0; i < slices.length; i++) {
      final slice = slices[i];
      final sweep = (slice.value / total) * 2 * pi;
      final paint = Paint()..color = foregroundColors[i % foregroundColors.length];

      // Slice zeichnen
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        paint,
      );

      // Nur Label zeichnen, wenn >= 10%
      if (slice.value / total >= 0.1) {
        final midAngle = startAngle + sweep / 2;
        final labelRadius = radius * 0.6;

        final labelPos = Offset(
          center.dx + cos(midAngle) * labelRadius,
          center.dy + sin(midAngle) * labelRadius,
        );

        final textPainter = TextPainter(
          text: TextSpan(
            text: slice.label,
            style: TextStyle(
              color: getContrastingTextColor(paint.color),
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        // zentriert auf labelPos
        final textOffset = Offset(
          labelPos.dx - textPainter.width / 2,
          labelPos.dy - textPainter.height / 2,
        );

        textPainter.paint(canvas, textOffset);
      }

      startAngle += sweep;
    }
  }


  static Future<void> _drawLogo(Canvas canvas, String path, Color textColor) async {
    const double imgHeight = 75;
    const double imgWidth = 75;

    final data = await rootBundle.load(path);
    final codec = await instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final pos = Offset(20, height - imgHeight - 20);
    final dst = Rect.fromLTWH(pos.dx, pos.dy, imgWidth, imgHeight);
    final rrect = RRect.fromRectAndRadius(dst, Radius.circular(20));

    canvas.save();
    canvas.clipRRect(rrect);

    final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    canvas.drawImageRect(image, src, dst, Paint());
    canvas.restore();

    final textPainter = TextPainter(
      text: TextSpan(text: "Abitur", style: TextStyle(color: textColor, fontSize: 40)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final textOffset = Offset(pos.dx + imgHeight + 10, pos.dy + (imgHeight - textPainter.height) / 2);
    textPainter.paint(canvas, textOffset);
  }

  static void _drawText(Canvas canvas, String text,
      {required Offset offset, TextStyle? style, bool center = true}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: style ??
            const TextStyle(
              color: Colors.white,
              fontSize: 150,
            ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    Offset pos;
    if (center) {
      pos = Offset(offset.dx - textPainter.width / 2, offset.dy);
    } else {
      pos = offset;
    }
    textPainter.paint(canvas, pos);
  }

  static void _drawRoundedRect(
      Canvas canvas,
      Offset offset,
      double width,
      double height,
      Color color,
      ) {
    final paint = Paint()..color = color;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, width, height),
      const Radius.circular(20),
    );
    canvas.drawRRect(rrect, paint);
  }
}
