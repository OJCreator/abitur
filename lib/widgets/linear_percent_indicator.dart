import 'package:flutter/material.dart';

class LinearPercentIndicator extends StatelessWidget {

  final String label;
  final String description;
  final double value;
  final Color? color;

  const LinearPercentIndicator({
    super.key,
    this.label = "",
    this.description = "",
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          LinearProgressIndicator(
            value: value,
            minHeight: 7,
            color: color ?? Theme.of(context).colorScheme.surfaceTint,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(5),
          ),
          Text(description, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
