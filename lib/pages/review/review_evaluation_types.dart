import 'package:abitur/storage/entities/evaluation_type.dart';
import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:flutter/material.dart';

import '../../widgets/review/animated_figure.dart';

class ReviewEvaluationTypes extends StatefulWidget {
  const ReviewEvaluationTypes({super.key});

  @override
  State<ReviewEvaluationTypes> createState() => _ReviewEvaluationTypesState();
}

class _ReviewEvaluationTypesState extends State<ReviewEvaluationTypes> {

  final Map<EvaluationType, double> evaluationTypesAverages = {};
  final Map<AssessmentType, double> assessmentTypesAverages = {};

  @override
  void initState() {

    final evaluations = EvaluationService.findAll();
    final groupedEvaluations = evaluations.groupBy((e) => e.evaluationType);
    groupedEvaluations.removeWhere((key, _) => key.name == "Kein Typ");

    groupedEvaluations.forEach((type, evaluations) {
      final notes = evaluations.map((e) => EvaluationService.calculateNote(e)).where((note) => note != null);
      if (notes.isEmpty) {
        evaluationTypesAverages[type] = 0.0;
      } else {
        final sum = notes.fold<double>(0.0, (total, note) => total + note!);
        evaluationTypesAverages[type] = sum / notes.length;
      }
    });

    final groupedEvaluations2 = evaluations.groupBy((e) => e.evaluationType.assessmentType);
    groupedEvaluations2.removeWhere((key, _) => key.name == "Kein Typ");

    groupedEvaluations2.forEach((type, evaluations) {
      final notes = evaluations.map((e) => EvaluationService.calculateNote(e)).where((note) => note != null);
      if (notes.isEmpty) {
        assessmentTypesAverages[type] = 0.0;
      } else {
        final sum = notes.fold<double>(0.0, (total, note) => total + note!);
        assessmentTypesAverages[type] = sum / notes.length;
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (final avg in evaluationTypesAverages.entries)
            AnimatedStat(targetNumber: avg.value, description: avg.key.name, fractionDigits: 2,),
          Divider(),
          for (final avg in assessmentTypesAverages.entries)
            AnimatedStat(targetNumber: avg.value, description: avg.key.name, fractionDigits: 2,),
        ],
      ),
    );
  }
}
