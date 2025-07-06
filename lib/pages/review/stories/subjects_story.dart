import 'package:abitur/pages/review/stories/story.dart';
import 'package:abitur/pages/review/story_widgets/story_number_view.dart';
import 'package:abitur/pages/review/story_widgets/story_ranking_view.dart';
import 'package:abitur/utils/pair.dart';
import 'package:flutter/material.dart';

import '../../../storage/entities/subject.dart';
import '../../../storage/services/subject_service.dart';

class SubjectsStory extends StatelessWidget implements Story {

  final List<Subject> subjects = SubjectService.findAll();

  final GlobalKey<StoryNumberViewState> key1 = GlobalKey();
  final GlobalKey<StoryRankingViewState> key2 = GlobalKey();

  SubjectsStory({super.key});

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
  Widget build(BuildContext context) {
    List<Pair<Subject, double>> subjectAvgs = [];
    for (Subject s in subjects) {
      double? avg = SubjectService.getAverage(s);
      if (avg == null) continue;
      subjectAvgs.add(Pair(s, avg));
    }
    subjectAvgs.sort((a,b) => b.second.compareTo(a.second));
    return Stack(
      children: [
        StoryNumberView(
          key: key1,
          number: subjects.length,
          title: "Fächer hast du belegt",
          subtitle: "Ein solides Grundwissen fürs Leben",
          delay: Duration(seconds: 0),
        ),
        StoryRankingView(
          key: key2,
          title: "Die hier scheinen richtig dein Ding zu sein!",
          delay: Duration(seconds: 8),
          ranking: subjectAvgs.take(5).map((pair) {
            return RankingElement(
              title: pair.first.name,
              subtitle: "Ø ${pair.second.toStringAsFixed(2)}",
              color: pair.first.color,
            );
          }).toList(),
        ),
      ],
    );
  }
}
