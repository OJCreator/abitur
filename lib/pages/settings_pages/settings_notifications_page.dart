import 'package:abitur/services/notification_service.dart';
import 'package:abitur/widgets/section_heading_list_tile.dart';
import 'package:flutter/material.dart';

import '../../services/database/evaluation_date_service.dart';
import '../../services/database/settings_service.dart';
import '../../sqlite/entities/evaluation/evaluation_date.dart';
import '../../sqlite/entities/settings.dart';
import '../../widgets/shimmer/shimmer_text.dart';

class SettingsNotificationsPage extends StatefulWidget {
  const SettingsNotificationsPage({super.key});

  @override
  State<SettingsNotificationsPage> createState() => _SettingsNotificationsPageState();
}

class _SettingsNotificationsPageState extends State<SettingsNotificationsPage> {

  late Future<Settings> settingsFuture;

  @override
  void initState() {
    _loadSettings();
    super.initState();
  }

  void _loadSettings() {
    settingsFuture = SettingsService.loadSettings();
  }

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
            FutureBuilder(
              future: settingsFuture,
              builder: (context, asyncSnapshot) {
                if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                  return SwitchListTile(
                    title: Text("Benachrichtigungen"),
                    value: false,
                    onChanged: null,
                  );
                }
                Settings settings = asyncSnapshot.data!;
                return SwitchListTile(
                  title: Text("Benachrichtigung"),
                  value: settings.evaluationReminder,
                  onChanged: (v) async {
                    setState(() {
                      settings.evaluationReminder = !settings.evaluationReminder;
                    });
                    SettingsService.saveSettings(settings);
                    List<EvaluationDate> evaluationDates = await EvaluationDateService.findAll();
                    if (!settings.evaluationReminder) {
                      NotificationService.cancelOnlyEvaluationReminders(evaluationDates);
                    } else {
                      NotificationService.scheduleOnlyEvaluationReminders(evaluationDates);
                    }
                  },
                );
              }
            ),
            FutureBuilder(
              future: settingsFuture,
              builder: (context, asyncSnapshot) {
                if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                  return ListTile(
                    title: Text("Zeitpunkt der Benachrichtigung am Vortag"),
                    subtitle: ShimmerText(),
                  );
                }
                Settings settings = asyncSnapshot.data!;
                return ListTile(
                  title: Text("Zeitpunkt der Benachrichtigung am Vortag"),
                  subtitle: Text(settings.evaluationReminderTime.format(context)),
                  enabled: settings.evaluationReminder,
                  onTap: () async {
                    TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime: settings.evaluationReminderTime,
                    );
                    if (selectedTime == null) return;
                    setState(() {
                      settings.evaluationReminderTime = selectedTime;
                    });
                    await SettingsService.saveSettings(settings);
                    List<EvaluationDate> evaluationDates = await EvaluationDateService.findAll();
                    NotificationService.scheduleOnlyEvaluationReminders(evaluationDates);
                  },
                );
              }
            ),
            Divider(),
            SectionHeadingListTile(heading: "Bei fehlenden Noten erinnern"),
            FutureBuilder(
              future: settingsFuture,
              builder: (context, asyncSnapshot) {
                if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                  return SwitchListTile(
                    title: Text("Benachrichtigung"),
                    value: false,
                    onChanged: null,
                  );
                }
                Settings settings = asyncSnapshot.data!;
                return SwitchListTile(
                  title: Text("Benachrichtigung"),
                  value: settings.missingGradeReminder,
                  onChanged: (v) async {
                    setState(() {
                      settings.missingGradeReminder = !settings.missingGradeReminder;
                    });
                    SettingsService.saveSettings(settings);
                    List<EvaluationDate> evaluationDates = await EvaluationDateService.findAll();
                    if (!settings.evaluationReminder) {
                      NotificationService.cancelOnlyMissingGradeReminders(evaluationDates);
                    } else {
                      NotificationService.scheduleOnlyMissingGradeReminders(evaluationDates);
                    }
                  },
                );
              }
            ),
            FutureBuilder(
              future: settingsFuture,
              builder: (context, asyncSnapshot) {
                if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                  return ListTile(
                    title: Text("Tage zwischen Prüfung und Erinnerung"),
                    subtitle: ShimmerText(),
                  );
                }
                Settings settings = asyncSnapshot.data!;
                return ListTile(
                  title: Text("Tage zwischen Prüfung und Erinnerung"),
                  subtitle: Text("${settings.missingGradeReminderDelayDays}"),
                  enabled: settings.missingGradeReminder,
                  onTap: () async {
                    TextEditingController delayDaysController = TextEditingController(text: "${settings.missingGradeReminderDelayDays}");
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
                      settings.missingGradeReminderDelayDays = selectedDelayDays;
                    });
                    SettingsService.saveSettings(settings);
                    List<EvaluationDate> evaluationDates = await EvaluationDateService.findAll();
                    NotificationService.scheduleOnlyMissingGradeReminders(evaluationDates);
                  },
                );
              }
            ),
            FutureBuilder(
              future: settingsFuture,
              builder: (context, asyncSnapshot) {
                if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                  return ListTile(
                    title: Text("Zeitpunkt der Benachrichtigung"),
                    subtitle: ShimmerText(),
                  );
                }
                Settings settings = asyncSnapshot.data!;
                return ListTile(
                  title: Text("Zeitpunkt der Benachrichtigung"),
                  subtitle: Text(settings.missingGradeReminderTime.format(context)),
                  enabled: settings.missingGradeReminder,
                  onTap: () async {
                    TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime: settings.missingGradeReminderTime,
                    );
                    if (selectedTime == null) return;
                    setState(() {
                      settings.missingGradeReminderTime = selectedTime;
                    });
                    List<EvaluationDate> evaluationDates = await EvaluationDateService.findAll();
                    NotificationService.scheduleOnlyMissingGradeReminders(evaluationDates);
                    SettingsService.saveSettings(settings);
                  },
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}