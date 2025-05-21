import 'package:abitur/utils/constants.dart';
import 'package:flutter/material.dart';

import '../storage/entities/evaluation_date.dart';
import 'badge.dart';

class GraduationDateListTile extends StatelessWidget {

  final EvaluationDate evaluationDate;
  final bool showDate;
  final GestureTapCallback? onTap;

  const GraduationDateListTile({super.key, required this.evaluationDate, this.showDate = true, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: showDate ? Text(evaluationDate.date?.format() ?? "Kein Datum") : null,
        subtitle: Text("${evaluationDate.weight}x Gewichtung"),
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