import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {

  final String text;
  final String? action;
  final Function()? onAction;

  const InfoCard(this.text, {super.key, this.action, this.onAction});

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
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            if (action != null)
              FilledButton(
                onPressed: onAction,
                child: Text(action!),
              )
          ],
        ),
      ),
    );
  }
}
