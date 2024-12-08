import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class PercentIndicator extends StatelessWidget {

  final double? pointAverage;
  String get pointString {
    if (pointAverage == null) {
      return "-";
    }
    double oneDecimalAvg = (pointAverage! * 10).round() / 10.0;
    return oneDecimalAvg.toString();
  }
  final Color? color;

  const PercentIndicator({required this.pointAverage, super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 75,
      animation: true,
      curve: Curves.easeOut,
      animationDuration: 1000,
      percent: (pointAverage ?? 0) / 15.0,
      circularStrokeCap: CircularStrokeCap.round,
      lineWidth: 10,
      progressColor: color ?? Theme.of(context).colorScheme.surfaceTint,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      center: Text(
        pointString,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
