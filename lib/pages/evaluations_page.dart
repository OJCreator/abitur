import 'package:abitur/pages/evaluation_edit_page.dart';
import 'package:abitur/pages/evaluation_new_page.dart';
import 'package:abitur/storage/entities/evaluation.dart';
import 'package:abitur/storage/services/api_service.dart';
import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/storage/storage.dart';
import 'package:abitur/widgets/subject_badge.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils/constants.dart';

class EvaluationsPage extends StatefulWidget {

  const EvaluationsPage({super.key});

  @override
  State<EvaluationsPage> createState() => _EvaluationsPageState();
}

class _EvaluationsPageState extends State<EvaluationsPage> {

  List<Evaluation> evaluations = [];
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
      evaluations = EvaluationService.findAll().where((e) => e.date.isAfter(DateTime.now()) || e.note == null).toList();
      evaluations.sort((a, b) => a.date.compareTo(b.date));
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
            ...evaluations.map((evaluation) {
              return EvaluationListTile(evaluation: evaluation, reloadEvaluations: searchEvaluations,);
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

  final Evaluation evaluation;
  final Function reloadEvaluations;
  final bool showDate;

  const EvaluationListTile({super.key, required this.evaluation, required this.reloadEvaluations, this.showDate = true});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(evaluation.name),
      subtitle: showDate ? Text(evaluation.date.format()) : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SubjectBadge(subject: evaluation.subject),
        ],
      ),
      leading: AspectRatio(
        aspectRatio: 1,
        child: Center(
          child: Text(
            evaluation.note?.toString() ?? "-",
            style: TextStyle(fontSize: 20,),
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

        reloadEvaluations();
      },
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

  List<Evaluation> evaluationsOnSelectedDay = [];

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
      evaluationsOnSelectedDay = EvaluationService.findAllByDay(widget.day);
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
              evaluation: e,
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

