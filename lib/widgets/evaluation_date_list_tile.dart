import 'package:abitur/utils/extensions/date_extension.dart';
import 'package:abitur/widgets/shimmer.dart';
import 'package:flutter/material.dart';

import '../storage/entities/evaluation_date.dart';
import 'badge.dart';

class EvaluationDateListTile extends StatelessWidget {

  final EvaluationDate evaluationDate;
  final bool showDate;
  final GestureTapCallback? onTap;

  final bool shimmer;

  const EvaluationDateListTile({super.key, required this.evaluationDate, this.showDate = true, this.onTap}):
        shimmer = false;
  EvaluationDateListTile.shimmer({this.showDate = true, super.key}):
        shimmer = true,
        onTap = null,
        evaluationDate = EvaluationDate.empty();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: shimmer ? Shimmer(height: 20, width: 50) : Text(evaluationDate.evaluation.name),
      subtitle: showDate ? ( shimmer ? Shimmer(height: 15, width: 40) : Text(evaluationDate.date?.format() ?? "Kein Datum")): null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (shimmer)
            Shimmer(width: 47, height: 30,),
          if (!shimmer)
            SubjectBadge(subject: evaluationDate.evaluation.subject),
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