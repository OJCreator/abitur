import 'dart:convert';
import 'dart:io';

import 'package:abitur/pages/settings_pages/settings_app_info_page.dart';
import 'package:abitur/pages/settings_pages/settings_appearance_page.dart';
import 'package:abitur/pages/settings_pages/settings_calendar_page.dart';
import 'package:abitur/pages/settings_pages/settings_evaluation_types_page.dart';
import 'package:abitur/pages/settings_pages/settings_notifications_page.dart';
import 'package:abitur/pages/setup_pages/setup_graduation_year_page.dart';
import 'package:abitur/storage/entities/evaluation_type.dart';
import 'package:abitur/storage/entities/graduation/graduation_evaluation.dart';
import 'package:abitur/storage/entities/timetable/timetable_entry.dart';
import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/services/graduation_service.dart';
import 'package:abitur/storage/services/performance_service.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/storage/services/timetable_service.dart';
import 'package:abitur/storage/storage.dart';
import 'package:abitur/utils/constants.dart';
import 'package:abitur/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../storage/entities/evaluation.dart';
import '../../storage/entities/evaluation_date.dart';
import '../../storage/entities/performance.dart';
import '../../storage/entities/settings.dart';
import '../../storage/entities/subject.dart';
import '../../storage/entities/timetable/timetable.dart';
import '../../storage/entities/timetable/timetable_settings.dart';
import '../../storage/services/evaluation_date_service.dart';
import '../../storage/services/evaluation_type_service.dart';

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
              leading: Icon(Icons.school),
              subtitle: Text(s.graduationYear.formatYear()),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,

                  builder: (context) {
                    return DraggableScrollableSheet(
                        expand: false,
                        snap: true,
                        maxChildSize: 0.8,
                        builder: (context, scrollController) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                              left: 16,
                              right: 16,
                            ),
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InfoCard("Diese Funktion befindet sich noch in Arbeit."),
                                  Text("In welchem Jahr planst du, das Abitur zu machen?"),
                                  for (int year in possibleGraduationYears())
                                    ListTile(
                                      title: Text("$year"),
                                      onTap: () {
                                        print("TODO (Jahr: $year)");
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        }
                    );
                    // return ManualTermNoteEnterSheet(subject: widget.subject, term: widget.term);
                  },
                ).then((value) {
                  setState(() { });
                });
              },
            ),
            ListTile(
              title: Text("Bundesland"),
              leading: Icon(Icons.location_on),
              subtitle: Text(s.land.name),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,

                  builder: (context) {
                    return DraggableScrollableSheet(
                      expand: false,
                      snap: true,
                      maxChildSize: 0.8,
                      builder: (context, scrollController) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                            left: 16,
                            right: 16,
                          ),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InfoCard("Diese Funktion befindet sich noch in Arbeit."),
                                Text("In welches Bundesland willst du wechseln?"),
                                for (Land l in Land.values)
                                  ListTile(
                                    title: Text(l.name),
                                    onTap: () {
                                      print("TODO (Bundesland: ${l.name})");
                                      Navigator.of(context).pop();
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      }
                    );
                    // return ManualTermNoteEnterSheet(subject: widget.subject, term: widget.term);
                  },
                ).then((value) {
                  setState(() { });
                });
              },
            ),
            ListTile(
              title: Text("Erscheinungsbild"),
              leading: Icon(Icons.palette),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return SettingsAppearancePage();
                    })
                );
              },
            ),
            ListTile(
              title: Text("Prüfungskategorien"),
              leading: Icon(Icons.assignment),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return SettingsEvaluationTypesPage();
                    })
                );
              },
            ),
            ListTile(
              title: Text("Kalender-Synchronisierung"),
              leading: Icon(Icons.calendar_month),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return SettingsCalendarPage();
                  })
                );
              },
            ),
            ListTile(
              title: Text("Benachrichtigungen"),
              leading: Icon(Icons.notifications),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return SettingsNotificationsPage();
                  })
                );
              },
            ),
            ListTile(
              title: Text("Feedback"),
              leading: Icon(Icons.mail),
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
              leading: Icon(Icons.data_object),
              title: Text("Daten exportieren (JSON)"),
              onTap: _exportToJson,
            ),
            ListTile(
              title: Text("App-Info"),
              leading: Icon(Icons.info),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return SettingsAppInfoPage();
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToJson() async {

    List<Evaluation> evaluations = EvaluationService.findAll();
    List<EvaluationDate> evaluationDates = EvaluationDateService.findAll();
    List<EvaluationType> evaluationTypes = EvaluationTypeService.findAll();
    List<Subject> subjects = SubjectService.findAll();
    List<Performance> performances = PerformanceService.findAll();
    Settings settings = SettingsService.loadSettings();
    List<GraduationEvaluation> graduationEvaluations = GraduationService.findAllEvaluations();
    TimetableSettings timetableSettings = TimetableService.loadTimetableSettings();
    List<Timetable> timetables = TimetableService.loadTimetables();
    List<TimetableEntry> timetableEntries = TimetableService.loadTimetableEntries();

    String jsonContent = exportDataToJson(subjects, performances, evaluations, evaluationDates, evaluationTypes, settings, graduationEvaluations, timetableSettings, timetables, timetableEntries);
    File f = await _saveToFile("abitur_data", jsonContent);
    Share.shareXFiles([XFile(f.path)], text: "Hier sind die Abitur-Daten!");
  }

  String exportDataToJson(List<Subject> subjects, List<Performance> performances, List<Evaluation> evaluations, List<EvaluationDate> evaluationDates, List<EvaluationType> evaluationTypes, Settings settings, List<GraduationEvaluation> graduationEvaluations, TimetableSettings timetableSettings, List<Timetable> timetables, List<TimetableEntry> timetableEntries) {
    final Map<String, dynamic> data = {
      "subjects": subjects.map((s) => s.toJson()).toList(),
      "performances": performances.map((p) => p.toJson()).toList(),
      "evaluations": evaluations.map((e) => e.toJson()).toList(),
      "evaluationDates": evaluationDates.map((e) => e.toJson()).toList(),
      "evaluationTypes": evaluationTypes.map((e) => e.toJson()).toList(),
      "settings": settings.toJson(),
      "graduationEvaluations": graduationEvaluations.map((e) => e.toJson()).toList(),
      "timetableSettings": timetableSettings.toJson(),
      "timetables": timetables.map((t) => t.toJson()).toList(),
      "timetableEntries": timetableEntries.map((t) => t.toJson()).toList(),
    };
    return jsonEncode(data);
  }

  Future<File> _saveToFile(String fileName, String jsonContent) async {

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.json');
    return await file.writeAsString(jsonContent);
  }
}
