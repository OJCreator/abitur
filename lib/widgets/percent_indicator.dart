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
  final String? title;
  final String? tooltip;
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
  final Function()? edit;

  const PercentIndicator({required this.value, this.type = PercentIndicatorType.points, super.key, this.color, this.title, this.tooltip, this.edit}):
        shimmer = false;

  const PercentIndicator.shimmer({this.color, super.key, this.title, this.tooltip}):
        value = 0,
        type = PercentIndicatorType.points,
        shimmer = true,
        edit = null;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Tooltip(
          message: tooltip ?? (type == PercentIndicatorType.note ? "Note" : "Punkte"),
          child: CircularPercentIndicator(
            radius: 75,
            animation: true,
            curve: Curves.easeOut,
            animationDuration: 1000,
            percent: _percent,
            circularStrokeCap: CircularStrokeCap.round,
            lineWidth: 10,
            progressColor: color ?? Theme.of(context).colorScheme.surfaceTint,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (shimmer)
                  Shimmer(width: 60, height: 30,),
                if (!shimmer)
                  Text(
                    pointString,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                if (title != null)
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
              ],
            ),
          ),
        ),
        if (edit != null)
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              shape: const CircleBorder(),
              elevation: 2,
              child: IconButton(
                icon: Icon(Icons.edit, size: 20),
                onPressed: edit,
                tooltip: "Bearbeiten",
                constraints: const BoxConstraints(),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

enum PercentIndicatorType {
  points, note;
}
