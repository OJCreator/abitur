import 'package:abitur/widgets/forms/subject_dropdown.dart';
import 'package:flutter/material.dart';

import '../../storage/entities/subject.dart';
import '../../storage/services/subject_service.dart';
import '../../widgets/forms/form_gap.dart';

class SubjectChoseGraduationPage extends StatefulWidget {
  const SubjectChoseGraduationPage({super.key});

  @override
  State<SubjectChoseGraduationPage> createState() => _SubjectChoseGraduationPageState();
}

class _SubjectChoseGraduationPageState extends State<SubjectChoseGraduationPage> {

  late List<Subject?> _graduationSubjects;

  @override
  void initState() {
    _graduationSubjects = SubjectService.graduationSubjects();
    if (_graduationSubjects.length < 5) {
      _graduationSubjects = [null, null, null, null, null];
    }
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
                _GraduationSubjectDropdown(
                  label: "Schriftliches Abiturfach",
                  subject: _graduationSubjects[0],
                  onSelected: (s) {
                    setState(() {
                      _graduationSubjects[0] = s;
                    });
                  },
                ),

                FormGap(),

                _GraduationSubjectDropdown(
                  label: "Schriftliches Abiturfach",
                  subject: _graduationSubjects[1],
                  onSelected: (s) {
                    setState(() {
                      _graduationSubjects[1] = s;
                    });
                  },
                ),

                FormGap(),

                _GraduationSubjectDropdown(
                  label: "Schriftliches Abiturfach",
                  subject: _graduationSubjects[2],
                  onSelected: (s) {
                    setState(() {
                      _graduationSubjects[2] = s;
                    });
                  },
                ),

                FormGap(),

                _GraduationSubjectDropdown(
                  label: "Mündliches Abiturfach",
                  subject: _graduationSubjects[3],
                  onSelected: (s) {
                    setState(() {
                      _graduationSubjects[3] = s;
                    });
                  },
                ),

                FormGap(),

                _GraduationSubjectDropdown(
                  label: "Mündliches Abiturfach",
                  subject: _graduationSubjects[4],
                  onSelected: (s) {
                    setState(() {
                      _graduationSubjects[4] = s;
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

          if (_graduationSubjects.toSet().length < 5 || _graduationSubjects.contains(null)) {

            showDialog(context: context, builder: (context) {
              return AlertDialog(
                title: Text("Ungültige Belegung"),
                content: Text("Alle Prüfungen müssen belegt werden und du darfst kein Fach mehrfach wählen."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Verstanden"),
                  ),
                ],
              );
            });

            return;
          }

          await SubjectService.setGraduationSubjects(_graduationSubjects);

          Navigator.pop(context);
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
  final Function(Subject s) onSelected;

  const _GraduationSubjectDropdown({required this.subject, required this.onSelected, required this.label});

  @override
  Widget build(BuildContext context) {
    return SubjectDropdown(
      label: label,
      subjects: [null, ...SubjectService.findAllGradable()],
      disabled: (s) {
        if (subject == s) {
          return false;
        }
        return s.terms.length < 4;
      },
      selectedSubject: subject,
      onSelected: (s) {
        if (s == null) {
          return;
        }
        onSelected(s);
      },
    );
  }
}