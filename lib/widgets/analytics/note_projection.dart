import 'package:flutter/material.dart';

class NoteProjection extends StatelessWidget {

  final bool background;
  final String note;
  final bool bold;

  const NoteProjection({super.key, required this.background, required this.note, required this.bold});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 3,),
          decoration: BoxDecoration(
            color: background ? Theme.of(context).colorScheme.secondaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            note,
            style: bold ? TextStyle(
              fontWeight: FontWeight.bold,
            ) : TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
