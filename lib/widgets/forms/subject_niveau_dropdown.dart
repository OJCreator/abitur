import 'package:abitur/utils/enums/subject_niveau.dart';
import 'package:flutter/material.dart';

class SubjectNiveauDropdown extends StatelessWidget {

  final String label;
  final List<SubjectNiveau> availableSubjectNiveaus;
  final SubjectNiveau? selectedSubjectNiveau;
  final Function(SubjectNiveau e) onSelected;

  const SubjectNiveauDropdown({
    this.label = "Fächertyp",
    required this.selectedSubjectNiveau,
    required this.availableSubjectNiveaus,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      initialSelection: selectedSubjectNiveau,
      expandedInsets: const EdgeInsets.all(0),
      label: Text(label),
      onSelected: (s) {
        if (s == null) return;
        onSelected(s);
      },
      dropdownMenuEntries: availableSubjectNiveaus.map((subjectNiveau) {
        return DropdownMenuEntry(
          value: subjectNiveau,
          label: subjectNiveau.name,
        );
      }).toList(),
    );
  }
}
