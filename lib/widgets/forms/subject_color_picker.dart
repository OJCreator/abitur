import 'package:abitur/utils/constants.dart';
import 'package:abitur/widgets/color_dialog.dart';
import 'package:abitur/widgets/forms/form_gap.dart';
import 'package:flutter/material.dart';

class SubjectColorPicker extends StatefulWidget {

  final Color currentColor;
  final Function(Color newColor) onSelected;

  const SubjectColorPicker({super.key, required this.currentColor, required this.onSelected});

  @override
  State<SubjectColorPicker> createState() => _SubjectColorPickerState();
}

class _SubjectColorPickerState extends State<SubjectColorPicker> {
  final TextEditingController _colorController = TextEditingController();

  @override
  void initState() {
    _colorController.text = widget.currentColor.toHexString(includeHashSign: true, enableAlpha: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: widget.currentColor,
          ),
          child: GestureDetector(
            onTap: () async {
              Color? newColor = await showDialog(
                context: context,
                builder: (context) {
                  return ColorDialog(initialColor: widget.currentColor,);
                },
              );
              if (newColor == null) {
                return;
              }
              setState(() {
                _colorController.text = newColor.toHexString(includeHashSign: true, enableAlpha: false);
              });
              widget.onSelected(newColor);
            },
          ),
        ),
        FormGap(),
        Expanded(
          child: TextFormField(
            controller: _colorController,
            decoration: InputDecoration(
              labelText: "Farbe",
              enabled: false,
              border: OutlineInputBorder(),
            ),
          ),
        )
      ],
    );
  }
}
