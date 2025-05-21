import 'package:abitur/widgets/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class PercentIndicator extends StatelessWidget {

  final double? value;
  final PercentIndicatorType type;
  double get _percent {
    switch (type) {
      case PercentIndicatorType.points:
        return (value ?? 0) / 15.0;
      case PercentIndicatorType.note:
        return -((value ?? 6) - 6) / 5.0;
    }
  }
  String get pointString {
    if (value == null) {
      return "-";
    }
    if (type == PercentIndicatorType.points) {
      double oneDecimalAvg = (value! * 100).round() / 100.0;
      return oneDecimalAvg.toString();
    } else {
      return value.toString();
    }
  }
  final Color? color;
  final bool shimmer;

  const PercentIndicator({required this.value, this.type = PercentIndicatorType.points, super.key, this.color}):
        shimmer = false;

  const PercentIndicator.shimmer({this.color, super.key}):
        value = 0,
        type = PercentIndicatorType.points,
        shimmer = true;

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 75,
      animation: true,
      curve: Curves.easeOut,
      animationDuration: 1000,
      percent: _percent,
      circularStrokeCap: CircularStrokeCap.round,
      lineWidth: 10,
      progressColor: color ?? Theme.of(context).colorScheme.surfaceTint,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      center: shimmer ? Shimmer(width: 60, height: 25,) : Text(
        pointString,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

enum PercentIndicatorType {
  points, note;
}
