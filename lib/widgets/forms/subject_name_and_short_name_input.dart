import 'package:abitur/widgets/forms/form_gap.dart';
import 'package:flutter/material.dart';

class SubjectNameAndShortNameInput extends StatelessWidget {

  final TextEditingController nameController;
  final TextEditingController shortNameController;

  const SubjectNameAndShortNameInput({super.key, required this.nameController, required this.shortNameController});

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
      ],
    );
  }
}
