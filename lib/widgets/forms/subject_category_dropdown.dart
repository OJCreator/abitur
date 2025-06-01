import 'package:abitur/storage/entities/subject_category.dart';
import 'package:flutter/material.dart';

class SubjectCategoryDropdown extends StatelessWidget {

  final String label;
  final List<SubjectCategory?> subjectCategories;
  final SubjectCategory? selectedSubjectCategory;
  final Function(SubjectCategory? e) onSelected;

  const SubjectCategoryDropdown({
    this.label = "Fachrichtung",
    required this.subjectCategories,
    required this.selectedSubjectCategory,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      initialSelection: selectedSubjectCategory,
      expandedInsets: const EdgeInsets.all(0),
      label: Text(label),
      onSelected: (s) {
        onSelected(s);
      },
      dropdownMenuEntries: subjectCategories.map((subjectCategory) {
        return DropdownMenuEntry(
          value: subjectCategory,
          label: subjectCategory?.name ?? "Kein Typ",
        );
      }).toList(),
    );
  }
}
