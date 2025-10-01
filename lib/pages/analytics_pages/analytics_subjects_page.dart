import 'dart:math';

import 'package:abitur/utils/constants.dart';
import 'package:abitur/widgets/enum_radio_sheet.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../storage/entities/subject.dart';
import '../../storage/services/subject_service.dart';
import '../../utils/pair.dart';

class AnalyticsSubjectsPage extends StatefulWidget {
  const AnalyticsSubjectsPage({super.key});

  @override
  State<AnalyticsSubjectsPage> createState() => _AnalyticsSubjectsPageState();
}

class _AnalyticsSubjectsPageState extends State<AnalyticsSubjectsPage> {

  late final List<Subject> subjects;
  late List<Pair<Subject, double>> subjectNotes;

  TermOption termOption = TermOption.all;
  SortOption sortOption = SortOption.alphabet;

  @override
  void initState() {
    subjects = SubjectService.findAllGradable();
    subjectNotes = subjects.map((s) => Pair(s, SubjectService.getAverage(s) ?? 0)).toList();
    subjectNotes.sort(sortOption.sortAlgorithm);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fächerübersicht"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                FilterChip(
                  label: Text(termOption.displayNameShort),
                  onSelected: (s) {
                    changeTermOption();
                  },
                  selected: true,
                ),
                FilterChip(
                  label: Text(sortOption.displayNameShort),
                  onSelected: (s) {
                    changeSortOption();
                  },
                  selected: true,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnalyticsSubjectsGraph(
                subjectNotes: subjectNotes,
              ),
            ),
            for (Pair<Subject, double> s in subjectNotes)
              ListTile(
                leading: Badge(
                  backgroundColor: s.first.color,
                  label: Text(s.second.toString()),
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  padding: const EdgeInsets.all(4),
                ),
                title: Text(s.first.name),
              )
          ],
        ),
      ),
    );
  }

  void changeTermOption() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,

      builder: (context) {
        return EnumRadioSheet(
          values: TermOption.values,
          groupValue: termOption,
          onSelected: (value) {
            setState(() {
              termOption = value;
              subjectNotes = subjects.map((s) => Pair(s, termOption.term == null ? SubjectService.getAverage(s) ?? 0 : roundNote(SubjectService.getAverageByTerm(s, termOption.term!) ?? 0)!.toDouble())).toList();
              subjectNotes.sort(sortOption.sortAlgorithm);
            });
          },
          displayName: (option) => option.displayName,
        );
      },
    );
  }
  void changeSortOption() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,

      builder: (context) {
        return EnumRadioSheet(
          values: SortOption.values,
          groupValue: sortOption,
          onSelected: (value) {
            setState(() {
              sortOption = value;
              subjectNotes = subjectNotes.sorted(sortOption.sortAlgorithm);
            });
          },
          displayName: (option) => option.displayName,
        );
      },
    );
  }
}

enum TermOption {
  all("Gesamt", "Gesamt", null),
  one("1. Halbjahr", "HJ 1", 0),
  two("2. Halbjahr", "HJ 2", 1),
  three("3. Halbjahr", "HJ 3", 2),
  four("4. Halbjahr", "HJ 4", 3);

  final String displayName;
  final String displayNameShort;
  final int? term;

  const TermOption(this.displayName, this.displayNameShort, this.term);
}

enum SortOption {
  alphabet("Alphabetisch sortieren", "Alphabetisch"),
  note("Nach Durchschnitt sortieren", "Durchschnitt"),
  color("Nach Farben sortieren", "Farbe");

  final String displayName;
  final String displayNameShort;

  const SortOption(this.displayName, this.displayNameShort);

  Comparator<Pair<Subject, double>> get sortAlgorithm {
    switch (this) {
      case SortOption.alphabet:
        return (a, b) => a.first.name.compareTo(b.first.name);
      case SortOption.note:
        return (a, b) => b.second.compareTo(a.second);
      case SortOption.color:
        return (a, b) => HSLColor.fromColor(a.first.color).hue.compareTo(HSLColor.fromColor(b.first.color).hue);
    }
  }
}

class AnalyticsSubjectsGraph extends StatefulWidget {

  final List<Pair<Subject, double>> subjectNotes;

  const AnalyticsSubjectsGraph({super.key, required this.subjectNotes});

  @override
  State<AnalyticsSubjectsGraph> createState() => _AnalyticsSubjectsGraphState();
}

class _AnalyticsSubjectsGraphState extends State<AnalyticsSubjectsGraph> {

  late List<BarChartGroupData> data;

  @override
  void initState() {
    super.initState();
    _updateData();
  }

  @override
  void didUpdateWidget(covariant AnalyticsSubjectsGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subjectNotes != widget.subjectNotes) {
      _updateData();
    }
  }

  void _updateData() {
    setState(() {
      data = widget.subjectNotes.asMap().mapToIterable((index, pair) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: pair.second,
              color: pair.first.color,
              width: 12,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          maxY: 15,
          minY: 0,
          barGroups: data,
          barTouchData: BarTouchData(enabled: false),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withAlpha(77),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.withAlpha(77),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: bottomTitles,
                reservedSize: 42,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: leftTitles,
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget leftTitles(double value, TitleMeta meta) {
    if (value.toInt() % 3 != 0) {
      return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(
        value.toInt().toString(),
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final List<String> titles = widget.subjectNotes.map((e) {
      return e.first.shortName;
    }).toList();

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      child: Transform.rotate(
        angle: 45 * (pi/180),
        child: Text(
          titles[value.toInt()],
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
    );
  }
}
