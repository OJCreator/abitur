import 'package:abitur/pages/review/review_data.dart';
import 'package:abitur/pages/review/review_final_export_page.dart';
import 'package:abitur/pages/review/review_page_overlay.dart';
import 'package:abitur/pages/review/stories/average_story.dart';
import 'package:abitur/pages/review/stories/differences_story.dart';
import 'package:abitur/pages/review/stories/evaluations_story.dart';
import 'package:abitur/pages/review/stories/final_story.dart';
import 'package:abitur/pages/review/stories/story.dart';
import 'package:abitur/pages/review/stories/subjects_story.dart';
import 'package:abitur/pages/review/stories/welcome_story.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {

  late ReviewData _reviewData;

  late AudioPlayer _audioPlayer;

  late List<Story> _stories;
  int _currentStoryIndex = 0;
  bool _pause = true;

  @override
  void initState() {
    super.initState();
    _loadReview();
  }

  Future<void> _loadReview() async {
    _reviewData = ReviewData();
    _stories = [
      WelcomeStory(),
      SubjectsStory(data: _reviewData),
      EvaluationsStory(data: _reviewData),
      DifferencesStory(data: _reviewData),
      AverageStory(data: _reviewData),
      FinalStory(data: _reviewData),
    ];
    await WakelockPlus.enable();
    _audioPlayer = AudioPlayer();
    await _loadAudio();
    _pause = false;
  }

  Future<void> _loadAudio() async {
    try {
      _audioPlayer.processingStateStream.firstWhere((state) => state == ProcessingState.ready).then((_) {
        if (!_pause) {
          _audioPlayer.play();
        }
      });
      _audioPlayer.setAsset("assets/mp3/embrace-364091.mp3");
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }
  @override
  void dispose() {
    _audioPlayer.dispose();
    WakelockPlus.disable();
    super.dispose();
  }
  void _seekAudioToStory(int storyIndex) {
    if (storyIndex < 0 || storyIndex > _stories.length) return;
    Duration d = Duration();
    for (int i = 0; i < storyIndex; i++) {
      d = d + _stories[i].getDuration();
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
      if (_currentStoryIndex < _stories.length) {
        _stories[_currentStoryIndex].pause();
      }
    } else {
      // resume
      _audioPlayer.play();
      if (_currentStoryIndex < _stories.length) {
        _stories[_currentStoryIndex].resume();
      }
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
          if (_currentStoryIndex < _stories.length)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: _stories[_currentStoryIndex],
              ),
            ),
          if (_currentStoryIndex == _stories.length)
            SafeArea(
              child: ReviewFinalExportPage(data: _reviewData),
            ),
          SafeArea(
            child: ReviewPageOverlay(
              storyDurations: _stories.map((s) => s.getDuration()).toList(),
              onChangePause: onPause,
              onChangeMusic: onMusic,
              onChangeStory: (int storyIndex) {
                setState(() {
                  _currentStoryIndex = storyIndex;
                });
                _seekAudioToStory(storyIndex);
                if (_currentStoryIndex < _stories.length) {
                  _stories[_currentStoryIndex].restart();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
