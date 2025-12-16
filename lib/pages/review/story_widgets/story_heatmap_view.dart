import 'package:abitur/utils/extensions/color_extension.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../delayed_animation_controller.dart';

class StoryHeatmapView extends StatefulWidget {
  final String title;
  final Map<DateTime, int> evaluationsPerDay;
  final Duration delay;

  const StoryHeatmapView({
    super.key,
    required this.title,
    required this.evaluationsPerDay,
    this.delay = const Duration(seconds: 0),
  });

  @override
  State<StoryHeatmapView> createState() => StoryHeatmapViewState();
}

class StoryHeatmapViewState extends State<StoryHeatmapView> with TickerProviderStateMixin {

  late DelayedAnimationController<Offset> _slideInController;
  late DelayedAnimationController<double> _offsetController;
  late DelayedAnimationController<double> _graphOpacityController;
  late DelayedAnimationController<Offset> _slideOutController;

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

    _graphOpacityController = DelayedAnimationController(
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
      delay: widget.delay + Duration(seconds: 7),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );

    startAnimation();
  }


  Future<void> startAnimation() async {
    _slideInController.start();
    _offsetController.start();
    _graphOpacityController.start();
    _slideOutController.start();
  }

  Future<void> pause() async {
    _slideInController.pause();
    _offsetController.pause();
    _graphOpacityController.pause();
    _slideOutController.pause();
  }
  Future<void> resume() async {
    _slideInController.resume();
    _offsetController.resume();
    _graphOpacityController.resume();
    _slideOutController.resume();
  }
  Future<void> restart() async {
    _slideInController.restart();
    _offsetController.restart();
    _graphOpacityController.restart();
    _slideOutController.restart();
  }

  @override
  void dispose() {
    _slideInController.dispose();
    _offsetController.dispose();
    _graphOpacityController.dispose();
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
              final maxOffset = MediaQuery.of(context).size.width / 3 * 2;
              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(0, _offsetController.animation.value * maxOffset),
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _graphOpacityController.animation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _graphOpacityController.animation.value,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _StoryHeatmap(
                            evaluationsPerDay: widget.evaluationsPerDay,
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

class _StoryHeatmap extends StatelessWidget {

  final Map<DateTime, int> evaluationsPerDay;

  const _StoryHeatmap({
    super.key,
    required this.evaluationsPerDay,
  });

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme.surface.generatePalette(4).reversed.toList();

    // TODO hier der erste Schultag!
    final dayOne = evaluationsPerDay.keys.sorted((a,b) => a.compareTo(b)).first;

    return GridView.builder(
      itemCount: 356*2,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 30, mainAxisSpacing: 2, crossAxisSpacing: 2, childAspectRatio: 1),
      padding: const EdgeInsets.all(2),
      itemBuilder: (context, index) {
        int amount = evaluationsPerDay[dayOne.add(Duration(days: index))] ?? 0;
        if (amount > 3) amount = 3;
        return Container(
          color: colors[amount],
        );
      },
    );
  }
}
