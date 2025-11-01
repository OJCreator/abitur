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

  final List<GlobalKey<StoryProgressBarElementState>> _storyKeys = [];
  int _currentStoryIndex = 0;

  @override
  void initState() {
    for (Duration _ in widget.storyDurations) {
      _storyKeys.add(GlobalKey());
    }
    super.initState();
  }

  void _lastStory() {
    int newStoryIndex;
    if (_currentStoryIndex <= 0) {
      newStoryIndex = 0;
    } else {
      if (_storyKeys[_currentStoryIndex].currentState?.beenActiveForLessThanOneSecond() ?? true) {
        newStoryIndex = _currentStoryIndex - 1;
      } else {
        newStoryIndex = _currentStoryIndex;
      }
    }
    _changeStory(newStoryIndex);
  }

  void _nextStory() {
    if (_currentStoryIndex >= widget.storyDurations.length) {
      return;
    }
    _changeStory(_currentStoryIndex+1);
  }

  void _changeStory(int newStoryIndex) {
    setState(() {
      _currentStoryIndex = newStoryIndex;
    });
    widget.onChangeStory(_currentStoryIndex);
    _setPause(false);
    if (_currentStoryIndex < widget.storyDurations.length) {
      _storyKeys[_currentStoryIndex].currentState?.restart();
    }
  }

  void _setPause(bool pause) {
    setState(() {
      _pause = pause;
    });
    widget.onChangePause(pause);
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
                  key: _storyKeys[index],
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
              if (_currentStoryIndex < widget.storyDurations.length)
                IconButton.filledTonal(
                  onPressed: () {
                    _setPause(!_pause);
                  },
                  icon: Icon(_pause ? Icons.play_arrow : Icons.pause),
                ),
              if (_currentStoryIndex == widget.storyDurations.length)
                FilledButton.tonalIcon(
                  onPressed: () {
                    _changeStory(0);
                  },
                  icon: Icon(Icons.replay),
                  label: Text("Replay"),
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
        if (_currentStoryIndex < widget.storyDurations.length)
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _lastStory,
                    onLongPressStart: (_) => _setPause(true),
                    onLongPressEnd: (_) => _setPause(false),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _nextStory,
                    onLongPressStart: (_) => _setPause(true),
                    onLongPressEnd: (_) => _setPause(false),
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
