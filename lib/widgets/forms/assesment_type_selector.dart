import 'package:abitur/storage/entities/evaluation_type.dart';
import 'package:flutter/material.dart';

class AssessmentTypeSelector extends StatelessWidget {

  final AssessmentType selectedAssessmentType;
  final Function(AssessmentType newSelection) onSelected;

  const AssessmentTypeSelector({super.key, required this.selectedAssessmentType, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      expandedInsets: const EdgeInsets.all(0),
      selected: {selectedAssessmentType},
      showSelectedIcon: false,
      onSelectionChanged: (Set<AssessmentType> newSelection) {
        onSelected(newSelection.first);
      },
      segments: [
        ButtonSegment(
          value: AssessmentType.written,
          label: Text("Schriftlich"),
        ),
        ButtonSegment(
          value: AssessmentType.oral,
          label: Text("Mündlich"),
        ),
        ButtonSegment(
          value: AssessmentType.other,
          label: Text("Sonstiges"),
        ),
      ],
    );
  }
}
