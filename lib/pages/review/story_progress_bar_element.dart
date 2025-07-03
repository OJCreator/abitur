import 'package:flutter/material.dart';

class StoryProgressBarElement extends StatefulWidget {
  final int index;
  final int currentStory;
  final Duration duration;
  final Function()? onFinishedStory;

  const StoryProgressBarElement({
    super.key,
    required this.index,
    required this.currentStory,
    required this.duration,
    this.onFinishedStory,
  });

  @override
  State<StoryProgressBarElement> createState() => _StoryProgressBarElementState();
}

class _StoryProgressBarElementState extends State<StoryProgressBarElement> with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.onFinishedStory != null) {
        widget.onFinishedStory!();
      }
    });

    if (widget.index == widget.currentStory) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant StoryProgressBarElement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index == widget.currentStory && !_controller.isAnimating) {
      _controller.forward(from: 0);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color darkGrey = Colors.grey.withAlpha(200);
    Color lightGrey = Colors.grey.withAlpha(76);

    if (widget.index < widget.currentStory) {
      return Container(
        height: 4,
        decoration: BoxDecoration(
          color: darkGrey,
          borderRadius: BorderRadius.circular(3),
        ),
      );
    }

    if (widget.index > widget.currentStory) {
      return Container(
        height: 4,
        decoration: BoxDecoration(
          color: lightGrey,
          borderRadius: BorderRadius.circular(3),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _controller.value,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: darkGrey,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
