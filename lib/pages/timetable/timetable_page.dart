import 'package:abitur/pages/timetable/timetable_edit_page.dart';
import 'package:flutter/material.dart';

import '../../services/database/settings_service.dart';
import '../../widgets/timetable_view.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  late Future<int> currentProbableTerm;

  @override
  void initState() {
    currentProbableTerm = SettingsService.currentProbableTerm();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    currentProbableTerm.then((term) {
      _tabController.animateTo(term);
    });
    super.initState();
  }

  Future<void> setCurrentProbableTerm() async {
    int currentTerm = await SettingsService.currentProbableTerm();
    _tabController.animateTo(currentTerm);
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
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TimetableView(term: index),
            ),
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

