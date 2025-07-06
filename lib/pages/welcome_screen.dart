import 'dart:convert';
import 'dart:io';

import 'package:abitur/main.dart';
import 'package:abitur/pages/setup_pages/setup_land_page.dart';
import 'package:abitur/storage/services/calendar_service.dart';
import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/services/evaluation_type_service.dart';
import 'package:abitur/storage/services/notification_service.dart';
import 'package:abitur/storage/services/performance_service.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/services/subject_category_service.dart';
import 'package:abitur/storage/services/timetable_service.dart';
import 'package:abitur/storage/storage.dart';
import 'package:abitur/utils/brightness_notifier.dart';
import 'package:abitur/utils/seed_notifier.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../storage/services/evaluation_date_service.dart';
import '../storage/services/graduation_service.dart';
import '../storage/services/subject_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  bool loading = false;

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
                if (loading) {
                  return;
                }
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
    if (loading) {
      return;
    }
    try {

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["json"],
      );

      if (result != null && result.files.single.path != null) {

        setState(() {
          loading = true;
        });

        File file = File(result.files.single.path!);
        String fileContent = await file.readAsString();

        Map<String, dynamic> jsonData = jsonDecode(fileContent);

        print("Extracted data from JSON...");
        await PerformanceService.buildFromJson((jsonData["performances"] as List).map((e) => e as Map<String, dynamic>).toList());
        print("Extracted Performances from JSON.");
        await SubjectService.buildFromJson((jsonData["subjects"] as List).map((e) => e as Map<String, dynamic>).toList());
        print("Extracted Subjects from JSON.");
        await SubjectCategoryService.buildFromJson((jsonData["subjectCategories"] as List).map((e) => e as Map<String, dynamic>).toList());
        print("Extracted SubjectCategories from JSON.");
        await EvaluationService.buildFromJson((jsonData["evaluations"] as List).map((e) => e as Map<String, dynamic>).toList());
        print("Extracted Evaluations from JSON.");
        await EvaluationDateService.buildFromJson((jsonData["evaluationDates"] as List).map((e) => e as Map<String, dynamic>).toList());
        print("Extracted EvaluationDates from JSON.");
        await EvaluationTypeService.buildFromJson((jsonData["evaluationTypes"] as List).map((e) => e as Map<String, dynamic>).toList());
        print("Extracted EvaluationTypes from JSON.");
        await SettingsService.buildFromJson(jsonData["settings"] as Map<String, dynamic>);
        print("Extracted Settings from JSON.");
        await GraduationService.buildFromJson((jsonData["graduationEvaluations"] as List).map((e) => e as Map<String, dynamic>).toList());
        print("Extracted GraduationEvaluations from JSON.");
        await TimetableService.buildSettingsFromJson(jsonData["timetableSettings"] as Map<String, dynamic>);
        print("Extracted TimetableSettings from JSON.");
        await TimetableService.buildTimetableFromJson((jsonData["timetables"] as List).map((e) => e as Map<String, dynamic>).toList());
        print("Extracted Timetables from JSON.");
        await TimetableService.buildEntriesFromJson((jsonData["timetableEntries"] as List).map((e) => e as Map<String, dynamic>).toList());
        print("Extracted TimetableEntries from JSON.");

        // Kalender und Notifications
        await CalendarService.syncAllEvaluationCalendarEvents();
        NotificationService.scheduleAllNotifications();

        SettingsService.markWelcomeScreenAsViewed();

        Storage.initialValues();

        // Theming
        Provider.of<BrightnessNotifier>(context, listen: false,).setThemeMode(SettingsService.loadSettings().themeMode);
        Provider.of<SeedNotifier>(context, listen: false,).seed = SettingsService.loadSettings().accentColor;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return ScreenScaffolding();
          }),
        );
      }
    } catch (e) {

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Es gab einen Fehler beim Einlesen der Daten."),
        ),
      );
      print(e.toString());
    }
  }
}
