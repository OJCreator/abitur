import 'package:abitur/storage/entities/performance.dart';
import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/widgets/forms/form_gap.dart';
import 'package:abitur/widgets/forms/performance_form.dart';
import 'package:abitur/widgets/forms/subject_color_picker.dart';
import 'package:abitur/widgets/forms/subject_name_and_short_name_input.dart';
import 'package:abitur/widgets/forms/subject_type_selector.dart';
import 'package:abitur/widgets/forms/terms_multiple_choice.dart';
import 'package:flutter/material.dart';

import '../storage/entities/subject.dart';

class SubjectEditPage extends StatefulWidget {

  final Subject subject;

  const SubjectEditPage({super.key, required this.subject});

  @override
  State<SubjectEditPage> createState() => _SubjectEditPageState();
}

class _SubjectEditPageState extends State<SubjectEditPage> {

  late final TextEditingController _nameController;
  late final TextEditingController _shortNameController;

  late Color _selectedColor;
  late int _countingTerms;
  late Set<int> _selectedTerms;
  late SubjectType _selectedSubjectType;
  late List<Performance> _performances;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.subject.name);
    _shortNameController = TextEditingController(text: widget.subject.shortName);
    _selectedColor = widget.subject.color;
    _countingTerms = widget.subject.countingTermAmount;
    _selectedTerms = widget.subject.terms;
    _selectedSubjectType = widget.subject.subjectType;
    _performances = widget.subject.performances;
    super.initState();
  }

  Future<bool> userAwareThatEvaluationsWillBeDeleted(int evaluationAmount) async {
    bool userAware = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(evaluationAmount > 1 ? "Verlust von $evaluationAmount Prüfungen" : "Verlust einer Prüfung"),
          content: Text("${evaluationAmount > 1 ? "$evaluationAmount Prüfungen gehen" : "Eine Prüfung geht"} mit dieser Aktion verloren, da ${evaluationAmount>1 ? "ihre Halbjahre entfernt werden" : "ihr Halbjahr entfernt wird"}. Bist du dir dessen bewusst?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text("Fortfahren"),
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
    return userAware;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fach bearbeiten"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Form(
            child: Column(
              children: [
                SubjectNameAndShortNameInput(
                  nameController: _nameController,
                  shortNameController: _shortNameController,
                ),

                FormGap(),

                SubjectColorPicker(
                  currentColor: _selectedColor,
                  onSelected: (newColor) {
                    setState(() {
                      _selectedColor = newColor;
                    });
                  },
                ),

                FormGap(),

                SubjectTypeSelector(
                  selectedSubjectType: _selectedSubjectType,
                  onSelected: (SubjectType newSelection) {
                    setState(() {
                      _selectedSubjectType = newSelection;
                    });
                  },
                ),

                FormGap(),

                TermsMultipleChoice(
                  selectedTerms: _selectedTerms,
                  onSelected: (Set<int> newSelection) {
                    setState(() {
                      _selectedTerms = newSelection;
                    });
                  },
                ),

                FormGap(),

                Text("Einzubringende Halbjahre:"),

                Slider( // todo material3: https://m3.material.io/components/sliders/overview
                  min: 0,
                  max: _selectedTerms.length.toDouble(),
                  divisions: _selectedTerms.length,
                  value: _countingTerms.toDouble(),
                  label: "$_countingTerms",
                  onChanged: (newValue) {
                    setState(() {
                      _countingTerms = newValue.toInt();
                    });
                  },
                ),
                
                FormGap(),

                PerformanceForm(
                  performances: _performances,
                  onChanged: (data) {
                    setState(() {
                      _performances = data;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {

          List<int> termsThatDontExist = [0,1,2,3].where((i) => !_selectedTerms.contains(i)).toList();
          int evaluationThatWouldBeDeleted = EvaluationService.findAllBySubjectAndTerms(widget.subject, termsThatDontExist).length;
          if (evaluationThatWouldBeDeleted > 0) {
            bool userAware = await userAwareThatEvaluationsWillBeDeleted(evaluationThatWouldBeDeleted);
            if (!userAware) {
              return;
            }
          }

          Subject editedSubject = await SubjectService.editSubject(
            widget.subject,
            name: _nameController.text,
            shortName: _shortNameController.text,
            color: _selectedColor,
            terms: _selectedTerms,
            countingTermAmount: _countingTerms,
            subjectType: _selectedSubjectType,
            performances: _performances,
          );

          Navigator.pop(context, editedSubject);
        },
        label: Text("Speichern"),
        icon: Icon(Icons.save),
      ),
    );
  }
}
