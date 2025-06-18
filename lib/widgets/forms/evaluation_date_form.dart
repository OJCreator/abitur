import 'package:abitur/widgets/forms/form_gap.dart';
import 'package:flutter/material.dart';

import '../../storage/entities/evaluation_date.dart';
import 'date_input.dart';

class EvaluationDateForm extends StatefulWidget {
  final String? evaluationId;
  final List<EvaluationDate> evaluationDates;
  final Function(List<EvaluationDate>) onChanged;

  const EvaluationDateForm({
    super.key,
    this.evaluationId,
    required this.evaluationDates,
    required this.onChanged,
  });

  @override
  State<EvaluationDateForm> createState() => _EvaluationDateFormState();
}

class _EvaluationDateFormState extends State<EvaluationDateForm> {

  @override
  void initState() {
    super.initState();
  }

  void _addEvaluationDate() {
    setState(() {
      final newEvaluationDate = EvaluationDate(date: DateTime.now(), evaluationId: widget.evaluationId ?? "");
      widget.evaluationDates.add(newEvaluationDate);
    });
    notifyChange();
  }

  void notifyChange() {
    widget.onChanged(widget.evaluationDates);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < widget.evaluationDates.length; i++)
          _EvaluationDateFormCard(
            date: widget.evaluationDates[i].date!,
            showWeight: widget.evaluationDates.length > 1,
            weight: widget.evaluationDates[i].weight,
            note: widget.evaluationDates[i].note,
            description: widget.evaluationDates[i].description,
            remove: () {
              if (widget.evaluationDates.length == 1) {
                return;
              }
              setState(() {
                widget.evaluationDates.removeAt(i);
              });
              notifyChange();
            },
            onChanged: (date, weight, note, description) {
              setState(() {
                widget.evaluationDates[i].date = date;
                widget.evaluationDates[i].weight = weight;
                widget.evaluationDates[i].note = note;
                widget.evaluationDates[i].description = description;
              });
              notifyChange();
            },
          ),
        FilledButton(
          onPressed: _addEvaluationDate,
          child: const Text("Weiteres Prüfungsdatum"),
        ),
      ],
    );
  }
}

class _EvaluationDateFormCard extends StatefulWidget {

  final DateTime date;
  final bool showWeight;
  final int weight;
  final int? note;
  final String description;
  final VoidCallback remove;
  final Function(DateTime date, int weight, int? note, String description) onChanged;

  const _EvaluationDateFormCard({required this.date, required this.showWeight, required this.weight, required this.note, required this.description, required this.onChanged, required this.remove,});

  @override
  State<_EvaluationDateFormCard> createState() => _EvaluationDateFormCardState();
}

class _EvaluationDateFormCardState extends State<_EvaluationDateFormCard> {

  late final TextEditingController _descriptionController;

  @override
  void initState() {
    _descriptionController = TextEditingController(text: widget.description);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: DateInput(
                    dateTime: widget.date,
                    onSelected: (newDate) {
                      widget.onChanged(newDate, widget.weight, widget.note, widget.description);
                    },
                  ),
                ),
                IconButton(
                  onPressed: widget.remove,
                  icon: Icon(Icons.remove_circle),
                ),
              ],
            ),

            if (widget.showWeight) ...[
              ListTile(
                title: Text("Gewichtung"),
              ),
              Slider(
                value: widget.weight.toDouble(),
                min: 0,
                max: 6,
                divisions: 6,
                label: "${widget.weight}",
                onChanged: (newWeight) {
                  widget.onChanged(widget.date, newWeight.round(), widget.note, widget.description);
                },
                year2023: false,
              ),
            ],

            SwitchListTile(
              title: Text("Note eintragen"),
              value: widget.note != null,
              onChanged: (newValue) {
                if (widget.note == null) {
                  widget.onChanged(widget.date, widget.weight, 8, widget.description);
                } else {
                  widget.onChanged(widget.date, widget.weight, null, widget.description);
                }
              },
            ),

            Slider(
              min: 0,
              max: 15,
              divisions: 15,
              value: widget.note?.toDouble() ?? 8,
              label: "${widget.note}",
              onChanged: widget.note != null ? (newNote) {
                widget.onChanged(widget.date, widget.weight, newNote.round(), widget.description);
              } : null,
              year2023: false,
            ),

            FormGap(),

            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: "Notizen",
                border: OutlineInputBorder(),
              ),
              onChanged: (newDescription) {
                widget.onChanged(widget.date, widget.weight, widget.note, newDescription);
              },
            ),
          ],
        ),
      ),
    );
  }
}
