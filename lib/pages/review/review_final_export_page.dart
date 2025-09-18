import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'image_generator.dart';


class ReviewFinalExportPage extends StatefulWidget {
  const ReviewFinalExportPage({super.key});

  @override
  State<ReviewFinalExportPage> createState() => _ReviewFinalExportPageState();
}

class _ReviewFinalExportPageState extends State<ReviewFinalExportPage> {
  final GlobalKey repaintKey = GlobalKey();
  Uint8List? imageBytes;

  @override
  void initState() {
    _generateImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Theme.of(context).colorScheme.inverseSurface, spreadRadius: 2, blurRadius: 4, offset: Offset(0, 0)),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: imageBytes == null ? CircularProgressIndicator() : Image.memory(imageBytes!),
            ),
          ),
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
    final bytes = await ImageGenerator.generateImage();
    setState(() {
      imageBytes = bytes;
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