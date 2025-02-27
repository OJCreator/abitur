import 'package:flutter/material.dart';

import '../../storage/entities/subject.dart';
import '../../storage/entities/timetable/timetable_entry.dart';
import '../../storage/services/timetable_service.dart';
import '../../utils/constants.dart';
import 'timetable_edit_event_page.dart';

class TimetableEditPage extends StatefulWidget {

  final int term;

  const TimetableEditPage({super.key, required this.term});

  @override
  State<TimetableEditPage> createState() => _TimetableEditPageState();
}

class _TimetableEditPageState extends State<TimetableEditPage> {
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

                  TimetableEntry? entry = TimetableService.getTimetableEntry(widget.term, day, hour);

                  return GestureDetector(
                    onTap: () {
                      _changeSubject(context, day, hour, entry?.subject, entry?.room);
                    },
                    child: Card(
                      elevation: 0,
                      margin: const EdgeInsets.all(2.0),
                      color: entry == null ? Theme.of(context).colorScheme.surfaceContainer : entry.subject.color,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              entry?.subject.shortName ?? "+",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: getContrastingTextColor(entry?.subject.color ?? Colors.black),
                              ),
                            ),
                            if (entry?.room?.isNotEmpty ?? false)
                              Text(
                                entry!.room!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: getContrastingTextColor(entry.subject.color),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
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

