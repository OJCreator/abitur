import 'dart:convert';
import 'dart:io';

import 'package:abitur/main.dart';
import 'package:abitur/pages/setup_pages/setup_land_page.dart';
import 'package:abitur/services/calendar_service.dart';
import 'package:abitur/services/database/timetable_entry_service.dart';
import 'package:abitur/services/database/timetable_time_service.dart';
import 'package:abitur/services/notification_service.dart';
import 'package:abitur/utils/brightness_notifier.dart';
import 'package:abitur/utils/seed_notifier.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/database/evaluation_date_service.dart';
import '../services/database/evaluation_service.dart';
import '../services/database/evaluation_type_service.dart';
import '../services/database/graduation_evaluation_service.dart';
import '../services/database/performance_service.dart';
import '../services/database/settings_service.dart';
import '../services/database/subject_service.dart';
import '../sqlite/entities/settings.dart';

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
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                "Willkommen in deiner Abitur-App.",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
        
              ListTile(
                leading: Icon(Icons.remove_red_eye, color: Theme.of(context).colorScheme.primary, size: 32),
                title: Text(
                  "Behalte die Übersicht",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Über Prüfungen, Noten und Fächer"),
              ),
              ListTile(
                leading: Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary, size: 32),
                title: Text(
                  "Vergiss nie mehr einen Termin",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Du wirst automatisch an alles Wichtige erinnert"),
              ),
              ListTile(
                leading: Icon(Icons.query_stats, color: Theme.of(context).colorScheme.primary, size: 32),
                title: Text(
                  "Wie gut wird dein Abi?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Sieh dir dynamische Hochrechnungen für deinen Abischnitt an"),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
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
                icon: Icon(Icons.double_arrow),
                label: Text("Loslegen"),
                style: FilledButton.styleFrom(minimumSize: Size(double.infinity, 56)),
              ),
              const SizedBox(height: 16.0,),
              FilledButton.tonalIcon(
                onPressed: () => _pickAndImportJson(context),
                icon: Icon(Icons.folder),
                label: Text("Daten importieren"),
                style: FilledButton.styleFrom(minimumSize: Size(double.infinity, 56)),
              ),
            ],
          ),
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

        // TODO SQLITE Tabelle aus JSON wiederherstellen

        debugPrint("Extracted data from JSON...");
        await PerformanceService.buildFromJson((jsonData["performances"] as List).map((e) => e as Map<String, dynamic>).toList());
        debugPrint("Extracted Performances from JSON.");
        await SubjectService.buildFromJson((jsonData["subjects"] as List).map((e) => e as Map<String, dynamic>).toList());
        debugPrint("Extracted Subjects from JSON.");
        await EvaluationService.buildFromJson((jsonData["evaluations"] as List).map((e) => e as Map<String, dynamic>).toList());
        debugPrint("Extracted Evaluations from JSON.");
        await EvaluationDateService.buildFromJson((jsonData["evaluationDates"] as List).map((e) => e as Map<String, dynamic>).toList());
        debugPrint("Extracted EvaluationDates from JSON.");
        await EvaluationTypeService.buildFromJson((jsonData["evaluationTypes"] as List).map((e) => e as Map<String, dynamic>).toList());
        debugPrint("Extracted EvaluationTypes from JSON.");
        await SettingsService.buildFromJson(jsonData["settings"] as Map<String, dynamic>);
        debugPrint("Extracted Settings from JSON.");
        await GraduationEvaluationService.buildFromJson((jsonData["graduationEvaluations"] as List).map((e) => e as Map<String, dynamic>).toList());
        debugPrint("Extracted GraduationEvaluations from JSON.");
        await TimetableEntryService.buildFromJson((jsonData["timetableEntries"] as List).map((e) => e as Map<String, dynamic>).toList());
        debugPrint("Extracted TimetableSettings from JSON.");
        await TimetableTimeService.buildFromJson((jsonData["timetableTimes"] as List).map((e) => e as Map<String, dynamic>).toList());
        debugPrint("Extracted Timetables from JSON.");

        // Kalender und Notifications
        await CalendarService.syncAllEvaluationCalendarEvents();
        NotificationService.scheduleAllNotifications();

        SettingsService.markWelcomeScreenAsViewed();

        // Storage.initialValues();

        Settings settings = await SettingsService.loadSettings();

        // Theming
        Provider.of<BrightnessNotifier>(context, listen: false,).setThemeMode(settings.themeMode);
        Provider.of<SeedNotifier>(context, listen: false,).seed = settings.accentColor;

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
      debugPrint(e.toString());
    }
  }
}
