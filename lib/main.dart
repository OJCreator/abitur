import 'package:abitur/pages/evaluation_pages/evaluations_page.dart';
import 'package:abitur/pages/analytics_page.dart';
import 'package:abitur/pages/subject_pages/subjects_page.dart';
import 'package:abitur/pages/welcome_screen.dart';
import 'package:abitur/storage/services/notification_service.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/storage.dart';
import 'package:abitur/utils/brightness_notifier.dart';
import 'package:abitur/utils/seed_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart';

// TODO Feature: Wochenübersicht bis Abitur
// TODO Feature: Startseite modular anpassbar
// TODO Feature: Seminararbeit irgendwie anders behandeln
// TODO Feature: Ferien offline
// TODO Feature: Abiturdaten fetchen und eintragen

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting();
  await NotificationService.init();
  initializeTimeZones();
  await Storage.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => SeedNotifier(),
      child: ChangeNotifierProvider(
        create: (_) => BrightnessNotifier(),
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<SeedNotifier>(
      builder: (BuildContext context, SeedNotifier seedValue, Widget? child) {
        return Consumer<BrightnessNotifier>(
          builder: (BuildContext context, BrightnessNotifier value, Widget? child) {
            Brightness b = value.currentBrightness;
            return MaterialApp(
              navigatorKey: navigatorKey,
              supportedLocales: [
                Locale("de"),
              ],
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate, // Lokalisierung für Material-Widgets
                GlobalWidgetsLocalizations.delegate,  // Basis-Widgets-Lokalisierung
                GlobalCupertinoLocalizations.delegate, // Lokalisierung für Cupertino-Widgets
              ],
              title: "Abitur",
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: seedValue.seed, brightness: b,),
                useMaterial3: true,
                brightness: b,
              ),
              home: SettingsService.loadSettings().viewedWelcomeScreen ? ScreenScaffolding() : WelcomeScreen(),
            );
          },
        );
      }
    );
  }
}

class ScreenScaffolding extends StatefulWidget {

  final List<Widget> screens = [
    AnalyticsPage(),
    SubjectsPage(),
    EvaluationsPage(),
  ];

  ScreenScaffolding({super.key});

  @override
  State<ScreenScaffolding> createState() => _ScreenScaffoldingState();
}

class _ScreenScaffoldingState extends State<ScreenScaffolding> {

  int screenIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: screenIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        setState(() {
          screenIndex = 0;
        });
      },
      child: Scaffold(
        body: widget.screens[screenIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: screenIndex,
          onDestinationSelected: (value) {
            setState(() {
              screenIndex = value;
            });
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

          destinations: [
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics),
              label: "Analyse",
            ),
            NavigationDestination(
              icon: Icon(Icons.list_outlined),
              selectedIcon: Icon(Icons.list),
              label: "Fächer",
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: "Prüfungen",
            ),
          ],
        ),
      ),
    );
  }
}
