import 'package:abitur/storage/entities/timetable/timetable_entry.dart';
import 'package:flutter/material.dart';

import '../storage/entities/subject.dart';
import '../storage/services/settings_service.dart';
import '../storage/services/timetable_service.dart';
import '../utils/constants.dart';
import 'analytics_pages/timetable_modify_page.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> with SingleTickerProviderStateMixin {

  bool editMode = false;
  late TabController _tabController;

  @override
  void initState() {
    int currentTerm = SettingsService.currentProbableTerm();
    _tabController = TabController(length: 4, vsync: this, initialIndex: currentTerm);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stundenplan"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "1. Halbjahr"),
            Tab(text: "2. Halbjahr"),
            Tab(text: "3. Halbjahr"),
            Tab(text: "4. Halbjahr"),
          ]
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TimetableTermView(editMode: editMode, term: 0),
          _TimetableTermView(editMode: editMode, term: 1),
          _TimetableTermView(editMode: editMode, term: 2),
          _TimetableTermView(editMode: editMode, term: 3),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(editMode ? Icons.check : Icons.edit),
        onPressed: () {
          setState(() {
            editMode = !editMode;
          });
        },
      ),
    );
  }
}

class _TimetableTermView extends StatefulWidget {

  final bool editMode;
  final int term;

  const _TimetableTermView({required this.editMode, required this.term});

  @override
  State<_TimetableTermView> createState() => _TimetableTermViewState();
}

class _TimetableTermViewState extends State<_TimetableTermView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1.5,
          ),
          itemCount: widget.editMode ? 5*14 : TimetableService.maxHours(widget.term) * 5,
          itemBuilder: (context, index) {
            int day = index % 5;  // Berechnung des Tages
            int hour = index ~/ 5; // Berechnung der Stunde

            TimetableEntry? entry = TimetableService.getTimetableEntry(widget.term, day, hour);

            return GestureDetector(
              onTap: () {
                _changeSubject(day, hour, entry?.subject, entry?.room);
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
                        entry?.subject.shortName ?? (widget.editMode ? "+" : ""),
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
              ),
            );
          },
        ),
      ),
    );
  }


  Future<void> _changeSubject(int day, int hour, Subject? subject, String? room) async {

    if (!widget.editMode) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimetableModifyPage(term: widget.term, day: day, hour: hour, initialSubject: subject, initialRoom: room,),
        fullscreenDialog: true,
      ),
    );

    setState(() {});
  }
}

