import 'package:abitur/pages/review/review_days.dart';
import 'package:abitur/pages/review/review_evaluation_types.dart';
import 'package:abitur/pages/review/review_figures.dart';
import 'package:abitur/pages/review/review_notes.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {

  final List<Widget> stats = [
    ReviewFigures(),
    ReviewNotes(),
    ReviewEvaluationTypes(),
    ReviewDays(),
  ];
  int statIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Abitur Review"),
      ),
      body: stats[statIndex],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (statIndex >= stats.length - 1) {
            Navigator.pop(context);
            return;
          }
          setState(() {
            statIndex++;
          });
        },
        label: Text("Weiter"),
        icon: Icon(Icons.forward),
      ),
    );
  }
}
