import 'package:flutter/material.dart';

class InvalidFormException implements Exception {
  final String message;

  InvalidFormException(this.message);

  @override
  String toString() => 'InvalidFormException: $message';
}

Future<bool> trySubmittingForm(BuildContext context, Function callback) async {
  try {
    await callback();
    return true;
  } on InvalidFormException catch (e) {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Es gab einen Fehler."),
          content: Text(e.message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Zurück"),
            ),
          ],
        );
      },
    );
    return false;
  }
}