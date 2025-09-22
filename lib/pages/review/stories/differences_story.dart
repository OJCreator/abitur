import 'package:abitur/pages/review/stories/story.dart';
import 'package:abitur/pages/review/story_widgets/story_number_view.dart';
import 'package:flutter/cupertino.dart';

import '../review_data.dart';
import '../story_widgets/story_text_view.dart';

class DifferencesStory extends StatelessWidget implements Story {

  final ReviewData data;

  final GlobalKey<StoryTextViewState> key1 = GlobalKey();
  final GlobalKey<StoryNumberViewState> key2 = GlobalKey();

  DifferencesStory({super.key, required this.data});

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
          number: (data.difference * 100).toInt().abs(),
          decimalPlaces: 2,
          title: data.difference == 0 ? "War der Unterschied zwischen mündlich und schriftlich" : (data.difference > 0 ? "Notenpunkte warst du mündlich besser als schriftlich" : "Notenpunkte warst du schriftlich besser als mündlich"),
          subtitle: data.difference == 0 ? "Du kannst deine Leistung beeindruckend gut halten" : ("Kriss krass"),
          delay: Duration(seconds: 6),
        ),
      ],
    );
  }
}
