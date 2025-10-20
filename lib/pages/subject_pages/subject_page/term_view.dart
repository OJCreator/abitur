import 'package:abitur/mappers/mappers/subject_mapper.dart';
import 'package:flutter/material.dart';

import '../../../mappers/models/subject_page_term_view_model.dart';
import '../../../sqlite/entities/evaluation/evaluation.dart';
import '../../../sqlite/entities/performance.dart';
import '../../../sqlite/entities/subject.dart';
import '../../../widgets/evaluation_list_tile.dart';
import '../../../widgets/info_card.dart';
import '../../../widgets/percent_indicator.dart';
import '../../../widgets/section_heading_list_tile.dart';
import '../../evaluation_pages/evaluation_input_page.dart';
import 'manual_term_note_enter_sheet.dart';

class TermView extends StatefulWidget {

  final Subject subject;
  final int term;

  const TermView({
    super.key,
    required this.subject,
    required this.term,
  });

  @override
  State<TermView> createState() => TermViewState();
}

class TermViewState extends State<TermView> {

  late Future<SubjectPageTermViewModel> termViewModelFuture;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TermView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subject != widget.subject || oldWidget.term != widget.term) {
      loadData();
    }
  }

  Future<void> loadData() async {
    termViewModelFuture = SubjectMapper.generateSubjectPageTermViewModel(widget.subject, widget.term);
  }

  Iterable<(int, Performance)> _getIndexedPerformances(Map<Performance, List<Evaluation>> evaluationsByPerformance) {
    List<Performance> keys = evaluationsByPerformance.keys.toList();
    keys.sort((a, b) => a.name.compareTo(b.name));
    return keys.indexed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(8),
        child: FutureBuilder(
          future: termViewModelFuture,
          builder: (context, asyncSnapshot) {
            if (!asyncSnapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: PercentIndicator.shimmer(),
                    ),
                  ),
                ],
              );
            }
            SubjectPageTermViewModel termViewModel = asyncSnapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: PercentIndicator(
                        value: termViewModel.termAverage,
                        color: widget.subject.color,
                        edit: () {
                          manuallyEnterTermNoteDialog();
                        },
                      ),
                    ),
                  ),
                  if (termViewModel.manualEnteredTermNote)
                    InfoCard("Diese Halbjahresnote wurde manuell eingetragen."),
                  ListTile(
                    title: Text(
                      "Noten:",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (termViewModel.evaluationsByPerformance.isEmpty)
                    InfoCard("In diesem Halbjahr gibt es noch keine Noten."),
                  for (final (i, p) in _getIndexedPerformances(termViewModel.evaluationsByPerformance)) ...[
                    if (i > 0)
                      Divider(),
                    SectionHeadingListTile(heading: p.name),
                    for (Evaluation e in termViewModel.evaluationsByPerformance[p]!)
                      EvaluationListTile(
                        evaluation: e,
                        evaluationDates: termViewModel.evaluationDatesByEvaluationId[e.id] ?? [],
                        note: termViewModel.evaluationNotes[e.id],
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return EvaluationInputPage(evaluation: e);
                            }),
                          );
                          loadData();
                        },
                      ),
                  ],
                  SizedBox(height: 80,), // damit der FloatingActionButton nichts verdeckt
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  void manuallyEnterTermNoteDialog() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return ManualTermNoteEnterSheet(subject: widget.subject, term: widget.term);
      },
    ).then((value) {
      loadData();
      setState(() { });
    });
  }
}