import 'package:flutter/material.dart';

import '../storage/entities/subject.dart';
import '../utils/constants.dart';

class GraduationBadge extends StatelessWidget {
  const GraduationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Badge("Abi");
  }
}

class SubjectBadge extends StatelessWidget {

  final Subject subject;

  const SubjectBadge({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Badge(
      subject.shortName,
      color: subject.color,
    );
  }
}

class Badge extends StatelessWidget {

  final Color? color;
  final String text;

  const Badge(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    Color c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(8),
      height: 30,
      width: 47,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: getContrastingTextColor(c),
          ),
        ),
      ),
    );
  }
}
