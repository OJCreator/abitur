import 'package:abitur/pages/review/stories/story.dart';
import 'package:abitur/pages/review/story_widgets/story_number_view.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:flutter/material.dart';

import '../../../storage/entities/subject.dart';
import '../../../storage/services/evaluation_date_service.dart';
import '../../../storage/services/subject_service.dart';
import '../story_widgets/story_graph_view.dart';

class AverageStory extends StatelessWidget implements Story {

  final List<Subject> subjects = SubjectService.findAll();

  late final List<double> dayAverages = List.generate(5, (_) => 0);
  late final List<double?> monthAverages = List.generate(24, (_) => null);

  final GlobalKey<StoryNumberViewState> key1 = GlobalKey();
  final GlobalKey<StoryGraphViewState> key2 = GlobalKey();
  final GlobalKey<StoryGraphViewState> key3 = GlobalKey();

  AverageStory({super.key});

  @override
  Duration getDuration() {
    return Duration(seconds: 24);
  }

  @override
  void pause() {
    key1.currentState?.pause();
    key2.currentState?.pause();
    key3.currentState?.pause();
  }

  @override
  void resume() {
    key1.currentState?.resume();
    key2.currentState?.resume();
    key3.currentState?.resume();
  }

  @override
  void restart() {
    key1.currentState?.restart();
    key2.currentState?.restart();
    key3.currentState?.restart();
  }

  int _getMonthIndex(int identifier, DateTime startMonth) {
    final idYear = identifier ~/ 1000;
    final idMonth = identifier % 1000;

    final startYear = startMonth.year % 100;
    final startMonthValue = startMonth.month;

    return (idYear - startYear) * 12 + (idMonth - startMonthValue);
  }

  @override
  Widget build(BuildContext context) {

    final evaluationDates = EvaluationDateService.findAll();
    final groupedEvaluationDatesByDay = evaluationDates.where((e) => e.date != null).toList().groupBy((e) => e.date!.weekday);
    groupedEvaluationDatesByDay.forEach((day, evaluationDates) {
      final notes = evaluationDates.map((e) => e.note).where((note) => note != null);
      if (notes.isEmpty) {
        dayAverages[day-1] = 0.0;
      } else {
        final sum = notes.fold<double>(0.0, (total, note) => total + note!);
        dayAverages[day-1] = sum / notes.length;
      }
    });
    final groupedEvaluationDatesByMonth = evaluationDates.where((e) => e.date != null && e.note != null).toList().groupBy((e) => (e.date!.year % 100) * 1000 + e.date!.month); // yyMM
    final startMonth = SettingsService.firstDayOfSchool;
    groupedEvaluationDatesByMonth.forEach((identifier, evaluationDates) {
      final notes = evaluationDates.map((e) => e.note).where((note) => note != null);

      final index = _getMonthIndex(identifier, startMonth);
      if (index < 0 || index >= monthAverages.length) return; // ignorieren, falls außerhalb der 24 Monate

      if (notes.isEmpty) {
        monthAverages[index] = 0.0;
      } else {
        final sum = notes.fold<double>(0.0, (total, note) => total + note!);
        monthAverages[index] = sum / notes.length;
      }
    });

    String bestDay;
    switch (dayAverages.indexOfMax()) {
      case 0: bestDay = "Montags";
      case 1: bestDay = "Dienstags";
      case 2: bestDay = "Mittwochs";
      case 3: bestDay = "Donnerstags";
      default: bestDay = "Freitags";
    }


    return Stack(
      children: [
        StoryNumberView(
          key: key1,
          number: 12345,
          title: "Tage in die Schule gegangen",
          subtitle: "Klar, dass da mancher besser war als der andere...",
          delay: Duration(seconds: 0),
        ),
        StoryGraphView(
          key: key2,
          title: "$bestDay hast du am besten performed",
          delay: Duration(seconds: 8),
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
        StoryGraphView(
          key: key3,
          title: "Und über die ganze Zeit:",
          delay: Duration(seconds: 16),
          data: monthAverages,
          xAxisTitle: null,
          yAxisTitle: "Durchschnitt",
          xValues: (index) {
            if (index % 2 != 0) return "";
            final monthNumber = (startMonth.month - 1 + index) % 12 + 1;
            return monthNumber.monthShort();
          }
        ),
      ],
    );
  }
}