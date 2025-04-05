import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {

  final String title;
  final String message;
  final String confirmText;
  final Function onConfirm;
  final String breakText;

  const ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.onConfirm,
    this.breakText = "Abbrechen",
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () async {
            onConfirm();
            Navigator.pop(context, true);
          },
          child: Text(confirmText),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Text(breakText),
        ),
      ],
    );
  }
}
