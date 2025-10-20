import 'package:abitur/exceptions/invalid_form_input_exception.dart';
import 'package:abitur/utils/extensions/land_extension.dart';
import 'package:abitur/utils/extensions/lists/list_extension.dart';
import 'package:abitur/widgets/forms/subject_dropdown.dart';
import 'package:flutter/material.dart';

import '../../services/database/settings_service.dart';
import '../../services/database/subject_service.dart';
import '../../sqlite/entities/subject.dart';
import '../../utils/enums/graduation_evaluation_type.dart';
import '../../utils/enums/land.dart';
import '../../widgets/forms/form_gap.dart';

class SubjectChoseGraduationPage extends StatefulWidget {
  const SubjectChoseGraduationPage({super.key});

  @override
  State<SubjectChoseGraduationPage> createState() => _SubjectChoseGraduationPageState();
}

class _SubjectChoseGraduationPageState extends State<SubjectChoseGraduationPage> {

  late Future<List<Subject>> _allSubjects;

  List<Subject?> _graduationSubjectsWritten = [];
  List<Subject?> _graduationSubjectsOral = [];
  Subject? _fifthGraduationSubject;
  late Future<Land> landFuture;

  bool includeFifthGraduationSubject = false;

  @override
  void initState() {
    _allSubjects = SubjectService.findAllGradable();
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    landFuture = SettingsService.land().then((land) {
      _loadGraduationSubjects(land);
      return land;
    });
    setState(() { });
  }
  Future<void> _loadGraduationSubjects(Land land) async {
    _graduationSubjectsWritten = await SubjectService.findGraduationSubjectsFiltered(GraduationEvaluationType.written).then((subjects) {
      return subjects.maxSize(land.writtenAmount).extendToSize(land.writtenAmount, (_) => null);
    });
    _graduationSubjectsOral = await SubjectService.findGraduationSubjectsFiltered(GraduationEvaluationType.oral).then((subjects) {
      if (subjects.length > land.oralAmount && land.extraGraduationSubject) {
        _fifthGraduationSubject = subjects.last;
        includeFifthGraduationSubject = true;
      }
      return subjects.maxSize(land.oralAmount).extendToSize(land.oralAmount, (_) => null);
    });
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Abifächer wählen"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Subject>>(
        future: _allSubjects,
        builder: (context, snapshotSubjects) {
          if (!snapshotSubjects.hasData) return Center(child: CircularProgressIndicator());

          final allSubjects = snapshotSubjects.data!;
          return FutureBuilder<Land>(
            future: landFuture,
            builder: (context, snapshotLand) {
              if (!snapshotLand.hasData) return Center(child: CircularProgressIndicator());
              final land = snapshotLand.data!;

              return SingleChildScrollView(
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

                        if (_graduationSubjectsWritten.length >= land.writtenAmount)
                          for (int i = 0; i < land.writtenAmount; i++) ...[
                            _GraduationSubjectDropdown(
                              label: "Schriftliches Abiturfach",
                              subject: _graduationSubjectsWritten[i],
                              subjects: allSubjects,
                              onSelected: (s) {
                                setState(() {
                                  _graduationSubjectsWritten[i] = s;
                                });
                              },
                            ),
                            FormGap(),
                          ],
                        if (_graduationSubjectsOral.length >= land.oralAmount)
                          for (int i = 0; i < land.oralAmount; i++) ...[
                            _GraduationSubjectDropdown(
                              label: "Mündliches Abiturfach",
                              subject: _graduationSubjectsOral[i],
                              subjects: allSubjects,
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
                            subjects: allSubjects,
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
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          List<Subject?> oral = List.from(_graduationSubjectsOral);
          if (includeFifthGraduationSubject) oral.add(_fifthGraduationSubject);

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
  final List<Subject?> subjects;
  final bool enabled;
  final Function(Subject? s) onSelected;

  const _GraduationSubjectDropdown({required this.subject, required this.onSelected, required this.label, required this.subjects, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return SubjectDropdown(
      label: label,
      subjects: [null, ...subjects],
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