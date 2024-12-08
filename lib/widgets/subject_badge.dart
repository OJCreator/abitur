import 'package:flutter/cupertino.dart';

import '../storage/entities/subject.dart';
import '../utils/constants.dart';

class SubjectBadge extends StatelessWidget {

  final Subject subject;

  const SubjectBadge({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      height: 30,
      width: 47,
      decoration: BoxDecoration(
        color: subject.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          subject.shortName,
          style: TextStyle(
            color: getContrastingTextColor(subject.color),
          ),
        ),
      ),
    );
  }
}
