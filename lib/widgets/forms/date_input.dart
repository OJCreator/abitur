import 'package:abitur/utils/constants.dart';
import 'package:flutter/material.dart';

import '../../storage/storage.dart';

class DateInput extends StatelessWidget {

  final DateTime dateTime;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime selected) onSelected;

  final TextEditingController _date = TextEditingController();

  DateInput({
    required this.dateTime,
    required this.firstDate,
    required this.lastDate,
    required this.onSelected,
    super.key,
  });


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: dateTime,
    );
    if (picked == null) {
      return;
    }
    onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    _date.text = dateTime.format();
    return
      TextFormField(
        controller: _date,
        readOnly: true,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.calendar_month_outlined),
          labelText: "Datum",
          border: OutlineInputBorder(),
        ),
        onTap: () {
          _selectDate(context);
        },
      );
  }
}
