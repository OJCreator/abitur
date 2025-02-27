import 'package:abitur/pages/timetable/timetable_edit_page.dart';
import 'package:flutter/material.dart';

import '../../storage/services/settings_service.dart';
import '../../widgets/timetable_view.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> with SingleTickerProviderStateMixin {

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
        children: List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: TimetableView(term: index),
          );
        })
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return TimetableEditPage(term: _tabController.index);
            })
          );
          setState(() { });
        },
      ),
    );
  }
}

