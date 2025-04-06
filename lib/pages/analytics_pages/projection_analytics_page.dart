import 'package:abitur/pages/analytics_pages/projection_change_graduation_subjects_page.dart';
import 'package:abitur/storage/services/projection_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/widgets/analytics/note_projection.dart';
import 'package:abitur/widgets/forms/form_gap.dart';
import 'package:abitur/widgets/info_card.dart';
import 'package:abitur/widgets/linear_percent_indicator.dart';
import 'package:flutter/material.dart';

import '../../storage/entities/subject.dart';
import '../../widgets/percent_indicator.dart';

class ProjectionAnalyticsPage extends StatefulWidget {
  const ProjectionAnalyticsPage({super.key});

  @override
  State<ProjectionAnalyticsPage> createState() => _ProjectionAnalyticsPageState();
}

class _ProjectionAnalyticsPageState extends State<ProjectionAnalyticsPage> {

  List<Subject> subjects = SubjectService.findAllGradable();
  double overallAvg = SubjectService.getCurrentAverage() ?? 15;

  late Map<Subject, List<TermNoteDto>> data;
  List<Subject?> graduationSubjects = SubjectService.graduationSubjects();

  late int resultBlock1;
  late int resultBlock2;

  @override
  void initState() {
    data = ProjectionService.buildProjectionOverviewInformation();
    resultBlock1 = ProjectionService.resultBlock1();
    loadGraduationData();

    super.initState();
  }

  void loadGraduationData() {

    setState(() {
      resultBlock2 = ProjectionService.resultBlock2();
      graduationSubjects = SubjectService.graduationSubjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hochrechnung"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              PercentIndicator(value: ProjectionService.getGraduationAvg(), type: PercentIndicatorType.note,),
              FormGap(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    LinearPercentIndicator(
                      label: "Block 1",
                      description: "$resultBlock1 / 600 Punkten",
                      value: resultBlock1 / 600,
                    ),
                    FormGap(),
                    LinearPercentIndicator(
                      label: "Block 2",
                      description: "$resultBlock2 / 300 Punkten",
                      value: resultBlock2 / 300,
                    ),
                  ],
                ),
              ),
              FormGap(),
              InfoCard("Diese Daten zeigen nur die aktuelle Tendenz und können von der Realität abweichen."),
              FormGap(),
              Table(
                columnWidths: {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                },
                children: List.generate(data.length+1, (row) {
                  if (row == 0) {
                    return TableRow(
                      children: [
                        Container(),
                        Center(child: Text("HJ 1"),),
                        Center(child: Text("HJ 2"),),
                        Center(child: Text("HJ 3"),),
                        Center(child: Text("HJ 4"),),
                      ],
                    );
                  }
                  Subject s = data.keys.toList()[row - 1];
                  return TableRow(
                    decoration: BoxDecoration(
                      color: row%2 == 0 ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    children: List.generate(5, (col) {
                      if (col == 0) {
                        return SubjectTableLabel(subject: s);
                      }
                      TermNoteDto termNoteDto = data[s]![col - 1];
                      return NoteProjection(
                        background: termNoteDto.counting,
                        note: termNoteDto.noteString,
                        bold: !termNoteDto.projection,
                      );
                    }),
                  );
                }),
              ),
              
              FormGap(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Abiturfächer:",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectionChangeGraduationSubjectsPage(),
                          fullscreenDialog: true,
                        ),
                      );
                      loadGraduationData();
                    },
                    icon: Icon(Icons.edit),
                  ),
                ],
              ),

              Table(
                columnWidths: {
                  0: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                children: List.generate(graduationSubjects.length, (row) {
                  Subject? s = graduationSubjects[row];
                  return TableRow(
                    decoration: BoxDecoration(
                      color: row%2 == 0 ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    children: List.generate(2, (col) {
                      if (s == null) {
                        return Container();
                      }
                      if (col == 0) {
                        return SubjectTableLabel(subject: s);
                      }
                      TermNoteDto dto = ProjectionService.graduationProjection(s);
                      return NoteProjection(
                        background: dto.counting,
                        note: dto.noteString,
                        bold: !dto.projection,
                      );
                    })
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubjectTableLabel extends StatelessWidget {

  final Subject subject;

  const SubjectTableLabel({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            width: 5,
            height: 17,
            decoration: BoxDecoration(
              color: subject.color,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          Expanded(
            child: Text(
              subject.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
