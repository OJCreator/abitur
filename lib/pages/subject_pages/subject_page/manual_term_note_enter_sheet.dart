
import 'package:flutter/material.dart';

import '../../../services/database/subject_service.dart';
import '../../../sqlite/entities/subject.dart';

class ManualTermNoteEnterSheet extends StatefulWidget {

  final Subject subject;
  final int term;

  const ManualTermNoteEnterSheet({super.key, required this.subject, required this.term});

  @override
  State<ManualTermNoteEnterSheet> createState() => _ManualTermNoteEnterSheetState();
}

class _ManualTermNoteEnterSheetState extends State<ManualTermNoteEnterSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: Text("Halbjahresnote manuell eintragen"),
            value: widget.subject.manuallyEnteredTermNotes[widget.term] != null,
            onChanged: (newValue) async {
              if (widget.subject.manuallyEnteredTermNotes[widget.term] == null) {
                await SubjectService.manuallyEnterTermNote(widget.subject, term: widget.term, note: 8);
              } else {
                await SubjectService.manuallyEnterTermNote(widget.subject, term: widget.term, note: null);
              }
              setState(() { });
            },
          ),

          Slider(
            min: 0,
            max: 15,
            divisions: 15,
            value: (widget.subject.manuallyEnteredTermNotes[widget.term] ?? 8).toDouble(),
            label: "${widget.subject.manuallyEnteredTermNotes[widget.term]}",
            onChanged: widget.subject.manuallyEnteredTermNotes[widget.term] != null ? (newNote) async {
              await SubjectService.manuallyEnterTermNote(widget.subject, term: widget.term, note: newNote.round());
              setState(() { });
            } : null,
            year2023: false,
          ),
        ],
      ),
    );
  }
}

