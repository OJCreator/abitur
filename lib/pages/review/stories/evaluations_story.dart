import 'package:abitur/pages/review/story_widgets/story_graph_view.dart';
import 'package:abitur/pages/review/story_widgets/story_number_view.dart';
import 'package:flutter/material.dart';

import '../../../storage/services/evaluation_date_service.dart';

class EvaluationsStory extends StatelessWidget {

  final int evaluationDateAmount = EvaluationDateService.findAll().length;
  late final List<int> noteAmounts = List.generate(16, (_) => 0);

  EvaluationsStory({super.key});

  @override
  Widget build(BuildContext context) {

    final evaluationDates = EvaluationDateService.findAll();
    for (var e in evaluationDates) {
      if (e.note == null) {
        continue;
      }
      noteAmounts[e.note!]++;
    }

    return Stack(
      children: [
        StoryNumberView(
          number: evaluationDateAmount,
          title: "Prüfungen absolviert",
          subtitle: "Wow! Was für eine Leistung!",
          delay: Duration(seconds: 0),
        ),
        StoryGraphView(
          title: "Falls du dich fragst, was deine häufigste Note war...",
          delay: Duration(seconds: 7),
          data: noteAmounts,
          xAxisTitle: "Note",
          yAxisTitle: "Häufigkeit",
        ),
      ],
    );
  }
}
