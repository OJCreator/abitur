import 'package:abitur/utils/enums/subject_niveau.dart';
import 'package:flutter/material.dart';


class SubjectNiveauSelector extends StatelessWidget {

  final SubjectNiveau selectedSubjectNiveau;
  final Function(SubjectNiveau newSelection)? onSelected;

  const SubjectNiveauSelector({super.key, required this.selectedSubjectNiveau, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      expandedInsets: const EdgeInsets.all(0),
      selected: {selectedSubjectNiveau},
      showSelectedIcon: false,
      onSelectionChanged: onSelected == null ? null : (Set<SubjectNiveau> newSelection) {
        onSelected!(newSelection.first);
      },
      segments: [
        ButtonSegment(
          value: SubjectNiveau.basic,
          label: Text("grundlegendes A."),
        ),
        ButtonSegment(
          value: SubjectNiveau.advanced,
          label: Text("erhöhtes A."),
        ),
      ],
    );
  }
}
