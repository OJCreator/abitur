import 'package:abitur/utils/constants.dart';
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
            ListTile(
              title: Text("Design"),
              subtitle: Text(s.themeMode.label),
              onTap: () async {
                ThemeMode? newThemeMode = await showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (context) => ThemeModeSelectorSheet(currentThemeMode: s.themeMode,),
                );
                if (newThemeMode == null) {
                  return;
                }
                setState(() {
                  s.themeMode = newThemeMode;
                });
                Storage.saveSettings(s);
                Provider.of<BrightnessNotifier>(context, listen: false).setThemeMode(s.themeMode);
              },
            ),
          ],
        ),
      ),
    );
  }
}
class ThemeModeSelectorSheet extends StatelessWidget {

  final ThemeMode currentThemeMode;

  const ThemeModeSelectorSheet({super.key, required this.currentThemeMode});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 8,
        right: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: ThemeMode.values.map((mode) {
          return RadioListTile<ThemeMode>(
            title: Text(mode.label),
            value: mode,
            groupValue: currentThemeMode,
            onChanged: (ThemeMode? selected) {
              Navigator.pop(context, selected);
            },
          );
        }).toList(),
      ),
    );
  }
}

