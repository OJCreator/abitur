import 'package:abitur/pages/subject_pages/subject_chose_graduation_page.dart';
import 'package:abitur/pages/subject_pages/subject_input_page.dart';
import 'package:abitur/pages/subject_pages/subject_page.dart';
import 'package:abitur/widgets/info_card.dart';
import 'package:flutter/material.dart';

import '../../services/database/graduation_evaluation_service.dart';
import '../../services/database/settings_service.dart';
import '../../services/database/subject_service.dart';
import '../../sqlite/entities/subject.dart';
import '../../widgets/list_tiles/subject_list_tile.dart';

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
      subjects = SubjectService.findAll();
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
            debugPrint(snapshot.data.toString());
            debugPrint(snapshot.hasError.toString());
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
                    child: InfoCard("Es gibt noch keine Fächer."),
                  ),
                FutureBuilder(
                  future: SettingsService.dayToChoseGraduationSubjects(),
                  builder: (context, asyncSnapshot) {
                    if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                      return Container();
                    }
                    DateTime dayToChoseGraduationSubjects = asyncSnapshot.data!;
                    if (!DateTime.now().isAfter(dayToChoseGraduationSubjects)) return Container();
                    return Padding(
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
                      ),
                    );
                  }
                ),
                for (Subject subject in snapshot.data!)
                  FutureBuilder(
                    future: GraduationEvaluationService.isGraduationSubject(subject),
                    builder: (context, asyncSnapshot) {
                      if (!asyncSnapshot.hasData) {
                        return SubjectListTile.shimmer();
                      }
                      bool isGraduationSubject = asyncSnapshot.data!;
                      return SubjectListTile(
                        subject: subject,
                        isGraduationSubject: isGraduationSubject,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return SubjectPage(subjectId: subject.id);
                            }),
                          );
                          _loadSubjects();
                        },
                      );
                    }
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
