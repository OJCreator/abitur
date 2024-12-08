import 'package:flutter/material.dart';

class TermsMultipleChoice extends StatelessWidget {

  final Set<int> selectedTerms;
  final Function(Set<int> newSelection) onSelected;

  const TermsMultipleChoice({super.key, required this.selectedTerms, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      expandedInsets: const EdgeInsets.all(0),
      selected: selectedTerms,
      multiSelectionEnabled: true,
      showSelectedIcon: false,
      onSelectionChanged: onSelected,
      segments: [
        ButtonSegment(
          value: 0,
          label: Text("1. Halbjahr"),
        ),
        ButtonSegment(
          value: 1,
          label: Text("2. Halbjahr"),
        ),
        ButtonSegment(
          value: 2,
          label: Text("3. Halbjahr"),
        ),
        ButtonSegment(
          value: 3,
          label: Text("4. Halbjahr"),
        ),
      ],
    );
  }
}
