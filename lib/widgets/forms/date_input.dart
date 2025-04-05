import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/utils/constants.dart';
import 'package:flutter/material.dart';

class DateInput extends StatelessWidget {

  final DateTime? dateTime;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime selected)? onSelected;

  final TextEditingController _date = TextEditingController();

  DateInput({
    required this.dateTime,
    this.onSelected,
    DateTime? firstDate,
    DateTime? lastDate,
    super.key,
  }) :
        firstDate = firstDate ?? SettingsService.firstDayOfSchool,
        lastDate = lastDate ?? SettingsService.lastDayOfSchool;


  Future<void> _selectDate(BuildContext context) async {
    if (onSelected == null) {
      return;
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
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
