import 'package:abitur/storage/entities/evaluation_date.dart';
import 'package:abitur/storage/services/evaluation_date_service.dart';
import 'package:abitur/widgets/forms/form_gap.dart';
import 'package:flutter/material.dart';

import '../../../widgets/forms/date_input.dart';

class SubjectEditGraduationEvaluationDialog extends StatefulWidget {

  final EvaluationDate graduationEvaluationDate;

  const SubjectEditGraduationEvaluationDialog({super.key, required this.graduationEvaluationDate});

  @override
  State<SubjectEditGraduationEvaluationDialog> createState() => _SubjectEditGraduationEvaluationDialogState();
}

class _SubjectEditGraduationEvaluationDialogState extends State<SubjectEditGraduationEvaluationDialog> {

  late bool _editWeighting;

  late bool giveGraduationNote;

  late int? selectedNote;
  late int selectedWeight;
  late DateTime? selectedDate;

  @override
  void initState() {

    _editWeighting = widget.graduationEvaluationDate.evaluation.evaluationDates.length > 1;
    selectedWeight = widget.graduationEvaluationDate.weight;

    giveGraduationNote = widget.graduationEvaluationDate.note != null;
    selectedNote = widget.graduationEvaluationDate.note;
    selectedDate = widget.graduationEvaluationDate.date;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Daten bearbeiten"),
      content: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text("Note geben"),
              value: giveGraduationNote,
              onChanged: (newValue) {
                setState(() {
                  giveGraduationNote = !giveGraduationNote;
                  if (giveGraduationNote) {
                    selectedNote = 8;
                  } else {
                    selectedNote = null;
                  }
                });
              },
            ),
            Slider(
              min: 0,
              max: 15,
              divisions: 15,
              value: selectedNote?.toDouble() ?? 8,
              label: "$selectedNote",
              onChanged: giveGraduationNote ? (newValue) {
                setState(() {
                  selectedNote = newValue.toInt();
                });
              } : null,
              year2023: false,
            ),
            FormGap(),
            if (_editWeighting) ...[
              Text("Gewichtung"),
              Slider(
                min: 0,
                max: 6,
                divisions: 6,
                value: selectedWeight?.toDouble() ?? 1,
                label: "$selectedWeight",
                onChanged: (newValue) {
                  setState(() {
                    selectedWeight = newValue.toInt();
                  });
                },
                year2023: false,
              ),
              FormGap(),
            ],
            DateInput(
              dateTime: selectedDate,
              onSelected: (newValue) {
                setState(() {
                  selectedDate = newValue;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Text("Abbrechen"),
        ),
        FilledButton(
          onPressed: () async {
            await EvaluationDateService.editEvaluationDate(widget.graduationEvaluationDate, date: selectedDate, note: selectedNote, weight: selectedWeight);
            Navigator.pop(context, true);
          },
          child: Text("Speichern"),
        ),
      ],
    );
  }
}
