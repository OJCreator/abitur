import 'package:flutter/material.dart';

import '../../sqlite/entities/subject.dart';
import '../../utils/constants.dart';
import '../badge.dart';
import '../shimmer.dart';

class SubjectListTile extends StatelessWidget {

  final Subject subject;
  final bool isGraduationSubject;
  final GestureTapCallback? onTap;

  final bool shimmer;

  const SubjectListTile({super.key, required this.subject, required this.isGraduationSubject, this.onTap}) :
        shimmer = false;
  SubjectListTile.shimmer({super.key}) :
        shimmer = true,
        isGraduationSubject = false,
        subject = Subject.empty(),
        onTap = null;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: shimmer ? Shimmer(height: 20, width: 50) : Text(subject.name),
      subtitle: shimmer ? Shimmer(height: 15, width: 40) : Text(subject.subjectType.canBeLeistungsfach ? subject.subjectNiveau.name : subject.subjectType.displayName),
      onTap: onTap,
      leading: Container(
        margin: const EdgeInsets.only(left: 10),
        width: 8,
        decoration: BoxDecoration(
          color: shimmer ? shimmerColor : subject.color,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isGraduationSubject)
            GraduationBadge(),
        ],
      ),
    );
  }
}
