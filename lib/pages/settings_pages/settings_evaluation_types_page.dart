import 'package:abitur/widgets/forms/assesment_type_selector.dart';
import 'package:flutter/material.dart';

import '../../services/database/evaluation_type_service.dart';
import '../../sqlite/entities/evaluation/evaluation_type.dart';
import '../../utils/enums/assessment_type.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/shimmer/shimmer_text.dart';

class SettingsEvaluationTypesPage extends StatefulWidget {
  const SettingsEvaluationTypesPage({super.key});

  @override
  State<SettingsEvaluationTypesPage> createState() => _SettingsEvaluationTypesPageState();
}

class _SettingsEvaluationTypesPageState extends State<SettingsEvaluationTypesPage> {

  Future<List<EvaluationType>> evaluationTypesFuture = Future.value([]);

  @override
  void initState() {
    _loadEvaluationTypes();
    super.initState();
  }

  void _loadEvaluationTypes() {
    setState(() {
      evaluationTypesFuture = EvaluationTypeService.findAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prüfungskategorien"),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: evaluationTypesFuture,
          builder: (context, asyncSnapshot) {

            if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < 4; i++)
                    ListTile(
                      title: ShimmerText(),
                      subtitle: ShimmerText(),
                    ),
                ],
              );
            }
            List<EvaluationType> evaluationTypes = asyncSnapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (EvaluationType evaluationType in evaluationTypes)
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
                        await EvaluationTypeService.deleteEvaluationType(evaluationType);
                        _loadEvaluationTypes();
                      }
                      return null;
                    },
                    child: ListTile(
                      title: Text(evaluationType.name),
                      subtitle: Text(evaluationType.assessmentType.name),
                      onTap: () async {
                        bool? edited = await showDialog(context: context, builder: (_) {
                          return EvaluationTypeDialog(
                            title: "Kategorie bearbeiten",
                            initialValue: evaluationType,
                            confirmText: "Speichern",
                          );
                        });
                        if (edited != true) {
                          return;
                        }
                        _loadEvaluationTypes();
                      },
                    ),
                  ),
              ],
            );
          }
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          bool? newEvaluationType = await showDialog(context: context, builder: (_) {
            return EvaluationTypeDialog();
          });
          if (newEvaluationType != true) {
            return;
          }
          _loadEvaluationTypes();
        },
        icon: Icon(Icons.add),
        label: Text("Neue Kategorie"),
      ),
    );
  }
}

class EvaluationTypeDialog extends StatefulWidget {

  final EvaluationType? initialValue;
  final String title;
  final String confirmText;

  const EvaluationTypeDialog({
    super.key,
    this.initialValue,
    this.title = "Kategorie bearbeiten",
    this.confirmText = "Erstellen",
  });

  @override
  State<EvaluationTypeDialog> createState() => _EvaluationTypeDialogState();
}

class _EvaluationTypeDialogState extends State<EvaluationTypeDialog> {

  final TextEditingController _textEditingController = TextEditingController();

  AssessmentType _chosenAssessmentType = AssessmentType.written;

  @override
  void initState() {
    _textEditingController.text = widget.initialValue?.name ?? "";
    _chosenAssessmentType = widget.initialValue?.assessmentType ?? AssessmentType.written;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
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
            AssessmentTypeSelector(
              selectedAssessmentType: _chosenAssessmentType,
              onSelected: (newAssessmentType) {
                setState(() {
                  _chosenAssessmentType = newAssessmentType;
                });
              },
            )
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("Abbrechen"),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FilledButton(
          child: Text(widget.confirmText),
          onPressed: () async {
            if (_textEditingController.text.isEmpty) {
              return;
            }
            String name = _textEditingController.text;
            if (widget.initialValue == null) {
              await EvaluationTypeService.newEvaluationType(_textEditingController.text, _chosenAssessmentType, true);
            } else {
              await EvaluationTypeService.editEvaluationType(widget.initialValue!, name: name, assessmentType: _chosenAssessmentType);
            }
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}

