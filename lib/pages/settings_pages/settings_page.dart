import 'dart:convert';
import 'dart:io';

import 'package:abitur/in_app_purchases/purchase_service.dart';
import 'package:abitur/isolates/serializer.dart';
import 'package:abitur/pages/in_app_purchase_pages/full_version_page.dart';
import 'package:abitur/pages/settings_pages/settings_app_info_page.dart';
import 'package:abitur/pages/settings_pages/settings_appearance_page.dart';
import 'package:abitur/pages/settings_pages/settings_calendar_page.dart';
import 'package:abitur/pages/settings_pages/settings_evaluation_types_page.dart';
import 'package:abitur/pages/settings_pages/settings_notifications_page.dart';
import 'package:abitur/pages/setup_pages/setup_graduation_year_page.dart';
import 'package:abitur/services/database/timetable_entry_service.dart';
import 'package:abitur/services/database/timetable_time_service.dart';
import 'package:abitur/sqlite/entities/timetable/timetable_time.dart';
import 'package:abitur/utils/extensions/date_extension.dart';
import 'package:abitur/widgets/info_card.dart';
import 'package:abitur/widgets/shimmer/shimmer_text.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/database/evaluation_date_service.dart';
import '../../services/database/evaluation_service.dart';
import '../../services/database/evaluation_type_service.dart';
import '../../services/database/graduation_evaluation_service.dart';
import '../../services/database/performance_service.dart';
import '../../services/database/settings_service.dart';
import '../../services/database/subject_service.dart';
import '../../sqlite/entities/evaluation/evaluation.dart';
import '../../sqlite/entities/evaluation/evaluation_date.dart';
import '../../sqlite/entities/evaluation/evaluation_type.dart';
import '../../sqlite/entities/graduation_evaluation.dart';
import '../../sqlite/entities/performance.dart';
import '../../sqlite/entities/settings.dart';
import '../../sqlite/entities/subject.dart';
import '../../sqlite/entities/timetable/timetable_entry.dart';
import '../../utils/enums/land.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  late Future<Settings> settings;

  @override
  void initState() {
    _loadSettings();
    super.initState();
  }

  void _loadSettings() {
    settings = SettingsService.loadSettings();
  }

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
              subtitle: FutureBuilder(
                future: settings,
                builder: (context, asyncSnapshot) {
                  if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                    return ShimmerText();
                  }
                  Settings settings = asyncSnapshot.data!;
                  return Text(settings.graduationYear.formatYear());
                }
              ),
              onTap: _changeGraduationYear,
            ),
            ListTile(
              title: Text("Bundesland"),
              leading: Icon(Icons.location_on),
              subtitle: FutureBuilder(
                  future: settings,
                  builder: (context, asyncSnapshot) {
                    if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                      return ShimmerText();
                    }
                    Settings settings = asyncSnapshot.data!;
                    return Text(settings.land.name);
                  }
              ),
              onTap: _changeLand,
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
                if (PurchaseService.fullAccess) {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return SettingsCalendarPage();
                      })
                  );
                } else {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return FullVersionPage(
                          nextPage: SettingsCalendarPage(),
                        );
                      })
                  );
                }
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
                  debugPrint('E-Mail-App konnte nicht geöffnet werden.');
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

  void _changeGraduationYear() {
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
                            debugPrint("TODO (Jahr: $year)");
                            Navigator.of(context).pop();
                          },
                        ),
                    ],
                  ),
                ),
              );
            }
        );
      },
    ).then((value) {
      setState(() { });
    });
  }

  void _changeLand() {
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
                            debugPrint("TODO (Bundesland: ${l.name})");
                            Navigator.of(context).pop();
                          },
                        ),
                    ],
                  ),
                ),
              );
            }
        );
      },
    ).then((value) {
      setState(() { });
    });
  }

  Future<void> _exportToJson() async {

    // TODO Von SQLITE EXPORTIEREN

    List<Evaluation> evaluations = await EvaluationService.findAll();
    List<EvaluationDate> evaluationDates = await EvaluationDateService.findAll();
    List<EvaluationType> evaluationTypes = await EvaluationTypeService.findAll();
    List<GraduationEvaluation> graduationEvaluations = await GraduationEvaluationService.findAllEvaluations();
    List<Performance> performances = await PerformanceService.findAll();
    Settings settings = await SettingsService.loadSettings();
    List<Subject> subjects = await SubjectService.findAll();
    List<TimetableEntry> timetableEntries = await TimetableEntryService.findAllEntries();
    List<TimetableTime> timetableTimes = await TimetableTimeService.findAllTimes();

    String jsonContent = exportDataToJson(evaluations, evaluationDates, evaluationTypes, graduationEvaluations, performances, settings, subjects, timetableEntries, timetableTimes);
    File f = await _saveToFile("abitur_data", jsonContent);
    Share.shareXFiles([XFile(f.path)], text: "Hier sind die Abitur-Daten!");
  }

  String exportDataToJson(List<Evaluation> evaluations, List<EvaluationDate> evaluationDates, List<EvaluationType> evaluationTypes, List<GraduationEvaluation> graduationEvaluations, List<Performance> performances, Settings settings, List<Subject> subjects, List<TimetableEntry> timetableEntries, List<TimetableTime> timetableTimes) {
    final Map<String, dynamic> data = {
      "evaluations": evaluations.serialize(),
      "evaluationDates": evaluationDates.serialize(),
      "evaluationTypes": evaluationTypes.serialize(),
      "graduationEvaluations": graduationEvaluations.serialize(),
      "performances": performances.serialize(),
      "settings": settings.toJson(),
      "subjects": subjects.serialize(),
      "timetableEntries": timetableEntries.serialize(),
      "timetableTimes": timetableTimes.serialize(),
    };
    return jsonEncode(data);
  }

  Future<File> _saveToFile(String fileName, String jsonContent) async {

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.json');
    return await file.writeAsString(jsonContent);
  }
}
