import 'package:abitur/utils/extensions/date_extension.dart';
import 'package:abitur/widgets/shimmer.dart';
import 'package:flutter/material.dart';

import '../sqlite/entities/evaluation/evaluation.dart';
import '../sqlite/entities/evaluation/evaluation_date.dart';
import '../sqlite/entities/subject.dart';
import 'badge.dart';

class EvaluationDateListTile extends StatelessWidget {

  final EvaluationDate evaluationDate;
  final Evaluation? evaluation;
  final Subject? subject;
  final bool showDate;
  final GestureTapCallback? onTap;

  final bool shimmer;

  const EvaluationDateListTile({super.key, required this.evaluationDate, required this.evaluation, required this.subject, this.showDate = true, this.onTap}):
        shimmer = false;
  EvaluationDateListTile.shimmer({this.showDate = true, super.key}):
        evaluationDate = EvaluationDate.empty(),
        evaluation = null,
        subject = null,
        shimmer = true,
        onTap = null;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: shimmer || evaluation == null ? Shimmer(height: 20, width: 50) : Text(evaluation!.name),
      subtitle: showDate ? ( shimmer ? Shimmer(height: 15, width: 40) : Text(evaluationDate.date?.format() ?? "Kein Datum")): null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (shimmer || subject == null)
            Shimmer(width: 47, height: 30,),
          if (!shimmer)
            SubjectBadge(subject: subject!),
        ],
      ),
      leading: AspectRatio(
        aspectRatio: 1,
        child: Center(
          child: shimmer ?
          Shimmer(width: 47, height: 30,) :
          Text(
            evaluationDate.note?.toString() ?? "-",
            style: TextStyle(fontSize: 20,),
          ),
        ),
      ),
      onTap: onTap
    );
  }
}