import 'package:abitur/pages/evaluation_edit_page.dart';
import 'package:abitur/pages/evaluation_new_page.dart';
import 'package:abitur/pages/subject_edit_page.dart';
import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:abitur/widgets/info_card.dart';
import 'package:abitur/widgets/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../storage/entities/evaluation.dart';
import '../storage/entities/subject.dart';
import '../utils/brightness_notifier.dart';

class SubjectPage extends StatefulWidget {

  final Subject subject;

  const SubjectPage({super.key, required this.subject});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> with SingleTickerProviderStateMixin {

  late Subject subject;

  late TabController _tabController;
  late List<GlobalKey<_TermViewState>> _tabKeys;

  @override
  void initState() {
    subject = widget.subject;

    int currentTerm = SettingsService.probableTerm(DateTime.now());
    if (!subject.terms.contains(currentTerm)) {
      currentTerm = 0;
    }
    _tabController = TabController(length: subject.terms.length, vsync: this, initialIndex: currentTerm);
    _tabKeys = subject.terms.map((e) =>  GlobalKey<_TermViewState>()).toList();

    super.initState();
  }

  Future<void> editSubject(BuildContext context) async {
    Subject? editedSubject = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return SubjectEditPage(
          subject: subject,
        );
      }),
    );
    if (editedSubject == null) {
      return;
    }
    setState(() {
      subject = editedSubject;
    });
  }

  Future<void> deleteSubject() async {
    bool deletedSubject = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Wirklich löschen?"),
          content: Text("Das Fach wird inklusive aller eingetragenen Prüfungen und den Einträgen im Stundenplan gelöscht und kann nicht wiederhergestellt werden."),
          actions: [
            TextButton(
              onPressed: () async {
                await SubjectService.deleteSubject(subject);
                Navigator.pop(context, true);
              },
              child: Text("Löschen"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text("Abbrechen"),
            ),
          ],
        );
      },
    );
    if (!deletedSubject) {
      return;
    }
    Navigator.pop(context);
  }

  Future<void> _newEvaluation(BuildContext context) async {
    Evaluation? newEvaluation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return EvaluationNewPage(
          initialSubject: widget.subject,
          initialTerm: subject.terms.elementAt(_tabController.index),
        );
      }),
    );
    if (newEvaluation == null) {
      return;
    }
    _tabKeys[_tabController.index].currentState!._loadEvaluations();
  }

  @override
  Widget build(BuildContext context) {

    Brightness b = Provider.of<BrightnessNotifier>(context).currentBrightness;
    return Theme(
        data: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: subject.color, brightness: b,),
          useMaterial3: true,
          brightness: b,
        ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(subject.name),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  deleteSubject();
                } else {
                  editSubject(context);
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Bearbeiten'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Löschen'),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: subject.terms.map((term) {
              return Tab(
                text: "${term + 1}. Halbjahr",
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: subject.terms.toList().asMap().entries.map((entry) {
            return _TermView(
              subject: subject,
              term: entry.value,
              key: _tabKeys[entry.key]
            );
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _newEvaluation(context);
          },
        ),
      ),
    );
  }
}

class _TermView extends StatefulWidget {

  final Subject subject;
  final int term;

  const _TermView({
    required this.subject,
    required this.term,
    super.key,
  });

  @override
  State<_TermView> createState() => _TermViewState();
}

class _TermViewState extends State<_TermView> {

  List<Evaluation> evaluations = [];

  @override
  void didUpdateWidget(covariant _TermView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subject != widget.subject || oldWidget.term != widget.term) {
      _loadEvaluations();
    }
  }

  @override
  void initState() {
    _loadEvaluations();
    super.initState();
  }

  void _loadEvaluations() {
    setState(() {
      evaluations = EvaluationService.findAllBySubjectAndTerm(widget.subject, widget.term);
      evaluations.sort((a, b) => a.date.compareTo(b.date));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: PercentIndicator(value: SubjectService.getAverageByTerm(widget.subject, widget.term), color: widget.subject.color),
                ),
              ),
              Text(
                "Noten:",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ...evaluations.isNotEmpty ? evaluations.map((evaluation) {
                return ListTile(
                  title: Text(evaluation.name),
                  subtitle: Text(evaluation.date.format()),
                  trailing: AspectRatio(
                    aspectRatio: 1,
                    child: Center(
                      child: Text(
                        evaluation.note?.toString() ?? "-",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return EvaluationEditPage(evaluation: evaluation);
                      }),
                    );
                    setState(() {
                      evaluations = EvaluationService.findAllBySubjectAndTerm(widget.subject, widget.term);
                    });
                  },
                );
              }) : [
                InfoCard("In diesem Halbjahr gibt es noch keine Noten.")
              ]
            ],
          ),
        ),
      ),
    );
  }
}
