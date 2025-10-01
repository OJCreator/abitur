import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../storage/entities/subject.dart';
import '../../storage/services/subject_service.dart';
import '../../utils/pair.dart';

class AnalyticsAveragePage extends StatefulWidget {

  const AnalyticsAveragePage({super.key});

  @override
  State<AnalyticsAveragePage> createState() => _AnalyticsAveragePageState();
}

class _AnalyticsAveragePageState extends State<AnalyticsAveragePage> {

  DateRange dateRange = DateRange.all;
  DateTime get startDate => DateTime.now().add(Duration(days: -300));


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Durchschnittsübersicht"),
      ),
      body: Column(
        children: [
          FilterChip(
            label: Text(dateRange.displayName),
            onSelected: (s) {
              changeDateRange();
            },
            selected: true,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnalyticsAverageGraph(dateRange: dateRange,),
          ),
        ],
      ),
    );
  }
  
  void changeDateRange() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,

      builder: (context) {
        return DraggableScrollableSheet(
            expand: false,
            snap: true,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: RadioGroup<DateRange>(
                  onChanged: (newValue) {
                    setState(() {
                      dateRange = newValue!;
                    });
                    Navigator.of(context).pop();
                  },
                  groupValue: dateRange,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: DateRange.values.map((option) =>
                      RadioListTile(
                        value: option,
                        title: Text(option.displayName),
                        selected: true,
                      )
                    ).toList(),
                  ),
                ),
              );
            }
        );
      },
    );
  }
}

enum DateRange {
  all("Gesamt bisher", null),
  ninety("Letzte 90 Tage", 90),
  halfYear("Letzte 180 Tage", 180),
  year("Letzte 365 Tage", 365);

  final String displayName;
  final int? days;

  const DateRange(this.displayName, this.days);
}

class AnalyticsAverageGraph extends StatefulWidget {

  final DateRange dateRange;

  const AnalyticsAverageGraph({super.key, required this.dateRange});

  @override
  State<AnalyticsAverageGraph> createState() => _AnalyticsAverageGraphState();
}

class _AnalyticsAverageGraphState extends State<AnalyticsAverageGraph> {

  DateTime get startDate => widget.dateRange.days == null ? SettingsService.firstDayOfSchool : DateTime.now().add(Duration(days: -widget.dateRange.days!));

  late Future<Map<Subject, List<Pair<DateTime, double>>>> averageHistory;

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

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: FutureBuilder(
        future: averageHistory,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return LineChart(
            duration: Duration.zero,
            LineChartData(
              lineTouchData: LineTouchData(enabled: false),
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
              lineBarsData: snapshot.data!.mapToIterable((key, value) => generateAverageData(key, value)).toList(),
              minX: 0,
              maxX: DateTime.now().difference(startDate).inDays.toDouble(),
              maxY: 15,
              minY: 0,
            ),
          );
        },
      ),
    );
  }

  LineChartBarData generateAverageData(Subject s, List<Pair<DateTime, double>> data) {

    List<Pair<DateTime, double>> filteredAvgHistory = data.where((data) => data.first.isAfter(startDate)).toList();
    List<Pair<DateTime, double>> abandonedEntries = data.where((data) => !data.first.isAfter(startDate)).toList();
    if (abandonedEntries.isNotEmpty) { // Alte Durchschnitte entfernen, aber Startwert beibehalten
      filteredAvgHistory = [ Pair(startDate, abandonedEntries.last.second), ...filteredAvgHistory ];
    }
    return LineChartBarData(
      color: s.color,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
        getDotPainter: (a,b,c,d) => FlDotCirclePainter(
          color: s.color,
          radius: 3,
        ),
      ),
      spots: filteredAvgHistory.map((data) => FlSpot(data.first.difference(startDate).inDays.toDouble(), data.second)).toList(),
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
