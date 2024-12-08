import 'package:abitur/pages/evaluation_new_page.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../storage/entities/subject.dart';
import '../../utils/pair.dart';

class AverageAnalytics extends StatefulWidget {
  const AverageAnalytics({super.key});

  @override
  State<AverageAnalytics> createState() => _AverageAnalyticsState();
}

class _AverageAnalyticsState extends State<AverageAnalytics> {

  DateTime get startDate => DateTime.now().add(Duration(days: -90));

  List<LineChartBarData> get lineData {
    return averageHistory.mapToIterable((key, value) => generateAverageData(key)).toList();
  }
  Map<Subject, List<Pair<DateTime, double>>> averageHistory = {};

  @override
  void initState() {
    _loadAverageHistory();
    super.initState();
  }

  void _loadAverageHistory() {
    setState(() {
      averageHistory = SubjectService.getAverageHistoryForAllSubjects();
    });
  }

  LineChartBarData generateAverageData(Subject s) {

    final data = averageHistory[s] ?? [];


    List<Pair<DateTime, double>> filteredAvgHistory = data.where((data) => data.first.isAfter(startDate)).toList();
    List<Pair<DateTime, double>> abandonedEntries = data.where((data) => !data.first.isAfter(startDate)).toList();
    if (abandonedEntries.isNotEmpty) { // Alte Durchschnitte entfernen, aber Startwert beibehalten
      filteredAvgHistory = [ Pair(startDate, abandonedEntries.last.second), ...filteredAvgHistory ];
    }
    return LineChartBarData(
      color: s.color,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      spots: filteredAvgHistory.map((data) => FlSpot(data.first.difference(startDate).inDays.toDouble(), data.second)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Durchschnittsübersicht",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 38,),
          AspectRatio(
            aspectRatio: 1.5,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(enabled: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: bottomTitleWidgets,
                    ),
                  ),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      getTitlesWidget: leftTitles,
                      showTitles: true,
                      interval: 1,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: lineData,
                minX: 0,
                maxX: DateTime.now().difference(startDate).inDays.toDouble(),
                maxY: 15,
                minY: 0,
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
      space: 5,
      child: Text(
        value.toInt().toString(),
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    Widget text = const Text('');
    DateTime dateValue = startDate.add(Duration(days: value.toInt()));

    if (dateValue.day == 1) {
      switch (dateValue.month) {
      case 1:
        text = const Text('Jan');
        break;
      case 2:
        text = const Text('Feb');
        break;
      case 3:
        text = const Text('Mär');
        break;
      case 4:
        text = const Text('Apr');
        break;
      case 5:
        text = const Text('Mai');
        break;
      case 6:
        text = const Text('Jun');
        break;
      case 7:
        text = const Text('Jul');
        break;
      case 8:
        text = const Text('Aug');
        break;
      case 9:
        text = const Text('Sep');
        break;
      case 10:
        text = const Text('Okt');
        break;
      case 11:
        text = const Text('Nov');
        break;
      case 12:
        text = const Text('Dez');
        break;
      }
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }
}
