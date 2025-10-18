import 'package:flutter/material.dart';

import '../../sqlite/entities/evaluation/evaluation_type.dart';

class EvaluationTypeDropdown extends StatelessWidget {

  final String label;
  final List<EvaluationType?> evaluationTypes;
  final EvaluationType? selectedEvaluationType;
  final Function(EvaluationType? e) onSelected;

  const EvaluationTypeDropdown({
    this.label = "Prüfungstyp",
    required this.evaluationTypes,
    required this.selectedEvaluationType,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      initialSelection: selectedEvaluationType,
      expandedInsets: const EdgeInsets.all(0),
      label: Text(label),
      onSelected: (s) {
        onSelected(s);
      },
      dropdownMenuEntries: evaluationTypes.map((evaluationType) {
        return DropdownMenuEntry(
          value: evaluationType,
          label: evaluationType?.name ?? "Kein Typ",
        );
      }).toList(),
    );
  }
}
