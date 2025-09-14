import 'package:abitur/pages/review/stories/story.dart';
import 'package:abitur/pages/review/story_widgets/story_number_view.dart';
import 'package:abitur/storage/entities/evaluation_date.dart';
import 'package:abitur/storage/entities/evaluation_type.dart';
import 'package:abitur/storage/services/evaluation_date_service.dart';
import 'package:flutter/cupertino.dart';

import '../story_widgets/story_text_view.dart';

class DifferencesStory extends StatelessWidget implements Story {

  final GlobalKey<StoryTextViewState> key1 = GlobalKey();
  final GlobalKey<StoryNumberViewState> key2 = GlobalKey();

  DifferencesStory({super.key});

  @override
  Duration getDuration() {
    return Duration(seconds: 13);
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

    List<EvaluationDate> evaluationDates = EvaluationDateService.findAll();
    List<EvaluationDate> oral = evaluationDates.where((e) => e.note != null && e.evaluation.evaluationType.assessmentType == AssessmentType.oral).toList();
    List<EvaluationDate> written = evaluationDates.where((e) => e.note != null && e.evaluation.evaluationType.assessmentType == AssessmentType.written).toList();

    double oralAvg = oral.isEmpty
        ? 0
        : oral.map((e) => e.note).reduce((a, b) => a! + b!)! / oral.length;
    double writtenAvg = written.isEmpty
        ? 0
        : written.map((e) => e.note).reduce((a, b) => a! + b!)! / written.length;

    int difference = ((oralAvg - writtenAvg) * 100).toInt();

    return Stack(
      children: [
        StoryTextView(
          key: key1,
          title: "Bla Bla Bla", // TODO Hier ein passendes Zitat
          subtitle: "Sagte einst irgendwer schlaues",
          delay: Duration(seconds: 0),
        ),
        StoryNumberView(
          key: key2,
          number: difference.abs(),
          decimalPlaces: 2,
          title: difference == 0 ? "War der Unterschied zwischen mündlich und schriftlich" : (difference > 0 ? "Notenpunkte warst du mündlich besser als schriftlich" : "Notenpunkte warst du schriftlich besser als mündlich"),
          subtitle: difference == 0 ? "Du kannst deine Leistung beeindruckend gut halten" : ("Kriss krass"),
          delay: Duration(seconds: 6),
        ),
      ],
    );
  }
}
