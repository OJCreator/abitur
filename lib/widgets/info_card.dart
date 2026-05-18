import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {

  final String text;
  final InfoCardType type;
  final String? action;
  final Function()? onAction;

  const InfoCard(this.text, {super.key, this.type = InfoCardType.info, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: type == InfoCardType.info ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              type == InfoCardType.info ? Icons.info : Icons.warning,
              color: type == InfoCardType.info ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onErrorContainer,),
            const SizedBox(width: 8,),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: type == InfoCardType.info ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            if (action != null)
              FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(
                    type == InfoCardType.info
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                  foregroundColor: WidgetStatePropertyAll<Color>(
                    type == InfoCardType.info
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onError,
                  ),
                ),
                onPressed: onAction,
                child: Text(action!),
              ),
          ],
        ),
      ),
    );
  }
}

enum InfoCardType {
  info, warning;
}
