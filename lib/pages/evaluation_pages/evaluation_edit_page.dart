import 'package:abitur/storage/services/evaluation_date_service.dart';
import 'package:abitur/utils/brightness_notifier.dart';
import 'package:abitur/widgets/forms/evaluation_date_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../storage/entities/evaluation.dart';
import '../../storage/entities/evaluation_date.dart';
import '../../storage/entities/performance.dart';
import '../../storage/entities/subject.dart';
import '../../storage/services/evaluation_service.dart';
import '../../storage/services/subject_service.dart';
import '../../widgets/forms/performance_selector.dart';
import '../../widgets/forms/subject_dropdown.dart';
import '../../widgets/forms/term_selector.dart';
import '../../widgets/forms/form_gap.dart';

class EvaluationEditPage extends StatefulWidget {

  final Evaluation evaluation;

  const EvaluationEditPage({required this.evaluation, super.key});

  @override
  State<EvaluationEditPage> createState() => _EvaluationEditPageState();
}

class _EvaluationEditPageState extends State<EvaluationEditPage> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();

  late Subject _selectedSubject;
  late Performance _selectedPerformance;
  late int _selectedTerm;

  late List<EvaluationDate> _evaluationDates;
  late final List<EvaluationDate> _oldEvaluationDates;

  @override
  void initState() {
    _name.text = widget.evaluation.name;
    _selectedSubject = widget.evaluation.subject;
    _selectedPerformance = widget.evaluation.performance;
    _selectedTerm = widget.evaluation.term;

    _evaluationDates = widget.evaluation.evaluationDates;
    _oldEvaluationDates = widget.evaluation.evaluationDates;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Brightness b = Provider.of<BrightnessNotifier>(context).currentBrightness;
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _selectedSubject.color, brightness: b,),
        useMaterial3: true,
        brightness: b,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Prüfung bearbeiten"),
          actions: [
            IconButton(
              onPressed: () async {
                bool confirmed = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Wirklich löschen?"),
                      content: Text("Die Prüfung wird gelöscht und kann nicht wiederhergestellt werden."),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            await EvaluationService.deleteEvaluation(widget.evaluation);
                            Navigator.pop(context, true);
                          },
                          child: Text("Löschen"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: Text("Abbrechen"),
                        ),
                      ],
                    );
                  },
                );
                if (confirmed) {
                  Navigator.pop(context);
                }
              },
              icon: Icon(Icons.delete),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
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
                      });
                    },
                  ),

                  FormGap(),

                  EvaluationDateForm(
                    evaluationId: widget.evaluation.id,
                    evaluationDates: widget.evaluation.evaluationDates,
                    onChanged: (newEvaluationDates) {
                      _evaluationDates = newEvaluationDates;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            await EvaluationService.editEvaluation(
              widget.evaluation,
              subject: _selectedSubject,
              performance: _selectedPerformance,
              term: _selectedTerm,
              name: _name.text,
              evaluationDates: _evaluationDates
              // date: _selectedDate,
              // note: _giveNote ? _selectedNote : null,
            );
            await EvaluationDateService.deleteAllEvaluationDates(_oldEvaluationDates.where((e) => !_evaluationDates.contains(e)).toList());
            await EvaluationDateService.saveAllEvaluationDates(_evaluationDates);
            Navigator.pop(context);
          },
          label: Text("Speichern"),
          icon: Icon(Icons.save),
        ),
      ),
    );
  }
}