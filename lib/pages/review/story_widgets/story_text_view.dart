import 'package:abitur/pages/review/delayed_animation_controller.dart';
import 'package:flutter/material.dart';

class StoryTextView extends StatefulWidget {
  final String title;
  final String subtitle;
  final Duration delay;

  const StoryTextView({
    super.key,
    required this.title,
    required this.subtitle,
    this.delay = const Duration(seconds: 0),
  });

  @override
  State<StoryTextView> createState() => StoryTextViewState();
}

class StoryTextViewState extends State<StoryTextView> with TickerProviderStateMixin {
  late DelayedAnimationController<Offset> _slideInController;
  late DelayedAnimationController<double> _offsetController;
  late DelayedAnimationController<double> _subtitleOpacityController;
  late DelayedAnimationController<Offset> _slideOutController;

  @override
  void initState() {
    super.initState();

    _slideInController = DelayedAnimationController<Offset>(
      vsync: this,
      begin: Offset(1.5, 0.0),
      end: Offset.zero,
      delay: widget.delay,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );

    _offsetController = DelayedAnimationController<double>(
      vsync: this,
      begin: 0,
      end: -10,
      delay: widget.delay + Duration(seconds: 2),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    _subtitleOpacityController = DelayedAnimationController(
      vsync: this,
      begin: 0,
      end: 1,
      delay: widget.delay + Duration(seconds: 2),
      duration: Duration(milliseconds: 150),
      curve: Curves.easeOut,
    );

    _slideOutController = DelayedAnimationController(
      vsync: this,
      begin: Offset.zero,
      end: Offset(-1.5, 0.0),
      delay: widget.delay + Duration(seconds: 5),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
    startAnimation();
  }

  Future<void> startAnimation() async {
    _slideInController.start();
    _offsetController.start();
    _subtitleOpacityController.start();
    _slideOutController.start();
  }

  void pause() async {
    _slideInController.pause();
    _offsetController.pause();
    _subtitleOpacityController.pause();
    _slideOutController.pause();
  }
  void resume() async {
    _slideInController.resume();
    _offsetController.resume();
    _subtitleOpacityController.resume();
    _slideOutController.resume();
  }
  void restart() async {
    _slideInController.restart();
    _offsetController.restart();
    _subtitleOpacityController.restart();
    _slideOutController.restart();
  }

  @override
  void dispose() {
    _slideInController.dispose();
    _offsetController.dispose();
    _subtitleOpacityController.dispose();
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
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(0, _offsetController.animation.value),
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _subtitleOpacityController.animation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _subtitleOpacityController.animation.value,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            widget.subtitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      );
                    },
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
