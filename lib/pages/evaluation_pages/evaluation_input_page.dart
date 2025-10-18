import 'package:abitur/services/database/performance_service.dart';
import 'package:abitur/services/database/subject_service.dart';
import 'package:abitur/services/database/timetable_entry_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:abitur/utils/extensions/lists/expand_to_list_extension.dart';
import 'package:abitur/widgets/forms/evaluation_date_form.dart';
import 'package:abitur/widgets/forms/evaluation_type_dropdown.dart';
import 'package:abitur/widgets/forms/form_page.dart';
import 'package:flutter/material.dart';

import '../../services/database/evaluation_date_service.dart';
import '../../services/database/evaluation_service.dart';
import '../../services/database/evaluation_type_service.dart';
import '../../services/database/settings_service.dart';
import '../../sqlite/entities/evaluation/evaluation.dart';
import '../../sqlite/entities/evaluation/evaluation_date.dart';
import '../../sqlite/entities/evaluation/evaluation_type.dart';
import '../../sqlite/entities/performance.dart';
import '../../sqlite/entities/subject.dart';
import '../../widgets/forms/performance_selector.dart';
import '../../widgets/forms/subject_dropdown.dart';
import '../../widgets/forms/term_selector.dart';
import '../../widgets/forms/form_gap.dart';

class EvaluationInputPage extends StatefulWidget {

  final Evaluation? evaluation;
  final DateTime? dateTime;
  final String? subjectId;
  final int? term;

  bool get editMode => evaluation != null;

  const EvaluationInputPage({this.evaluation, this.dateTime, this.subjectId, this.term, super.key,});

  @override
  State<EvaluationInputPage> createState() => _EvaluationInputPageState();
}

class _EvaluationInputPageState extends State<EvaluationInputPage> {

  bool loading = true;
  Color seedColor = primaryColor;

  late Future<Map<String, Subject>> _allSubjects;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;

  late EvaluationType _selectedEvaluationType;
  late String _selectedSubjectId;
  late String _selectedPerformanceId;
  late int _selectedTerm;

  late List<EvaluationDate> _evaluationDates;
  late List<String> _initialEvaluationDateIds;

  bool unsavedChanges = false;

  Future<List<Performance>> performances = Future.value([]);
  Map<String, EvaluationType> evaluationTypes = {};

  @override
  void initState() {
    _name = TextEditingController()..addListener(() {
      unsavedChanges = true;
    });
    _allSubjects = SubjectService.findAllGradableAsMap();

    super.initState();
  }

  Future<void> initValues() async {
    evaluationTypes = await EvaluationTypeService.findAllAsMap();
    final timetableSubject = await TimetableEntryService.findLatestGradableSubject();
    final eval = widget.evaluation;
    final evaluationDates = eval == null ? null : await EvaluationDateService.findAllByEvaluationIds([eval.id]);
    final probableTerm = await SettingsService.probableTerm(_evaluationDates.firstOrNull?.date ?? DateTime.now());

    setState(() {
      _name.text = eval?.name ?? "";
      _selectedEvaluationType = evaluationTypes[eval?.evaluationTypeId] ?? evaluationTypes.values.first;
      _selectedSubjectId = widget.subjectId ?? eval?.subjectId ?? timetableSubject.id;
      _selectedPerformanceId = eval?.performanceId ?? "";
      _evaluationDates = evaluationDates?.values.expandToList() ?? [EvaluationDate(date: widget.dateTime ?? DateTime.now())];
      _initialEvaluationDateIds = _evaluationDates.map((e) => e.id).toList();
      _selectedTerm = widget.term ?? eval?.term ?? probableTerm;

      loading = false;
    });
    _loadPerformances();
  }

  Future<void> _setSubject(String subjectId) async {
    setState(() {
      _selectedSubjectId = subjectId;
      unsavedChanges = true;
    });
    seedColor = (await _allSubjects)[subjectId]!.color;
    setState(() { });
    _loadPerformances();
  }

  void _loadPerformances() {
    setState(() {
      performances = PerformanceService.findAllBySubjectId(_selectedSubjectId)..then((performances) {
        if (!performances.any((p) => p.subjectId == _selectedSubjectId)) {
          _selectedPerformanceId = performances.first.id;
        }
        return performances;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return FormPage(
        formKey: _formKey,
        appBarTitle: widget.editMode ? "Prüfung bearbeiten" : "Neue Prüfung",
        colorSeed: seedColor,
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
            evaluationTypes: evaluationTypes.values.toList(),
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

          FutureBuilder(
            future: _allSubjects,
            builder: (context, asyncSnapshot) {
              return SubjectDropdown(
                subjects: asyncSnapshot.data?.values.toList() ?? [],
                selectedSubject: asyncSnapshot.data?[_selectedSubjectId],
                onSelected: (s) {
                  if (s == null) {
                    return;
                  }
                  _setSubject(s.id);
                },
              );
            }
          ),

          FormGap(),

          FutureBuilder(
            future: performances,
            builder: (context, asyncSnapshot) {
              if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                return PerformanceSelector(performances: [], currentPerformance: null, onSelected: null);
              }
              return PerformanceSelector(
                performances: asyncSnapshot.data!,
                currentPerformance: asyncSnapshot.data!.firstWhere((p) => p.id == _selectedPerformanceId),
                onSelected: (Performance selected) {
                  setState(() {
                    _selectedPerformanceId = selected.id;
                    unsavedChanges = true;
                  });
                },
              );
            }
          ),

          FormGap(),

          FormGap(),

          FutureBuilder(
            future: _allSubjects,
            builder: (context, asyncSnapshot) {
              if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                return TermSelector(selectedTerm: -1, terms: {0, 1, 2, 3}, onSelected: null);
              }
              return TermSelector(
                selectedTerm: _selectedTerm,
                terms: asyncSnapshot.data!.values.firstWhere((s) => s.id == _selectedSubjectId).terms,
                onSelected: (int newTerm) {
                  setState(() {
                    _selectedTerm = newTerm;
                    unsavedChanges = true;
                  });
                },
              );
            }
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
      List<String> evaluationDateIdsToDelete = _initialEvaluationDateIds.where((e) => !_evaluationDates.map((e) => e.id).contains(e)).toList();
      await EvaluationDateService.deleteAllEvaluationDates(evaluationDateIdsToDelete);
      await EvaluationDateService.saveAllEvaluationDates(_evaluationDates);
      await EvaluationService.editEvaluation(
        widget.evaluation!,
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