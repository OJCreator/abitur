import 'dart:math';

import 'package:abitur/utils/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../storage/services/evaluation_date_service.dart';

class ReviewDays extends StatefulWidget {
  const ReviewDays({super.key});

  @override
  State<ReviewDays> createState() => _ReviewDaysState();
}

class _ReviewDaysState extends State<ReviewDays> {

  late final List<double> dayAverages = List.generate(5, (_) => 0);

  @override
  void initState() {
    final evaluationDates = EvaluationDateService.findAll();
    final groupedEvaluationDates = evaluationDates.where((e) => e.date != null).toList().groupBy((e) => e.date!.weekday);

    groupedEvaluationDates.forEach((day, evaluationDates) {
      final notes = evaluationDates.map((e) => e.note).where((note) => note != null);
      if (notes.isEmpty) {
        dayAverages[day-1] = 0.0;
      } else {
        final sum = notes.fold<double>(0.0, (total, note) => total + note!);
        dayAverages[day-1] = sum / notes.length;
      }
    });


    // for (var e in evaluationDates) {
    //   if (e.note == null || e.date == null || e.date!.weekday > 5) {
    //     continue;
    //   }
    //   dayAverages[e.date!.weekday - 1]++;
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Durchschnitt pro Tag"),
        AspectRatio(
          aspectRatio: 1,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 4,
              minY: min(dayAverages.reduce((curr, next) => curr < next ? curr : next).toDouble(), 9).floorToDouble(),
              maxY: max(dayAverages.reduce((curr, next) => curr > next ? curr : next).toDouble(), 13).ceilToDouble(),

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
                    5, (index) => FlSpot(
                    (index).toDouble(),
                    dayAverages[index].toDouble(),
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
