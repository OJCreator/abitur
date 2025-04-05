import 'package:abitur/pages/subject_pages/subject_chose_graduation_page.dart';
import 'package:abitur/pages/subject_pages/subject_new_page.dart';
import 'package:abitur/pages/subject_pages/subject_page.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/widgets/info_card.dart';
import 'package:flutter/material.dart';

import '../../storage/entities/subject.dart';
import '../../widgets/badge.dart';

class SubjectsPage extends StatefulWidget {

  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  List<Subject> subjects = SubjectService.findAll();

  Future<void> _addNewSubject() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return SubjectNewPage();
      }),
    );
    _reloadSubjects();
  }

  void _reloadSubjects() {
    setState(() {
      subjects = SubjectService.findAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fächer"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (subjects.isEmpty)
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InfoCard("Es gibt noch keine Fächer.")
              ),
            if (SettingsService.choseGraduationSubjectsTime())
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InfoCard(
                    "Es wird Zeit, deine Abiturfächer zu wählen.",
                    action: "Wählen",
                    onAction: () async {
                      await Navigator.push(context,
                        MaterialPageRoute(
                          builder: (context) {
                            return SubjectChoseGraduationPage();
                          },
                          fullscreenDialog: true,
                      ));
                      _reloadSubjects();
                    },
                  )
              ),
            for (Subject subject in subjects)
              ListTile(
                title: Text(subject.name),
                subtitle: Text(subject.subjectType.name),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return SubjectPage(subject: subject);
                    }),
                  );
                  _reloadSubjects();
                },
                leading: Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: 8,
                  decoration: BoxDecoration(
                    color: subject.color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (SubjectService.graduationSubjects().contains(subject)) GraduationBadge(),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSubject,
        child: Icon(Icons.add),
      ),
    );
  }
}
