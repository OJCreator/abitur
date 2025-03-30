import 'package:abitur/storage/services/evaluation_type_service.dart';
import 'package:flutter/material.dart';

import '../../storage/entities/evaluation_type.dart';
import '../../storage/entities/settings.dart';
import '../../storage/services/evaluation_date_service.dart';
import '../../storage/storage.dart';
import '../../utils/calender_sync.dart';

class SettingsCalendarPage extends StatefulWidget {
  const SettingsCalendarPage({super.key});

  @override
  State<SettingsCalendarPage> createState() => _SettingsCalendarPageState();
}

class _SettingsCalendarPageState extends State<SettingsCalendarPage> {


  Settings s = Storage.loadSettings();

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
            SwitchListTile(
              title: Text("Kalender-Synchronisierung"),
              value: s.calendarSynchronisation,
              onChanged: (v) async {
                setState(() {
                  s.calendarSynchronisation = !s.calendarSynchronisation;
                });
                Storage.saveSettings(s);
                if (!s.calendarSynchronisation) {
                  await deleteAllCalendarEvents();
                } else {
                  syncEvaluationCalendarEvents(EvaluationDateService.findAll());
                }
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                "Prüfungskategorien im Kalender anzeigen",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            for (EvaluationType evaluationType in EvaluationTypeService.findAll())
              SwitchListTile(
                title: Text(evaluationType.name),
                value: evaluationType.showInCalendar,
                onChanged: s.calendarSynchronisation ? (v) async {
                  setState(() {
                    EvaluationTypeService.editEvaluationType(evaluationType, showInCalendar: !evaluationType.showInCalendar);
                  });
                  Storage.saveSettings(s);
                  syncEvaluationCalendarEvents(EvaluationDateService.findAll());
                } : null,
              ),
            Divider(),
            ListTile(
              title: Text(
                "Kalendereinstellungen",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            SwitchListTile(
              title: Text("Ganztagesereignis"),
              value: s.calendarFullDayEvents,
              enableFeedback: false,
              onChanged: s.calendarSynchronisation ? (v) async {
                setState(() {
                  s.calendarFullDayEvents = !s.calendarFullDayEvents;
                });
                Storage.saveSettings(s);
                // todo neu zeichnen
              } : null,
            ),
          ],
        ),
      ),
    );
  }
}
