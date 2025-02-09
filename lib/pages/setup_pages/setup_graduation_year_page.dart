import 'package:abitur/pages/setup_pages/setup_ui_page.dart';
import 'package:abitur/storage/entities/settings.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/storage.dart';
import 'package:flutter/material.dart';

class SetupGraduationYearPage extends StatelessWidget {
  const SetupGraduationYearPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "In welchem Jahr machst du voraussichtlich dein Abitur?",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ...generateChoices().map((year) {
                  return ListTile(
                    dense: true,
                    title: Text(year.toString()),
                    onTap: () async {
                      Settings s = SettingsService.loadSettings();
                      s.graduationYear = DateTime(year);
                      await Storage.saveSettings(s);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return SetupUiPage();
                        }),
                      );
                    },
                  );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<int> generateChoices() {
    DateTime now = DateTime.now();
    int currentYear = now.year;

    if (now.isBefore(now.copyWith(month: 8, day: 1))) {
      return [currentYear, currentYear + 1, currentYear + 2, currentYear + 3];
    }
    return [currentYear + 1, currentYear + 2, currentYear + 3];
  }
}
