import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../services/database/settings_service.dart';
import '../services/database/subject_service.dart';
import '../sqlite/entities/subject.dart';
import '../sqlite/entities/timetable/timetable_entry.dart';
import '../services/database/timetable_entry_service.dart';
import '../utils/constants.dart';
import 'info_card.dart';

class TimetableView extends StatefulWidget {
  final int term;
  final bool shimmer;

  const TimetableView({super.key, required this.term}):
        shimmer = false;

  const TimetableView.shimmer({super.key}):
        term = 0,
        shimmer = true;

  @override
  State<TimetableView> createState() => TimetableViewState();
}

class TimetableViewState extends State<TimetableView> {

  late Future<_TimetableData> _timetableFuture;

  @override
  void didUpdateWidget(covariant TimetableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shimmer != widget.shimmer || oldWidget.term != widget.term) {
      setState(() {
        setTimetableData();
      });
    }
  }

  @override
  void initState() {
    setTimetableData();
    super.initState();
  }

  void setTimetableData() {
    setState(() {
      _timetableFuture = _loadTimetableData();
    });
  }

  Future<_TimetableData> _loadTimetableData() async {

    if (widget.shimmer) {
      return _TimetableData.empty();
    }

    final isEmpty = await TimetableEntryService.timetableIsEmpty(widget.term);
    final prevEmpty = widget.term > 0 ? await TimetableEntryService.timetableIsEmpty(widget.term - 1) : true;
    final maxHours = await TimetableEntryService.maxHours(widget.term);
    final entries = await TimetableEntryService.findAllEntriesOfTerm(widget.term);
    final probableTerm = await SettingsService.currentProbableTerm();
    final subjects = await SubjectService.findAll();

    return _TimetableData(
      entries: entries,
      maxHours: maxHours,
      isEmpty: isEmpty,
      prevEmpty: prevEmpty,
      probableTerm: probableTerm,
      subjects: subjects
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_TimetableData>(
      future: _timetableFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final term = widget.term;

        return Column(
          children: [
            if (term > 0 && data.isEmpty && !data.prevEmpty)
              InfoCard(
                "Der aktuelle Stundenplan ist leer. Möchtest du die Daten aus dem vorherigen hierhin kopieren?",
                action: "Daten kopieren",
                onAction: () async {
                  await TimetableEntryService.copyTerm(term - 1, term);
                  setState(() {
                    _timetableFuture = _loadTimetableData();
                  });
                },
              ),
            if (term < data.probableTerm)
              const InfoCard(
                "Das hier ist ein alter Stundenplan. Er dient der richtigen Verwaltung der Kalendereinträge. Und natürlich der Nostalgie.",
              ),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1.5,
              ),
              itemCount: data.maxHours * 5,
              itemBuilder: (context, index) {
                final day = index % 5;
                final hour = index ~/ 5;

                final entry = data.entries.firstWhereOrNull((e) => e.day == day && e.hour == hour);

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.all(2.0),
                  color: entry == null
                      ? Theme.of(context).colorScheme.surfaceContainer
                      : data.subjects.firstWhere((s) => s.id == entry.subjectId).color,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data.subjects.firstWhereOrNull((s) => s.id == entry?.subjectId)?.shortName ?? "",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: getContrastingTextColor(
                              data.subjects.firstWhereOrNull((s) => s.id == entry?.subjectId)?.color ?? Colors.black,
                            ),
                          ),
                        ),
                        if (entry?.room?.isNotEmpty ?? false)
                          Text(
                            entry!.room!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: getContrastingTextColor(data.subjects.firstWhereOrNull((s) => s.id == entry.subjectId)!.color),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _TimetableData {
  final List<TimetableEntry> entries;
  final int maxHours;
  final bool isEmpty;
  final bool prevEmpty;
  final int probableTerm;
  final List<Subject> subjects;

  _TimetableData({
    required this.entries,
    required this.maxHours,
    required this.isEmpty,
    required this.prevEmpty,
    required this.probableTerm,
    required this.subjects,
  });

  const _TimetableData.empty():
        entries = const [],
        maxHours = 0,
        isEmpty = true,
        prevEmpty = true,
        probableTerm = 0,
        subjects = const [];
}
