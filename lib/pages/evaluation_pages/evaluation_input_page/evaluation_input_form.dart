import 'package:abitur/mappers/models/evaluation_input_page_model.dart';
import 'package:abitur/services/database/evaluation_date_service.dart';
import 'package:abitur/services/database/evaluation_service.dart';
import 'package:abitur/services/database/performance_service.dart';
import 'package:abitur/sqlite/entities/evaluation/evaluation.dart';
import 'package:abitur/sqlite/entities/evaluation/evaluation_date.dart';
import 'package:abitur/sqlite/entities/evaluation/evaluation_type.dart';
import 'package:abitur/sqlite/entities/performance.dart';
import 'package:abitur/widgets/forms/evaluation_date_form.dart';
import 'package:abitur/widgets/forms/evaluation_type_dropdown.dart';
import 'package:abitur/widgets/forms/form_gap.dart';
import 'package:abitur/widgets/forms/form_page.dart';
import 'package:abitur/widgets/forms/performance_selector.dart';
import 'package:abitur/widgets/forms/subject_dropdown.dart';
import 'package:abitur/widgets/forms/term_selector.dart';
import 'package:flutter/material.dart';

class EvaluationInputForm extends StatefulWidget {

  final EvaluationInputPageModel model;

  const EvaluationInputForm({required this.model, super.key,});

  @override
  State<EvaluationInputForm> createState() => _EvaluationInputFormState();
}

class _EvaluationInputFormState extends State<EvaluationInputForm> {

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;

  late EvaluationType _selectedEvaluationType;
  late String _selectedSubjectId;
  late String _selectedPerformanceId;
  late int _selectedTerm;

  late List<EvaluationDate> _evaluationDates;
  late List<Performance> _performances;

  bool unsavedChanges = false;


  @override
  void initState() {
    _name = TextEditingController(text: widget.model.initialName)..addListener(() {
      unsavedChanges = true;
    });
    _selectedEvaluationType = widget.model.initialEvaluationType;
    _selectedSubjectId = widget.model.initialSubjectId;
    _selectedPerformanceId = widget.model.initialPerformanceId;
    _selectedTerm = widget.model.initialTerm;

    _evaluationDates = widget.model.initialEvaluationDates;
    _performances = widget.model.initialPerformances;

    super.initState();
  }

  void _onSubjectChanged(String newSubjectId) async {
    setState(() {
      _selectedSubjectId = newSubjectId;
    });
    final performances = await PerformanceService.findAllBySubjectId(newSubjectId);
    setState(() {
      _performances = performances;
    });
  }

  @override
  Widget build(BuildContext context) {

    return FormPage(
      formKey: _formKey,
      appBarTitle: widget.model.editMode ? "Prüfung bearbeiten" : "Neue Prüfung",
      colorSeed: widget.model.seedColor,
      hasUnsavedChanges: () => widget.model.editMode && unsavedChanges,
      saveTitle: widget.model.editMode ? "Speichern" : "Eintragen",
      save: save,
      delete: widget.model.editMode ? () async {
        await EvaluationService.deleteEvaluation(widget.model.evaluation!);
      } : null,
      children: [
        TextFormField(
          controller: _name,
          validator: (input) {
            if (input == null || input.isEmpty) {
              return "Erforderlich";
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: "Name",
            border: OutlineInputBorder(),
          ),
        ),

        FormGap(),

        EvaluationTypeDropdown(
          evaluationTypes: widget.model.evaluationTypes.values.toList(),
          selectedEvaluationType: _selectedEvaluationType,
          onSelected: (e) {
            if (e == null) {
              return;
            }
            setState(() {
              _selectedEvaluationType = e;
              unsavedChanges = true;
            });
          },
        ),

        FormGap(),

        SubjectDropdown(
          subjects: widget.model.subjects.values.toList(),
          selectedSubject: widget.model.subjects[_selectedSubjectId],
          onSelected: (s) {
            if (s == null) {
              return;
            }
            _onSubjectChanged(s.id);
          },
        ),

        FormGap(),

        PerformanceSelector(
          performances: _performances,
          currentPerformance: _performances.firstWhere((p) => p.id == _selectedPerformanceId, orElse: Performance.empty),
          onSelected: (Performance selected) {
            setState(() {
              _selectedPerformanceId = selected.id;
              unsavedChanges = true;
            });
          },
        ),

        FormGap(),

        FormGap(),

        TermSelector(
          selectedTerm: _selectedTerm,
          terms: widget.model.subjects[_selectedSubjectId]!.terms,
          onSelected: (int newTerm) {
            setState(() {
              _selectedTerm = newTerm;
              unsavedChanges = true;
            });
          },
        ),

        FormGap(),

        EvaluationDateForm(
          evaluationId: widget.model.evaluation?.id,
          evaluationDates: _evaluationDates,
          onChanged: (newEvaluationDates) {
            _evaluationDates = newEvaluationDates;
            unsavedChanges = true;
          },
        ),
      ],
    );
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (widget.model.editMode) {
      List<String> evaluationDateIdsToDelete = widget.model.initialEvaluationDates.where((e) => !_evaluationDates.contains(e)).map((e) => e.id).toList();
      await EvaluationDateService.deleteAllEvaluationDates(evaluationDateIdsToDelete);
      await EvaluationDateService.saveAllEvaluationDates(_evaluationDates);
      await EvaluationService.editEvaluation(
        widget.model.evaluation!,
        subjectId: _selectedSubjectId,
        performanceId: _selectedPerformanceId,
        evaluationType: _selectedEvaluationType,
        term: _selectedTerm,
        name: _name.text,
      );
      Navigator.pop(context);
    } else {
      Evaluation newEvaluation = await EvaluationService.newEvaluation(
        _selectedSubjectId,
        _selectedPerformanceId,
        _selectedEvaluationType,
        _selectedTerm,
        _name.text,
        _evaluationDates,
      );
      Navigator.pop(context, newEvaluation);
    }
  }
}