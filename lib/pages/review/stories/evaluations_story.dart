import 'package:abitur/pages/review/stories/story.dart';
import 'package:abitur/pages/review/story_widgets/story_graph_view.dart';
import 'package:abitur/pages/review/story_widgets/story_number_view.dart';
import 'package:abitur/pages/review/story_widgets/story_pie_chart_view.dart';
import 'package:flutter/material.dart';

import '../review_data.dart';

class EvaluationsStory extends StatelessWidget implements Story {

  final ReviewData data;

  final GlobalKey<StoryNumberViewState> key1 = GlobalKey();
  final GlobalKey<StoryGraphViewState> key2 = GlobalKey();
  final GlobalKey<StoryPieChartViewState> key3 = GlobalKey();

  EvaluationsStory({super.key, required this.data});

  @override
  Duration getDuration() {
    return Duration(seconds: 24);
  }

  @override
  void pause() {
    key1.currentState?.pause();
    key2.currentState?.pause();
    key3.currentState?.pause();
  }

  @override
  void resume() {
    key1.currentState?.resume();
    key2.currentState?.resume();
    key3.currentState?.resume();
  }

  @override
  void restart() {
    key1.currentState?.restart();
    key2.currentState?.restart();
    key3.currentState?.restart();
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        StoryNumberView(
          key: key1,
          number: data.evaluationDates.length,
          title: "Prüfungen absolviert",
          subtitle: "Wow! Was für eine Leistung!",
          delay: Duration(seconds: 0),
        ),
        StoryGraphView(
          key: key2,
          title: "Falls du dich fragst, was deine häufigste Note war...",
          delay: Duration(seconds: 8),
          data: data.noteAmounts,
          xAxisTitle: "Note",
          yAxisTitle: "Häufigkeit",
        ),
        StoryPieChartView(
          key: key3,
          title: "Und wie wurdest du geprüft?",
          delay: Duration(seconds: 16),
          data: data.evaluationTypeUses,
          xAxisTitle: "Note",
          yAxisTitle: "Häufigkeit",
        ),
      ],
    );
  }
}
