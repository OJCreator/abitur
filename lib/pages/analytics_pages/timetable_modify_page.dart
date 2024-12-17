import 'package:abitur/utils/constants.dart';
import 'package:flutter/material.dart';

import '../../storage/entities/subject.dart';
import '../../storage/services/subject_service.dart';
import '../../storage/services/timetable_service.dart';
import '../../widgets/forms/form_gap.dart';
import '../../widgets/forms/subject_dropdown.dart';

class TimetableModifyPage extends StatefulWidget {

  final int day;
  final int hour;

  final Subject? initialSubject;
  final String? initialRoom;

  const TimetableModifyPage({super.key, required this.day, required this.hour, required this.initialSubject, required this.initialRoom});

  @override
  State<TimetableModifyPage> createState() => _TimetableModifyPageState();
}

class _TimetableModifyPageState extends State<TimetableModifyPage> {

  Subject? _selectedSubject;
  final TextEditingController _roomController = TextEditingController();

  @override
  void initState() {
    _selectedSubject = widget.initialSubject;
    _roomController.text = widget.initialRoom ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.day.weekday()}, ${widget.hour+1}. Stunde"),
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
                  subjects: [null, ...SubjectService.findAll()],
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
          await TimetableService.changeSubject(widget.day, widget.hour, _selectedSubject, _roomController.text);

          Navigator.pop(context);
        },
        label: Text("Speichern"),
        icon: Icon(Icons.save),
      ),
    );
  }
}