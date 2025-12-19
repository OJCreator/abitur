import 'package:abitur/main.dart';
import 'package:abitur/utils/brightness_notifier.dart';
import 'package:abitur/utils/constants.dart';
import 'package:abitur/utils/extensions/theme_mode_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/database/settings_service.dart';
import '../../sqlite/entities/settings.dart';
import '../../widgets/color_dialog.dart';
import '../settings_pages/settings_appearance_page.dart';

class SetupUiPage extends StatefulWidget {
  const SetupUiPage({super.key});

  @override
  State<SetupUiPage> createState() => _SetupUiPageState();
}

class _SetupUiPageState extends State<SetupUiPage> {

  ThemeMode themeMode = ThemeMode.system;
  Color accentColor = primaryColor;

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
                  "Und jetzt die wirklich wichtigen Fragen:",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text("Design"),
                  subtitle: Text(themeMode.label),
                  onTap: () async {
                    ThemeMode? newThemeMode = await showModalBottomSheet(
                      context: context,
                      builder: (context) => ThemeModeSelectorSheet(currentThemeMode: themeMode,),
                    );
                    if (newThemeMode == null) {
                      return;
                    }
                    Settings settings = await SettingsService.loadSettings();
                    setState(() {
                      settings.themeMode = newThemeMode;
                      themeMode = newThemeMode;
                    });
                    Provider.of<BrightnessNotifier>(context, listen: false,).setThemeMode(settings.themeMode);
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
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: () {
                  SettingsService.markWelcomeScreenAsViewed();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return ScreenScaffolding();
                    }),
                  );
                },
                icon: Icon(Icons.check_circle),
                label: Text("Fertigstellen"),
                style: FilledButton.styleFrom(minimumSize: Size(double.infinity, 56)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
