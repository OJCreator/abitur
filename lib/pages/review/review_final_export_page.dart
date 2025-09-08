import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';


class ReviewFinalExportPage extends StatefulWidget {
  const ReviewFinalExportPage({super.key});

  @override
  State<ReviewFinalExportPage> createState() => _ReviewFinalExportPageState();
}

class _ReviewFinalExportPageState extends State<ReviewFinalExportPage> {
  final GlobalKey repaintKey = GlobalKey();
  Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          RepaintBoundary(
            key: repaintKey,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: AbiSummaryWidget(
                abijahrgang: "2026",
                abischnitt: "1,4",
                topFaecherLeft: ["Englisch", "Mathe", "Kunst"],
                topFaecherRight: ["Deutsch", "Physik", "Geschichte"],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await _generateImage();
              // Hier könntest du z.B. das Bild teilen, in der Galerie speichern etc.
              // Für Debugzwecke:
              print("Bild generiert mit ${imageBytes?.length} bytes.");
              _shareImage();
            },
            child: const Text("Bild erstellen & teilen"),
          )
        ],
      ),
    );
  }

  Future<void> _generateImage() async {
    final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    if (byteData == null) return;

    setState(() {
      imageBytes = byteData.buffer.asUint8List();
    });
  }

  Future<void> _shareImage() async {
    if (imageBytes == null) return;

    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/summary.png').create();
    await file.writeAsBytes(imageBytes!);

    await Share.shareXFiles([XFile(file.path)], text: "Mein Abitur Rückblick!");
  }
}
class AbiSummaryWidget extends StatelessWidget {
  final String abijahrgang;
  final String abischnitt;
  final List<String> topFaecherLeft;
  final List<String> topFaecherRight;

  const AbiSummaryWidget({
    super.key,
    required this.abijahrgang,
    required this.abischnitt,
    required this.topFaecherLeft,
    required this.topFaecherRight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // wächst mit Inhalt
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Abijahrgang $abijahrgang",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          "Abischnitt $abischnitt",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFachColumn("Deine Top-Fächer:", topFaecherLeft),
            _buildFachColumn("Deine Top-Fächer:", topFaecherRight),
          ],
        )
      ],
    );
  }

  Widget _buildFachColumn(String title, List<String> faecher) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...faecher.map((fach) => Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            fach,
            style: const TextStyle(fontSize: 18),
          ),
        )),
      ],
    );
  }
}
