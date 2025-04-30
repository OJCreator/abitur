import 'package:abitur/pages/evaluation_pages/evaluation_edit_page.dart';
import 'package:abitur/pages/evaluation_pages/evaluation_new_page.dart';
import 'package:abitur/pages/subject_pages/subject/subject_edit_graduation_evaluation_dialog.dart';
import 'package:abitur/pages/subject_pages/subject_edit_page.dart';
import 'package:abitur/storage/entities/evaluation_date.dart';
import 'package:abitur/storage/entities/performance.dart';
import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:abitur/widgets/section_heading_list_tile.dart';
import 'package:abitur/widgets/confirm_dialog.dart';
import 'package:abitur/widgets/evaluation_list_tile.dart';
import 'package:abitur/widgets/forms/date_input.dart';
import 'package:abitur/widgets/forms/form_gap.dart';
import 'package:abitur/widgets/info_card.dart';
import 'package:abitur/widgets/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../storage/entities/evaluation.dart';
import '../../storage/entities/subject.dart';
import '../../utils/brightness_notifier.dart';

class SubjectPage extends StatefulWidget {

  final Subject subject;
  final bool openGraduationPage;

  const SubjectPage({super.key, required this.subject, this.openGraduationPage = false});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> with SingleTickerProviderStateMixin {

  late Subject subject;
  Evaluation? graduationEvaluation;
  bool giveGraduationNote = false;

  late TabController _tabController;
  late List<GlobalKey<_TermViewState>> _tabKeys;

  @override
  void initState() {
    subject = widget.subject;

    int currentTerm = SettingsService.currentProbableTerm();
    if (!subject.terms.contains(currentTerm)) {
      currentTerm = 0;
    }
    if (widget.openGraduationPage && (SubjectService.isGraduationSubject(subject) || subject.subjectType == SubjectType.seminar)) {
      currentTerm = subject.terms.length;
    }
    _tabKeys = subject.terms.map((e) => GlobalKey<_TermViewState>()).toList();
    int tabLength = subject.terms.length;
    if (SubjectService.isGraduationSubject(subject) || subject.subjectType == SubjectType.seminar) {
      tabLength++;
      _tabKeys.add(GlobalKey<_TermViewState>());
      graduationEvaluation = subject.graduationEvaluation;
      giveGraduationNote = graduationEvaluation!.evaluationDates.first.note != null;
    }
    _tabController = TabController(length: tabLength, vsync: this, initialIndex: currentTerm);
    _tabController.addListener(() {
      setState(() {});
    });

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
        return ConfirmDialog(
          title: "Wirklich löschen?",
          message: "Das Fach wird inklusive aller eingetragenen Prüfungen und den Einträgen im Stundenplan gelöscht und kann nicht wiederhergestellt werden.",
          confirmText: "Löschen",
          onConfirm: () async {
            await SubjectService.deleteSubject(subject);
          },
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

  Future<void> _editGraduationWorkData() async {
    await showDialog(context: context, builder: (context) {
      return SubjectEditGraduationEvaluationDialog(graduationEvaluationDate: graduationEvaluation!.evaluationDates.first);
    });

    setState(() {});
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
            tabs: [
              for (int term in subject.terms)
                Tab(
                  text: "${term + 1}. Halbjahr",
                ),
              if (SubjectService.isGraduationSubject(subject))
                Tab(
                  text: "Abitur",
                ),
              if (subject.subjectType == SubjectType.seminar)
                Tab(
                  text: "Seminararbeit",
                ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            for (MapEntry<int, int> entry in subject.terms.toList().asMap().entries)
              _TermView(
                subject: subject,
                term: entry.value,
                key: _tabKeys[entry.key],
              ),
            if (SubjectService.isGraduationSubject(subject))
              _GraduationWorkTermView(
                subject: subject,
                graduationEvaluationDate: graduationEvaluation?.evaluationDates.first,
                key: _tabKeys.last,
              ),
            if (subject.subjectType == SubjectType.seminar)
              _GraduationWorkTermView(
                subject: subject,
                graduationEvaluationDate: graduationEvaluation?.evaluationDates.first,
                key: _tabKeys.last,
              ),
          ],
        ),
        floatingActionButton: _tabController.index < subject.terms.length ? FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _newEvaluation(context);
          },
        ) : FloatingActionButton(
          child: Icon(Icons.edit),
          onPressed: () {
            _editGraduationWorkData();
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

  // List<Evaluation> evaluations = [];
  Map<Performance, List<Evaluation>> evaluations = {};

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
      final allEvaluations = EvaluationService.findAllBySubjectAndTerm(widget.subject, widget.term);
      evaluations = allEvaluations.groupBy((e) => e.performance);
      for (List<Evaluation> list in evaluations.values) {
        list.sort((a, b) => a.evaluationDates.first.compareTo(b.evaluationDates.first));
      }
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
              ListTile(
                title: Text(
                  "Noten:",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (evaluations.isEmpty)
                InfoCard("In diesem Halbjahr gibt es noch keine Noten."),
              for (final (i, p) in evaluations.keys.indexed) ...[
                if (i > 0)
                  Divider(),
                SectionHeadingListTile(heading: p.name),
                for (Evaluation e in evaluations[p]!)
                  EvaluationListTile(
                    evaluation: e,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return EvaluationEditPage(evaluation: e);
                        }),
                      );
                      _loadEvaluations();
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GraduationWorkTermView extends StatelessWidget {
  
  final Subject subject;
  final EvaluationDate? graduationEvaluationDate;
  
  const _GraduationWorkTermView({super.key, required this.subject, required this.graduationEvaluationDate});

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
                  child: PercentIndicator(value: graduationEvaluationDate?.note?.toDouble(), color: subject.color),
                ),
              ),
              FormGap(),
              DateInput(
                dateTime: graduationEvaluationDate?.date,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
