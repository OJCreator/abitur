import 'package:abitur/pages/review/story_widgets/story_number_view.dart';
import 'package:abitur/pages/review/story_widgets/story_ranking_view.dart';
import 'package:abitur/utils/pair.dart';
import 'package:flutter/material.dart';

import '../../../storage/entities/subject.dart';
import '../../../storage/services/subject_service.dart';

class SubjectsStory extends StatelessWidget {

  final List<Subject> subjects = SubjectService.findAll();

  SubjectsStory({super.key});

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
          number: subjects.length,
          title: "Fächer hast du belegt",
          subtitle: "Ein solides Grundwissen fürs Leben",
          delay: Duration(seconds: 0),
        ),
        StoryRankingView(
          title: "Die hier scheinen richtig dein Ding zu sein!",
          delay: Duration(seconds: 7),
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
