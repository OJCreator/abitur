import 'dart:math';

import 'package:abitur/utils/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../delayed_animation_controller.dart';

class StoryPieChartView extends StatefulWidget {
  final String title;
  final Duration delay;
  final Map<String, int> data;
  final String? xAxisTitle;
  final String yAxisTitle;
  final String Function(int index)? xValues;

  const StoryPieChartView({
    super.key,
    required this.title,
    this.delay = const Duration(seconds: 0),
    required this.data,
    required this.xAxisTitle,
    required this.yAxisTitle,
    this.xValues,
  });

  @override
  State<StoryPieChartView> createState() => StoryPieChartViewState();
}

class StoryPieChartViewState extends State<StoryPieChartView> with TickerProviderStateMixin {

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
                          child: _StoryGraphViewPieChart(
                            widget.data,
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

class _StoryGraphViewPieChart extends StatelessWidget {

  final Map<String, int> data;

  const _StoryGraphViewPieChart(this.data,);

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme.surface.generatePalette(min(data.keys.length, 8));

    final sortedDataKeys = data.keys.toList();
    sortedDataKeys.sort((a,b) => data[b]?.compareTo(data[a]!) ?? 0);

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: PieChart(
          PieChartData(

            borderData: FlBorderData(
              show: false,
            ),
            sectionsSpace: 0,
            pieTouchData: PieTouchData(enabled: false),

              sections: List.generate(data.length, (index) {
                final key = sortedDataKeys.elementAt(index);
                final value = data[key]!;
                return PieChartSectionData(
                  radius: 150,
                  value: value.toDouble(),
                  color: colors[index % colors.length],
                  title: '$key (${value.toInt()})',
                  titleStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: getContrastingTextColor(colors[index % colors.length]),
                  ),
                );
              }
              ),
          ),
        ),
      ),
    );
  }
}