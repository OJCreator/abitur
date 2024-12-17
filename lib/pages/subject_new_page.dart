import 'package:abitur/storage/entities/performance.dart';
import 'package:abitur/storage/services/performance_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:abitur/widgets/forms/form_gap.dart';
import 'package:abitur/widgets/forms/performance_form.dart';
import 'package:abitur/widgets/forms/subject_color_picker.dart';
import 'package:abitur/widgets/forms/subject_name_and_short_name_input.dart';
import 'package:abitur/widgets/forms/subject_type_selector.dart';
import 'package:abitur/widgets/forms/terms_multiple_choice.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../storage/entities/subject.dart';

class SubjectNewPage extends StatefulWidget {

  const SubjectNewPage({super.key});

  @override
  State<SubjectNewPage> createState() => _SubjectNewPageState();
}

class _SubjectNewPageState extends State<SubjectNewPage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _shortName = TextEditingController();
  Color _color = primaryColor;
  Set<int> _terms = {0,1,2,3};
  int _countingTerms = 4;
  SubjectType _subjectType = SubjectType.basic;
  List<Performance> _performances = [
    Performance(name: "Klausur", weighting: 0.5),
    Performance(name: "Mündliche Note", weighting: 0.5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Neues Fach"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SubjectNameAndShortNameInput(
                  nameController: _name,
                  shortNameController: _shortName,
                ),

                FormGap(),

                SubjectColorPicker(
                  currentColor: _color,
                  onSelected: (newColor) {
                    setState(() {
                      _color = newColor;
                    });
                  },
                ),

                FormGap(),

                SubjectTypeSelector(
                  selectedSubjectType: _subjectType,
                  onSelected: (SubjectType newSelection) {
                    setState(() {
                      _subjectType = newSelection;
                    });
                  },
                ),

                FormGap(),

                TermsMultipleChoice(
                  selectedTerms: _terms,
                  onSelected: (Set<int> newSelection) {
                    setState(() {
                      _terms = newSelection;
                      if (_countingTerms > _terms.length) {
                        _countingTerms = _terms.length;
                      }
                    });
                  },
                ),

                FormGap(),

                Text("Einzubringende Halbjahre:"),

                Slider( // todo material3: https://m3.material.io/components/sliders/overview
                  min: 0,
                  max: _terms.length.toDouble(),
                  divisions: _terms.length,
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
                  onChanged: (value) {
                    setState(() {
                      _performances = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Erstellen"),
        icon: Icon(Icons.save),
        onPressed: () async {
          if (!_formKey.currentState!.validate()) {
            return;
          }

          await PerformanceService.savePerformances(_performances);

          await SubjectService.newSubject(
            _name.text,
            _shortName.text,
            _color,
            _terms,
            _countingTerms,
            _subjectType,
            _performances.map((p) => p.id).toList(),
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}
