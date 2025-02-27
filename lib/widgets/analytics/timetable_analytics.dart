import 'package:abitur/pages/timetable/timetable_page.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:flutter/material.dart';

import '../timetable_view.dart';

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
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return TimetablePage();
                })
              );
              setState(() { });
            },
            child: TimetableView(term: term),
          ),
        ],
      ),
    );
  }
}
