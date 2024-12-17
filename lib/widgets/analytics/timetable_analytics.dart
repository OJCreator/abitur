import 'package:abitur/storage/entities/subject.dart';
import 'package:abitur/storage/services/timetable_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:flutter/material.dart';

import '../../pages/analytics_pages/timetable_modify_page.dart';

class TimetableAnalytics extends StatefulWidget {

  const TimetableAnalytics({super.key});

  @override
  State<TimetableAnalytics> createState() => _TimetableAnalyticsState();
}

class _TimetableAnalyticsState extends State<TimetableAnalytics> {

  bool editMode = false;

  void _loadTimeTable() {
    setState(() { });
  }

  @override
  void initState() {
    _loadTimeTable();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Stundenplan",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    editMode = !editMode;
                  });
                },
                icon: Icon(editMode ? Icons.check : Icons.edit),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.5,
            ),
            itemCount: editMode ? 5*14 : TimetableService.maxHours() * 5,
            itemBuilder: (context, index) {
              int day = index % 5;  // Berechnung des Tages
              int hour = index ~/ 5; // Berechnung der Stunde

              Subject? subject = TimetableService.getSubject(day, hour);
              String? room = TimetableService.getRoom(day, hour);

              return GestureDetector(
                onTap: () {
                  _changeSubject(day, hour, subject, room);
                },
                child: Card(
                  elevation: 0,
                  margin: const EdgeInsets.all(2.0),
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(5),
                  // ),
                  color: subject == null ? Theme.of(context).colorScheme.surfaceContainer : subject.color,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          subject?.shortName ?? (editMode ? "+" : ""),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: getContrastingTextColor(subject?.color ?? Colors.black),
                          ),
                        ),
                        if (room?.isNotEmpty ?? false)
                          Text(
                            room!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: getContrastingTextColor(subject?.color ?? Colors.black),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _changeSubject(int day, int hour, Subject? subject, String? room) async {

    if (!editMode) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimetableModifyPage(day: day, hour: hour, initialSubject: subject, initialRoom: room,),
        fullscreenDialog: true,
      ),
    );

    setState(() {});
  }
}
