import 'package:flutter/material.dart';

class TermSelector extends StatelessWidget {

  final int selectedTerm;
  final Set<int> terms;
  final Function(int term)? onSelected;

  const TermSelector({
    super.key,
    required this.selectedTerm,
    required this.terms,
    required this.onSelected
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      expandedInsets: EdgeInsets.all(0),
      selected: {selectedTerm},
      showSelectedIcon: false,
      onSelectionChanged: onSelected == null ? null : (Set<int> newSelection) {
        onSelected!(newSelection.first);
      },
      segments: terms.map((term) {
        return ButtonSegment(
            value: term,
            label: Text("${term + 1}. Halbjahr")
        );
      }).toList(),
    );
  }
}
