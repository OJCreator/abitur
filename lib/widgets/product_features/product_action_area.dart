import 'package:flutter/cupertino.dart';

class ProductActionArea extends StatelessWidget {

  final List<Widget> children;

  const ProductActionArea({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: children,
        ),
      ),
    );
  }
}
