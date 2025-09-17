import 'package:abitur/utils/enums/subject_type.dart';
import 'package:flutter/material.dart';

class SubjectTypeDropdown extends StatelessWidget {

  final String label;
  final SubjectType? selectedSubjectType;
  final Function(SubjectType? e) onSelected;

  const SubjectTypeDropdown({
    this.label = "Fachrichtung",
    required this.selectedSubjectType,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      initialSelection: selectedSubjectType,
      expandedInsets: const EdgeInsets.all(0),
      label: Text(label),
      onSelected: (s) {
        onSelected(s);
      },
      dropdownMenuEntries: SubjectType.values.map((subjectType) {
        return DropdownMenuEntry(
          value: subjectType,
          label: subjectType.displayName,
        );
      }).toList(),
    );
  }
}
