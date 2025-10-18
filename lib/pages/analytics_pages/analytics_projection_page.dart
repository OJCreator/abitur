import 'package:abitur/isolates/models/projection/projection_model.dart';
import 'package:abitur/services/projection_service.dart';
import 'package:abitur/widgets/analytics/note_projection.dart';
import 'package:abitur/widgets/forms/form_gap.dart';
import 'package:abitur/widgets/info_card.dart';
import 'package:abitur/widgets/linear_percent_indicator.dart';
import 'package:flutter/material.dart';

import '../../services/database/subject_service.dart';
import '../../sqlite/entities/subject.dart';
import '../../widgets/percent_indicator.dart';

class ProjectionAnalyticsPage extends StatefulWidget {
  const ProjectionAnalyticsPage({super.key});

  @override
  State<ProjectionAnalyticsPage> createState() => _ProjectionAnalyticsPageState();
}

class _ProjectionAnalyticsPageState extends State<ProjectionAnalyticsPage> {

  late Future<ProjectionModel> projection;

  @override
  void initState() {
    loadData();

    super.initState();
  }

  void loadData() {

    setState(() {
      projection = ProjectionService.computeProjectionIsolated();
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
              FutureBuilder(
                future: projection,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return PercentIndicator.shimmer(title: "Abiturschnitt",);
                  return PercentIndicator(value: snapshot.data!.graduationAverage, type: PercentIndicatorType.note, title: "Abiturschnitt",);
                },
              ),
              FormGap(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    FutureBuilder(
                      future: projection,
                      builder: (context, snapshot) {
                        return LinearPercentIndicator(
                          label: "Block 1",
                          description: snapshot.hasData ? "${snapshot.data!.resultBlock1} / 600 Punkten" : "max. 600 Punkte",
                          value: snapshot.hasData ? (snapshot.data!.resultBlock1 / 600) : 0,
                        );
                      }
                    ),
                    FormGap(),
                    FutureBuilder(
                        future: projection,
                        builder: (context, snapshot) {
                          return LinearPercentIndicator(
                            label: "Block 2",
                            description: snapshot.hasData ? "${snapshot.data!.resultBlock2} / 300 Punkten" : "max. 300 Punkte",
                            value: snapshot.hasData ? (snapshot.data!.resultBlock2 / 300) : 0,
                          );
                        }
                    ),
                  ],
                ),
              ),
              FormGap(),
              InfoCard("Diese Daten zeigen nur die aktuelle Tendenz und können von der Realität abweichen."),
              FormGap(),
              FutureBuilder(
                future: projection,
                builder: (context, snapshot) {
                  List<ProjectionSubjectBlock1Model> data;
                  if (snapshot.hasData) {
                    data = snapshot.data!.block1;
                  } else {
                    data = [];
                  }
                  return Table(
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
                      Future<Subject?> subject = SubjectService.findById(data[row - 1].subjectId);
                      return TableRow(
                        decoration: BoxDecoration(
                          color: row%2 == 0 ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        children: List.generate(5, (col) {
                          if (col == 0) {
                            return FutureBuilder(
                                future: subject,
                                builder: (context, asyncSnapshot) {
                                  return SubjectTableLabel(subject: asyncSnapshot.data ?? Subject.empty());
                                }
                            );
                          }
                          ProjectionTermModel termNoteDto = data[row - 1].terms[col - 1];
                          return NoteProjection(
                            background: termNoteDto.counting,
                            note: termNoteDto.noteString,
                            bold: !termNoteDto.projection,
                            weight: termNoteDto.weight,
                          );
                        }),
                      );
                    }),
                  );
                }
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
                          builder: (context) => Scaffold(), // TODO
                          fullscreenDialog: true,
                        ),
                      );
                      loadData();
                    },
                    icon: Icon(Icons.edit),
                  ),
                ],
              ),

              FutureBuilder(
                future: projection,
                builder: (context, snapshot) {
                  List<ProjectionSubjectBlock2Model> data;
                  if (snapshot.hasData) {
                    data = snapshot.data!.block2;
                  } else {
                    data = [];
                  }
                  return Table(
                    columnWidths: {
                      0: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                    },
                    children: List.generate(data.length, (row) {
                      Future<Subject?> subject = SubjectService.findById(data[row].subjectId);
                      return TableRow(
                        decoration: BoxDecoration(
                          color: row%2 == 0 ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        children: List.generate(2, (col) {
                          if (col == 0) {
                            return FutureBuilder(
                              future: subject,
                              builder: (context, asyncSnapshot) {
                                return SubjectTableLabel(subject: asyncSnapshot.data ?? Subject.empty());
                              }
                            );
                          }
                          ProjectionTermModel dto = data[row].result;
                          return NoteProjection(
                            background: dto.counting,
                            note: dto.noteString,
                            bold: !dto.projection,
                            weight: dto.weight,
                          );
                        })
                      );
                    }),
                  );
                }
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
