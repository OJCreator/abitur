import 'package:flutter/material.dart';

import '../../storage/entities/evaluation_date.dart';
import '../../storage/services/settings_service.dart';
import 'date_input.dart';

class EvaluationDateForm extends StatefulWidget {
  final String evaluationId;
  final List<EvaluationDate> evaluationDates;
  final Function(List<EvaluationDate>) onChanged;

  const EvaluationDateForm({
    super.key,
    required this.evaluationId,
    required this.evaluationDates,
    required this.onChanged,
  });

  @override
  State<EvaluationDateForm> createState() => _EvaluationDateFormState();
}

class _EvaluationDateFormState extends State<EvaluationDateForm> {

  final List<bool> _giveNotes = List.empty(growable: true);

  @override
  void initState() {
    for (EvaluationDate date in widget.evaluationDates) {
      _giveNotes.add(date.note != null);
    }
    super.initState();
  }

  void _addEvaluationDate() {
    setState(() {
      final newEvaluationDate = EvaluationDate(date: DateTime.now(), evaluationId: widget.evaluationId);
      widget.evaluationDates.add(newEvaluationDate);
      _giveNotes.add(false);
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: DateInput(
                          dateTime: widget.evaluationDates[i].date,
                          firstDate: SettingsService.firstDayOfSchool,
                          lastDate: SettingsService.lastDayOfSchool,
                          onSelected: (picked) {
                            setState(() {
                              widget.evaluationDates[i].date = picked;
                              notifyChange();
                            });
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (widget.evaluationDates.length == 1) {
                            return;
                          }
                          setState(() {
                            widget.evaluationDates.removeAt(i);
                            _giveNotes.removeAt(i);
                          });
                          notifyChange();
                        },
                        icon: Icon(Icons.remove_circle),
                      ),
                    ],
                  ),

                  if (widget.evaluationDates.length > 1)
                    ListTile(
                      title: Text("Gewichtung"),
                    ),
                  if (widget.evaluationDates.length > 1)
                    Slider(
                      value: widget.evaluationDates[i].weight.toDouble(),
                      min: 0,
                      max: 6,
                      divisions: 6,
                      label: "${widget.evaluationDates[i].weight}",
                      onChanged: (value) {
                        setState(() {
                          widget.evaluationDates[i].weight = value.round();
                        });
                        notifyChange();
                      },
                      year2023: false,
                    ),


                  SwitchListTile(
                    title: Text("Note eintragen"),
                    value: _giveNotes[i],
                    onChanged: (newValue) {
                      setState(() {
                        _giveNotes[i] = !_giveNotes[i];
                        if (_giveNotes[i]) {
                          widget.evaluationDates[i].note = 8;
                        } else {
                          widget.evaluationDates[i].note = null;
                        }
                      });
                    },
                  ),

                  Slider(
                    min: 0,
                    max: 15,
                    divisions: 15,
                    value: widget.evaluationDates[i].note?.toDouble() ?? 8,
                    label: "${widget.evaluationDates[i].note}",
                    onChanged: _giveNotes[i] ? (newValue) {
                      setState(() {
                        widget.evaluationDates[i].note = newValue.toInt();
                      });
                    } : null,
                    year2023: false,
                  ),
                ],
              ),
            ),
          ),
        FilledButton(
          onPressed: _addEvaluationDate,
          child: const Text("Weiteres Prüfungsdatum"),
        ),
      ],
    );
  }
}
