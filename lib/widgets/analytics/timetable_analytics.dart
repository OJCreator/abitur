import 'package:abitur/pages/timetable/timetable_page.dart';
import 'package:flutter/material.dart';

import '../../services/database/settings_service.dart';
import '../timetable_view.dart';

class TimetableAnalytics extends StatefulWidget {

  const TimetableAnalytics({super.key});

  @override
  State<TimetableAnalytics> createState() => _TimetableAnalyticsState();
}

class _TimetableAnalyticsState extends State<TimetableAnalytics> {

  late Future<int> currentProbableTerm;

  final GlobalKey<TimetableViewState> _termViewKey = GlobalKey<TimetableViewState>();

  @override
  void initState() {
    currentProbableTerm = SettingsService.currentProbableTerm();
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
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              Feedback.forTap(context);
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return TimetablePage();
                })
              );
              _termViewKey.currentState?.setTimetableData();
            },
            child: FutureBuilder(
              future: currentProbableTerm,
              builder: (context, asyncSnapshot) {
                if (!asyncSnapshot.hasData || asyncSnapshot.data == null) return TimetableView.shimmer();
                return TimetableView(
                  key: _termViewKey,
                  term: asyncSnapshot.data!,
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
