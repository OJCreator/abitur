import 'package:abitur/utils/extensions/date_extension.dart';
import 'package:flutter/material.dart';

import '../../services/database/settings_service.dart';

class DateInput extends StatelessWidget {

  final DateTime? dateTime;
  final Future<DateTime> firstDate;
  final Future<DateTime> lastDate;
  final Function(DateTime selected)? onSelected;

  final TextEditingController _date = TextEditingController();

  DateInput({
    required this.dateTime,
    this.onSelected,
    DateTime? firstDate,
    DateTime? lastDate,
    super.key,
  }) :
        firstDate = firstDate != null ? Future.value(firstDate) : SettingsService.firstDayOfSchool(),
        lastDate = lastDate != null ? Future.value(lastDate) : SettingsService.lastDayOfSchool();


  Future<void> _selectDate(BuildContext context) async {
    if (onSelected == null) {
      return;
    }
    DateTime firstDatePossible = await firstDate;
    DateTime lastDatePossible = await lastDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: firstDatePossible,
      lastDate: lastDatePossible,
      initialDate: dateTime,
    );
    if (picked == null) {
      return;
    }
    onSelected!(picked);
  }

  @override
  Widget build(BuildContext context) {
    _date.text = dateTime?.format() ?? "Kein Datum gewählt";
    return
      TextFormField(
        controller: _date,
        readOnly: true,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.calendar_month_outlined),
          labelText: "Datum",
          border: OutlineInputBorder(),
        ),
        enabled: onSelected != null,
        onTap: () {
          _selectDate(context);
        },
      );
  }
}
