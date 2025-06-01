import 'package:abitur/storage/services/evaluation_date_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/widgets/review/animated_figure.dart';
import 'package:flutter/material.dart';

class ReviewFigures extends StatefulWidget {

  const ReviewFigures({super.key});

  @override
  State<ReviewFigures> createState() => _ReviewFiguresState();
}

class _ReviewFiguresState extends State<ReviewFigures> {

  final int subjectAmount = SubjectService.findAll().length;
  final int evaluationDateAmount = EvaluationDateService.findAll().length;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedStat(targetNumber: 12345, description: "Schultage"), // todo schultage berechnen
        AnimatedStat(targetNumber: subjectAmount, description: "Fächer"),
        AnimatedStat(targetNumber: evaluationDateAmount, description: "Noten"),
      ],
    );
  }
}
