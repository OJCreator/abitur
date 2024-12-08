import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorDialog extends StatefulWidget {

  final Color initialColor;
  final String? title;

  const ColorDialog({super.key, required this.initialColor, this.title});

  @override
  State<ColorDialog> createState() => _ColorDialogState();
}

class _ColorDialogState extends State<ColorDialog> {

  late Color pickerColor;

  @override
  void initState() {
    pickerColor = widget.initialColor;
    super.initState();
  }

  void changeColor(Color color) {
    setState(() {
      pickerColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title ?? "Farbe wählen"),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: pickerColor,
          onColorChanged: changeColor,

          enableAlpha: false,
          hexInputBar: true,

          paletteType: PaletteType.hsv,
        ),
      ),
      actions: <Widget>[
        FilledButton(
          child: const Text("Auswählen"),
          onPressed: () {
            Navigator.pop(context, pickerColor);
          },
        ),
      ],
    );
  }
}
