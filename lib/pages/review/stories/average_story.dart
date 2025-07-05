import 'package:abitur/pages/review/story_widgets/story_number_view.dart';
import 'package:abitur/utils/constants.dart';
import 'package:flutter/material.dart';

import '../../../storage/entities/subject.dart';
import '../../../storage/services/evaluation_date_service.dart';
import '../../../storage/services/subject_service.dart';
import '../story_widgets/story_graph_view.dart';

class AverageStory extends StatelessWidget {

  final List<Subject> subjects = SubjectService.findAll();

  late final List<double> dayAverages = List.generate(5, (_) => 0);

  AverageStory({super.key});

  @override
  Widget build(BuildContext context) {

    final evaluationDates = EvaluationDateService.findAll();
    final groupedEvaluationDates = evaluationDates.where((e) => e.date != null).toList().groupBy((e) => e.date!.weekday);

    groupedEvaluationDates.forEach((day, evaluationDates) {
      final notes = evaluationDates.map((e) => e.note).where((note) => note != null);
      if (notes.isEmpty) {
        dayAverages[day-1] = 0.0;
      } else {
        final sum = notes.fold<double>(0.0, (total, note) => total + note!);
        dayAverages[day-1] = sum / notes.length;
      }
    });


    return Stack(
      children: [
        StoryNumberView(
          number: 12345,
          title: "Tage in die Schule gegangen",
          subtitle: "Klar, dass da mancher besser war als der andere...",
          delay: Duration(seconds: 0),
        ),
        StoryGraphView(
          title: "Deine Durchschnittsleistung im Laufe einer Woche",
          delay: Duration(seconds: 7),
          data: dayAverages,
          xAxisTitle: null,
          yAxisTitle: "Durchschnitt",
          xValues: (index) {
            switch (index) {
              case 0: return "Mo";
              case 1: return "Di";
              case 2: return "Mi";
              case 3: return "Do";
              default: return "Fr";
            }
          }
        ),
      ],
    );
  }
}
