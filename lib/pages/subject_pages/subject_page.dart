import 'package:abitur/pages/subject_pages/subject/subject_edit_graduation_evaluation_dialog.dart';
import 'package:abitur/pages/subject_pages/subject_input_page.dart';
import 'package:abitur/storage/entities/performance.dart';
import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/services/graduation_service.dart';
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
import '../../storage/entities/graduation/graduation_evaluation.dart';
import '../../storage/entities/subject.dart';
import '../../utils/brightness_notifier.dart';
import '../../utils/enums/subject_type.dart';
import '../../widgets/graduation_date_list_tile.dart';
import '../evaluation_pages/evaluation_input_page.dart';

class SubjectPage extends StatefulWidget {

  final Subject subject;
  final bool openGraduationPage;

  const SubjectPage({super.key, required this.subject, this.openGraduationPage = false});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> with SingleTickerProviderStateMixin {

  late Subject subject;
  GraduationEvaluation? graduationEvaluation;
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
    if (widget.openGraduationPage && (GraduationService.isGraduationSubject(subject) || subject.subjectType == SubjectType.wSeminar)) {
      currentTerm = subject.terms.length;
    }
    _tabKeys = subject.terms.map((e) => GlobalKey<_TermViewState>()).toList();
    int tabLength = subject.terms.length;
    if (GraduationService.isGraduationSubject(subject) || subject.subjectType == SubjectType.wSeminar) {
      tabLength++;
      _tabKeys.add(GlobalKey<_TermViewState>());
      graduationEvaluation = GraduationService.findEvaluationBySubject(subject)!;
      giveGraduationNote = graduationEvaluation!.notePartOne != null;
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
        return SubjectInputPage(
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
        return EvaluationInputPage(
          subject: widget.subject,
          term: subject.terms.elementAt(_tabController.index),
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
            tabs: [
              for (int term in subject.terms)
                Tab(
                  text: "${term + 1}. Halbjahr",
                ),
              if (GraduationService.isGraduationSubject(subject))
                Tab(
                  text: "Abitur",
                ),
              if (subject.subjectType == SubjectType.wSeminar)
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
            if (graduationEvaluation != null)
              _GraduationWorkTermView(
                subject: subject,
                graduationEvaluation: graduationEvaluation!,
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
            _editGraduationWorkData(graduationEvaluation!);
          },
        ),
      ),
    );
  }

  Future<void> _editGraduationWorkData(GraduationEvaluation e) async {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SubjectEditGraduationEvaluationDialog(
          graduationEvaluation: e,
        );
        // return ManualTermNoteEnterSheet(subject: widget.subject, term: widget.term);
      },
    ).then((value) {
      setState(() { });
    });
    // await showDialog(context: context, barrierDismissible: false, builder: (context) {
    //   return SubjectEditGraduationEvaluationDialog(
    //     graduationEvaluation: e,
    //   );
    // });
    //
    // setState(() {});
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

  Iterable<(int, Performance)> _getIndexedPerformances() {
    List<Performance> keys = evaluations.keys.toList();
    keys.sort((a, b) => a.name.compareTo(b.name));
    return keys.indexed;
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
                  child: PercentIndicator(
                    value: SubjectService.getAverageByTerm(widget.subject, widget.term),
                    color: widget.subject.color,
                    edit: () {
                      manuallyEnterTermNoteDialog();
                    },
                  ),
                ),
              ),
              if (widget.subject.manuallyEnteredTermNotes[widget.term] != null)
                InfoCard("Diese Halbjahresnote wurde manuell eingetragen."),
              ListTile(
                title: Text(
                  "Noten:",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (evaluations.isEmpty)
                InfoCard("In diesem Halbjahr gibt es noch keine Noten."),
              for (final (i, p) in _getIndexedPerformances()) ...[
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
                          return EvaluationInputPage(evaluation: e);
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

  void manuallyEnterTermNoteDialog() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return ManualTermNoteEnterSheet(subject: widget.subject, term: widget.term);
      },
    ).then((value) {
      setState(() { });
    });
  }
}

class _GraduationWorkTermView extends StatefulWidget {
  
  final Subject subject;
  final GraduationEvaluation graduationEvaluation;
  
  const _GraduationWorkTermView({super.key, required this.subject, required this.graduationEvaluation});

  @override
  State<_GraduationWorkTermView> createState() => _GraduationWorkTermViewState();
}

class _GraduationWorkTermViewState extends State<_GraduationWorkTermView> {
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
                child: Center( // TODO Wichtig: sh. Tabelle https://km.baden-wuerttemberg.de/fileadmin/redaktion/m-km/intern/PDF/Publikationen/Gymnasium/2025_Leitfaden_fuer_die_gymnasiale_Oberstufe_Abitur_2027.pdf Seite 14, nicht erst runden und dann mal 4, sondern erst mal 4 und dann runden!
                  child: PercentIndicator(
                    value: GraduationService.calculateNote(widget.graduationEvaluation)?.toDouble(),
                    color: widget.subject.color,
                    title: widget.graduationEvaluation.graduationEvaluationType.name,
                  ),
                ),
              ),
              FormGap(),
              if (!widget.graduationEvaluation.isDividedEvaluation)
                DateInput(
                  dateTime: widget.graduationEvaluation.datePartOne,
                ),
              if (widget.graduationEvaluation.isDividedEvaluation)
                ...[
                  GraduationDateListTile(
                    date: widget.graduationEvaluation.datePartOne,
                    weight: widget.graduationEvaluation.weightPartOne,
                    note: widget.graduationEvaluation.notePartOne,
                  ),
                  GraduationDateListTile(
                    date: widget.graduationEvaluation.datePartTwo,
                    weight: widget.graduationEvaluation.weightPartTwo,
                    note: widget.graduationEvaluation.notePartTwo,
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class ManualTermNoteEnterSheet extends StatefulWidget {

  final Subject subject;
  final int term;

  const ManualTermNoteEnterSheet({super.key, required this.subject, required this.term});

  @override
  State<ManualTermNoteEnterSheet> createState() => _ManualTermNoteEnterSheetState();
}

class _ManualTermNoteEnterSheetState extends State<ManualTermNoteEnterSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: Text("Halbjahresnote manuell eintragen"),
            value: widget.subject.manuallyEnteredTermNotes[widget.term] != null,
            onChanged: (newValue) {
              setState(() {
                if (widget.subject.manuallyEnteredTermNotes[widget.term] == null) {
                  SubjectService.manuallyEnterTermNote(widget.subject, term: widget.term, note: 8);
                } else {
                  SubjectService.manuallyEnterTermNote(widget.subject, term: widget.term, note: null);
                }
              });
            },
          ),

          Slider(
            min: 0,
            max: 15,
            divisions: 15,
            value: (widget.subject.manuallyEnteredTermNotes[widget.term] ?? 8).toDouble(),
            label: "${widget.subject.manuallyEnteredTermNotes[widget.term]}",
            onChanged: widget.subject.manuallyEnteredTermNotes[widget.term] != null ? (newNote) {
              setState(() {
                SubjectService.manuallyEnterTermNote(widget.subject, term: widget.term, note: newNote.round());
              });
            } : null,
            year2023: false,
          ),
        ],
      ),
    );
  }
}

