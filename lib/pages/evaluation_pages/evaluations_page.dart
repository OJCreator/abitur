import 'package:abitur/pages/evaluation_pages/evaluation_input_page.dart';
import 'package:abitur/pages/subject_pages/subject_page.dart';
import 'package:abitur/services/database/settings_service.dart';
import 'package:abitur/services/api_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:abitur/utils/extensions/date_extension.dart';
import 'package:abitur/utils/extensions/lists/list_extension.dart';
import 'package:abitur/widgets/evaluation_date_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../services/database/evaluation_date_service.dart';
import '../../services/database/evaluation_service.dart';
import '../../services/database/subject_service.dart';
import '../../sqlite/entities/evaluation/evaluation.dart';
import '../../sqlite/entities/evaluation/evaluation_date.dart';
import '../../sqlite/entities/settings.dart';
import '../../sqlite/entities/subject.dart';

class EvaluationsPage extends StatefulWidget {

  const EvaluationsPage({super.key});

  @override
  State<EvaluationsPage> createState() => _EvaluationsPageState();
}

class _EvaluationsPageState extends State<EvaluationsPage> {

  late Future<Map<String, Evaluation>> evaluationsFuture;
  late Future<Map<String, Subject>> subjectsFuture;
  late Future<List<EvaluationDate>> evaluationDatesFuture;
  List<Holiday> holidays = [];
  DateTime firstDay = DateTime.now().copyWith(day: 0);
  DateTime lastDay = DateTime.now().copyWith(month: DateTime.now().month+1, day: 0).add(Duration(days: -1));
  DateTime focusedDay = DateTime.now();
  late Map<DateTime, List<Evaluation>> evaluationMapOfCurrentMonth = {};

  @override
  void initState() {
    _loadSettings();
    searchEvaluations();
    setVisibleMonth(DateTime.now());
    super.initState();
  }

  Future<void> setVisibleMonth(DateTime date) async {
    setState(() {
      focusedDay = date;
    });

    final first = DateTime(date.year, date.month, 1);
    final last = DateTime(date.year, date.month + 1, 0);
    evaluationMapOfCurrentMonth = await EvaluationService.findAllBetweenDays(first, last);
    setState(() {});

    holidays = await ApiService.loadHolidays(date.year);
    if (!mounted) return;
    setState(() { });
  }

  void searchEvaluations() {
    setState(() {
      evaluationsFuture = EvaluationService.findAllAsMap();
      subjectsFuture = SubjectService.findAllGradableAsMap();
      evaluationDatesFuture = EvaluationDateService.findAllFutureOrUngraded(); // ursprünglich: findAllFutureOrUngradedEvaluationDatesIsolated();
    });
  }

  Future<void> newEvaluation() async {
    if (await SubjectService.hasSubjects()) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return EvaluationInputPage();
        }),
      );
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Du musst erst ein Fach anlegen, um Prüfungen eintragen zu können!"),
          duration: Duration(seconds: 2),
        ),
      );
    }
    searchEvaluations();
  }

  Future<void> _loadSettings() async {
    Settings s = await SettingsService.loadSettings();
    setState(() {
      firstDay = DateTime(s.graduationYear.year-2, 9, 1);
      lastDay = DateTime(s.graduationYear.year, 8, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prüfungen"),
        actions: [
          SearchAnchor(
            builder: (BuildContext context, SearchController controller) {
              return IconButton(onPressed: () {
                controller.openView();
              }, icon: Icon(Icons.search));
            },
            suggestionsBuilder: (context, controller) async {
              String text = controller.text;
              List<EvaluationDate> results = await EvaluationDateService.findAllByQuery(text);
              Map<String, Subject> subjects = await subjectsFuture;
              Map<String, Evaluation> evaluations = await evaluationsFuture;

              return results.map((evaluationDate) {
              Evaluation? evaluation = evaluations[evaluationDate.evaluationId];
                return EvaluationListTile(
                  evaluationDate: evaluationDate,
                  evaluation: evaluations[evaluationDate.evaluationId],
                  subject: subjects[evaluation?.subjectId],
                  enabled: false,
                  reloadEvaluations: () {},
                );
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Kalender
            TableCalendar(
              onPageChanged: setVisibleMonth,
              focusedDay: focusedDay,
              locale: "de_DE",
              firstDay: firstDay,
              lastDay: lastDay,
              holidayPredicate: (date) {
                return isHoliday(date) != null;
              },
              calendarStyle: CalendarStyle(
                holidayTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
                holidayDecoration: BoxDecoration(
                  border: Border.fromBorderSide(
                    BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.4),
                  ),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true,),
              onDaySelected: _onDaySelected,
              startingDayOfWeek: StartingDayOfWeek.monday,
              eventLoader: (day) => evaluationMapOfCurrentMonth[DateTime(day.year, day.month, day.day)] ?? [],
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: events.maxSize(5).map((event) {
                          return FutureBuilder(
                            future: subjectsFuture,
                            builder: (context, asyncSnapshot) {
                              if (!asyncSnapshot.hasData) {
                                return EvaluationIndicatorDot(color: shimmerColor);
                              }
                              return EvaluationIndicatorDot(
                                color: asyncSnapshot.data![(event as Evaluation).subjectId]?.color ?? shimmerColor,
                              );
                            }
                          );
                        }).toList(),
                      ),
                    );
                  }
                  return SizedBox();
                }
              ),
            ),
            // Prüfungen
            FutureBuilder(
              future: evaluationDatesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Column(
                    children: [
                      for (int i = 0; i < 5; i++)
                        EvaluationDateListTile.shimmer(),
                    ],
                  );
                } else {
                  return Column(
                    children: snapshot.data!.map((evaluationDate) {
                      return FutureBuilder(
                        future: Future.wait([evaluationsFuture, subjectsFuture]),
                        builder: (context, asyncSnapshot) {
                          if (!asyncSnapshot.hasData) return EvaluationDateListTile.shimmer();
                          Evaluation evaluation = (asyncSnapshot.data![0] as Map<String, Evaluation>)[evaluationDate.evaluationId]!;
                          Subject subject = (asyncSnapshot.data![1] as Map<String, Subject>)[evaluation.subjectId]!;
                          return EvaluationListTile(
                            evaluationDate: evaluationDate,
                            reloadEvaluations: searchEvaluations,
                            evaluation: evaluation,
                            subject: subject,
                          );
                        }
                      );
                    }).toList(),
                  );
                }
              },
            ),
            SizedBox(height: 80,), // damit der FloatingActionButton nichts verdeckt
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: newEvaluation,
        child: Icon(Icons.add),
      ),
    );
  }

  String? isHoliday(DateTime date) {
    List<Holiday> possibleHolidays = holidays.where((holiday) => holiday.begin.isBefore(date.add(Duration(days: 1))) && holiday.end.isAfter(date.add(Duration(days: -1)))).toList();
    if (possibleHolidays.isNotEmpty) {
      return "Ferien";
    }
    if (date.weekday > 5) {
      return "Wochenende";
    }
    return null;
  }

  Future<void> _onDaySelected(DateTime selected, DateTime focused) async {
    String? holiday = isHoliday(selected);
    final evaluations = await evaluationsFuture;
    final subjects = await subjectsFuture;
    await showDialog(
      context: context,
      builder: (context) {
        if (holiday == null) {
          return EvaluationDayDialog(
            day: selected,
            reloadEvaluations: searchEvaluations,
            evaluations: evaluations,
            subjects: subjects,
          );
        }
        return HolidayDayDialog(day: selected, holiday: holiday);
      },
    );
  }
}


class EvaluationListTile extends StatelessWidget {

  final EvaluationDate evaluationDate;
  final Evaluation? evaluation;
  final Subject? subject;
  final Function reloadEvaluations;
  final bool showDate;
  final bool enabled;

  const EvaluationListTile({super.key, required this.evaluationDate, required this.evaluation, required this.subject, required this.reloadEvaluations, this.showDate = true, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return EvaluationDateListTile(
      evaluationDate: evaluationDate,
      evaluation: evaluation,
      subject: subject,
      showDate: showDate,
      onTap: !enabled || subject == null || evaluation == null ? null : () async { // TODO Enabled umfunktionieren: -> Link zu Fach??
        if (subject!.graduationEvaluationId == evaluation!.id) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return SubjectPage(subjectId: subject!.id, openGraduationPage: true,);
            }),
          );
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return EvaluationInputPage(evaluation: evaluation);
            }),
          );
        }

        reloadEvaluations();
      },
    );
  }
}


class EvaluationDayDialog extends StatefulWidget {

  final DateTime day;
  final Function reloadEvaluations;
  final Map<String, Evaluation> evaluations;
  final Map<String, Subject> subjects;
  const EvaluationDayDialog({super.key, required this.day, required this.reloadEvaluations, required this.evaluations, required this.subjects});

  @override
  State<EvaluationDayDialog> createState() => _EvaluationDayDialogState();
}

class _EvaluationDayDialogState extends State<EvaluationDayDialog> {

  Future<List<EvaluationDate>> evaluationsOnSelectedDay = Future.value([]);

  @override
  void initState() {
    _reloadEvaluations();
    super.initState();
  }


  Future<void> _newEvaluation(DateTime selectedDate) async {
    if (await SubjectService.hasSubjects()) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return EvaluationInputPage(
            dateTime: selectedDate,
          );
        }),
      );
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Du musst erst ein Fach anlegen, um Prüfungen eintragen zu können!"),
          duration: Duration(seconds: 2),
        ),
      );
    }
    _reloadEvaluations();
  }

  void _reloadEvaluations() {
    setState(() {
      evaluationsOnSelectedDay = EvaluationDateService.findAllByDay(widget.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.day.format()),
      content: FutureBuilder(
        future: evaluationsOnSelectedDay,
        builder: (context, asyncSnapshot) {
          if (!asyncSnapshot.hasData) {
            return Column(
              children: [
                EvaluationDateListTile.shimmer(),
              ],
            );
          }
          return asyncSnapshot.data!.isNotEmpty ? SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: asyncSnapshot.data!.map((e) {
                return EvaluationListTile(
                  evaluationDate: e,
                  evaluation: widget.evaluations[e.evaluationId],
                  subject: widget.subjects[widget.evaluations[e.evaluationId]?.subjectId],
                  showDate: false,
                  reloadEvaluations: () {
                    _reloadEvaluations();
                    widget.reloadEvaluations();
                  },
                );
              }).toList(),
            ),
          ) : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
            child: Text("Heute gibt es keine Prüfungen."),
          );
        }
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      actions: [
        TextButton(
          onPressed: () async {
            await _newEvaluation(widget.day);
            _reloadEvaluations();
            widget.reloadEvaluations();
          },
          child: Text("Neue Prüfung"),
        )
      ],
    );
  }
}

class HolidayDayDialog extends StatelessWidget {

  final DateTime day;
  final String holiday;

  const HolidayDayDialog({super.key, required this.day, required this.holiday});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(day.format()),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
        child: Text(holiday),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cool"),
        )
      ],
    );
  }
}

class EvaluationIndicatorDot extends StatelessWidget {

  final Color color;

  const EvaluationIndicatorDot({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1.5),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
