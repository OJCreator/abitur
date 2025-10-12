import 'package:abitur/utils/extensions/int_extension.dart';
import 'package:flutter/material.dart';

import '../../storage/entities/subject.dart';
import '../../storage/services/subject_service.dart';
import '../../storage/services/timetable_service.dart';
import '../../widgets/forms/form_gap.dart';
import '../../widgets/forms/subject_dropdown.dart';

class TimetableEditEventPage extends StatefulWidget {

  final int term;

  final int day;
  final int hour;

  final Subject? initialSubject;
  final String? initialRoom;

  const TimetableEditEventPage({super.key, required this.term, required this.day, required this.hour, required this.initialSubject, required this.initialRoom});

  @override
  State<TimetableEditEventPage> createState() => _TimetableEditEventPageState();
}

class _TimetableEditEventPageState extends State<TimetableEditEventPage> {

  Subject? _selectedSubject;
  final TextEditingController _roomController = TextEditingController();
  late final List<Subject?> subjects;

  @override
  void initState() {
    _selectedSubject = widget.initialSubject;
    _roomController.text = widget.initialRoom ?? "";
    subjects = [null, ...SubjectService.findAll().where((s) => s.terms.contains(widget.term))];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${(widget.day+1).weekday()}, ${widget.hour+1}. Stunde"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Form(
            child: Column(
              children: [
                SubjectDropdown(
                  subjects: subjects,
                  selectedSubject: _selectedSubject,
                  onSelected: (s) {
                    setState(() {
                      _selectedSubject = s;
                      String? knownRoom = TimetableService.knownRoom(s);
                      if (knownRoom != null) {
                        _roomController.text = knownRoom;
                      }
                    });
                  },
                ),

                FormGap(),

                TextFormField(
                  controller: _roomController,
                  enabled: _selectedSubject != null,
                  decoration: InputDecoration(
                    labelText: "Raum",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await TimetableService.changeSubject(widget.term, widget.day, widget.hour, _selectedSubject, _roomController.text);
          Navigator.pop(context);
        },
        label: Text("Speichern"),
        icon: Icon(Icons.save),
      ),
    );
  }
}