import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/brightness_notifier.dart';
import '../confirm_dialog.dart';

class FormPage extends StatelessWidget {

  final Key formKey;
  final String appBarTitle;
  final Color colorSeed;
  final bool Function() hasUnsavedChanges;
  final String saveTitle;
  final Future<void> Function() save;
  final String deleteTitle;
  final String deleteMessage;
  final String deleteAction;
  final Function()? delete;
  final List<Widget> children;

  const FormPage({
    super.key,
    required this.formKey,
    required this.appBarTitle,
    required this.colorSeed,
    required this.hasUnsavedChanges,
    this.saveTitle = "Speichern",
    required this.save,
    this.delete,
    this.deleteTitle = "Wirklich löschen?",
    this.deleteMessage = "Du kannst diese Aktion nicht rückgängig machen.",
    this.deleteAction = "Löschen",
    required this.children,
  });

  @override
  Widget build(BuildContext context) {

    Brightness b = Provider.of<BrightnessNotifier>(context).currentBrightness;
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: colorSeed, brightness: b,),
        useMaterial3: true,
        brightness: b,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (!hasUnsavedChanges()) {
            Navigator.of(context).pop();
            return;
          }

          final shouldLeave = await shouldLeaveDespiteUnsavedChanges(context);
          if (shouldLeave) {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            actions: [
              if (delete != null)
                IconButton(
                  onPressed: () async {
                    bool confirmed = await showDialog(
                      context: context,
                      builder: (context) {
                        return ConfirmDialog(
                          title: deleteTitle,
                          message: deleteMessage,
                          confirmText: deleteAction,
                          onConfirm: () async {
                            await delete!();
                          },
                        );
                      },
                    );
                    if (confirmed) {
                      Navigator.pop(context);
                    }
                  },
                  icon: Icon(Icons.delete),
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Form(
                key: formKey,
                child: Column(
                  children: children,
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: save,
            label: Text(saveTitle),
            icon: Icon(Icons.save),
          ),
        ),
      ),
    );
  }



  Future<bool> shouldLeaveDespiteUnsavedChanges(BuildContext context) async {
    bool? userAware = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Du hast ungespeicherte Änderungen."),
          content: Text("Wenn du jetzt gehst, werden sie nicht gespeichert."),
          actions: [
            FilledButton.tonal(
              onPressed: () async {
                await save();
                Navigator.of(context).pop(true);
              },
              child: Text("Änderungen speichern"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Änderungen verwerfen"),
            ),
          ],
        );
      },
    );
    return userAware == true;
  }
}
