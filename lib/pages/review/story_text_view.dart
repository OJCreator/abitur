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
  State<StoryTextView> createState() => _StoryTextViewState();
}

class _StoryTextViewState extends State<StoryTextView> with TickerProviderStateMixin {
  late AnimationController _slideInController;
  late Animation<Offset> _slideInAnimation;

  late AnimationController _offsetController;
  late Animation<double> _offsetAnimation;

  late AnimationController _slideOutController;
  late Animation<Offset> _slideOutAnimation;

  bool showSubtitle = false;

  @override
  void initState() {
    super.initState();

    _slideInController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _slideInAnimation = Tween<Offset>(
      begin: Offset(1.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideInController,
      curve: Curves.easeOut,
    ));

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
    if (!mounted) return;
    await _slideInController.forward();

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
    _slideInController.dispose();
    _offsetController.dispose();
    _slideOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SlideTransition(
        position: _slideOutAnimation,
        child: SlideTransition(
          position: _slideInAnimation,
          child: AnimatedBuilder(
            animation: _offsetController,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(0, _offsetAnimation.value),
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
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
      ),
    );
  }
}
