import 'package:flutter/material.dart';

import '../../storage/entities/subject.dart';

class SubjectTypeSelector extends StatelessWidget {

  final SubjectType selectedSubjectType;
  final Function(SubjectType newSelection) onSelected;

  const SubjectTypeSelector({super.key, required this.selectedSubjectType, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      expandedInsets: const EdgeInsets.all(0),
      selected: {selectedSubjectType},
      showSelectedIcon: false,
      onSelectionChanged: (Set<SubjectType> newSelection) {
        onSelected(newSelection.first);
      },
      segments: [
        ButtonSegment(
          value: SubjectType.basic,
          label: Text("gA"),
        ),
        ButtonSegment(
          value: SubjectType.advanced,
          label: Text("eA"),
        ),
        ButtonSegment(
          value: SubjectType.profile,
          label: Text("Profilfach"),
        ),
        ButtonSegment(
          value: SubjectType.voluntary,
          label: Text("Wahlfach"),
        ),
      ],
    );
  }
}
