import 'package:abitur/pages/review/stories/story.dart';
import 'package:abitur/pages/review/story_widgets/story_number_view.dart';
import 'package:abitur/pages/review/story_widgets/story_ranking_view.dart';
import 'package:abitur/storage/entities/evaluation_date.dart';
import 'package:abitur/storage/services/evaluation_date_service.dart';
import 'package:abitur/utils/pair.dart';
import 'package:flutter/material.dart';

import '../../../storage/entities/subject.dart';
import '../../../storage/services/subject_service.dart';

class SubjectsStory extends StatelessWidget implements Story {

  final List<Subject> subjects = SubjectService.findAll();
  final List<EvaluationDate> evaluationDates = EvaluationDateService.findAll();

  final GlobalKey<StoryNumberViewState> key1 = GlobalKey();
  final GlobalKey<StoryRankingViewState> key2 = GlobalKey();
  final GlobalKey<StoryNumberViewState> key3 = GlobalKey();
  final GlobalKey<StoryRankingViewState> key4 = GlobalKey();

  SubjectsStory({super.key});

  @override
  Duration getDuration() {
    return Duration(seconds: 32);
  }

  @override
  void pause() {
    key1.currentState?.pause();
    key2.currentState?.pause();
    key3.currentState?.pause();
    key4.currentState?.pause();
  }

  @override
  void resume() {
    key1.currentState?.resume();
    key2.currentState?.resume();
    key3.currentState?.resume();
    key4.currentState?.resume();
  }

  @override
  void restart() {
    key1.currentState?.restart();
    key2.currentState?.restart();
    key3.currentState?.restart();
    key4.currentState?.restart();
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

    Map<Subject, int> evaluationDatesPerSubject = {};
    for (EvaluationDate e in evaluationDates) {
      evaluationDatesPerSubject[e.evaluation.subject] = (evaluationDatesPerSubject[e.evaluation.subject] ?? 0) + 1;
    }
    List<Subject> subjectNames = evaluationDatesPerSubject.keys.toList();
    subjectNames.sort((a,b) => evaluationDatesPerSubject[b]?.compareTo(evaluationDatesPerSubject[a]!) ?? 0);

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
        StoryNumberView(
          key: key3,
          number: evaluationDatesPerSubject[subjectNames.first]!,
          title: "Prüfungen hattest du in ${subjectNames.first.name}",
          subtitle: "Das Fach sollte damit die präziseste Note haben",
          delay: Duration(seconds: 16),
        ),
        StoryRankingView(
          key: key4,
          title: "Und die hier folgen nur knapp dahinter",
          delay: Duration(seconds: 24),
          startWithIndex: 2,
          ranking: subjectNames.skip(1).take(5).map((subject) {
            return RankingElement(
              title: subject.name,
              subtitle: "${evaluationDatesPerSubject[subject]} Prüfungen",
              color: subject.color,
            );
          }).toList(),
        ),
      ],
    );
  }
}
