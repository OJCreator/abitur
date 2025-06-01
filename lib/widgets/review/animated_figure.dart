import 'dart:math';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';

class AnimatedStat extends StatefulWidget {
  final num targetNumber;
  final String description;
  final Duration duration;
  final int fractionDigits;

  const AnimatedStat({
    super.key,
    required this.targetNumber,
    required this.description,
    this.duration = const Duration(seconds: 3),
    this.fractionDigits = 0,
  });

  @override
  State<AnimatedStat> createState() => _AnimatedStatState();
}

class _AnimatedStatState extends State<AnimatedStat> {

  num value = 0;

  @override
  void initState() {
    if (widget.targetNumber.isNaN || widget.targetNumber.isInfinite) {
      return;
    }
    setState(() {
      value = (widget.targetNumber - widget.targetNumber * 0.5 * Random().nextDouble()).floor();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        value = widget.targetNumber;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          AnimatedFlipCounter(
            duration: widget.duration,
            curve: Curves.easeOut,
            value: value,
            fractionDigits: widget.fractionDigits,
            textStyle: TextStyle(
              fontSize: 32,
            ),
          ),

          Text(
            widget.description,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}