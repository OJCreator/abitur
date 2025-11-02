import 'package:abitur/utils/constants.dart';
import 'package:abitur/utils/enums/subject_type.dart';
import 'package:abitur/widgets/forms/form_gap.dart';
import 'package:flutter/material.dart';

import '../color_dialog.dart';

class SubjectNameAndColorInput extends StatelessWidget {

  final TextEditingController nameController;
  final TextEditingController shortNameController;
  final Color color;
  final Function(SubjectTemplate subjectTemplate) onSelectedSubjectTemplate;
  final Function(Color newColor) onSelectedColor;

  const SubjectNameAndColorInput({
    super.key,
    required this.nameController,
    required this.shortNameController,
    required this.color,
    required this.onSelectedSubjectTemplate,
    required this.onSelectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 2,
          child: Autocomplete<SubjectTemplate>(
            displayStringForOption: (o) => o.name,
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<SubjectTemplate>.empty();
              }
              final currentOption = SubjectTemplate(textEditingValue.text, "", SubjectType.wahlfach);
              return [currentOption, ...subjectsBayern].where((option) => option.name
                  .toLowerCase()
                  .startsWith(textEditingValue.text.toLowerCase()));
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: options.map((option) {
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(option.name, style: const TextStyle(fontSize: 16)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
              return TextFormField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: "Name",
                  helperText: "Vollständiger Name",
                  border: OutlineInputBorder(),
                ),
                validator: (input) {
                  if (input == null || input.isEmpty) {
                    return "Erforderlich";
                  }
                  return null;
                },
              );
            },
            onSelected: (SubjectTemplate selection) {
              debugPrint('Ausgewählt: $selection');
              onSelectedSubjectTemplate(selection);
            },
          ),
        ),

        FormGap(),

        Flexible(
          flex: 1,
          child:
          TextFormField(
            controller: shortNameController,
            validator: (input) {
              if (input == null || input.isEmpty) {
                return "Erforderlich";
              } else if (input.length > 3) {
                return "Max. 3 Buchstaben";
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: "Kürzel",
              helperText: "Max. 3 Buchstaben",
              border: OutlineInputBorder(),
            ),
          ),
        ),

        FormGap(),

        Expanded(
          flex: 1,
          child: InkWell(
            onTap: () async {
              Color? newColor = await showDialog(
                context: context,
                builder: (context) {
                  return ColorDialog(initialColor: color,);
                },
              );
              if (newColor == null) {
                return;
              }
              onSelectedColor(newColor);
            },
            child: Container(
              height: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: color,
              ),
              child: Center(
                child: Icon(
                  Icons.color_lens,
                  color: getContrastingTextColor(color),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}