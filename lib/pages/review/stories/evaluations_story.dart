import 'package:abitur/pages/review/stories/story.dart';
import 'package:abitur/pages/review/story_widgets/story_graph_view.dart';
import 'package:abitur/pages/review/story_widgets/story_number_view.dart';
import 'package:flutter/material.dart';

import '../../../storage/services/evaluation_date_service.dart';

class EvaluationsStory extends StatelessWidget implements Story {

  final int evaluationDateAmount = EvaluationDateService.findAll().length;
  late final List<int> noteAmounts = List.generate(16, (_) => 0);

  final GlobalKey<StoryNumberViewState> key1 = GlobalKey();
  final GlobalKey<StoryGraphViewState> key2 = GlobalKey();

  EvaluationsStory({super.key});

  @override
  Duration getDuration() {
    return Duration(seconds: 16);
  }

  @override
  void pause() {
    key1.currentState?.pause();
    key2.currentState?.pause();
  }

  @override
  void resume() {
    key1.currentState?.resume();
    key2.currentState?.resume();
  }

  @override
  void restart() {
    key1.currentState?.restart();
    key2.currentState?.restart();
  }

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
          key: key1,
          number: evaluationDateAmount,
          title: "Prüfungen absolviert",
          subtitle: "Wow! Was für eine Leistung!",
          delay: Duration(seconds: 0),
        ),
        StoryGraphView(
          key: key2,
          title: "Falls du dich fragst, was deine häufigste Note war...",
          delay: Duration(seconds: 8),
          data: noteAmounts,
          xAxisTitle: "Note",
          yAxisTitle: "Häufigkeit",
        ),
      ],
    );
  }
}
