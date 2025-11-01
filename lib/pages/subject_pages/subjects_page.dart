import 'package:abitur/mappers/mappers/subject_mapper.dart';
import 'package:abitur/pages/subject_pages/subject_chose_graduation_page.dart';
import 'package:abitur/pages/subject_pages/subject_input_page.dart';
import 'package:abitur/pages/subject_pages/subject_page.dart';
import 'package:abitur/widgets/fab_overlap_preventer.dart';
import 'package:abitur/widgets/info_card.dart';
import 'package:flutter/material.dart';

import '../../mappers/models/subjects_page_model.dart';
import '../../sqlite/entities/subject.dart';
import '../../widgets/list_tiles/subject_list_tile.dart';

class SubjectsPage extends StatefulWidget {

  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {

  late Future<SubjectsPageModel> subjectsPageDtoFuture;

  @override
  void initState() {
    _loadSubjects();
    super.initState();
  }

  void _loadSubjects() {
    setState(() {
      subjectsPageDtoFuture = SubjectMapper.generateSubjectsPageModel();
    });
  }

  Future<void> _addNewSubject() async {
    await Navigator.push(context,
      MaterialPageRoute(builder: (context) {
        return SubjectInputPage();
      }),
    );
    _loadSubjects();
  }

  Future<void> _setGraduationSubjects() async {
    await Navigator.push(context,
      MaterialPageRoute(
        builder: (context) {
          return SubjectChoseGraduationPage();
        },
        fullscreenDialog: true,
      ),
    );
    _loadSubjects();
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
                _setGraduationSubjects();
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
          future: subjectsPageDtoFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Column(
                children: [
                  for (int i = 0; i < 10; i++)
                    SubjectListTile.shimmer(),
                ],
              );
            }
            SubjectsPageModel subjectsPageDto = snapshot.data!;
            return Column(
              children: [
                if (subjectsPageDto.subjects.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InfoCard("Es gibt noch keine Fächer."),
                  ),
                if (subjectsPageDto.timeToChoseGraduationSubjects)
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
                  ),
                ),
                for (Subject subject in subjectsPageDto.subjects)
                  SubjectListTile(
                    subject: subject,
                    isGraduationSubject: subjectsPageDto.isGraduationSubject[subject] == true,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return SubjectPage(subjectId: subject.id);
                        }),
                      );
                      _loadSubjects();
                    },
                  ),
                FabOverlapPreventer(),
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
