import 'package:abitur/pages/settings_pages/settings_page.dart';
import 'package:abitur/pages/subject_pages/subject_chose_graduation_page.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/widgets/analytics/average_analytics.dart';
import 'package:abitur/widgets/analytics/subjects_analytics.dart';
import 'package:abitur/widgets/analytics/timetable_analytics.dart';
import 'package:abitur/widgets/percent_indicator.dart';
import 'package:flutter/material.dart';

import '../storage/services/settings_service.dart';
import '../widgets/analytics/projection_analytics.dart';
import '../widgets/info_card.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

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
            PercentIndicator(value: SubjectService.getCurrentAverage(),),
            if (SettingsService.choseGraduationSubjectsTime())
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InfoCard(
                    "Es wird Zeit, deine Abiturfächer zu wählen.",
                    action: "Wählen",
                    onAction: () {
                      Navigator.push(context,
                          MaterialPageRoute(
                            builder: (context) {
                              return SubjectChoseGraduationPage();
                            },
                            fullscreenDialog: true,
                          ));
                    },
                  )
              ),
            SubjectsAnalytics(
              subjects: SubjectService.findAllGradable(),
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
