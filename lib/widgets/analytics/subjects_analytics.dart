import 'dart:math';

import 'package:abitur/pages/analytics_pages/analytics_subjects_page.dart';
import 'package:abitur/utils/extensions/map_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../in_app_purchases/purchase_service.dart';
import '../../pages/in_app_purchase_pages/full_version_page.dart';
import '../../services/database/subject_service.dart';
import '../../sqlite/entities/subject.dart';

class SubjectsAnalytics extends StatefulWidget {

  final List<Subject> subjects;

  const SubjectsAnalytics({required this.subjects, super.key});

  @override
  State<StatefulWidget> createState() => SubjectsAnalyticsState();
}

class SubjectsAnalyticsState extends State<SubjectsAnalytics> {


  List<BarChartGroupData>? data;
  Map<String, double> subjectAvgs = {};

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SubjectsAnalytics oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.subjects != widget.subjects) {
      _loadData();
    }
  }


  Future<void> _loadData() async {
    final averages = await SubjectService.getAverages(widget.subjects.map((s) => s.id).toList());

    data = widget.subjects.asMap().mapToIterable((index, subject) {
      return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: averages[subject.id] ?? 0,
              color: subject.color,
              width: 12,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
      );
    }).toList();

    setState(() { });
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
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withAlpha(77),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withAlpha(77),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
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