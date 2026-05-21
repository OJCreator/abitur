import 'dart:convert';
import 'dart:io';

import 'package:abitur/main.dart';
import 'package:abitur/services/calendar_service.dart';
import 'package:abitur/services/database/timetable_entry_service.dart';
import 'package:abitur/services/database/timetable_time_service.dart';
import 'package:abitur/services/notification_service.dart';
import 'package:abitur/utils/brightness_notifier.dart';
import 'package:abitur/utils/seed_notifier.dart';
import 'package:abitur/widgets/product_features/product_button.dart';
import 'package:abitur/widgets/product_features/product_feature.dart';
import 'package:abitur/widgets/product_features/product_title.dart';
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
import '../widgets/product_features/product_action_area.dart';

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
              const ProductTitle(
                "Willkommen in deiner Abitur-App.",
              ),
        
              ProductFeature(
                icon: Icons.remove_red_eye,
                title: "Behalte die Übersicht",
                subtitle: "Über Prüfungen, Noten und Fächer",
              ),
              ProductFeature(
                icon: Icons.notifications,
                title: "Vergiss nie mehr einen Termin",
                subtitle: "Du wirst automatisch an alles Wichtige erinnert",
              ),
              ProductFeature(
                icon: Icons.query_stats,
                title: "Wie gut wird dein Abi?",
                subtitle: "Sieh dir dynamische Hochrechnungen für deinen Abischnitt an",
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ProductActionArea(
            children: [
              ProductButton(
                icon: Icons.double_arrow,
                label: "Loslegen",
                onPressed: loading ? null : _openSetupPage,
              ),
              ProductButton.tonal(
                icon: Icons.folder,
                label: "Daten importieren",
                onPressed: loading ? null : _pickAndImportJson,
              ),
            ],
          ),
    );
  }

  void _openSetupPage() {
    Navigator.pushReplacementNamed(context, "/welcome/land");
  }

  Future<void> _pickAndImportJson() async {
    if (loading) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["json"],
      );

      if (result != null && result.files.single.path != null) {


        File file = File(result.files.single.path!);
        String fileContent = await file.readAsString();

        Map<String, dynamic> jsonData = jsonDecode(fileContent);

        debugPrint("Extracted data from JSON...");
        await SettingsService.buildFromJson(jsonData["settings"] as Map<String, dynamic>);
        debugPrint("Extracted Settings from JSON.");
        await EvaluationTypeService.buildFromJson((jsonData["evaluationTypes"] as List).map((e) => e as Map<String, dynamic>).toList());
        debugPrint("Extracted EvaluationTypes from JSON.");
        await TimetableTimeService.buildFromJson((jsonData["timetableTimes"] as List).map((e) => e as Map<String, dynamic>).toList());
        debugPrint("Extracted Timetables from JSON.");
        await SubjectService.buildFromJson((jsonData["subjects"] as List).map((e) => e as Map<String, dynamic>).toList());
        debugPrint("Extracted Subjects from JSON.");
        await PerformanceService.buildFromJson((jsonData["performances"] as List).map((e) => e as Map<String, dynamic>).toList());
        debugPrint("Extracted Performances from JSON.");
        await GraduationEvaluationService.buildFromJson((jsonData["graduationEvaluations"] as List).map((e) => e as Map<String, dynamic>).toList());
        debugPrint("Extracted GraduationEvaluations from JSON.");
        await TimetableEntryService.buildFromJson((jsonData["timetableEntries"] as List).map((e) => e as Map<String, dynamic>).toList());
        debugPrint("Extracted TimetableSettings from JSON.");
        await EvaluationService.buildFromJson((jsonData["evaluations"] as List).map((e) => e as Map<String, dynamic>).toList());
        debugPrint("Extracted Evaluations from JSON.");
        await EvaluationDateService.buildFromJson((jsonData["evaluationDates"] as List).map((e) => e as Map<String, dynamic>).toList());
        debugPrint("Extracted EvaluationDates from JSON.");

        // Kalender und Notifications
        await CalendarService.syncAll();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Es gab einen Fehler beim Einlesen der Daten."),
        ),
      );
      debugPrint(e.toString());
    }

    setState(() {
      loading = false;
    });
  }
}
