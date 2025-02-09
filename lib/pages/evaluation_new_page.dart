import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/widgets/forms/date_input.dart';
import 'package:abitur/widgets/forms/performance_selector.dart';
import 'package:abitur/widgets/forms/subject_dropdown.dart';
import 'package:abitur/widgets/forms/term_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../storage/entities/evaluation.dart';
import '../storage/entities/performance.dart';
import '../storage/entities/subject.dart';
import '../utils/brightness_notifier.dart';
import '../widgets/forms/form_gap.dart';

class EvaluationNewPage extends StatefulWidget {

  final DateTime initialDateTime;
  final Subject initialSubject;
  final int? initialTerm;

  EvaluationNewPage({
    DateTime? initialDateTime,
    Subject? initialSubject,
    this.initialTerm,
    super.key,
  }) : initialDateTime = initialDateTime ?? DateTime.now(),
        initialSubject = initialSubject ?? SubjectService.findAllGradable()[0];

  @override
  State<EvaluationNewPage> createState() => _EvaluationNewPageState();
}

class _EvaluationNewPageState extends State<EvaluationNewPage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();

  late Subject _selectedSubject;

  late DateTime _selectedDateTime;

  int _term = 0;

  late Performance _selectedPerformance;
  bool _giveNote = false;
  int _currentNote = 8;

  @override
  void initState() {
    _selectedSubject = widget.initialSubject;
    _selectedPerformance = _selectedSubject.performances.first;
    _selectedDateTime = widget.initialDateTime;
    if (widget.initialTerm != null) {
      _term = widget.initialTerm!;
    } else {
      _setProbableTerm();
    }
    super.initState();
  }

  void _selectSubject(Subject? newSubject) {
    if (newSubject == null) {
      return;
    }
    setState(() {
      _selectedSubject = newSubject;
      _selectedPerformance = newSubject.performances.first;
    });
    _setProbableTerm();
  }

  void _setProbableTerm() {
    setState(() {
      int probableTerm = SettingsService.probableTerm(_selectedDateTime);
      if (_selectedSubject.terms.contains(probableTerm)) {
        _term = probableTerm;
      } else {
        _term = _selectedSubject.terms.first;
      }
    });
  }

  void _selectedDate(DateTime picked) {
    int probableTerm = SettingsService.probableTerm(picked);
    setState(() {
      _selectedDateTime = picked;
      if (_selectedSubject.terms.contains(probableTerm)) {
        _term = probableTerm;
      }
    });
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
          title: Text("Neue Prüfung"),
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

                  SubjectDropdown(
                    subjects: SubjectService.findAllGradable(),
                    selectedSubject: _selectedSubject,
                    onSelected: _selectSubject,
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

                  DateInput(
                    dateTime: _selectedDateTime,
                    firstDate: SettingsService.firstDayOfSchool,
                    lastDate: SettingsService.lastDayOfSchool,
                    onSelected: _selectedDate,
                  ),

                  FormGap(),

                  TermSelector(
                    selectedTerm: _term,
                    terms: _selectedSubject.terms,
                    onSelected: (int newTerm) {
                      setState(() {
                        _term = newTerm;
                      });
                    },
                  ),

                  FormGap(),

                  SwitchListTile(
                    title: Text("Note eintragen"),
                    value: _giveNote,
                    onChanged: (newValue) {
                      setState(() {
                        _giveNote = !_giveNote;
                      });
                    },
                  ),

                  Slider( // todo material3: https://m3.material.io/components/sliders/overview
                    min: 0,
                    max: 15,
                    divisions: 15,
                    value: _currentNote.toDouble(),
                    label: "$_currentNote",
                    onChanged: _giveNote ? (newValue) {
                      setState(() {
                        _currentNote = newValue.toInt();
                      });
                    } : null,
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
            Evaluation newEvaluation = await EvaluationService.newEvaluation(
                _selectedSubject,
                _selectedPerformance,
                _term,
                _name.text,
                _selectedDateTime,
                _giveNote ? _currentNote : null
            );
            Navigator.pop(context, newEvaluation);
          },
          label: Text("Eintragen"),
          icon: Icon(Icons.save),
        ),
      ),
    );
  }
}
