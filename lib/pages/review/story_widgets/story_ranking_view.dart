import 'package:flutter/material.dart';

import '../delayed_animation_controller.dart';

class RankingElement {
  final String title;
  final String subtitle;
  final Color color;

  RankingElement({required this.title, required this.subtitle, required this.color});
}

class StoryRankingView extends StatefulWidget {
  final String title;
  final Duration delay;
  final int startWithIndex;
  final List<RankingElement> ranking;

  const StoryRankingView({
    super.key,
    required this.title,
    required this.ranking,
    this.startWithIndex = 1,
    this.delay = const Duration(seconds: 0),
  });

  @override
  State<StoryRankingView> createState() => StoryRankingViewState();
}

class StoryRankingViewState extends State<StoryRankingView> with TickerProviderStateMixin {
  late DelayedAnimationController<Offset> _slideInController;
  late DelayedAnimationController<double> _offsetController;
  late List<DelayedAnimationController<double>> _openRankingControllers;
  late DelayedAnimationController<Offset> _slideOutController;

  bool showRanking = false;

  @override
  void initState() {
    super.initState();

    _slideInController = DelayedAnimationController(
      vsync: this,
      begin: Offset(1.5, 0.0),
      end: Offset.zero,
      delay: widget.delay,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );

    _offsetController = DelayedAnimationController(
      vsync: this,
      begin: 0,
      end: -1,
      delay: widget.delay + Duration(seconds: 2),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    _openRankingControllers = List.generate(5, (i) {
      return DelayedAnimationController(
        vsync: this,
        begin: 0,
        end: 1,
        delay: widget.delay + Duration(seconds: 2, milliseconds: 400*i),
        duration: Duration(seconds: 1),
        curve: Curves.easeOut,
      );
    });

    _slideOutController = DelayedAnimationController(
      vsync: this,
      begin: Offset.zero,
      end: Offset(-1.5, 0.0),
      delay: widget.delay + Duration(seconds: 7),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );

    startAnimation();
  }

  Future<void> startAnimation() async {
    _slideInController.start();
    _offsetController.start();
    for (final c in _openRankingControllers) {
      c.start();
    }
    _slideOutController.start();
  }
  void pause() async {
    _slideInController.pause();
    _offsetController.pause();
    for (final c in _openRankingControllers) {
      c.pause();
    }
    _slideOutController.pause();
  }
  void resume() async {
    _slideInController.resume();
    _offsetController.resume();
    for (final c in _openRankingControllers) {
      c.resume();
    }
    _slideOutController.resume();
  }
  void restart() async {
    _slideInController.restart();
    _offsetController.restart();
    for (final c in _openRankingControllers) {
      c.restart();
    }
    _slideOutController.restart();
  }

  @override
  void dispose() {
    _slideInController.dispose();
    _offsetController.dispose();
    for (final c in _openRankingControllers) {
      c.dispose();
    }
    _slideOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SlideTransition(
        position: _slideOutController.animation,
        child: SlideTransition(
          position: _slideInController.animation,
          child: AnimatedBuilder(
            animation: _offsetController.animation,
            builder: (context, child) {
              final maxTextOffset = MediaQuery.of(context).size.width / 3 * 2;

              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(0, _offsetController.animation.value * maxTextOffset),
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 36),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 5; i++)
                        AnimatedBuilder(
                          animation: _openRankingControllers[i].animation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _openRankingControllers[i].animation.value,
                              child: Transform.translate(
                                offset: Offset(0, _openRankingControllers[i].animation.value * -00),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          widget.ranking[i].color.withAlpha(204),
                                          widget.ranking[i].color.withAlpha(128),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          alignment: Alignment.center,
                                          child: Text(
                                            "${i + widget.startWithIndex}",
                                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget.ranking[i].title,
                                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  widget.ranking[i].subtitle,
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
