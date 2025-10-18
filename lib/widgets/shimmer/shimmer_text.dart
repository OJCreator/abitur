import 'package:flutter/material.dart';

import '../shimmer.dart';

class ShimmerText extends StatelessWidget {
  const ShimmerText({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      height: 40,
      width: 100,
    );
  }
}
