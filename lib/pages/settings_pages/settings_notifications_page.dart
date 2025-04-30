import 'package:abitur/storage/entities/evaluation_date.dart';
import 'package:abitur/storage/services/evaluation_date_service.dart';
import 'package:abitur/storage/services/notification_service.dart';
import 'package:abitur/widgets/section_heading_list_tile.dart';
import 'package:flutter/material.dart';

import '../../storage/entities/settings.dart';
import '../../storage/storage.dart';

class SettingsNotificationsPage extends StatefulWidget {
  const SettingsNotificationsPage({super.key});

  @override
  State<SettingsNotificationsPage> createState() => _SettingsNotificationsPageState();
}

class _SettingsNotificationsPageState extends State<SettingsNotificationsPage> {


  Settings s = Storage.loadSettings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Benachrichtigungen"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeadingListTile(heading: "An Prüfungen erinnern"),
            SwitchListTile(
              title: Text("Benachrichtigung"),
              value: s.evaluationReminder,
              onChanged: (v) async {
                setState(() {
                  s.evaluationReminder = !s.evaluationReminder;
                });
                Storage.saveSettings(s);
                List<EvaluationDate> evaluationDates = EvaluationDateService.findAll();
                if (!s.evaluationReminder) {
                  NotificationService.cancelOnlyEvaluationReminders(evaluationDates);
                } else {
                  NotificationService.scheduleOnlyEvaluationReminders(evaluationDates);
                }
              },
            ),
            ListTile(
              title: Text("Zeitpunkt der Benachrichtigung am Vortag"),
              subtitle: Text(s.evaluationReminderTime.format(context)),
              enabled: s.evaluationReminder,
              onTap: () async {
                TimeOfDay? selectedTime = await showTimePicker(
                  context: context,
                  initialTime: s.evaluationReminderTime,
                );
                if (selectedTime == null) return;
                setState(() {
                  s.evaluationReminderTimeInMinutes = selectedTime.hour*60 + selectedTime.minute;
                });
                List<EvaluationDate> evaluationDates = EvaluationDateService.findAll();
                NotificationService.scheduleOnlyEvaluationReminders(evaluationDates);
                Storage.saveSettings(s);
              },
            ),
            Divider(),
            SectionHeadingListTile(heading: "Bei fehlenden Noten erinnern"),
            SwitchListTile(
              title: Text("Benachrichtigung"),
              value: s.missingGradeReminder,
              onChanged: (v) async {
                setState(() {
                  s.missingGradeReminder = !s.missingGradeReminder;
                });
                Storage.saveSettings(s);
                List<EvaluationDate> evaluationDates = EvaluationDateService.findAll();
                if (!s.evaluationReminder) {
                  NotificationService.cancelOnlyMissingGradeReminders(evaluationDates);
                } else {
                  NotificationService.scheduleOnlyMissingGradeReminders(evaluationDates);
                }
              },
            ),
            ListTile(
              title: Text("Tage zwischen Prüfung und Erinnerung"),
              subtitle: Text("${s.missingGradeReminderDelayDays}"),
              enabled: s.missingGradeReminder,
              onTap: () async {
                TextEditingController delayDaysController = TextEditingController(text: "${s.missingGradeReminderDelayDays}");
                int? selectedDelayDays = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Tage zwischen Prüfung und Benachrichtigung"),
                      content: Form(
                        child: TextFormField(
                          controller: delayDaysController,
                          keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                          decoration: InputDecoration(
                            labelText: "Tage",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Abbrechen"),
                        ),
                        FilledButton.tonal(
                          onPressed: () {
                            Navigator.pop(context, double.parse(delayDaysController.text).round());
                          },
                          child: Text("Speichern"),
                        ),
                      ],
                    );
                  },
                );
                if (selectedDelayDays == null) return;
                if (selectedDelayDays < 0 || selectedDelayDays > 100) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Die Tageanzahl muss zwischen 0 und 100 liegen."),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                setState(() {
                  s.missingGradeReminderDelayDays = selectedDelayDays;
                });
                Storage.saveSettings(s);
                List<EvaluationDate> evaluationDates = EvaluationDateService.findAll();
                NotificationService.scheduleOnlyMissingGradeReminders(evaluationDates);
              },
            ),
            ListTile(
              title: Text("Zeitpunkt der Benachrichtigung"),
              subtitle: Text(s.missingGradeReminderTime.format(context)),
              enabled: s.missingGradeReminder,
              onTap: () async {
                TimeOfDay? selectedTime = await showTimePicker(
                  context: context,
                  initialTime: s.missingGradeReminderTime,
                );
                if (selectedTime == null) return;
                setState(() {
                  s.missingGradeReminderTimeInMinutes = selectedTime.hour*60 + selectedTime.minute;
                });
                List<EvaluationDate> evaluationDates = EvaluationDateService.findAll();
                NotificationService.scheduleOnlyMissingGradeReminders(evaluationDates);
                Storage.saveSettings(s);
              },
            ),
          ],
        ),
      ),
    );
  }
}