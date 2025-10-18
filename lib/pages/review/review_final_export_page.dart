import 'dart:io';
import 'dart:typed_data';

import 'package:abitur/pages/review/review_data.dart';
import 'package:abitur/utils/extensions/int_extension.dart';
import 'package:abitur/utils/extensions/lists/nullable_num_list_extension.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'image_generator.dart';


class ReviewFinalExportPage extends StatefulWidget {

  final ReviewData data;

  const ReviewFinalExportPage({super.key, required this.data});

  @override
  State<ReviewFinalExportPage> createState() => _ReviewFinalExportPageState();
}

class _ReviewFinalExportPageState extends State<ReviewFinalExportPage> {
  final GlobalKey repaintKey = GlobalKey();
  Uint8List? imageBytes;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateImage();
    });
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
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Theme.of(context).colorScheme.inverseSurface, spreadRadius: 2, blurRadius: 4, offset: Offset(0, 0)),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: imageBytes == null ? AspectRatio(
                aspectRatio: ImageGenerator.width / ImageGenerator.height,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                  width: double.infinity,
                ),
              ) : Image.memory(imageBytes!),
            ),
          ),
          FilledButton.icon(
            onPressed: () async {
              await _generateImage();
              // Hier könntest du z.B. das Bild teilen, in der Galerie speichern etc.
              // Für Debugzwecke:
              debugPrint("Bild generiert mit ${imageBytes?.length} bytes.");
              _shareImage();
            },
            icon: Icon(Icons.share),
            label: const Text("Bild erstellen & teilen"),
          )
        ],
      ),
    );
  }

  Future<void> _generateImage() async {
    final bestMonth = widget.data.monthAverages.indexOfMax();
    final startMonth = widget.data.startMonth.month;
    final startYear = widget.data.startMonth.year;
    final totalMonth = startMonth - 1 + bestMonth; // 0-basierter Monat
    final bestMonthNumber = totalMonth % 12 + 1; // Monat 1..12
    final bestMonthYear = startYear + totalMonth ~/ 12;
    final bestMonthString = bestMonthNumber.monthShort();
    final data = AbiturImageData(
      title: "Mein Abi in Zahlen",
      cards: [
        InfoCard("Bester Wochentag", (widget.data.weekdayAverages.indexOfMax()+1).weekday()),
        InfoCard("Bester Monat", "$bestMonthString $bestMonthYear"),
        InfoCard("Meistgeprüftes Fach", widget.data.subjectsSortedByEvaluationDescending.first.name),
        InfoCard("Anzahl Prüfungen", widget.data.evaluationDates.length.toString()),
      ],
      pieData: widget.data.evaluationTypeUses.entries.map((entry) {
        return PieSlice(entry.key, entry.value.toDouble());
      }).toList(),
    );
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bytes = await ImageGenerator.generateImage(colorScheme, data);
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