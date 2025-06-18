import 'package:abitur/storage/entities/evaluation_type.dart';
import 'package:abitur/storage/services/evaluation_date_service.dart';
import 'package:abitur/storage/services/evaluation_type_service.dart';
import 'package:abitur/widgets/forms/evaluation_date_form.dart';
import 'package:abitur/widgets/forms/evaluation_type_dropdown.dart';
import 'package:abitur/widgets/forms/form_page.dart';
import 'package:flutter/material.dart';

import '../../storage/entities/evaluation.dart';
import '../../storage/entities/evaluation_date.dart';
import '../../storage/entities/performance.dart';
import '../../storage/entities/subject.dart';
import '../../storage/services/evaluation_service.dart';
import '../../storage/services/settings_service.dart';
import '../../storage/services/subject_service.dart';
import '../../storage/services/timetable_service.dart';
import '../../widgets/forms/performance_selector.dart';
import '../../widgets/forms/subject_dropdown.dart';
import '../../widgets/forms/term_selector.dart';
import '../../widgets/forms/form_gap.dart';

class EvaluationInputPage extends StatefulWidget {

  final Evaluation? evaluation;
  final DateTime? dateTime;
  final Subject? subject;
  final int? term;

  bool get editMode => evaluation != null;

  String get initialName => evaluation?.name ?? "";
  EvaluationType get initialEvaluationType => evaluation?.evaluationType ?? EvaluationTypeService.findAll().first;
  Subject get initialSubject => subject ?? evaluation?.subject ?? TimetableService.findLatestGradableSubject();
  Performance get initialPerformance => evaluation?.performance ?? initialSubject.performances.first;
  int get initialTerm => term ?? evaluation?.term ?? SettingsService.probableTerm(initialEvaluationDates.firstOrNull?.date ?? DateTime.now());
  List<EvaluationDate> get initialEvaluationDates => evaluation?.evaluationDates ?? [EvaluationDate(date: dateTime ?? DateTime.now())];

  const EvaluationInputPage({this.evaluation, this.dateTime, this.subject, this.term, super.key,});

  @override
  State<EvaluationInputPage> createState() => _EvaluationInputPageState();
}

class _EvaluationInputPageState extends State<EvaluationInputPage> {

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;

  late EvaluationType _selectedEvaluationType;
  late Subject _selectedSubject;
  late Performance _selectedPerformance;
  late int _selectedTerm;

  late List<EvaluationDate> _evaluationDates;

  bool unsavedChanges = false;

  @override
  void initState() {
    _name = TextEditingController(text: widget.initialName)..addListener(() {
      unsavedChanges = true;
    });

    _selectedEvaluationType = widget.initialEvaluationType;
    _selectedSubject = widget.initialSubject;
    _selectedPerformance = widget.initialPerformance;
    _selectedTerm = widget.initialTerm;

    _evaluationDates = widget.initialEvaluationDates.map((e) => e.clone()).toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return FormPage(
        formKey: _formKey,
        appBarTitle: widget.editMode ? "Prüfung bearbeiten" : "Neue Prüfung",
        colorSeed: _selectedSubject.color,
        hasUnsavedChanges: () => widget.editMode && unsavedChanges,
        saveTitle: widget.editMode ? "Speichern" : "Eintragen",
        save: save,
        delete: widget.editMode ? () async {
          await EvaluationService.deleteEvaluation(widget.evaluation!);
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
            evaluationTypes: EvaluationTypeService.findAll(),
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
            subjects: SubjectService.findAllGradable(),
            selectedSubject: _selectedSubject,
            onSelected: (s) {
              if (s == null) {
                return;
              }
              setState(() {
                _selectedSubject = s;
                _selectedPerformance = s.performances.first;
                unsavedChanges = true;
              });
            },
          ),

          FormGap(),

          PerformanceSelector(
            performances: _selectedSubject.performances,
            currentPerformance: _selectedPerformance,
            onSelected: (Performance selected) {
              setState(() {
                _selectedPerformance = selected;
                unsavedChanges = true;
              });
            },
          ),

          FormGap(),

          FormGap(),

          TermSelector(
            selectedTerm: _selectedTerm,
            terms: _selectedSubject.terms,
            onSelected: (int newTerm) {
              setState(() {
                _selectedTerm = newTerm;
                unsavedChanges = true;
              });
            },
          ),

          FormGap(),

          EvaluationDateForm(
            evaluationId: widget.evaluation?.id,
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
    if (widget.editMode) {
      await EvaluationDateService.deleteAllEvaluationDates(widget.initialEvaluationDates.where((e) => !_evaluationDates.contains(e)).toList());
      await EvaluationDateService.saveAllEvaluationDates(_evaluationDates);
      await EvaluationService.editEvaluation(
        widget.evaluation!,
        subject: _selectedSubject,
        performance: _selectedPerformance,
        term: _selectedTerm,
        name: _name.text,
        evaluationDates: _evaluationDates,
        evaluationType: _selectedEvaluationType,
      );
      Navigator.pop(context);
    } else {
      Evaluation newEvaluation = await EvaluationService.newEvaluation(
        _selectedSubject,
        _selectedPerformance,
        _selectedTerm,
        _name.text,
        _evaluationDates,
        _selectedEvaluationType,
      );
      Navigator.pop(context, newEvaluation);
    }
  }
}