import 'package:abitur/pages/review/stories/story.dart';
import 'package:flutter/cupertino.dart';

import '../story_widgets/story_text_view.dart';

class WelcomeStory extends StatelessWidget implements Story {

  final GlobalKey<StoryTextViewState> key1 = GlobalKey();
  final GlobalKey<StoryTextViewState> key2 = GlobalKey();

  WelcomeStory({super.key});

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
          title: "Willkommen zu deinem persönlichen Abitur-Review",
          subtitle: "Bist du bereit?",
          delay: Duration(seconds: 1),
        ),
        StoryTextView(
          key: key2,
          title: "Die Zeit vergeht schnell",
          subtitle: "Gut dass wir uns ein paar Notizen gemacht haben",
          delay: Duration(seconds: 7),
        ),
      ],
    );
  }
}
