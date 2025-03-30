import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../storage/entities/settings.dart';
import '../../storage/services/settings_service.dart';
import '../../storage/storage.dart';
import '../../utils/brightness_notifier.dart';
import '../../widgets/color_dialog.dart';

class SettingsAppearancePage extends StatefulWidget {
  const SettingsAppearancePage({super.key});

  @override
  State<SettingsAppearancePage> createState() => _SettingsAppearancePageState();
}

class _SettingsAppearancePageState extends State<SettingsAppearancePage> {


  Settings s = Storage.loadSettings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Erscheinungsbild"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              trailing: CircleAvatar(
                backgroundColor: s.accentColor,
              ),
              title: Text("Akzentfarbe wählen"),
              onTap: () async {
                Color? newAccentColor = await showDialog(context: context, builder: (context) {
                  return ColorDialog(
                    initialColor: s.accentColor,
                    title: "Akzentfarbe wählen",
                  );
                });
                if (newAccentColor == null) {
                  return;
                }
                setState(() {
                  SettingsService.setAccentColor(context, newAccentColor);
                });
              },
            ),
            SwitchListTile(
              title: Text("Light Mode"),
              value: s.lightMode,
              onChanged: (v) {
                setState(() {
                  s.lightMode = !s.lightMode;
                });
                Provider.of<BrightnessNotifier>(context, listen: false).setBrightness(s.lightMode);
                Storage.saveSettings(s);
              },
            ),
          ],
        ),
      ),
    );
  }
}
