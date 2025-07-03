import 'package:flutter/cupertino.dart';

import '../story_text_view.dart';

class WelcomeStory extends StatelessWidget {
  const WelcomeStory({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StoryTextView(
          title: "Willkommen zu deinem persönlichen Abitur-Review",
          subtitle: "Bist du bereit?",
          delay: Duration(seconds: 1),
        ),
        StoryTextView(
          title: "Die Zeit vergeht schnell",
          subtitle: "Gut dass wir uns ein paar Notizen gemacht haben",
          delay: Duration(seconds: 7),
        ),
      ],
    );
  }
}
