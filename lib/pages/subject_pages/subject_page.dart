import 'package:abitur/pages/subject_pages/subject_input_page.dart';
import 'package:abitur/pages/subject_pages/subject_page/graduation_work_term_view.dart';
import 'package:abitur/pages/subject_pages/subject_page/subject_edit_graduation_evaluation_dialog.dart';
import 'package:abitur/pages/subject_pages/subject_page/term_view.dart';
import 'package:abitur/utils/constants.dart';
import 'package:abitur/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/database/graduation_evaluation_service.dart';
import '../../services/database/settings_service.dart';
import '../../services/database/subject_service.dart';
import '../../sqlite/entities/evaluation/evaluation.dart';
import '../../sqlite/entities/graduation_evaluation.dart';
import '../../sqlite/entities/subject.dart';
import '../../utils/brightness_notifier.dart';
import '../../utils/enums/subject_type.dart';
import '../../widgets/shimmer/shimmer_text.dart';
import '../evaluation_pages/evaluation_input_page.dart';

class SubjectPage extends StatefulWidget {

  final String subjectId;
  final bool openGraduationPage;

  const SubjectPage({super.key, required this.subjectId, this.openGraduationPage = false});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> with SingleTickerProviderStateMixin {

  Color seedColor = primaryColor;

  late Future<Subject?> subject;
  Future<GraduationEvaluation?> graduationEvaluation = Future.value(null);
  bool giveGraduationNote = false;

  late TabController _tabController;
  late List<GlobalKey<TermViewState>> _tabKeys;

  @override
  void initState() {
    _loadSubject();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSubject() {
    subject = SubjectService.findById(widget.subjectId);
    subject.then((s) {
      if (s == null) {
        if (mounted) {
          Navigator.pop(context);
        }
        return;
      }
      setState(() {
        seedColor = s.color;
      });
      _loadGraduationEvaluation(s);
    });
  }

  void _loadGraduationEvaluation(Subject s) {
    if (s.graduationEvaluationId == null) {
      _initTabs(s, null);
      return;
    }
    graduationEvaluation = GraduationEvaluationService.findEvaluationById(s.graduationEvaluationId!);
    graduationEvaluation.then((ge) {
      _initTabs(s,ge);
    });
  }

  Future<void> _initTabs(Subject s, GraduationEvaluation? ge) async {

    int currentTerm = await SettingsService.currentProbableTerm();
    if (!s.terms.contains(currentTerm)) currentTerm = 0;

    if (widget.openGraduationPage && ge != null) {
      currentTerm = s.terms.length;
    }
    _tabKeys = s.terms.map((e) => GlobalKey<TermViewState>()).toList();
    int tabLength = s.terms.length;
    if (ge != null) {
      tabLength++;
      _tabKeys.add(GlobalKey<TermViewState>());
      giveGraduationNote = ge.notePartOne != null;
    }
    setState(() {
      _tabController = TabController(length: tabLength, vsync: this, initialIndex: currentTerm);
    });
    _tabController.addListener(() {
      setState(() {});
    });
  }

  Future<void> editSubject(BuildContext context) async {
    Subject? s = await subject;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return SubjectInputPage(
          subject: s,
        );
      }),
    );
    _loadSubject();
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
            await SubjectService.deleteSubject(widget.subjectId);
          },
        );
      },
    );
    if (!deletedSubject) {
      return;
    }
    Navigator.pop(context);
  }

  Future<void> _newEvaluation(BuildContext context, int term) async {
    Evaluation? newEvaluation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return EvaluationInputPage(
          subjectId: widget.subjectId,
          term: term,//subject.terms.elementAt(_tabController.index),
        );
      }),
    );
    if (newEvaluation == null) {
      return;
    }
    _tabKeys[_tabController.index].currentState?.loadEvaluations();
  }

  @override
  Widget build(BuildContext context) {

    Brightness b = Provider.of<BrightnessNotifier>(context).currentBrightness;
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: b,),
        useMaterial3: true,
        brightness: b,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: FutureBuilder(
            future: subject,
            builder: (context, asyncSnapshot) {
              if (!asyncSnapshot.hasData || asyncSnapshot.data == null) return ShimmerText();
              return Text(asyncSnapshot.data!.name);
            }
          ),
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: FutureBuilder(
              future: Future.wait([subject, graduationEvaluation]),
              builder: (context, asyncSnapshot) {
                if (!asyncSnapshot.hasData) {
                  return const SizedBox(
                    height: kToolbarHeight,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                Subject s = (asyncSnapshot.data![0] as Subject);
                GraduationEvaluation? ge = (asyncSnapshot.data![1] as GraduationEvaluation?);

                return TabBar(
                  controller: _tabController,
                  tabs: [
                    for (int term in s.terms)
                      Tab(text: "${term + 1}. Halbjahr"),
                    if (ge != null && s.subjectType != SubjectType.wSeminar)
                      const Tab(text: "Abitur"),
                    if (s.subjectType == SubjectType.wSeminar)
                      const Tab(text: "Seminararbeit"),
                  ],
                );
              },
            ),
          ),
        ),
        body: FutureBuilder(
          future: Future.wait([subject, graduationEvaluation]),
          builder: (context, asyncSnapshot) {
            if (!asyncSnapshot.hasData) {
              return const SizedBox(
                height: kToolbarHeight,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            Subject s = (asyncSnapshot.data![0] as Subject);
            GraduationEvaluation? ge = (asyncSnapshot.data![1] as GraduationEvaluation?);

            return TabBarView(
              controller: _tabController,
              children: [
                for (MapEntry<int, int> entry in s.terms.toList().asMap().entries)
                  TermView(
                    subject: s,
                    term: entry.value,
                    key: _tabKeys[entry.key],
                  ),
                if (ge != null)
                  GraduationWorkTermView(
                    subject: s,
                    graduationEvaluation: ge,
                    key: _tabKeys.last,
                  ),
              ],
            );
          }
        ),
        floatingActionButton: FutureBuilder(
          future: Future.wait([subject, graduationEvaluation]),
          builder: (context, asyncSnapshot) {

            if (!asyncSnapshot.hasData) {
              return const SizedBox(
                height: kToolbarHeight,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            Subject s = (asyncSnapshot.data![0] as Subject);
            GraduationEvaluation? ge = (asyncSnapshot.data![1] as GraduationEvaluation?);

            return _tabController.index < s.terms.length ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                _newEvaluation(context, s.terms.elementAt(_tabController.index),);
              },
            ) : FloatingActionButton(
              child: Icon(Icons.edit),
              onPressed: () {
                _editGraduationWorkData(ge!);
              },
            );
          }
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


