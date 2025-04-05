import 'package:abitur/utils/constants.dart';
import 'package:flutter/material.dart';

import '../storage/entities/evaluation_date.dart';
import 'badge.dart';

class EvaluationDateListTile extends StatelessWidget {

  final EvaluationDate evaluationDate;
  final bool showDate;
  final GestureTapCallback? onTap;

  const EvaluationDateListTile({super.key, required this.evaluationDate, this.showDate = true, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(evaluationDate.evaluation.name),
      subtitle: showDate ? Text(evaluationDate.date?.format() ?? "Kein Datum") : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SubjectBadge(subject: evaluationDate.evaluation.subject),
        ],
      ),
      leading: AspectRatio(
        aspectRatio: 1,
        child: Center(
          child: Text(
            evaluationDate.note?.toString() ?? "-",
            style: TextStyle(fontSize: 20,),
          ),
        ),
      ),
      onTap: onTap
    );
  }
}