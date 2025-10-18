import 'package:abitur/services/calendar_service.dart';
import 'package:abitur/services/database/evaluation_type_service.dart';
import 'package:abitur/sqlite/entities/evaluation/evaluation_type.dart';
import 'package:abitur/widgets/section_heading_list_tile.dart';
import 'package:abitur/widgets/shimmer/shimmer_text.dart';
import 'package:flutter/material.dart';

import '../../services/database/settings_service.dart';
import '../../sqlite/entities/settings.dart';

class SettingsCalendarPage extends StatefulWidget {
  const SettingsCalendarPage({super.key});

  @override
  State<SettingsCalendarPage> createState() => _SettingsCalendarPageState();
}

class _SettingsCalendarPageState extends State<SettingsCalendarPage> {


  late Future<Settings> settingsFuture;
  late Future<List<EvaluationType>> evaluationTypesFuture;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  void _loadData() {
    settingsFuture = SettingsService.loadSettings();
    evaluationTypesFuture = EvaluationTypeService.findAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kalender-Synchronisierung"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: settingsFuture,
              builder: (context, asyncSnapshot) {
                if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                  return SwitchListTile(
                    title: Text("Kalender-Synchronisierung"),
                    value: false,
                    onChanged: null,
                  );
                }
                Settings settings = asyncSnapshot.data!;
                return SwitchListTile(
                  title: Text("Kalender-Synchronisierung"),
                  value: settings.calendarSynchronisation,
                  onChanged: (v) async {
                    setState(() {
                      settings.calendarSynchronisation = !settings.calendarSynchronisation;
                    });
                    SettingsService.saveSettings(settings);
                    if (!settings.calendarSynchronisation) {
                      await CalendarService.deleteAllCalendarEvents();
                    } else {
                      CalendarService.syncAllEvaluationCalendarEvents();
                    }
                  },
                );
              }
            ),
            Divider(),
            SectionHeadingListTile(heading: "Prüfungskategorien im Kalender anzeigen"),
            FutureBuilder(
              future: Future.wait([evaluationTypesFuture, settingsFuture]),
              builder: (context, asyncSnapshot) {
                if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                  return Column(
                    children: [
                      for (int i = 0; i < 4; i++)
                        SwitchListTile(
                          title: ShimmerText(),
                          value: false,
                          onChanged: null,
                        ),
                    ],
                  );
                }
                List<EvaluationType> evaluationTypes = asyncSnapshot.data![0] as List<EvaluationType>;
                Settings settings = asyncSnapshot.data![1] as Settings;
                return Column(
                  children: [
                    for (EvaluationType evaluationType in evaluationTypes)
                      SwitchListTile(
                        title: Text(evaluationType.name),
                        value: evaluationType.showInCalendar,
                        onChanged: settings.calendarSynchronisation ? (v) async {
                          setState(() {
                            EvaluationTypeService.editEvaluationType(evaluationType, showInCalendar: !evaluationType.showInCalendar);
                          });
                          CalendarService.syncAllEvaluationCalendarEvents();
                        } : null,
                      ),
                  ],
                );
              }
            ),
            Divider(),
            SectionHeadingListTile(heading: "Kalendereinstellungen"),
            FutureBuilder(
              future: settingsFuture,
              builder: (context, asyncSnapshot) {
                if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                  return SwitchListTile(
                    title: Text("Kalender-Synchronisierung"),
                    value: false,
                    onChanged: null,
                  );
                }
                Settings settings = asyncSnapshot.data!;
                return SwitchListTile(
                  title: Text("Ganztagesereignis"),
                  value: settings.calendarFullDayEvents,
                  enableFeedback: false,
                  onChanged: settings.calendarSynchronisation ? (v) async {
                    setState(() {
                      settings.calendarFullDayEvents = !settings.calendarFullDayEvents;
                    });
                    SettingsService.saveSettings(settings);
                    CalendarService.syncAllEvaluationCalendarEvents();
                    // todo neu zeichnen
                  } : null,
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}
