import 'package:abitur/widgets/info_card.dart';
import 'package:flutter/material.dart';

import '../../services/database/settings_service.dart';
import '../../sqlite/entities/settings.dart';
import '../../utils/enums/land.dart';
import '../../widgets/product_features/product_title.dart';

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


                const ProductTitle(
                  "Aus welchem Bundeland kommst du?",
                ),

                ...Land.values.map((land) {
                  return ListTile(
                    title: Text(land.name),
                    onTap: () async {
                      Settings s = await SettingsService.loadSettings();
                      s.land = land;
                      await SettingsService.saveSettings(s);

                      Navigator.pushReplacementNamed(context, "/welcome/graduationYear");
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
