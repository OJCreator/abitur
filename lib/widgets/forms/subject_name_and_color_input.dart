import 'package:abitur/utils/constants.dart';
import 'package:abitur/widgets/forms/form_gap.dart';
import 'package:flutter/material.dart';

import '../color_dialog.dart';

class SubjectNameAndColorInput extends StatelessWidget {

  final TextEditingController nameController;
  final TextEditingController shortNameController;
  final Color color;
  final Function(Color newColor) onSelectedColor;

  const SubjectNameAndColorInput({super.key, required this.nameController, required this.shortNameController, required this.color, required this.onSelectedColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 2,
          child: TextFormField(
            controller: nameController,
            validator: (input) {
              if (input == null || input.isEmpty) {
                return "Erforderlich";
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: "Name",
              helperText: "Vollständiger Name",
              border: OutlineInputBorder(),
            ),
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