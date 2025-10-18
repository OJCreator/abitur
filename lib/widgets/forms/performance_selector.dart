import 'package:flutter/material.dart';

import '../../sqlite/entities/performance.dart';

class PerformanceSelector extends StatelessWidget {

  final List<Performance> performances;
  final Performance? currentPerformance;
  final Function(Performance selected)? onSelected;

  const PerformanceSelector({
    required this.performances,
    required this.currentPerformance,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Performance>(
      expandedInsets: const EdgeInsets.all(0),
      selected: currentPerformance == null ? {} : {currentPerformance!},
      onSelectionChanged: onSelected == null ? null : (Set<Performance> newSelection) {
        onSelected!(newSelection.first);
      },
      showSelectedIcon: false,
      segments: performances.map((performance) {
        return ButtonSegment(
          value: performance,
          label: Text(performance.name),
        );
      }).toList(),
    );
  }
}
