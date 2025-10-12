import 'package:abitur/utils/extensions/date_extension.dart';
import 'package:flutter/material.dart';

class GraduationDateListTile extends StatelessWidget {

  final DateTime? date;
  final int weight;
  final int? note;
  final GestureTapCallback? onTap;

  const GraduationDateListTile({super.key, this.date, required this.weight, this.note, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(date?.format() ?? "Kein Datum"),
        subtitle: Text("${weight}x Gewichtung"),
        leading: AspectRatio(
          aspectRatio: 1,
          child: Center(
            child: Text(
              note?.toString() ?? "-",
              style: TextStyle(fontSize: 20,),
            ),
          ),
        ),
        onTap: onTap
    );
  }
}