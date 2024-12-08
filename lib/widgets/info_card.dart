import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {

  final String text;

  const InfoCard(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(Icons.info, color: Theme.of(context).colorScheme.onPrimaryContainer,),
            const SizedBox(width: 8,),
            Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
