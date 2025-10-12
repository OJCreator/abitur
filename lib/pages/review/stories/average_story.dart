import 'package:abitur/pages/review/review_data.dart';
import 'package:abitur/pages/review/stories/story.dart';
import 'package:abitur/pages/review/story_widgets/story_number_view.dart';
import 'package:abitur/utils/extensions/int_extension.dart';
import 'package:abitur/utils/extensions/lists/nullable_num_list_extension.dart';
import 'package:flutter/material.dart';

import '../story_widgets/story_graph_view.dart';

class AverageStory extends StatelessWidget implements Story {

  final ReviewData data;

  final GlobalKey<StoryNumberViewState> key1 = GlobalKey();
  final GlobalKey<StoryGraphViewState> key2 = GlobalKey();
  final GlobalKey<StoryGraphViewState> key3 = GlobalKey();

  AverageStory({super.key, required this.data});

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

    String bestDay;
    switch (data.weekdayAverages.indexOfMax()) {
      case 0: bestDay = "Montags";
      case 1: bestDay = "Dienstags";
      case 2: bestDay = "Mittwochs";
      case 3: bestDay = "Donnerstags";
      default: bestDay = "Freitags";
    }

    return Stack(
      children: [
        StoryNumberView(
          key: key1,
          number: data.schoolDays,
          title: "Tage in die Schule gegangen",
          subtitle: "Klar, dass da mancher besser war als der andere...",
          delay: Duration(seconds: 0),
        ),
        StoryGraphView(
          key: key2,
          title: "$bestDay hast du am besten performed",
          delay: Duration(seconds: 8),
          data: data.weekdayAverages,
          xAxisTitle: null,
          yAxisTitle: "Durchschnitt",
          xValues: (index) {
            switch (index) {
              case 0: return "Mo";
              case 1: return "Di";
              case 2: return "Mi";
              case 3: return "Do";
              default: return "Fr";
            }
          }
        ),
        StoryGraphView(
          key: key3,
          title: "Und über die ganze Zeit:",
          delay: Duration(seconds: 16),
          data: data.monthAverages,
          xAxisTitle: null,
          yAxisTitle: "Durchschnitt",
          xValues: (index) {
            if (index % 2 != 0) return "";
            final monthNumber = (data.startMonth.month - 1 + index) % 12 + 1;
            return monthNumber.monthShort();
          }
        ),
      ],
    );
  }
}