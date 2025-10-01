import 'package:flutter/material.dart';

class EnumRadioSheet<T extends Enum> extends StatelessWidget {

  final List<T> values;
  final T groupValue;
  final ValueChanged<T> onSelected;
  final String Function(T) displayName;

  const EnumRadioSheet({super.key, required this.values, required this.groupValue, required this.onSelected, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        snap: true,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: RadioGroup<T>(
              onChanged: (newValue) {
                if (newValue == null) return;
                onSelected(newValue);
                Navigator.of(context).pop();
              },
              groupValue: groupValue,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: values.map((option) =>
                    RadioListTile(
                      value: option,
                      title: Text(displayName(option)),
                      selected: true,
                    )
                ).toList(),
              ),
            ),
          );
        }
    );
  }
}
