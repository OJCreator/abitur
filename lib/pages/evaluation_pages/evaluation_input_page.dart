import 'package:abitur/mappers/mappers/evaluations_mapper.dart';
import 'package:abitur/mappers/models/evaluation_input_page_model.dart';
import 'package:flutter/material.dart';

import '../../sqlite/entities/evaluation/evaluation.dart';
import 'evaluation_input_page/evaluation_input_form.dart';

class EvaluationInputPage extends StatefulWidget {

  final Evaluation? evaluation;
  final DateTime? dateTime;
  final String? subjectId;
  final int? term;

  bool get editMode => evaluation != null;

  const EvaluationInputPage({this.evaluation, this.dateTime, this.subjectId, this.term, super.key,});

  @override
  State<EvaluationInputPage> createState() => _EvaluationInputPageState();
}

class _EvaluationInputPageState extends State<EvaluationInputPage> {

  late Future<EvaluationInputPageModel> evaluationInputPageModelFuture;

  @override
  void initState() {
    super.initState();
    evaluationInputPageModelFuture = EvaluationsMapper.generateEvaluationInputModel(
      evaluation: widget.evaluation,
      dateTime: widget.dateTime,
      subjectId: widget.subjectId,
      term: widget.term,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: evaluationInputPageModelFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final model = snapshot.data!;
        return EvaluationInputForm(model: model);
      },
    );
  }
}