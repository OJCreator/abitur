import 'package:abitur/pages/settings_page.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/widgets/analytics/average_analytics.dart';
import 'package:abitur/widgets/analytics/subjects_analytics.dart';
import 'package:abitur/widgets/analytics/timetable_analytics.dart';
import 'package:abitur/widgets/percent_indicator.dart';
import 'package:flutter/material.dart';

import '../widgets/analytics/projection_analytics.dart';

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
