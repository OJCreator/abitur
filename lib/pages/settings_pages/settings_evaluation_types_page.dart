import 'package:abitur/storage/services/evaluation_type_service.dart';
import 'package:flutter/material.dart';

import '../../storage/entities/evaluation_type.dart';
import '../../storage/entities/settings.dart';
import '../../storage/storage.dart';
import '../../widgets/confirm_dialog.dart';

class SettingsEvaluationTypesPage extends StatefulWidget {
  const SettingsEvaluationTypesPage({super.key});

  @override
  State<SettingsEvaluationTypesPage> createState() => _SettingsEvaluationTypesPageState();
}

class _SettingsEvaluationTypesPageState extends State<SettingsEvaluationTypesPage> {


  Settings s = Storage.loadSettings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prüfungskategorien"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (EvaluationType evaluationType in EvaluationTypeService.findAll())
              Dismissible(
                key: Key(evaluationType.id),
                direction: DismissDirection.startToEnd,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  bool? shouldDelete = await showDialog(
                    context: context,
                    builder: (context) {
                      return ConfirmDialog(
                        title: "Wirklich löschen?",
                        message: "Möchtest du die Prüfungskategorie \"${evaluationType.name}\" wirklich löschen?",
                        confirmText: "Löschen",
                        onConfirm: () {},
                      );
                    }
                  );

                  if (shouldDelete == true) {
                    setState(() {
                      EvaluationTypeService.deleteEvaluationType(evaluationType);
                    });
                  }
                  return null;
                },
                child: ListTile(
                  title: Text(evaluationType.name),
                  onTap: () async {
                    String? newName = await showDialog(context: context, builder: (_) {
                      return EvaluationTypeDialog(
                        title: "Kategorie bearbeiten",
                        initialValue: evaluationType.name,
                        confirmText: "Speichern",
                      );
                    });
                    if (newName == null) {
                      return;
                    }
                    setState(() {
                      EvaluationTypeService.editEvaluationType(evaluationType, name: newName);
                    });
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          String? newName = await showDialog(context: context, builder: (_) {
            return EvaluationTypeDialog();
          });
          if (newName == null) {
            return;
          }
          setState(() {
            EvaluationTypeService.newEvaluationType(newName, true);
          });
        },
        icon: Icon(Icons.add),
        label: Text("Neue Kategorie"),
      ),
    );
  }
}

class EvaluationTypeDialog extends StatelessWidget {

  final TextEditingController _textEditingController = TextEditingController();
  final String initialValue;
  final String title;
  final String confirmText;

  EvaluationTypeDialog({
    super.key,
    this.initialValue = "",
    this.title = "Kategorie bearbeiten",
    this.confirmText = "Erstellen",
  });

  @override
  Widget build(BuildContext context) {

    _textEditingController.text = initialValue;

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _textEditingController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("Abbrechen"),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
        FilledButton(
          child: Text(confirmText),
          onPressed: () {
            if (_textEditingController.text.isEmpty) {
              return;
            }
            Navigator.pop(context, _textEditingController.text);
          },
        ),
      ],
    );
  }
}

