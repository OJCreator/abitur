import 'package:flutter/material.dart';

import '../storage/entities/timetable/timetable_entry.dart';
import '../storage/services/settings_service.dart';
import '../storage/services/timetable_service.dart';
import '../utils/constants.dart';
import 'info_card.dart';

class TimetableView extends StatefulWidget {

  final int term;

  const TimetableView({super.key, required this.term});

  @override
  State<TimetableView> createState() => _TimetableViewState();
}

class _TimetableViewState extends State<TimetableView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.term > 0 && TimetableService.timetableIsEmpty(widget.term) && !TimetableService.timetableIsEmpty(widget.term-1))
          InfoCard(
            "Der aktuelle Stundenplan ist leer. Möchstes du die Daten aus dem vorherigen hierhin kopieren?",
            action: "Daten kopieren",
            onAction: () async {
              await TimetableService.copyTimetable(widget.term-1, widget.term);
              setState(() { });
            },
          ),
        if (widget.term < SettingsService.currentProbableTerm())
          InfoCard("Das hier ist ein alter Stundenplan. Er dient der richtigen Verwaltung der Kalenderneinträge. Und natürlich der Nostalgie."),
        GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1.5,
          ),
          itemCount: TimetableService.maxHours(widget.term) * 5,
          itemBuilder: (context, index) {
            int day = index % 5;  // Berechnung des Tages
            int hour = index ~/ 5; // Berechnung der Stunde

            TimetableEntry? entry = TimetableService.getTimetableEntry(widget.term, day, hour);

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
                      )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}