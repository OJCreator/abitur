import 'package:flutter/material.dart';

import '../../storage/entities/subject.dart';

class SubjectDropdown extends StatelessWidget {

  final List<Subject?> subjects;
  final Subject? selectedSubject;
  final Function(Subject? s) onSelected;

  const SubjectDropdown({
    required this.subjects,
    required this.selectedSubject,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      initialSelection: selectedSubject,
      expandedInsets: const EdgeInsets.all(0),
      label: Text("Fach"),
      onSelected: (s) {
        onSelected(s);
      },
      dropdownMenuEntries: subjects.map((subject) {
        return DropdownMenuEntry(
          value: subject,
          label: subject?.name ?? "Kein Fach",
        );
      }).toList(),
    );
  }
}
