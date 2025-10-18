import 'package:abitur/services/database/performance_service.dart';
import 'package:abitur/sqlite/entities/evaluation/evaluation_date.dart';
import 'package:abitur/utils/extensions/lists/iterable_extension.dart';
import 'package:flutter/material.dart';

import '../../../services/database/evaluation_date_service.dart';
import '../../../services/database/evaluation_service.dart';
import '../../../services/database/subject_service.dart';
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

  // List<Evaluation> evaluations = [];
  Map<Performance, List<Evaluation>> evaluations = {};
  Map<String, List<EvaluationDate>> evaluationDatesByEvaluationId = {};

  @override
  void didUpdateWidget(covariant TermView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subject != widget.subject || oldWidget.term != widget.term) {
      loadEvaluations();
    }
  }

  @override
  void initState() {
    loadEvaluations();
    super.initState();
  }

  Future<void> loadEvaluations() async {
    final allEvaluations = await EvaluationService.findAllBySubjectAndTerm(widget.subject, widget.term);
    final evaluationsMap = allEvaluations.groupBy((e) => e.performanceId);
    final performanceIds = evaluationsMap.keys;
    final evaluationIds = allEvaluations.map((e) => e.id);
    final performances = await PerformanceService.findAllByIds(performanceIds.toList());
    evaluationDatesByEvaluationId = await EvaluationDateService.findAllByEvaluationIds(evaluationIds.toList());
    setState(() {
      evaluations = evaluationsMap.map((pId, e) => MapEntry(performances[pId]!, e));
      for (List<Evaluation> list in evaluations.values) {
        list.sort((a, b) => evaluationDatesByEvaluationId[a.id]!.first.compareTo(evaluationDatesByEvaluationId[b.id]!.first));
      }
    });
  }

  Iterable<(int, Performance)> _getIndexedPerformances() {
    List<Performance> keys = evaluations.keys.toList();
    keys.sort((a, b) => a.name.compareTo(b.name));
    return keys.indexed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: FutureBuilder(
                      future: SubjectService.getAverageByTerm(widget.subject, widget.term),
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.hasData) return PercentIndicator.shimmer();
                        return PercentIndicator(
                          value: asyncSnapshot.data,
                          color: widget.subject.color,
                          edit: () {
                            manuallyEnterTermNoteDialog();
                          },
                        );
                      }
                  ),
                ),
              ),
              if (widget.subject.manuallyEnteredTermNotes[widget.term] != null)
                InfoCard("Diese Halbjahresnote wurde manuell eingetragen."),
              ListTile(
                title: Text(
                  "Noten:",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (evaluations.isEmpty)
                InfoCard("In diesem Halbjahr gibt es noch keine Noten."),
              for (final (i, p) in _getIndexedPerformances()) ...[
                if (i > 0)
                  Divider(),
                SectionHeadingListTile(heading: p.name),
                for (Evaluation e in evaluations[p]!)
                  EvaluationListTile(
                    evaluation: e,
                    evaluationDates: evaluationDatesByEvaluationId[e.id]!,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return EvaluationInputPage(evaluation: e);
                        }),
                      );
                      loadEvaluations();
                    },
                  ),
              ],
            ],
          ),
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
      setState(() { });
    });
  }
}