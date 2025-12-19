import 'package:abitur/pages/setup_pages/setup_graduation_year_page.dart';
import 'package:abitur/widgets/info_card.dart';
import 'package:flutter/material.dart';

import '../../services/database/settings_service.dart';
import '../../sqlite/entities/settings.dart';
import '../../utils/enums/land.dart';

class SetupLandPage extends StatelessWidget {
  const SetupLandPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                InfoCard("Die App befindet sich momentan in der Alpha-Phase. Das heißt, es können jederzeit Daten durch Updates oder fehlerhafte Programmierung verloren gehen. Ich würde mich über Feedback oder Informationen zu verschiedenen Bundesländern an oj.creator@gmail.com freuen."),
                InfoCard("Die App ist momentan nur auf Bayern ausgelegt. Andere Bundesländer sollen folgen."),

                const Text(
                  "Aus welchem Bundeland kommst du?",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

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
