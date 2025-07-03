import 'package:abitur/pages/review/story_progress_bar_element.dart';
import 'package:flutter/material.dart';

class ReviewPageOverlay extends StatefulWidget {

  final List<Duration> storyDurations;
  final void Function(bool pause) onChangePause;
  final void Function(bool pause) onChangeMusic;
  final void Function(int storyIndex) onChangeStory;

  const ReviewPageOverlay({super.key, required this.storyDurations, required this.onChangePause, required this.onChangeMusic, required this.onChangeStory});

  @override
  State<ReviewPageOverlay> createState() => _ReviewPageOverlayState();
}

class _ReviewPageOverlayState extends State<ReviewPageOverlay> {

  bool _pause = false;
  bool _music = true;

  int _currentStoryIndex = 0;

  void _lastStory() {
    // todo an den Anfang zurückspringen, wenn man in der ersten halben Sekunde ist, eine Story zurückspringen
    if (_currentStoryIndex <= 0) {
      return;
    }
    setState(() {
      _currentStoryIndex--;
    });
    widget.onChangeStory(_currentStoryIndex);
  }

  void _nextStory() {
    // todo ganz am Ende auf so eine Übersichtsseite springen
    if (_currentStoryIndex >= widget.storyDurations.length - 1) {
      return;
    }
    setState(() {
      _currentStoryIndex++;
    });
    widget.onChangeStory(_currentStoryIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(widget.storyDurations.length, (index) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: StoryProgressBarElement(
                  index: index,
                  currentStory: _currentStoryIndex,
                  duration: widget.storyDurations[index],
                  isPaused: _pause,
                  onFinishedStory: _nextStory,
                ),
              ),
            );
          }),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton.filledTonal(
                onPressed: () {
                  setState(() {
                    _pause = !_pause;
                  });
                  widget.onChangePause(_pause);
                },
                icon: Icon(_pause ? Icons.play_arrow : Icons.pause),
              ),
              IconButton.filledTonal(
                onPressed: () {
                  setState(() {
                    _music = !_music;
                  });
                  widget.onChangeMusic(_music);
                },
                icon: Icon(_music ? Icons.volume_up : Icons.volume_off),
              ),
              IconButton.filledTonal(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close),
              )
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _lastStory,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _nextStory,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
