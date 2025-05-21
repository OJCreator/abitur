import 'package:flutter/material.dart';

import '../utils/constants.dart';

class Shimmer extends StatelessWidget {

  final double height;
  final double width;

  const Shimmer({super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: shimmerColor,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
