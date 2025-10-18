import 'package:abitur/pages/setup_pages/setup_graduation_year_page.dart';
import 'package:flutter/material.dart';

import '../../services/database/settings_service.dart';
import '../../sqlite/entities/settings.dart';
import '../../utils/enums/land.dart';

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
                      Settings s = await SettingsService.loadSettings();
                      s.land = land;
                      await SettingsService.saveSettings(s);

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
