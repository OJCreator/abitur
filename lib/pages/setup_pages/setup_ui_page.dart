import 'package:abitur/main.dart';
import 'package:abitur/storage/entities/settings.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/utils/brightness_notifier.dart';
import 'package:abitur/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/color_dialog.dart';

class SetupUiPage extends StatefulWidget {
  const SetupUiPage({super.key});

  @override
  State<SetupUiPage> createState() => _SetupUiPageState();
}

class _SetupUiPageState extends State<SetupUiPage> {

  bool lightMode = true;
  Color accentColor = primaryColor;

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
                  "Und jetzt die wirklich wichtigen Fragen:",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SwitchListTile(
                  value: lightMode,
                  title: Text("Light Mode"),
                  onChanged: (s) {
                    Provider.of<BrightnessNotifier>(context, listen: false,).setBrightness(!lightMode);
                    setState(() {
                      Settings s = SettingsService.loadSettings();
                      s.lightMode = !lightMode;
                      lightMode = !lightMode;
                    });
                  },
                ),
                ListTile(
                  trailing: CircleAvatar(
                    backgroundColor: accentColor,
                  ),
                  title: Text("Akzentfarbe wählen"),
                  onTap: () async {
                    Color? newAccentColor = await showDialog(context: context, builder: (context) {
                      return ColorDialog(
                        initialColor: accentColor,
                        title: "Akzentfarbe wählen",
                      );
                    });
                    if (newAccentColor == null) {
                      return;
                    }
                    setState(() {
                      SettingsService.setAccentColor(context, newAccentColor);
                      setState(() {
                        accentColor = newAccentColor;
                      });
                    });
                  },
                ),
                FilledButton(
                  onPressed: () {
                    SettingsService.markWelcomeScreenAsViewed();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return ScreenScaffolding();
                      }),
                    );
                  },
                  child: Text("Fertigstellen"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
