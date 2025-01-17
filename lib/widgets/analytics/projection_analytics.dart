import 'package:abitur/pages/analytics_pages/projection_analytics_page.dart';
import 'package:abitur/widgets/percent_indicator.dart';
import 'package:flutter/material.dart';

import '../../storage/services/projection_service.dart';

class ProjectionAnalytics extends StatefulWidget {
  const ProjectionAnalytics({super.key});

  @override
  State<ProjectionAnalytics> createState() => _ProjectionAnalyticsState();
}

class _ProjectionAnalyticsState extends State<ProjectionAnalytics> {

  double graduationAvg = 0;

  @override
  void initState() {
    loadGraduationAvg();
    super.initState();
  }

  void loadGraduationAvg() {
    setState(() {
      graduationAvg = ProjectionService.getGraduationAvg();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Hochrechnung",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),

          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return ProjectionAnalyticsPage();
                }),
              );
              loadGraduationAvg();
            },
            child: Center(
              child: PercentIndicator(value: graduationAvg, type: PercentIndicatorType.note,),
            ),
          ),

        ],
      ),
    );
  }
}
