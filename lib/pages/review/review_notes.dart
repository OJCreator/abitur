import 'package:abitur/storage/services/evaluation_date_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReviewNotes extends StatefulWidget {
  const ReviewNotes({super.key});

  @override
  State<ReviewNotes> createState() => _ReviewNotesState();
}

class _ReviewNotesState extends State<ReviewNotes> {

  late final List<int> noteAmounts = List.generate(16, (_) => 0);

  @override
  void initState() {
    final evaluationDates = EvaluationDateService.findAll();
    for (var e in evaluationDates) {
      if (e.note == null) {
        continue;
      }
      noteAmounts[e.note!]++;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Verteilung der Punktzahlen"),
        AspectRatio(
          aspectRatio: 1,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 15,
              minY: 0,
              maxY: noteAmounts.reduce((curr, next) => curr > next ? curr : next).toDouble(),

              // Optional: Achsenbeschriftungen
              // titlesData: FlTitlesData(
              //   bottomTitles: AxisTitles(
              //     sideTitles: SideTitles(
              //       showTitles: true,
              //       interval: 1,
              //       getTitlesWidget: (value, meta) {
              //         return Text(value.toInt().toString());
              //       },
              //     ),
              //   ),
              //   leftTitles: AxisTitles(
              //     sideTitles: SideTitles(
              //       showTitles: true,
              //       interval: 5,
              //       getTitlesWidget: (value, meta) {
              //         return Text(value.toInt().toString());
              //       },
              //     ),
              //   ),
              // ),

              // Die eigentlichen Daten
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    16, (index) => FlSpot(
                      (index).toDouble(),
                      noteAmounts[index].toDouble(),
                    ),
                  ),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  dotData: FlDotData(show: true),
                ),
              ],
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
            ),
          ),
        ),
      ],
    );
  }
}
