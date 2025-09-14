import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../delayed_animation_controller.dart';

class StoryNumberView extends StatefulWidget {
  final int number;
  final int decimalPlaces;
  final bool countBackwards;
  final String title;
  final String subtitle;
  final Duration delay;

  const StoryNumberView({
    super.key,
    required this.number,
    this.decimalPlaces = 0,
    this.countBackwards = false,
    required this.title,
    required this.subtitle,
    this.delay = const Duration(seconds: 0),
  });

  @override
  State<StoryNumberView> createState() => StoryNumberViewState();
}

class StoryNumberViewState extends State<StoryNumberView> with TickerProviderStateMixin {
  late DelayedAnimationController<double> _numberController;
  late DelayedAnimationController<double> _titleOpacityController;
  late DelayedAnimationController<double> _offsetController;
  late DelayedAnimationController<double> _subtitleOpacityController;
  late DelayedAnimationController<Offset> _slideOutController;

  int? _currentValue;

  @override
  void initState() {
    super.initState();

    double startValue;
    if (!widget.countBackwards && widget.number > 1) {
      startValue = widget.number * 0.7;
      if (widget.number > 100) {
        startValue = widget.number - 30;
      }
      if (widget.number < 23) {
        startValue = widget.number - 7;
      }
      if (widget.number < 7) {
        startValue = 0;
      }
    } else {
      startValue = widget.number * 1.3;
      if (widget.number < 40) {
        startValue = widget.number * 1.7;
      }
      if (widget.number < 8) {
        startValue = widget.number + 7;
      }
    }

    startValue = startValue.roundToDouble();

    _numberController = DelayedAnimationController(
      vsync: this,
      begin: startValue,
      end: widget.number.toDouble(),
      delay: widget.delay,
      duration: Duration(seconds: 3),
      curve: Curves.decelerate,
    );

    _titleOpacityController = DelayedAnimationController(
      vsync: this,
      begin: 0,
      end: 1,
      delay: widget.delay + Duration(seconds: 2),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );

    _offsetController = DelayedAnimationController(
      vsync: this,
      begin: 0,
      end: -10,
      delay: widget.delay + Duration(seconds: 4),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    _subtitleOpacityController = DelayedAnimationController(
      vsync: this,
      begin: 0,
      end: 1,
      delay: widget.delay + Duration(seconds: 4),
      duration: Duration(milliseconds: 150),
      curve: Curves.easeOut,
    );

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
    _numberController.start();
    _titleOpacityController.start();
    _offsetController.start();
    _subtitleOpacityController.start();
    _slideOutController.start();
  }

  Future<void> pause() async {
    _numberController.pause();
    _titleOpacityController.pause();
    _offsetController.pause();
    _subtitleOpacityController.pause();
    _slideOutController.pause();
  }
  Future<void> resume() async {
    _numberController.resume();
    _titleOpacityController.resume();
    _offsetController.resume();
    _subtitleOpacityController.resume();
    _slideOutController.resume();
  }
  Future<void> restart() async {
    _numberController.restart();
    _titleOpacityController.restart();
    _offsetController.restart();
    _subtitleOpacityController.restart();
    _slideOutController.restart();
  }

  @override
  void dispose() {
    _numberController.dispose();
    _titleOpacityController.dispose();
    _offsetController.dispose();
    _subtitleOpacityController.dispose();
    _slideOutController.dispose();
    super.dispose();
  }

  Future<void> _vibrateLight() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 5); // ganz kurze, leichte Vibration
    }
  }

  Future<void> _vibrateStrong() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 100); // längere Vibration am Ende
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SlideTransition(
        position: _slideOutController.animation,
        child: AnimatedBuilder(
          animation: _offsetController.animation,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, _offsetController.animation.value),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _numberController.animation,
                        builder: (context, child) {
                          double animationValue = _numberController.animation.value;
                          int newValue = widget.countBackwards || widget.number < 2 ? animationValue.floor() : animationValue.ceil();
                          if (newValue != _currentValue) {
                            _currentValue = newValue;
                            if (newValue == widget.number) {
                              _vibrateStrong();
                            } else {
                              _vibrateLight();
                            }
                          }
                          return (_numberController.animation.isAnimating || _numberController.animation.isCompleted) ? Text(
                            insertComma(newValue, widget.decimalPlaces),
                            style: Theme.of(context).textTheme.displayLarge,
                          ) : Container();
                        },
                      ),
                      AnimatedBuilder(
                        animation: _titleOpacityController.animation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _titleOpacityController.animation.value,
                            child: Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          );
                        },
                      ),
                    ],
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
    );
  }
}

String insertComma(int number, int decimalPlaces) {
  String numStr = number.toString();
  if (decimalPlaces == 0) {
    return numStr;
  }
  if (decimalPlaces >= numStr.length) {
    // Komma vor die ganze Zahl
    return '0,${numStr.padLeft(decimalPlaces, '0')}';
  }
  String left = numStr.substring(0, numStr.length - decimalPlaces);
  String right = numStr.substring(numStr.length - decimalPlaces);
  return '$left,$right';
}