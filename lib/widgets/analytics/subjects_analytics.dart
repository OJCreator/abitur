import 'package:abitur/pages/analytics_pages/analytics_subjects_page.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../in_app_purchases/purchase_service.dart';
import '../../pages/in_app_purchase_pages/full_version_page.dart';
import '../../services/database/subject_service.dart';
import '../../sqlite/entities/subject.dart';
import '../../utils/constants.dart';
import '../../utils/pair.dart';

class SubjectsAnalytics extends StatefulWidget {

  final List<Subject> subjects;

  const SubjectsAnalytics({required this.subjects, super.key});

  @override
  State<StatefulWidget> createState() => SubjectsAnalyticsState();
}

class SubjectsAnalyticsState extends State<SubjectsAnalytics> {


  List<Pair<Subject, double>> subjectNotes = [];

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SubjectsAnalytics oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!const ListEquality().equals(oldWidget.subjects, widget.subjects)) {
      _loadData();
    }
  }


  Future<void> _loadData() async {

    /* SORT OPTION */
    final prefs = await SharedPreferences.getInstance();
    SortOption sortOption = SortOption.fromName(
      prefs.getString(analyticsPageSortOptionPrefsKey),
    );

    final averages = await SubjectService.getAverages(
      widget.subjects.map((s) => s.id).toList(),
    );

    setState(() {
      subjectNotes = widget.subjects
          .map((s) => Pair(s, averages[s.id] ?? 0))
          .sorted(sortOption.sortAlgorithm)
          .toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Fächerübersicht",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 38),
          GestureDetector(
            onTap: _onTap,
            child: AnalyticsSubjectsGraph(
              subjectNotes: subjectNotes,
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _onTap() async {
    Feedback.forTap(context);

    if (PurchaseService.fullAccess) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AnalyticsSubjectsPage()),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FullVersionPage(
            nextPage: const AnalyticsSubjectsPage(),
          ),
        ),
      );
    }
    _loadData();
  }
}