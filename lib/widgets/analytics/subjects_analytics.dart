import 'dart:math';

import 'package:abitur/pages/analytics_pages/analytics_subjects_page.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../in_app_purchases/purchase_service.dart';
import '../../pages/in_app_purchase_pages/full_version_page.dart';
import '../../storage/entities/subject.dart';

class SubjectsAnalytics extends StatefulWidget {

  final List<Subject> subjects;

  const SubjectsAnalytics({required this.subjects, super.key});

  @override
  State<StatefulWidget> createState() => SubjectsAnalyticsState();
}

class SubjectsAnalyticsState extends State<SubjectsAnalytics> {

  late List<BarChartGroupData> data;

  @override
  void initState() {
    super.initState();

    data = widget.subjects.asMap().mapToIterable((index, subject) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: SubjectService.getAverage(subject) ?? 0,
            color: subject.color,
            width: 12,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Fächerübersicht",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 38,),
          GestureDetector(
            onTap: () async {
              Feedback.forTap(context);
              if (PurchaseService.fullAccess) {
                await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return AnalyticsSubjectsPage();
                    })
                );
              } else {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return FullVersionPage(
                        nextPage: AnalyticsSubjectsPage(),
                      );
                    })
                );
              }
            },
            child: AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  maxY: 15,
                  minY: 0,
                  barGroups: data,
                  barTouchData: BarTouchData(enabled: false),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: bottomTitles,
                        reservedSize: 42,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: leftTitles,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    if (value.toInt() % 3 != 0) {
      return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(
        value.toInt().toString(),
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final List<String> titles = widget.subjects.map((e) {
      return e.shortName;
    }).toList();

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      child: Transform.rotate(
        angle: 45 * (pi/180),
        child: Text(
          titles[value.toInt()],
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
    );
  }
}