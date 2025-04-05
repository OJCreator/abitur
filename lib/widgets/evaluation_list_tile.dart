import 'package:abitur/storage/entities/evaluation.dart';
import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:flutter/material.dart';

class EvaluationListTile extends StatelessWidget {

  final Evaluation evaluation;
  final GestureTapCallback? onTap;

  const EvaluationListTile({super.key, required this.evaluation, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(evaluation.name),
      subtitle: Text(timeString()),
      trailing: AspectRatio(
        aspectRatio: 1,
        child: Center(
          child: Text(
            EvaluationService.calculateNote(evaluation)?.toString() ?? "-",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  String timeString() {
    String firstDate = evaluation.evaluationDates.first.date!.format();
    String lastDate = evaluation.evaluationDates.last.date!.format();
    if (firstDate == lastDate) {
      return firstDate;
    }
    return "$firstDate - $lastDate";
  }
}
