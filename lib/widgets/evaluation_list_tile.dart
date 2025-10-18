import 'package:abitur/utils/extensions/date_extension.dart';
import 'package:abitur/widgets/shimmer/shimmer_text.dart';
import 'package:flutter/material.dart';

import '../services/database/evaluation_service.dart';
import '../services/database/settings_service.dart';
import '../sqlite/entities/evaluation/evaluation.dart';
import '../sqlite/entities/evaluation/evaluation_date.dart';

class EvaluationListTile extends StatelessWidget {

  final Evaluation evaluation;
  final List<EvaluationDate> evaluationDates;
  final GestureTapCallback? onTap;

  const EvaluationListTile({super.key, required this.evaluation, required this.evaluationDates, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(evaluation.name),
      subtitle: FutureBuilder(
        future: timeString(),
        builder: (context, asyncSnapshot) {
          if (!asyncSnapshot.hasData || asyncSnapshot.data == null) return ShimmerText();
          return Text(asyncSnapshot.data!);
        }
      ),
      trailing: AspectRatio(
        aspectRatio: 1,
        child: Center(
          child: Text(
            EvaluationService.calculateNote(evaluation).toString(),
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  Future<String> timeString() async {
    DateTime lastDayOfSchool = await SettingsService.lastDayOfSchool();
    String firstDate = (evaluationDates.firstOrNull?.date ?? lastDayOfSchool).format();
    String lastDate = (evaluationDates.lastOrNull?.date ?? lastDayOfSchool).format();
    if (firstDate == lastDate) {
      return firstDate;
    }
    return "$firstDate - $lastDate";
  }
}
