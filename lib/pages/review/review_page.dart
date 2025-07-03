import 'package:abitur/pages/review/review_days.dart';
import 'package:abitur/pages/review/review_evaluation_types.dart';
import 'package:abitur/pages/review/review_figures.dart';
import 'package:abitur/pages/review/review_notes.dart';
import 'package:abitur/pages/review/review_page_overlay.dart';
import 'package:abitur/pages/review/story_text_view.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {

  final List<Widget> stories = [
    Stack(
      children: [
        StoryTextView(
          title: "Willkommen zu deinem persönlichen Abitur-Review",
          subtitle: "Bist du bereit?",
        ),
        StoryTextView(
          title: "Die Zeit vergeht schnell",
          subtitle: "Gut dass wir uns ein paar Notizen gemacht haben",
          delay: Duration(seconds: 6),
        ),
      ],
    ),
    ReviewFigures(),
    ReviewNotes(),
    ReviewEvaluationTypes(),
    ReviewDays(),
  ];
  List<Duration> durations = [
    Duration(seconds: 12),
    Duration(seconds: 5),
    Duration(seconds: 5),
    Duration(seconds: 5),
    Duration(seconds: 5),
  ];
  int _currentStoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // background
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 80),
              child: stories[_currentStoryIndex],
            ),
          ),
          SafeArea(
            child: ReviewPageOverlay(
              storyDurations: durations,
              onChangePause: (bool pause) {
                // todo
              },
              onChangeMusic: (bool pause) {
                // todo
              },
              onChangeStory: (int storyIndex) {
                setState(() {
                  _currentStoryIndex = storyIndex;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
