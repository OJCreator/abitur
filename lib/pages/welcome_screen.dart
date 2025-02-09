import 'dart:convert';
import 'dart:io';

import 'package:abitur/main.dart';
import 'package:abitur/pages/setup_pages/setup_land_page.dart';
import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/services/performance_service.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/services/timetable_service.dart';
import 'package:abitur/utils/brightness_notifier.dart';
import 'package:abitur/utils/seed_notifier.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../storage/services/subject_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Dein Weg zum Abitur",
              style: Theme.of(context).textTheme.headlineLarge
            ),
            SizedBox(height: 20),
            Text(
              "Plane, lerne und bereite dich optimal vor – alles an einem Ort.",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return SetupLandPage();
                  }),
                );
              },
              child: Text("Loslegen"),
            ),
            FilledButton.tonal(
              onPressed: () => _pickAndImportJson(context),
              child: Text("Daten importieren"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndImportJson(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["json"],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String fileContent = await file.readAsString();

        Map<String, dynamic> jsonData = jsonDecode(fileContent);

        await PerformanceService.buildFromJson((jsonData["performances"] as List).map((e) => e as Map<String, dynamic>).toList());
        await SubjectService.buildFromJson((jsonData["subjects"] as List).map((e) => e as Map<String, dynamic>).toList());
        await EvaluationService.buildFromJson((jsonData["evaluations"] as List).map((e) => e as Map<String, dynamic>).toList());
        await SettingsService.buildFromJson(jsonData["settings"] as Map<String, dynamic>);
        await TimetableService.buildFromJson(jsonData["timetable"] as Map<String, dynamic>);

        SettingsService.markWelcomeScreenAsViewed();

        // Theming
        Provider.of<BrightnessNotifier>(context, listen: false,).setBrightness(SettingsService.loadSettings().lightMode);
        Provider.of<SeedNotifier>(context, listen: false,).seed = SettingsService.loadSettings().accentColor;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return ScreenScaffolding();
          }),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Es gab einen Fehler beim Einlesen der Daten."),
        ),
      );
      print(e.toString());
    }
  }
}
