import 'package:abitur/services/database/timetable_entry_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../services/database/subject_service.dart';
import '../../sqlite/entities/subject.dart';
import '../../sqlite/entities/timetable/timetable_entry.dart';
import '../../utils/constants.dart';
import 'timetable_edit_event_page.dart';

class TimetableEditPage extends StatefulWidget {

  final int term;

  const TimetableEditPage({super.key, required this.term});

  @override
  State<TimetableEditPage> createState() => _TimetableEditPageState();
}

class _TimetableEditPageState extends State<TimetableEditPage> {

  List<TimetableEntry> timetable = [];

  @override
  void initState() {
    loadTimetable();
    super.initState();
  }

  Future<void> loadTimetable() async {
    timetable = await TimetableEntryService.findAllEntriesOfTerm(widget.term);
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.term + 1}. Halbjahr - Stundenplan bearbeiten"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1.5,
                ),
                itemCount: 5*14,
                itemBuilder: (context, index) {
                  int day = index % 5;  // Berechnung des Tages
                  int hour = index ~/ 5; // Berechnung der Stunde

                  TimetableEntry? entry = timetable.firstWhereOrNull((t) => t.day == day && t.hour == hour);

                  return FutureBuilder(
                    future: SubjectService.findById(entry?.subjectId),
                    builder: (context, asyncSnapshot) {

                      Subject? subject = asyncSnapshot.data;
                      Color bgColor = subject?.color ?? Theme.of(context).colorScheme.surfaceContainer;

                      return GestureDetector(
                        onTap: () {
                          _changeSubject(context, day, hour, subject, entry?.room);
                        },
                        child: Card(
                          elevation: 0,
                          margin: const EdgeInsets.all(2.0),
                          color: bgColor,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  subject?.shortName ?? "+",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: getContrastingTextColor(bgColor),
                                  ),
                                ),
                                if (entry?.room?.isNotEmpty ?? false)
                                  Text(
                                    entry!.room!,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: getContrastingTextColor(bgColor),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _changeSubject(BuildContext context, int day, int hour, Subject? subject, String? room) async {

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimetableEditEventPage(term: widget.term, day: day, hour: hour, initialSubject: subject, initialRoom: room,),
        fullscreenDialog: true,
      ),
    );

    setState(() {});
  }
}

