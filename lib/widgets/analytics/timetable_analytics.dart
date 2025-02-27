import 'package:abitur/pages/timetable_page.dart';
import 'package:abitur/storage/entities/timetable/timetable_entry.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/services/timetable_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:flutter/material.dart';

class TimetableAnalytics extends StatefulWidget {

  const TimetableAnalytics({super.key});

  @override
  State<TimetableAnalytics> createState() => _TimetableAnalyticsState();
}

class _TimetableAnalyticsState extends State<TimetableAnalytics> {

  @override
  Widget build(BuildContext context) {
    int term = SettingsService.currentProbableTerm();
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
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return TimetablePage();
                })
              );
              setState(() { });
            },
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1.5,
              ),
              itemCount: TimetableService.maxHours(term) * 5,
              itemBuilder: (context, index) {
                int day = index % 5;  // Berechnung des Tages
                int hour = index ~/ 5; // Berechnung der Stunde

                TimetableEntry? entry = TimetableService.getTimetableEntry(term, day, hour);

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.all(2.0),
                  color: entry == null ? Theme.of(context).colorScheme.surfaceContainer : entry.subject.color,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          entry?.subject.shortName ?? "",
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
