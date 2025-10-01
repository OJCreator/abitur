import 'package:abitur/isolates/models/projection/projection_model.dart';
import 'package:abitur/pages/analytics_pages/analytics_projection_page.dart';
import 'package:abitur/widgets/percent_indicator.dart';
import 'package:flutter/material.dart';

import '../../storage/services/projection_service.dart';
import '../forms/form_gap.dart';
import '../linear_percent_indicator.dart';

class ProjectionAnalytics extends StatefulWidget {
  const ProjectionAnalytics({super.key});

  @override
  State<ProjectionAnalytics> createState() => _ProjectionAnalyticsState();
}

class _ProjectionAnalyticsState extends State<ProjectionAnalytics> {

  late Future<ProjectionModel> projection;

  @override
  void initState() {
    loadGraduationAvg();
    super.initState();
  }

  void loadGraduationAvg() {
    setState(() {
      projection = ProjectionService.computeProjectionIsolated();
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
              Feedback.forTap(context);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return ProjectionAnalyticsPage();
                }),
              );
              loadGraduationAvg();
            },
            child: Center(
              child: Column(
                children: [
                  FutureBuilder(
                    future: projection,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return PercentIndicator.shimmer(title: "Abiturschnitt",);
                      return PercentIndicator(value: snapshot.data!.graduationAverage, type: PercentIndicatorType.note, title: "Abiturschnitt",);
                    },
                  ),
                  FormGap(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        FutureBuilder(
                            future: projection,
                            builder: (context, snapshot) {
                              return LinearPercentIndicator(
                                label: "Block 1",
                                description: snapshot.hasData ? "${snapshot.data!.resultBlock1} / 600 Punkten" : "max. 600 Punkte",
                                value: snapshot.hasData ? (snapshot.data!.resultBlock1 / 600) : 0,
                              );
                            }
                        ),
                        FormGap(),
                        FutureBuilder(
                            future: projection,
                            builder: (context, snapshot) {
                              return LinearPercentIndicator(
                                label: "Block 2",
                                description: snapshot.hasData ? "${snapshot.data!.resultBlock2} / 300 Punkten" : "max. 300 Punkte",
                                value: snapshot.hasData ? (snapshot.data!.resultBlock2 / 300) : 0,
                              );
                            }
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
