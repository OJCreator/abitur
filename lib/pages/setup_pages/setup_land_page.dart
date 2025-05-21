import 'package:abitur/pages/setup_pages/setup_graduation_year_page.dart';
import 'package:abitur/storage/entities/settings.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/storage.dart';
import 'package:flutter/material.dart';

class SetupLandPage extends StatelessWidget {
  const SetupLandPage({super.key});

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
                  "Aus welchem Bundeland kommst du?",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ...Land.values.map((land) {
                  return ListTile(
                    dense: true,
                    title: Text(land.name),
                    onTap: () async {
                      Settings s = SettingsService.loadSettings();
                      s.land = land;
                      await Storage.saveSettings(s);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return SetupGraduationYearPage();
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
