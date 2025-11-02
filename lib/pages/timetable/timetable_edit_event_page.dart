import 'package:abitur/services/database/timetable_entry_service.dart';
import 'package:abitur/utils/extensions/int_extension.dart';
import 'package:flutter/material.dart';

import '../../services/database/subject_service.dart';
import '../../sqlite/entities/subject.dart';
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
  Future<List<Subject>> subjects = Future.value([]);

  @override
  void initState() {
    subjects = SubjectService.findAll();
    _selectedSubject = widget.initialSubject;
    _roomController.text = widget.initialRoom ?? "";
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
                FutureBuilder(
                  future: subjects,
                  builder: (context, asyncSnapshot) {
                    if (!asyncSnapshot.hasData) return CircularProgressIndicator();
                    return SubjectDropdown(
                      subjects: [null, ...asyncSnapshot.data!],
                      selectedSubject: _selectedSubject,
                      onSelected: (s) async {
                        setState(() {
                          _selectedSubject = s;
                        });
                        if (s == null) {
                          setState(() {
                            _roomController.text = "";
                          });
                          return;
                        }
                        String? knownRoom = await TimetableEntryService.knownRoom(s.id);
                        if (knownRoom != null) {
                          _roomController.text = knownRoom;
                        }
                        setState(() { });
                      },
                    );
                  }
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
          await TimetableEntryService.changeTimetableEntry(widget.term, widget.day, widget.hour, _selectedSubject?.id, _roomController.text, null);
          Navigator.pop(context);
        },
        label: Text("Speichern"),
        icon: Icon(Icons.save),
      ),
    );
  }
}