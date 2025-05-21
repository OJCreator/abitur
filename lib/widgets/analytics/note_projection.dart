import 'package:flutter/material.dart';

class NoteProjection extends StatelessWidget {

  final bool background;
  final String note;
  final bool bold;
  final int weight;

  const NoteProjection({super.key, required this.background, required this.note, required this.bold, required this.weight});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
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
            if (weight > 1)
              Text("x$weight")
          ],
        ),
      ),
    );
  }
}
