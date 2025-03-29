import 'package:abitur/storage/entities/performance.dart';
import 'package:flutter/material.dart';

class PerformanceForm extends StatefulWidget {
  final List<Performance> performances;
  final Function(List<Performance>) onChanged;

  const PerformanceForm({
    super.key,
    required this.performances,
    required this.onChanged,
  });

  @override
  State<PerformanceForm> createState() => _PerformanceFormState();
}

class _PerformanceFormState extends State<PerformanceForm> {
  late List<TextEditingController> _textControllers;

  @override
  void initState() {
    super.initState();
    // TextEditingController initialisieren
    _textControllers = widget.performances
        .map((p) => TextEditingController(text: p.name))
        .toList();
  }

  @override
  void dispose() {
    // Ressourcen aufräumen
    for (final controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateWeighting(int index) {
    setState(() {

      double totalPerformanceWeight = widget.performances.map((p) => p.weighting).fold(0, (sum, value) => sum + value);
      double overhang = totalPerformanceWeight - 1;

      int nextIndex = (index + 1) % widget.performances.length;

      while (overhang != 0) {
        double adjustment = overhang > 0
            ? overhang.clamp(0, widget.performances[nextIndex].weighting)
            : overhang.clamp(-1 + widget.performances[nextIndex].weighting, 0);

        widget.performances[nextIndex].weighting -= adjustment;
        overhang -= adjustment;

        nextIndex = (nextIndex + 1) % widget.performances.length;
      }
    });

    widget.onChanged(widget.performances);
  }

  void _addPerformance() {
    if (widget.performances.length > 2) {
      return;
    }
    setState(() {
      final newPerformance = Performance(name: "Leistung", weighting: 0);
      widget.performances.add(newPerformance);
      _textControllers.add(TextEditingController(text: newPerformance.name));
    });

    widget.onChanged(widget.performances);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < widget.performances.length; i++)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        flex: 15,
                        child: TextFormField(
                          controller: _textControllers[i],
                          validator: (input) {
                            if (input == null || input.isEmpty) {
                              return "Erforderlich";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: "Name der Leistung",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              widget.performances[i].name = value;
                            });
                            widget.onChanged(widget.performances);
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (widget.performances.length == 1) {
                            return;
                          }
                          widget.performances.removeAt(i);
                          _textControllers.removeAt(i);
                          _updateWeighting(i-1);
                        },
                        icon: Icon(Icons.remove_circle),
                      ),
                    ],
                  ),
                  Slider(
                    value: widget.performances[i].weighting,
                    min: 0,
                    max: 1,
                    divisions: 6,
                    onChanged: (value) {
                      widget.performances[i].weighting = value;
                      _updateWeighting(i);
                    },
                    year2023: false,
                  ),
                ],
              ),
            ),
          ),
        if (widget.performances.length < 3)
          FilledButton(
            onPressed: _addPerformance,
            child: const Text("Neue Leistung"),
          ),
      ],
    );
  }
}
