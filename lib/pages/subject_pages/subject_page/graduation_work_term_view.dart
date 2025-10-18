
import 'package:flutter/material.dart';

import '../../../services/database/graduation_evaluation_service.dart';
import '../../../sqlite/entities/graduation_evaluation.dart';
import '../../../sqlite/entities/subject.dart';
import '../../../widgets/forms/date_input.dart';
import '../../../widgets/forms/form_gap.dart';
import '../../../widgets/graduation_date_list_tile.dart';
import '../../../widgets/percent_indicator.dart';

class GraduationWorkTermView extends StatefulWidget {

  final Subject subject;
  final GraduationEvaluation graduationEvaluation;

  const GraduationWorkTermView({super.key, required this.subject, required this.graduationEvaluation});

  @override
  State<GraduationWorkTermView> createState() => _GraduationWorkTermViewState();
}

class _GraduationWorkTermViewState extends State<GraduationWorkTermView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center( // TODO Wichtig: sh. Tabelle https://km.baden-wuerttemberg.de/fileadmin/redaktion/m-km/intern/PDF/Publikationen/Gymnasium/2025_Leitfaden_fuer_die_gymnasiale_Oberstufe_Abitur_2027.pdf Seite 14, nicht erst runden und dann mal 4, sondern erst mal 4 und dann runden!
                  child: PercentIndicator(
                    value: GraduationEvaluationService.calculateNote(widget.graduationEvaluation)?.toDouble(),
                    color: widget.subject.color,
                    title: widget.graduationEvaluation.graduationEvaluationType.name,
                  ),
                ),
              ),
              FormGap(),
              if (!widget.graduationEvaluation.isDividedEvaluation)
                DateInput(
                  dateTime: widget.graduationEvaluation.datePartOne,
                ),
              if (widget.graduationEvaluation.isDividedEvaluation)
                ...[
                  GraduationDateListTile(
                    date: widget.graduationEvaluation.datePartOne,
                    weight: widget.graduationEvaluation.weightPartOne,
                    note: widget.graduationEvaluation.notePartOne,
                  ),
                  GraduationDateListTile(
                    date: widget.graduationEvaluation.datePartTwo,
                    weight: widget.graduationEvaluation.weightPartTwo,
                    note: widget.graduationEvaluation.notePartTwo,
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}