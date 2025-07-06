import 'dart:async';
import 'package:flutter/animation.dart';

class DelayedAnimationController<T> {

  final Duration delay;
  final Duration duration;
  final T begin;
  final T end;
  final Curve curve;
  final TickerProvider vsync;

  late AnimationController animationController;
  late Animation<T> animation;

  Timer? _delayTimer;
  bool _isPaused = false;
  bool _isStarted = false;
  bool _isDisposed = false;

  DateTime? _delayStartTime;
  Duration _elapsedDelay = Duration.zero;

  DelayedAnimationController({
    required this.vsync,
    required this.begin,
    required this.end,
    this.delay = Duration.zero,
    this.duration = const Duration(seconds: 1),
    this.curve = Curves.easeIn,
  });

  void start() {
    if (_isStarted || _isDisposed) return;


    animationController = AnimationController(
      vsync: vsync,
      duration: duration,
    );
    animation = Tween<T>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: curve
    ));

    _isStarted = true;
    _isPaused = false;
    _elapsedDelay = Duration.zero;
    _startDelayTimer(delay);
  }

  void _startDelayTimer(Duration duration) {
    if (_isDisposed) return;
    _delayStartTime = DateTime.now();
    _delayTimer = Timer(duration, () {
      _delayTimer = null;
      _elapsedDelay += delay;
      animationController.forward();
    });
  }

  void pause() {
    if (_isPaused || _isDisposed) return;
    _isPaused = true;

    if (_delayTimer != null) {
      // Timer stoppen und schon vergangene Zeit speichern
      _delayTimer!.cancel();
      _delayTimer = null;
      final now = DateTime.now();
      _elapsedDelay += now.difference(_delayStartTime!);
    }

    if (animationController.isAnimating) {
      animationController.stop();
    }
  }

  void resume() {
    if (!_isStarted || !_isPaused || _isDisposed) return;
    _isPaused = false;

    if (animationController.isAnimating) {
      return;
    }

    final remainingDelay = delay - _elapsedDelay;

    if (remainingDelay <= Duration.zero) {
      animationController.forward();
    } else {
      _startDelayTimer(remainingDelay);
    }
  }

  void dispose() {
    _isDisposed = true;
    _delayTimer?.cancel();
    animationController.dispose();
  }
}
