import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class StoryNumberView extends StatefulWidget {
  final int number;
  final String title;
  final String subtitle;
  final Duration delay;

  const StoryNumberView({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    this.delay = const Duration(seconds: 0),
  });

  @override
  State<StoryNumberView> createState() => _StoryNumberViewState();
}

class _StoryNumberViewState extends State<StoryNumberView> with TickerProviderStateMixin {

  late AnimationController _offsetController;
  late Animation<double> _offsetAnimation;

  late AnimationController _slideOutController;
  late Animation<Offset> _slideOutAnimation;

  bool showTitle = false;
  bool showSubtitle = false;

  @override
  void initState() {
    super.initState();

    _offsetController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _offsetAnimation = Tween<double>(
      begin: 0,
      end: -10,
    ).animate(CurvedAnimation(
      parent: _offsetController,
      curve: Curves.easeOut,
    ));

    _slideOutController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-1.5, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideOutController,
      curve: Curves.easeIn,
    ));

    startAnimation();
  }

  Future<void> startAnimation() async {

    await Future.delayed(widget.delay);

    await Future.delayed(Duration(seconds: 1)); // hochzählen (nur halb)
    if (!mounted) return;
    setState(() {
      showTitle = true;
    });

    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;
    _offsetController.forward();
    setState(() {
      showSubtitle = true;
    });

    await Future.delayed(Duration(seconds: 3));
    if (!mounted) return;
    await _slideOutController.forward();
  }

  @override
  void dispose() {
    _offsetController.dispose();
    _slideOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Center(
      child: SlideTransition(
        position: _slideOutAnimation,
        child: AnimatedBuilder(
          animation: _offsetController,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, _offsetAnimation.value),
                  child: Column(
                    children: [
                      VibratingAnimatedNumber(
                        targetNumber: widget.number,
                        delay: widget.delay,
                      ),
                      AnimatedOpacity(
                        opacity: showTitle ? 1 : 0,
                        duration: Duration(milliseconds: 500),
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  opacity: showSubtitle ? 1 : 0,
                  duration: Duration(milliseconds: 500),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class VibratingAnimatedNumber extends StatefulWidget {
  final int targetNumber;
  final Duration delay;

  const VibratingAnimatedNumber({required this.targetNumber, super.key, required this.delay});

  @override
  State<VibratingAnimatedNumber> createState() => _VibratingAnimatedNumberState();
}

class _VibratingAnimatedNumberState extends State<VibratingAnimatedNumber> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  int? _currentValue;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }
  Future<void> _startAnimation() async {
    await Future.delayed(widget.delay);

    double startValue = widget.targetNumber * 0.7;
    if (widget.targetNumber > 100) {
      startValue = widget.targetNumber - 30;
    }
    if (widget.targetNumber < 23) {
      startValue = widget.targetNumber - 7;
    }
    if (widget.targetNumber < 7) {
      startValue = 0;
    }

    setState(() {
      _currentValue = startValue.toInt();
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _animation = Tween<double>(begin: startValue, end: widget.targetNumber.toDouble()).animate(curve)
      ..addListener(() {
        int newValue = _animation.value.toInt();
        if (newValue != _currentValue) {
          _currentValue = newValue;
          // Vibrieren bei jedem Wertwechsel ganz leicht
          _vibrateLight();

          setState(() {}); // Update Text
        }
      });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Am Ende stärkere Vibration
        _vibrateStrong();
      }
    });

    _controller.forward();
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _currentValue == null ? Container() : Text(
      _currentValue.toString(),
      style: Theme.of(context).textTheme.displayLarge,
    );
  }
}