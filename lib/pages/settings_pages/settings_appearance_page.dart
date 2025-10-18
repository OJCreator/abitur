import 'package:abitur/services/database/settings_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:abitur/utils/extensions/theme_mode_extension.dart';
import 'package:abitur/widgets/shimmer/shimmer_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../sqlite/entities/settings.dart';
import '../../utils/brightness_notifier.dart';
import '../../widgets/color_dialog.dart';

class SettingsAppearancePage extends StatefulWidget {
  const SettingsAppearancePage({super.key});

  @override
  State<SettingsAppearancePage> createState() => _SettingsAppearancePageState();
}

class _SettingsAppearancePageState extends State<SettingsAppearancePage> {

  late Future<Settings> s;

  @override
  void initState() {
    _loadSettings();
    super.initState();
  }

  void _loadSettings() {
    s = SettingsService.loadSettings();
  }

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
            FutureBuilder(
              future: s,
              builder: (context, asyncSnapshot) {
                if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                  return ListTile(
                    trailing: CircleAvatar(
                      backgroundColor: shimmerColor,
                    ),
                    title: Text("Akzentfarbe wählen"),
                  );
                }
                Settings settings = asyncSnapshot.data!;
                return ListTile(
                  trailing: CircleAvatar(
                    backgroundColor: settings.accentColor,
                  ),
                  title: Text("Akzentfarbe wählen"),
                  onTap: () async {
                    Color? newAccentColor = await showDialog(context: context, builder: (context) {
                      return ColorDialog(
                        initialColor: settings.accentColor,
                        title: "Akzentfarbe wählen",
                      );
                    });
                    if (newAccentColor == null) {
                      return;
                    }
                    setState(() {
                      SettingsService.setAccentColor(context, newAccentColor);
                    });
                    _loadSettings();
                  },
                );
              }
            ),
            FutureBuilder(
              future: s,
              builder: (context, asyncSnapshot) {
                if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                  return ListTile(
                    title: Text("Design"),
                    subtitle: ShimmerText(),
                  );
                }
                Settings settings = asyncSnapshot.data!;
                return ListTile(
                  title: Text("Design"),
                  subtitle: Text(settings.themeMode.label),
                  onTap: () async {
                    ThemeMode? newThemeMode = await showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      builder: (context) => ThemeModeSelectorSheet(currentThemeMode: settings.themeMode,),
                    );
                    if (newThemeMode == null) {
                      return;
                    }

                    setState(() {
                      settings.themeMode = newThemeMode;
                    });
                    SettingsService.saveSettings(settings);
                    Provider.of<BrightnessNotifier>(context, listen: false).setThemeMode(settings.themeMode);
                    _loadSettings();
                  },
                );
              }
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

