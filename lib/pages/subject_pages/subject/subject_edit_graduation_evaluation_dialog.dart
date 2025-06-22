import 'package:abitur/storage/entities/graduation/graduation_evaluation.dart';
import 'package:abitur/storage/services/graduation_service.dart';
import 'package:abitur/widgets/forms/form_gap.dart';
import 'package:flutter/material.dart';

import '../../../widgets/forms/date_input.dart';

class SubjectEditGraduationEvaluationDialog extends StatefulWidget {

  final GraduationEvaluation graduationEvaluation;

  const SubjectEditGraduationEvaluationDialog({super.key, required this.graduationEvaluation});

  @override
  State<SubjectEditGraduationEvaluationDialog> createState() => _SubjectEditGraduationEvaluationDialogState();
}

class _SubjectEditGraduationEvaluationDialogState extends State<SubjectEditGraduationEvaluationDialog> {

  // late bool _editWeighting;
  //
  // late bool giveGraduationNote;
  //
  // late int? selectedNote;
  // late int selectedWeight;
  // late DateTime? selectedDate;

  // neu
  late bool _giveNotePartOne;
  late int? _notePartOne;
  late int _weightPartOne;
  late DateTime? _datePartOne;
  late bool _divideEvaluation;
  late bool _giveNotePartTwo;
  late int? _notePartTwo;
  late int _weightPartTwo;
  late DateTime? _datePartTwo;

  late final bool secondGraduationDateAvailable;

  @override
  void initState() {


    _giveNotePartOne = widget.graduationEvaluation.notePartOne != null;
    _notePartOne = widget.graduationEvaluation.notePartOne;
    _weightPartOne = widget.graduationEvaluation.weightPartOne;
    _datePartOne = widget.graduationEvaluation.datePartOne;
    _divideEvaluation = widget.graduationEvaluation.isDividedEvaluation;
    _giveNotePartTwo = widget.graduationEvaluation.notePartTwo != null;
    _notePartTwo = widget.graduationEvaluation.notePartTwo;
    _weightPartTwo = widget.graduationEvaluation.weightPartTwo;
    _datePartTwo = widget.graduationEvaluation.datePartTwo;

    secondGraduationDateAvailable = GraduationService.canAddSecondGraduationDate(widget.graduationEvaluation);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        left: 16,
        right: 16,
      ),
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (secondGraduationDateAvailable)
              ListTile(
                title: Text(
                  "Hauptprüfung",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                dense: true,
              ),
            SwitchListTile(
              title: Text("Note geben"),
              value: _giveNotePartOne,
              onChanged: (newValue) {
                setState(() {
                  _giveNotePartOne = newValue;
                  if (newValue) {
                    _notePartOne = 8;
                  } else {
                    _notePartOne = null;
                  }
                });
                _saveChanges();
              },
            ),
            Slider(
              min: 0,
              max: 15,
              divisions: 15,
              value: _notePartOne?.toDouble() ?? 8,
              label: "$_notePartOne",
              onChanged: _giveNotePartOne ? (newValue) {
                setState(() {
                  _notePartOne = newValue.toInt();
                });
                _saveChanges();
              } : null,
              year2023: false,
            ),
            FormGap(),
            Text(
              "Gewichtung",
              style: TextStyle(
                color: _divideEvaluation ? null : Theme.of(context).disabledColor,
              ),
            ),
            Slider(
              min: 0,
              max: 6,
              divisions: 6,
              value: _weightPartOne.toDouble(),
              label: "$_weightPartOne",
              onChanged: _divideEvaluation ? (newValue) {
                setState(() {
                  _weightPartOne = newValue.toInt();
                });
                _saveChanges();
              } : null,
              year2023: false,
            ),
            FormGap(),
            DateInput(
              dateTime: _datePartOne,
              onSelected: (newValue) {
                setState(() {
                  _datePartOne = newValue;
                });
                _saveChanges();
              },
            ),
            FormGap(),
            if (secondGraduationDateAvailable) ...[
              ListTile(
                title: Text(
                  "Zweiter Prüfungstermin",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                dense: true,
              ),
              SwitchListTile(
                title: Text("Zweiter Prüfungstermin"),
                value: _divideEvaluation,
                onChanged: (newValue) {
                  setState(() {
                    _divideEvaluation = newValue;
                    if (!newValue) {
                      _divideEvaluation = false;
                      _giveNotePartTwo = false;
                      _notePartTwo = null;
                      _weightPartOne = 1;
                      _weightPartTwo = 1;
                      _datePartTwo = null;
                    }
                  });
                  _saveChanges();
                },
              ),
              SwitchListTile(
                title: Text("Note geben"),
                value: _giveNotePartTwo,
                onChanged: _divideEvaluation ? (newValue) {
                  setState(() {
                    _giveNotePartTwo = newValue;
                    if (newValue) {
                      _notePartTwo = 8;
                    } else {
                      _notePartTwo = null;
                    }
                  });
                  _saveChanges();
                } : null,
              ),
              Slider(
                min: 0,
                max: 15,
                divisions: 15,
                value: _notePartTwo?.toDouble() ?? 8,
                label: "$_notePartTwo",
                onChanged: _giveNotePartTwo ? (newValue) {
                  setState(() {
                    _notePartTwo = newValue.toInt();
                  });
                  _saveChanges();
                } : null,
                year2023: false,
              ),
              FormGap(),
              Text(
                "Gewichtung",
                style: TextStyle(
                  color: _divideEvaluation ? null : Theme.of(context).disabledColor,
                ),
              ),
              Slider(
                min: 0,
                max: 6,
                divisions: 6,
                value: _weightPartTwo.toDouble(),
                label: "$_weightPartTwo",
                onChanged: _divideEvaluation ? (newValue) {
                  setState(() {
                    _weightPartTwo = newValue.toInt();
                  });
                  _saveChanges();
                } : null,
                year2023: false,
              ),
              FormGap(),
              DateInput(
                dateTime: _datePartTwo,
                onSelected: _divideEvaluation ? (newValue) {
                  setState(() {
                    _datePartTwo = newValue;
                  });
                  _saveChanges();
                } : null,
              ),
            ]
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    await GraduationService.editEvaluation(
      widget.graduationEvaluation,
      notePartOne: _notePartOne,
      weightPartOne: _weightPartOne,
      datePartOne: _datePartOne,
      divideEvaluation: _divideEvaluation,
      notePartTwo : _notePartTwo ,
      weightPartTwo: _weightPartTwo,
      datePartTwo: _datePartTwo,
    );
  }
}
