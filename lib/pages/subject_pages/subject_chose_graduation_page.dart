import 'package:abitur/exceptions/invalid_form_input_exception.dart';
import 'package:abitur/storage/entities/graduation/graduation_evaluation.dart';
import 'package:abitur/storage/services/graduation_service.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/utils/extensions/land_extension.dart';
import 'package:abitur/widgets/forms/subject_dropdown.dart';
import 'package:flutter/material.dart';

import '../../storage/entities/subject.dart';
import '../../storage/services/subject_service.dart';
import '../../utils/enums/land.dart';
import '../../widgets/forms/form_gap.dart';

class SubjectChoseGraduationPage extends StatefulWidget {
  const SubjectChoseGraduationPage({super.key});

  @override
  State<SubjectChoseGraduationPage> createState() => _SubjectChoseGraduationPageState();
}

class _SubjectChoseGraduationPageState extends State<SubjectChoseGraduationPage> {

  late List<Subject?> _graduationSubjectsWritten;
  late List<Subject?> _graduationSubjectsOral;
  Subject? _fifthGraduationSubject;
  late Land land;

  bool includeFifthGraduationSubject = false;

  @override
  void initState() {
    land = SettingsService.land;
    _graduationSubjectsWritten = GraduationService.graduationSubjectsFiltered(GraduationEvaluationType.written);
    _graduationSubjectsWritten = List.generate(land.writtenAmount, (i) => _graduationSubjectsWritten.elementAtOrNull(i));

    _graduationSubjectsOral = GraduationService.graduationSubjectsFiltered(GraduationEvaluationType.oral);
    if (_graduationSubjectsOral.length > land.oralAmount && land.extraGraduationSubject) {
      _fifthGraduationSubject = _graduationSubjectsOral.last;
      includeFifthGraduationSubject = true;
    }
    _graduationSubjectsOral = List.generate(land.oralAmount, (i) => _graduationSubjectsOral.elementAtOrNull(i));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Abifächer wählen"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Form(
            child: Column(
              children: [
                if (land.extraGraduationSubject) ...[
                  SwitchListTile(
                    title: Text("Einbringung eines weiteren Prüfungsfaches"),
                    value: includeFifthGraduationSubject,
                    onChanged: (newValue) {
                      setState(() {
                        includeFifthGraduationSubject = newValue;
                      });
                    },
                  ),
                  FormGap(),
                ],

                for (int i = 0; i < land.writtenAmount; i++) ...[
                  _GraduationSubjectDropdown(
                    label: "Schriftliches Abiturfach",
                    subject: _graduationSubjectsWritten[i],
                    onSelected: (s) {
                      setState(() {
                        _graduationSubjectsWritten[i] = s;
                      });
                    },
                  ),
                  FormGap(),
                ],
                for (int i = 0; i < land.oralAmount; i++) ...[
                  _GraduationSubjectDropdown(
                    label: "Mündliches Abiturfach",
                    subject: _graduationSubjectsOral[i],
                    onSelected: (s) {
                      setState(() {
                        _graduationSubjectsOral[i] = s;
                      });
                    },
                  ),
                  FormGap(),
                ],
                if (includeFifthGraduationSubject)
                  _GraduationSubjectDropdown(
                    label: "Besondere Lernleistung",
                    enabled: includeFifthGraduationSubject,
                    subject: _fifthGraduationSubject,
                    onSelected: (s) {
                      setState(() {
                        _fifthGraduationSubject = s;
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
          List<Subject?> oral = _graduationSubjectsOral.toList();
          if (includeFifthGraduationSubject) {
            oral.add(_fifthGraduationSubject);
          }

          trySubmittingForm(context, () async {
            await SubjectService.setGraduationSubjects(_graduationSubjectsWritten, oral);
            Navigator.pop(context);
          });
        },
        label: Text("Speichern"),
        icon: Icon(Icons.save),
      ),
    );
  }
}

class _GraduationSubjectDropdown extends StatelessWidget {

  final String label;
  final Subject? subject;
  final bool enabled;
  final Function(Subject? s) onSelected;

  const _GraduationSubjectDropdown({required this.subject, required this.onSelected, required this.label, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return SubjectDropdown(
      label: label,
      subjects: [null, ...SubjectService.findAllGradable()],
      enabled: enabled,
      disabled: (s) {
        if (subject == s) {
          return false;
        }
        return s.terms.length < 4;
      },
      selectedSubject: subject,
      onSelected: (s) {
        onSelected(s);
      },
    );
  }
}