import 'package:abitur/pages/setup_pages/setup_ui_page.dart';
import 'package:flutter/material.dart';

import '../../services/database/settings_service.dart';
import '../../sqlite/entities/settings.dart';

class SetupGraduationYearPage extends StatelessWidget {
  const SetupGraduationYearPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "In welchem Jahr machst du voraussichtlich dein Abitur?",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ...possibleGraduationYears().map((year) {
                  return ListTile(
                    dense: true,
                    title: Text(year.toString()),
                    onTap: () async {
                      Settings s = await SettingsService.loadSettings();
                      s.graduationYear = DateTime(year);
                      await SettingsService.saveSettings(s);

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
}



List<int> possibleGraduationYears() {
  DateTime now = DateTime.now();
  int currentYear = now.year;

  if (now.isBefore(now.copyWith(month: 8, day: 1))) {
    return [currentYear, currentYear + 1, currentYear + 2, currentYear + 3];
  }
  return [currentYear + 1, currentYear + 2, currentYear + 3];
}