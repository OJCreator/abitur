import 'package:abitur/storage/entities/performance.dart';
import 'package:abitur/storage/entities/subject_category.dart';
import 'package:abitur/storage/services/performance_service.dart';
import 'package:abitur/storage/services/subject_category_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:abitur/widgets/forms/form_gap.dart';
import 'package:abitur/widgets/forms/performance_form.dart';
import 'package:abitur/widgets/forms/subject_category_dropdown.dart';
import 'package:abitur/widgets/forms/subject_name_and_color_input.dart';
import 'package:abitur/widgets/forms/subject_type_selector.dart';
import 'package:abitur/widgets/forms/terms_multiple_choice.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../exceptions/invalid_form_input_exception.dart';
import '../../storage/entities/subject.dart';
import '../../utils/brightness_notifier.dart';

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
  late SubjectCategory _subjectCategory;
  List<SubjectCategory> _allSubjectCategories = List.empty(growable: true);
  List<Performance> _performances = [
    Performance(name: "Klausuren", weighting: 0.5),
    Performance(name: "Kleine Noten", weighting: 0.5),
  ];

  @override
  void initState() {
    _allSubjectCategories = SubjectCategoryService.findAll();
    _subjectCategory = _allSubjectCategories.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Brightness b = Provider.of<BrightnessNotifier>(context).currentBrightness;
    return Theme(
        data: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: _color, brightness: b,),
          useMaterial3: true,
          brightness: b,
        ),
      child: Scaffold(
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
                  SubjectNameAndColorInput(
                    nameController: _name,
                    shortNameController: _shortName,
                    color: _color,
                    onSelectedColor: (newColor) {
                      print("New: ${newColor.toHexString()}");
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

                  SubjectCategoryDropdown(
                    selectedSubjectCategory: _subjectCategory,
                    subjectCategories: _allSubjectCategories,
                    onSelected: (SubjectCategory? newSubjectCategory) {
                      if (newSubjectCategory == null) {
                        return;
                      }
                      setState(() {
                        _subjectCategory = newSubjectCategory;
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

                  Slider(
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
                    year2023: false,
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

            trySubmittingForm(context, () async {
              await SubjectService.newSubject(
                _name.text,
                _shortName.text,
                _color,
                _terms,
                _countingTerms,
                _subjectType,
                _subjectCategory,
                _performances.map((p) => p.id).toList(),
              );
              await PerformanceService.savePerformances(_performances);

              Navigator.pop(context);
            });
          },
        ),
      ),
    );
  }
}
