import 'package:abitur/exceptions/invalid_form_input_exception.dart';
import 'package:abitur/storage/entities/performance.dart';
import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/services/subject_category_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/widgets/forms/form_gap.dart';
import 'package:abitur/widgets/forms/form_page.dart';
import 'package:abitur/widgets/forms/performance_form.dart';
import 'package:abitur/widgets/forms/subject_name_and_color_input.dart';
import 'package:abitur/widgets/forms/subject_type_selector.dart';
import 'package:abitur/widgets/forms/terms_multiple_choice.dart';
import 'package:flutter/material.dart';

import '../../storage/entities/subject.dart';
import '../../storage/entities/subject_category.dart';
import '../../storage/services/performance_service.dart';
import '../../utils/constants.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/forms/subject_category_dropdown.dart';

class SubjectInputPage extends StatefulWidget {

  final Subject? subject;

  bool get editMode => subject != null;

  String get initialName => subject?.name ?? "";
  String get initialShortName => subject?.shortName ?? "";
  Color get initialColor => subject?.color ?? primaryColor;
  int get initialCountingTerms => subject?.countingTermAmount ?? 4;
  Set<int> get initialTerms => subject?.terms ?? {0,1,2,3};
  SubjectType get initialSubjectType => subject?.subjectType ?? SubjectType.basic;
  SubjectCategory get initialSubjectCategory => subject?.subjectCategory ?? SubjectCategoryService.findAll().first;
  List<Performance> get initialPerformances => subject?.performances ?? [
    Performance(name: "Klausuren", weighting: 0.5),
    Performance(name: "Kleine Noten", weighting: 0.5),
  ];

  const SubjectInputPage({super.key, this.subject});

  @override
  State<SubjectInputPage> createState() => _SubjectInputPageState();
}

class _SubjectInputPageState extends State<SubjectInputPage> {

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _shortName;
  late final List<SubjectCategory> _allSubjectCategories;

  late Color _color;
  late int _countingTerms;
  late Set<int> _terms;
  late SubjectType _subjectType;
  late SubjectCategory _subjectCategory;
  late List<Performance> _performances;

  bool _unsavedChanges = false;

  @override
  void initState() {
    _name = TextEditingController(text: widget.initialName)..addListener(() {
      _unsavedChanges = true;
    });
    _shortName = TextEditingController(text: widget.initialShortName)..addListener(() {
      _unsavedChanges = true;
    });
    _allSubjectCategories = SubjectCategoryService.findAll();
    _color = widget.initialColor;
    _countingTerms = widget.initialCountingTerms;
    _terms = widget.initialTerms;
    _subjectType = widget.initialSubjectType;
    _subjectCategory = widget.initialSubjectCategory;
    _performances = widget.initialPerformances;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return FormPage(
      formKey: _formKey,
      appBarTitle: widget.editMode ? "Fach bearbeiten" : "Neues Fach",
      colorSeed: _color,
      hasUnsavedChanges: () => widget.editMode && _unsavedChanges,
      saveTitle: widget.editMode ? "Speichern" : "Erstellen",
      save: save,
      children: [
        SubjectNameAndColorInput(
          nameController: _name,
          shortNameController: _shortName,
          color: _color,
          onSelectedColor: (newColor) {
            setState(() {
              _color = newColor;
              _unsavedChanges = true;
            });
          },
        ),

        FormGap(),

        SubjectTypeSelector(
          selectedSubjectType: _subjectType,
          onSelected: (SubjectType newSelection) {
            setState(() {
              _subjectType = newSelection;
              _unsavedChanges = true;
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
              _unsavedChanges = true;
            });
          },
        ),

        FormGap(),

        TermsMultipleChoice(
          selectedTerms: _terms,
          onSelected: (Set<int> newSelection) {
            setState(() {
              _terms = newSelection;
              _unsavedChanges = true;
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
              _unsavedChanges = true;
            });
          },
          year2023: false,
        ),

        FormGap(),

        PerformanceForm(
          performances: _performances,
          onChanged: (data) {
            setState(() {
              _performances = data;
              _unsavedChanges = true;
            });
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
      List<int> termsThatDontExist = [0,1,2,3].where((i) => !_terms.contains(i)).toList();
      int evaluationThatWouldBeDeleted = EvaluationService.findAllBySubjectAndTerms(widget.subject!, termsThatDontExist).length;
      if (evaluationThatWouldBeDeleted > 0) {
        bool userAware = await userAwareThatEvaluationsWillBeDeleted(evaluationThatWouldBeDeleted);
        if (!userAware) {
          return;
        }
      }

      trySubmittingForm(context, () async {
        Subject editedSubject = await SubjectService.editSubject(
          widget.subject!,
          name: _name.text,
          shortName: _shortName.text,
          color: _color,
          terms: _terms,
          countingTermAmount: _countingTerms,
          subjectType: _subjectType,
          subjectCategory: _subjectCategory,
          performances: _performances,
        );

        Navigator.pop(context, editedSubject);
      });
    }
    else {

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
    }
  }

  Future<bool> userAwareThatEvaluationsWillBeDeleted(int evaluationAmount) async {
    bool userAware = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ConfirmDialog(
          title: evaluationAmount > 1 ? "Verlust von $evaluationAmount Prüfungen" : "Verlust einer Prüfung",
          message: "${evaluationAmount > 1 ? "$evaluationAmount Prüfungen gehen" : "Eine Prüfung geht"} mit dieser Aktion verloren, da ${evaluationAmount>1 ? "ihre Halbjahre entfernt werden" : "ihr Halbjahr entfernt wird"}. Bist du dir dessen bewusst?",
          confirmText: "Fortfahren",
          onConfirm: () async {},
        );
      },
    );
    return userAware;
  }
}
