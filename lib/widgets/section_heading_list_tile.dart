import 'package:flutter/material.dart';

class SectionHeadingListTile extends StatelessWidget {

  final String heading;

  const SectionHeadingListTile({super.key, required this.heading});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        heading,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
