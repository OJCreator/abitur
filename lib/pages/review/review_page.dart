import 'package:abitur/pages/review/review_days.dart';
import 'package:abitur/pages/review/review_evaluation_types.dart';
import 'package:abitur/pages/review/review_figures.dart';
import 'package:abitur/pages/review/review_notes.dart';
import 'package:abitur/pages/review/review_page_overlay.dart';
import 'package:abitur/pages/review/stories/welcome_story.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {

  late AudioPlayer _audioPlayer;

  final List<Widget> stories = [
    WelcomeStory(),
    ReviewFigures(),
    ReviewNotes(),
    ReviewEvaluationTypes(),
    ReviewDays(),
  ];
  List<Duration> storyDurations = [
    Duration(seconds: 13),
    Duration(seconds: 5),
    Duration(seconds: 5),
    Duration(seconds: 5),
    Duration(seconds: 5),
  ];
  int _currentStoryIndex = 0;
  bool _pause = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadAudio();
  }
  Future<void> _loadAudio() async {
    try {
      await _audioPlayer.setAsset("assets/mp3/embrace-364091.mp3");
      _audioPlayer.play();
    } catch (e) {
      print("Error loading audio: $e");
    }
  }
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
  void _seekAudioToStory(int storyIndex) {
    if (storyIndex < 0 || storyIndex >= storyDurations.length) return;
    Duration d = Duration();
    for (int i = 0; i < storyIndex; i++) {
      d = d + storyDurations[i];
    }
    if ((_audioPlayer.position - d).abs().compareTo(Duration(seconds: 1)) < 0) return; // es ist nur ein ganz kleiner Unterschied
    _audioPlayer.seek(d);
    if (_pause) return;
    _audioPlayer.play();
  }

  void onPause(bool pause) {
    setState(() {
      _pause = pause;
    });
    if (pause) {
      // pause
      _audioPlayer.pause();
      // todo pause story
    } else {
      // resume
      _audioPlayer.play();
      // todo resume story
    }
  }

  void onMusic(bool music) {
    if (music) {
      _audioPlayer.setVolume(1);
    } else {
      _audioPlayer.setVolume(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // todo background
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 80),
              child: stories[_currentStoryIndex],
            ),
          ),
          SafeArea(
            child: ReviewPageOverlay(
              storyDurations: storyDurations,
              onChangePause: onPause,
              onChangeMusic: onMusic,
              onChangeStory: (int storyIndex) {
                setState(() {
                  _currentStoryIndex = storyIndex;
                });
                _seekAudioToStory(storyIndex);
              },
            ),
          ),
        ],
      ),
    );
  }
}
