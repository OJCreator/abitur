import 'package:abitur/pages/review/stories/story.dart';
import 'package:abitur/pages/review/story_widgets/story_number_view.dart';
import 'package:abitur/storage/services/projection_service.dart';
import 'package:flutter/cupertino.dart';

import '../../../isolates/models/projection/projection_model.dart';
import '../story_widgets/story_text_view.dart';

class FinalStory extends StatelessWidget implements Story {

  final GlobalKey<StoryNumberViewState> key1 = GlobalKey();
  final GlobalKey<StoryTextViewState> key2 = GlobalKey();
  final GlobalKey<StoryNumberViewState> key3 = GlobalKey();

  FinalStory({super.key});

  @override
  Duration getDuration() {
    return Duration(seconds: 22);
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

    Future<ProjectionModel> projection = ProjectionService.computeProjectionIsolated();

    return Stack(
      children: [
        StoryNumberView(
          key: key1,
          number: 1000,
          title: "Dank, dass du da warst",
          subtitle: "Und dass du deine Reise mit uns gegangen bist",
          delay: Duration(seconds: 0),
        ),
        StoryTextView(
          key: key2,
          title: "Und jetzt, ...",
          subtitle: "worauf wir alle schon gewartet haben, ...",
          delay: Duration(seconds: 8),
        ),
        FutureBuilder(
          future: projection,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();
            return StoryNumberView(
              key: key3,
              number: (snapshot.data!.graduationAverage * 10).toInt(),
              decimalPlaces: 1,
              countBackwards: true,
              title: "Dein Abischnitt",
              subtitle: "Viel Glück auf deinen weiteren Wegen",
              delay: Duration(seconds: 14),
            );
          }
        ),
      ],
    );
  }
}
