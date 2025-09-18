import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageGenerator {

  static final double width = 1080;
  static final double height = 1920;

  static Future<Uint8List> generateImage() async {

    // DATA
    final Color backgroundColor = const Color(0xFFFFFDEA);
    final List<Color> foregroundColors = [
      Colors.yellow,
      Colors.blue,
      Colors.red,
      Colors.green,
    ];
    // END DATA

    final recorder = PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    );

    final paint = Paint()..color = backgroundColor;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      paint,
    );

    drawText(
      canvas,
      "Mein Abi in Zahlen",
      style: TextStyle(
        fontSize: 80,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      offset: Offset(width/2, 100),
    );
    
    await drawImage(canvas, "assets/abitur_icon.png", offset: Offset(20, 20), label: "Abitur");

    final double rectWidth = 430;
    final double rectHeight = rectWidth * 0.7;
    final double rectDistance = (width/2 - rectWidth) / 1.5;
    final double rectMarginTop = 290;
    drawRoundedRect(
      canvas,
      offset: Offset(rectDistance, rectMarginTop),
      width: rectWidth,
      height: rectHeight,
      color: foregroundColors[0],
    );
    drawRoundedRect(
      canvas,
      offset: Offset(2*rectDistance + rectWidth, rectMarginTop),
      width: rectWidth,
      height: rectHeight,
      color: foregroundColors[1],
    );
    drawRoundedRect(
      canvas,
      offset: Offset(rectDistance, rectHeight + rectDistance + rectMarginTop),
      width: rectWidth,
      height: rectHeight,
      color: foregroundColors[2],
    );
    drawRoundedRect(
      canvas,
      offset: Offset(2*rectDistance + rectWidth, rectHeight + rectDistance + rectMarginTop),
      width: rectWidth,
      height: rectHeight,
      color: foregroundColors[3],
    );

    drawText(canvas, "Bester Wochentag",
      offset: Offset(rectDistance + 0.5 * rectWidth, rectMarginTop + 30),
      style: TextStyle(
        color: Colors.black,
        fontSize: 45,
      ),
    );
    drawText(canvas, "Montag",
      offset: Offset(rectDistance + 0.5 * rectWidth, rectMarginTop + (rectHeight-30) / 2),
      style: TextStyle(
        color: Colors.black,
        fontSize: 70,
        fontWeight: FontWeight.bold,
      ),
    );

    drawText(canvas, "Bester Monat",
      offset: Offset(2*rectDistance + 1.5 * rectWidth, rectMarginTop + 30),
      style: TextStyle(
        color: Colors.black,
        fontSize: 45,
      ),
    );
    drawText(canvas, "Mai 2026",
      offset: Offset(2*rectDistance + 1.5 * rectWidth, rectMarginTop + (rectHeight-30) / 2),
      style: TextStyle(
        color: Colors.black,
        fontSize: 70,
        fontWeight: FontWeight.bold,
      ),
    );

    drawText(canvas, "Meistgeprüftes Fach",
      offset: Offset(rectDistance + 0.5 * rectWidth, rectMarginTop + rectDistance + rectHeight + 30),
      style: TextStyle(
        color: Colors.black,
        fontSize: 45,
      ),
    );
    drawText(canvas, "Mathematik",
      offset: Offset(rectDistance + 0.5 * rectWidth, rectMarginTop + rectDistance + rectHeight + (rectHeight-30) / 2),
      style: TextStyle(
        color: Colors.black,
        fontSize: 70,
        fontWeight: FontWeight.bold,
      ),
    );

    drawText(canvas, "Unterschied mdl / schr",
      offset: Offset(2*rectDistance + 1.5 * rectWidth, rectMarginTop + rectDistance + rectHeight + 30),
      style: TextStyle(
        color: Colors.black,
        fontSize: 45,
      ),
    );
    drawText(canvas, "0,64",
      offset: Offset(2*rectDistance + 1.5 * rectWidth, rectMarginTop + rectDistance + rectHeight + (rectHeight-30) / 2),
      style: TextStyle(
        color: Colors.black,
        fontSize: 70,
        fontWeight: FontWeight.bold,
      ),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.round(), height.round());

    final byteData = await img.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static Future<void> drawImage(
      Canvas canvas,
      String path,
      {Offset offset = const Offset(0, 0), double radius = 20, String? label, TextStyle? textStyle}) async {

    const double imgHeight = 75;
    const double imgWidth = 75;

    final data = await
    rootBundle.load(path);
    final codec = await instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final pos = Offset(0 + offset.dx, height - imgHeight - offset.dy);

    final dst = Rect.fromLTWH(pos.dx, pos.dy, imgWidth, imgHeight);
    final rrect = RRect.fromRectAndRadius(dst, Radius.circular(radius));

    canvas.save();
    canvas.clipRRect(rrect);

    final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    canvas.drawImageRect(image, src, dst, Paint());
    canvas.restore();

    if (label != null) {
      final textPainter = TextPainter(
        text: TextSpan(text: label, style: textStyle ?? TextStyle(color: Colors.black, fontSize: 40)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final textOffset = Offset(pos.dx + imgHeight + 10, pos.dy + (imgHeight - textPainter.height) / 2);
      textPainter.paint(canvas, textOffset);
    }
  }

  static void drawText(Canvas canvas, String text, {TextStyle? style, Offset offset = const Offset(100, 100), bool center = true}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: style ?? TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 150,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    Offset pos;
    if (center) {
      pos = Offset(offset.dx - (textPainter.width) / 2, offset.dy);
    } else {
      pos = offset;
    }
    textPainter.paint(canvas, pos);
  }

  static void drawRoundedRect(Canvas canvas, {
        required Offset offset,
        required double width,
        required double height,
        double radius = 20,
        Color color = Colors.blue,
      }) {
    final paint = Paint()..color = color;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, width, height),
      Radius.circular(radius),
    );

    canvas.drawRRect(rrect, paint);
  }
}
