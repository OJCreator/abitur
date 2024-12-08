import 'package:abitur/main.dart';
import 'package:abitur/storage/entities/settings.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/storage.dart';
import 'package:flutter/material.dart';

class SetupLandPage extends StatelessWidget {
  const SetupLandPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("Bitte wähle dein Bundesland."),
              ...Land.values.map((land) {
                return ListTile(
                  title: Text(land.name),
                  onTap: () async {
                    Settings s = SettingsService.loadSettings();
                    s.land = land;
                    s.viewedWelcomeScreen = true;
                    await Storage.saveSettings(s);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return ScreenScaffolding();
                      }),
                    );
                  },
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}
