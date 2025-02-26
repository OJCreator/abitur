import 'dart:convert';
import 'dart:io';

import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/services/performance_service.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/storage/services/timetable_service.dart';
import 'package:abitur/storage/storage.dart';
import 'package:abitur/utils/calender_sync.dart';
import 'package:abitur/utils/constants.dart';
import 'package:abitur/widgets/color_dialog.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../storage/entities/evaluation.dart';
import '../storage/entities/performance.dart';
import '../storage/entities/settings.dart';
import '../storage/entities/subject.dart';
import '../storage/entities/timetable.dart';
import '../utils/brightness_notifier.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  Settings s = Storage.loadSettings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Einstellungen"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text("Abijahrgang"),
              subtitle: Text(s.graduationYear.formatYear()),
              onTap: () {
                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    title: Text("Abijahrgang wechseln"),
                    content: Placeholder(child: Text("\n\n\n\n\n\n\n"),),
                    actions: [],
                  );
                });
              },
            ),
            ListTile(
              trailing: CircleAvatar(
                backgroundColor: s.accentColor,
              ),
              title: Text("Akzentfarbe wählen"),
              onTap: () async {
                Color? newAccentColor = await showDialog(context: context, builder: (context) {
                  return ColorDialog(
                    initialColor: s.accentColor,
                    title: "Akzentfarbe wählen",
                  );
                });
                if (newAccentColor == null) {
                  return;
                }
                setState(() {
                  SettingsService.setAccentColor(context, newAccentColor);
                });
              },
            ),
            SwitchListTile(
              title: Text("Light Mode"),
              value: s.lightMode,
              onChanged: (v) {
                setState(() {
                  s.lightMode = !s.lightMode;
                });
                Provider.of<BrightnessNotifier>(context, listen: false).setBrightness(s.lightMode);
                Storage.saveSettings(s);
              },
            ),
            SwitchListTile(
              title: Text("Kalender Synchronisierung"),
              value: s.calendarSynchronisation,
              onChanged: (v) async {
                setState(() {
                  s.calendarSynchronisation = !s.calendarSynchronisation;
                });
                Storage.saveSettings(s);
                if (!s.calendarSynchronisation) {
                  await deleteAllCalendarEvents();
                } else {
                  syncEvaluationCalendarEvents(EvaluationService.findAll());
                }
              },
            ),
            ListTile(
              title: Text("Feedback"),
              onTap: () async {
                final email = Uri.encodeComponent("oj.creator@gmail.com");
                final subject = Uri.encodeComponent("Kontakt (Abi-Planer)");
                final url = Uri.parse("mailto:$email?subject=$subject");

                try {
                  launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (e) {
                  print('E-Mail-App konnte nicht geöffnet werden.');
                }
              },
            ),
            ListTile(
              title: Text("Daten exportieren (JSON)"),
              onTap: _exportToJson,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToJson() async {

    List<Evaluation> evaluations = EvaluationService.findAll();
    List<Subject> subjects = SubjectService.findAll();
    List<Performance> performances = PerformanceService.findAll();
    Settings settings = SettingsService.loadSettings();
    Timetable timetable = TimetableService.loadTimetable();

    String jsonContent = exportDataToJson(subjects, performances, evaluations, settings, timetable);
    File f = await _saveToFile("abitur_data", jsonContent);
    Share.shareXFiles([XFile(f.path)], text: "Hier sind die Abitur-Daten!");
  }

  String exportDataToJson(List<Subject> subjects, List<Performance> performances, List<Evaluation> evaluations, Settings settings, Timetable timetable) {
    final Map<String, dynamic> data = {
      "subjects": subjects.map((s) => s.toJson()).toList(),
      "performances": performances.map((p) => p.toJson()).toList(),
      "evaluations": evaluations.map((e) => e.toJson()).toList(),
      "settings": settings.toJson(),
      "timetable": timetable.toJson(),
    };
    return jsonEncode(data);
  }

  Future<File> _saveToFile(String fileName, String jsonContent) async {

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.json');
    return await file.writeAsString(jsonContent);
  }
}
