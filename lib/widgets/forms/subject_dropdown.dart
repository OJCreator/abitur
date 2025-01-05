import 'package:flutter/material.dart';

import '../../storage/entities/subject.dart';

class SubjectDropdown extends StatelessWidget {

  final String label;
  final List<Subject?> subjects;
  final Subject? selectedSubject;
  final bool Function(Subject s)? disabled;
  final Function(Subject? s) onSelected;

  const SubjectDropdown({
    this.label = "Fach",
    required this.subjects,
    required this.selectedSubject,
    required this.onSelected,
    this.disabled,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      initialSelection: selectedSubject,
      expandedInsets: const EdgeInsets.all(0),
      label: Text(label),
      onSelected: (s) {
        onSelected(s);
      },
      dropdownMenuEntries: subjects.map((subject) {
        return DropdownMenuEntry(
          value: subject,
          enabled: disabled == null || subject == null ? true : !disabled!(subject),
          label: subject?.name ?? "Kein Fach",
        );
      }).toList(),
    );
  }
}
