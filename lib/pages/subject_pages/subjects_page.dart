import 'package:abitur/pages/subject_pages/subject_chose_graduation_page.dart';
import 'package:abitur/pages/subject_pages/subject_input_page.dart';
import 'package:abitur/pages/subject_pages/subject_page.dart';
import 'package:abitur/storage/services/graduation_service.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/widgets/info_card.dart';
import 'package:abitur/widgets/shimmer.dart';
import 'package:flutter/material.dart';

import '../../storage/entities/subject.dart';
import '../../utils/constants.dart';
import '../../widgets/badge.dart';

class SubjectsPage extends StatefulWidget {

  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  late Future<List<Subject>> subjects;

  @override
  void initState() {
    _loadSubjects();
    super.initState();
  }

  Future<void> _addNewSubject() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return SubjectInputPage();
      }),
    );
    _loadSubjects();
  }

  void _loadSubjects() {
    setState(() {
      subjects = SubjectService.findAllSortedIsolated();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fächer"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == "selectGraduationSubjects") {
                await Navigator.push(context,
                    MaterialPageRoute(
                      builder: (context) {
                        return SubjectChoseGraduationPage();
                      },
                      fullscreenDialog: true,
                    ));
                _loadSubjects();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: "selectGraduationSubjects",
                child: Text("Abiturfächer wählen"),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: subjects,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Column(
                children: [
                  for (int i = 0; i < 10; i++)
                    SubjectListTile.shimmer(),
                ],
              );
            }
            return Column(
              children: [
                if (snapshot.data!.isEmpty)
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
                          _loadSubjects();
                        },
                      )
                  ),
                for (Subject subject in snapshot.data!)
                  SubjectListTile(
                    subject: subject,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return SubjectPage(subject: subject);
                        }),
                      );
                      _loadSubjects();
                    },
                  ),
              ],
            );
          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSubject,
        child: Icon(Icons.add),
      ),
    );
  }
}

class SubjectListTile extends StatelessWidget {

  final Subject subject;
  final GestureTapCallback? onTap;

  final bool shimmer;

  const SubjectListTile({super.key, required this.subject, this.onTap}) :
        shimmer = false;
  SubjectListTile.shimmer({super.key}) :
        shimmer = true,
        subject = Subject.empty(),
        onTap = null;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: shimmer ? Shimmer(height: 20, width: 50) : Text(subject.name),
      subtitle: shimmer ? Shimmer(height: 15, width: 40) : Text(subject.subjectType.name),
      onTap: onTap,
      leading: Container(
        margin: const EdgeInsets.only(left: 10),
        width: 8,
        decoration: BoxDecoration(
          color: shimmer ? shimmerColor : subject.color,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (GraduationService.isGraduationSubject(subject)) GraduationBadge(),
        ],
      ),
    );
  }
}
