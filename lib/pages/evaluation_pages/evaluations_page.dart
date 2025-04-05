import 'package:abitur/pages/evaluation_pages/evaluation_edit_page.dart';
import 'package:abitur/pages/evaluation_pages/evaluation_new_page.dart';
import 'package:abitur/pages/subject_pages/subject_page.dart';
import 'package:abitur/storage/entities/evaluation.dart';
import 'package:abitur/storage/entities/evaluation_date.dart';
import 'package:abitur/storage/services/api_service.dart';
import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/storage/storage.dart';
import 'package:abitur/widgets/evaluation_date_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../storage/services/evaluation_date_service.dart';
import '../../utils/constants.dart';

class EvaluationsPage extends StatefulWidget {

  const EvaluationsPage({super.key});

  @override
  State<EvaluationsPage> createState() => _EvaluationsPageState();
}

class _EvaluationsPageState extends State<EvaluationsPage> {

  List<EvaluationDate> evaluationDates = [];
  List<Holiday> holidays = [];
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    searchEvaluations();
    DateTime now = DateTime.now();
    loadHolidays(now);
    super.initState();
  }

  Future<void> loadHolidays(DateTime date) async {
    focusedDay = date;
    holidays = await ApiService.loadHolidays(date.year, date.month);
    setState(() { });
  }

  void searchEvaluations() {
    setState(() {
      evaluationDates = EvaluationDateService.findAll().where((e) => e.date != null && (e.date!.isAfter(DateTime.now()) || (e.note == null && e.weight > 0))).toList();
      evaluationDates.sort((a, b) => a.compareTo(b));
    });
  }

  Future<void> newEvaluation() async {
    if (SubjectService.hasSubjects()) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return EvaluationNewPage();
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
            suggestionsBuilder: (context, controller) {
              String text = controller.text;
              List<EvaluationDate> results = EvaluationDateService.findAllByQuery(text);

              return results.map((evaluationDate) {
                return EvaluationListTile(
                  evaluationDate: evaluationDate,
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
              onPageChanged: loadHolidays,
              holidayPredicate: (date) {
                return isHoliday(date) != null;
              },
              calendarStyle: CalendarStyle(
                holidayTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary
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
              locale: "de_DE",
              focusedDay: focusedDay,
              firstDay: DateTime(Storage.loadSettings().graduationYear.year-2, 9, 1),
              lastDay: DateTime(Storage.loadSettings().graduationYear.year, 8, 1),
              headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true,),
              onDaySelected: _onDaySelected,
              startingDayOfWeek: StartingDayOfWeek.monday,
              eventLoader: (day) => EvaluationService.findAllByDay(day),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: events.maxSize(5).map((event) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 1.5),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (event as Evaluation).subject.color,
                            ),
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
            ...evaluationDates.map((evaluationDate) {
              return EvaluationListTile(evaluationDate: evaluationDate, reloadEvaluations: searchEvaluations,);
            }),
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
      return possibleHolidays.first.name;
    }
    if (date.weekday > 5) {
      return "Wochenende";
    }
    return null;
  }

  Future<void> _onDaySelected(DateTime selected, DateTime focused) async {
    String? holiday = isHoliday(selected);
    await showDialog(
      context: context,
      builder: (context) {
        if (holiday == null) {
          return EvaluationDayDialog(day: selected, reloadEvaluations: searchEvaluations,);
        }
        return HolidayDayDialog(day: selected, holiday: holiday);
      },
    );
  }
}

class EvaluationListTile extends StatelessWidget {

  final EvaluationDate evaluationDate;
  final Function reloadEvaluations;
  final bool showDate;
  final bool enabled;

  const EvaluationListTile({super.key, required this.evaluationDate, required this.reloadEvaluations, this.showDate = true, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return EvaluationDateListTile(
      evaluationDate: evaluationDate,
      showDate: showDate,
      onTap: enabled ? () async { // TODO Enabled umfunktionieren: -> Link zu Fach??
        Evaluation e = evaluationDate.evaluation;
        if (e.subject.graduationEvaluation == e) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return SubjectPage(subject: e.subject, openGraduationPage: true,);
            }),
          );
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return EvaluationEditPage(evaluation: evaluationDate
                  .evaluation); // TODO Wohin soll man hier gelangen? Was soll man bearbeiten?
            }),
          );
        }

        reloadEvaluations();
      } : null,
    );
  }
}

class EvaluationDayDialog extends StatefulWidget {

  final DateTime day;
  final Function reloadEvaluations;
  const EvaluationDayDialog({super.key, required this.day, required this.reloadEvaluations});

  @override
  State<EvaluationDayDialog> createState() => _EvaluationDayDialogState();
}

class _EvaluationDayDialogState extends State<EvaluationDayDialog> {

  List<EvaluationDate> evaluationsOnSelectedDay = [];

  @override
  void initState() {
    _reloadEvaluations();
    super.initState();
  }


  Future<void> _newEvaluation(DateTime selectedDate) async {
    if (SubjectService.hasSubjects()) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return EvaluationNewPage(initialDateTime: selectedDate,);
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
      content: evaluationsOnSelectedDay.isNotEmpty ? SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: evaluationsOnSelectedDay.map((e) {
            return EvaluationListTile(
              evaluationDate: e,
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

