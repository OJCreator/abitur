import 'package:abitur/in_app_purchases/purchase_service.dart';
import 'package:abitur/pages/review/review_locked_page.dart';
import 'package:abitur/pages/review/review_page.dart';
import 'package:abitur/pages/settings_pages/settings_page.dart';
import 'package:abitur/pages/subject_pages/subject_chose_graduation_page.dart';
import 'package:abitur/services/database/settings_service.dart';
import 'package:abitur/widgets/analytics/average_analytics.dart';
import 'package:abitur/widgets/analytics/subjects_analytics.dart';
import 'package:abitur/widgets/analytics/timetable_analytics.dart';
import 'package:abitur/widgets/percent_indicator.dart';
import 'package:flutter/material.dart';

import '../services/database/subject_service.dart';
import '../widgets/analytics/projection_analytics.dart';
import '../widgets/info_card.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {

  late Future<double?> currentAverage;

  @override
  void initState() {
    currentAverage = SubjectService.getCurrentAverage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return SettingsPage();
                }),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
              future: currentAverage,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return PercentIndicator.shimmer(title: "Durchschnitt",);
                return PercentIndicator(value: snapshot.data, type: PercentIndicatorType.points, title: "Durchschnitt", tooltip: "Durschschnitt der Halbjahresnoten",);
              },
            ),
            FutureBuilder(
              future: SettingsService.dayToShowReview(),
              builder: (context, asyncSnapshot) {
                if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                  return Container();
                }
                DateTime dayToShowReview = asyncSnapshot.data!;
                if (!DateTime.now().isAfter(dayToShowReview)) return Container();
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InfoCard(
                    "Dein persönliches Abitur-Review ist fertig!",
                    action: "Ansehen",
                    onAction: () {
                      if (PurchaseService.abiturReviewAccess) {
                        Navigator.push(context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ReviewPage();
                              },
                            ));
                      } else {
                        Navigator.push(context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ReviewLockedPage();
                              },
                            ));
                      }
                    },
                  ),
                );
              }
            ),
            FutureBuilder(
                future: SettingsService.dayToChoseGraduationSubjects(),
                builder: (context, asyncSnapshot) {
                  if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                    return Container();
                  }
                  DateTime dayToChoseGraduationSubjects = asyncSnapshot.data!;
                  if (!DateTime.now().isAfter(dayToChoseGraduationSubjects)) return Container();
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InfoCard(
                      "Es wird Zeit, deine Abiturfächer zu wählen.",
                      action: "Wählen",
                      onAction: () async {
                        Navigator.push(context,
                            MaterialPageRoute(
                              builder: (context) {
                                return SubjectChoseGraduationPage();
                              },
                              fullscreenDialog: true,
                            ));
                      },
                    ),
                  );
                }
            ),
            FutureBuilder(
              future: SubjectService.findAllGradable(),
              builder: (context, asyncSnapshot) {
                return SubjectsAnalytics(
                  subjects: asyncSnapshot.data ?? [],
                );
              }
            ),
            TimetableAnalytics(),
            AverageAnalytics(),
            ProjectionAnalytics(),
          ],
        ),
      ),
    );
  }
}
