import 'dart:async';

class PausableTimer {
  final Duration originalDuration;
  final void Function() onDone;

  Timer? _timer;
  DateTime? _startTime;
  Duration? _remaining;

  bool get isRunning => _timer?.isActive ?? false;

  PausableTimer(this.originalDuration, this.onDone) {
    _remaining = originalDuration;
    _start();
  }

  void _start() {
    _startTime = DateTime.now();
    _timer = Timer(_remaining!, () => onDone());
  }

  void pause() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
      final passed = DateTime.now().difference(_startTime!);
      _remaining = _remaining! - passed;
    }
  }

  void resume() {
    if (_remaining!.inMilliseconds > 0) {
      _start();
    }
  }

  void cancel() {
    _timer?.cancel();
  }
}
