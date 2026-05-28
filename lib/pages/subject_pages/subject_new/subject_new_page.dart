import 'package:abitur/services/database/subject_service.dart';
import 'package:abitur/utils/enums/subject_niveau.dart';
import 'package:abitur/utils/enums/subject_type.dart';
import 'package:abitur/utils/uuid.dart';
import 'package:abitur/widgets/forms/form_page.dart';
import 'package:abitur/widgets/forms/subject_name_and_color_input.dart';
import 'package:abitur/widgets/forms/subject_niveau_dropdown.dart';
import 'package:flutter/material.dart';

import '../../../sqlite/entities/performance.dart';
import '../../../widgets/forms/form_gap.dart';
import '../../../widgets/forms/performance_form.dart';
import '../../../widgets/forms/terms_multiple_choice.dart';

class SubjectNewPage extends StatefulWidget {
  const SubjectNewPage({super.key});

  @override
  State<SubjectNewPage> createState() => _SubjectNewPageState();
}

class _SubjectNewPageState extends State<SubjectNewPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<SubjectTemplate> _allSubjects = subjectsBayern..sort();

  Set<String> _disabledSubjects = {};

  String _searchText = "";
  bool _showCreateTileAtBottom = false;

  @override
  void initState() {
    super.initState();

    _initDisabledSubjects();

    _scrollController.addListener(() {
      final reachedBottom =
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 20;

      if (reachedBottom && !_showCreateTileAtBottom) {
        setState(() {
          _showCreateTileAtBottom = true;
        });
      }
    });
  }

  Future<void> _initDisabledSubjects() async {
    List<String> shortNames = await SubjectService.findAllTechnicalName();
    setState(() {
      _disabledSubjects = shortNames.toSet();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSubjects = _allSubjects.where((subject) {
      return subject.id.toLowerCase().contains(
        _searchText.toLowerCase(),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Neues Fach"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Fach suchen...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                  _showCreateTileAtBottom = false;
                });
              },
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                ...filteredSubjects.map((subject) {
                  final disabled = _disabledSubjects.contains(subject.id);

                  return ListTile(
                    enabled: !disabled,
                    leading: Icon(
                      disabled
                          ? Icons.check_circle
                          : Icons.book,
                    ),
                    title: Text(subject.name),
                    subtitle: disabled
                        ? const Text("Bereits hinzugefügt")
                        : null,
                    trailing: disabled
                        ? null
                        : const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),
                    onTap: disabled
                        ? null
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubjectDetailPage(
                            subject: subject,
                          ),
                        ),
                      );
                    },
                  );
                }),

                _buildCreateCustomSubjectTile(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCreateCustomSubjectTile() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.add),
          title: Text(
            _searchText.trim().isEmpty
                ? "Eigenes Fach erstellen"
                : "\"$_searchText\" erstellen",
          ),
          subtitle: const Text(
            "Dieses Fach existiert noch nicht",
          ),
          onTap: () {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SubjectDetailPage(
                  templateUsed: false,
                  subject: SubjectTemplate(
                    id: Uuid.generate(),
                    name: _searchText,
                    shortName: "",
                    niveauOptions: [
                      SubjectNiveau.voluntary
                    ],
                    termsOptions: [
                      {0,1,2,3},
                      {0}, {1}, {2}, {3},
                      {0,1}, {0,2}, {0,3},
                      {1,2},{1,3},{2,3},
                      {0,1,2},{0,1,3},{0,2,3},{1,2,3},
                    ],
                    minCountingTermAmount: 0
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SubjectDetailPage extends StatefulWidget {
  final SubjectTemplate subject;
  final bool templateUsed;

  const SubjectDetailPage({
    super.key,
    required this.subject,
    this.templateUsed = true,
  });

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {

  late final GlobalKey formKey = GlobalKey();

  late Color color;
  late final TextEditingController nameController = TextEditingController(text: widget.subject.name);
  late final TextEditingController shortNameController = TextEditingController(text: widget.subject.shortName);
  late SubjectNiveau subjectNiveau = widget.subject.niveauOptions.firstOrNull ?? SubjectNiveau.voluntary;
  late Set<int> terms = widget.subject.termsOptions.firstOrNull ?? {0,1,2,3};
  late int countingTerms = widget.subject.minCountingTermAmount;
  late Future<List<Performance>> performances = Future.value([
    Performance(name: "Klausuren", weighting: 0.5, subjectId: ""),
    Performance(name: "Kleine Noten", weighting: 0.5, subjectId: ""),
  ]);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    color = Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
      formKey: formKey,
      appBarTitle: widget.templateUsed ? widget.subject.name : "Eigenes Fach",
      colorSeed: color,
      hasUnsavedChanges: () {return false;},
      saveTitle: "Erstellen",
      save: () async {},
      children: [
        SubjectNameAndColorInput(
          nameController: nameController,
          shortNameController: shortNameController,
          color: color,
          onSelectedColor: (Color newColor) {
            setState(() {
              color = newColor;
            });
          },
        ),

        FormGap(),

        SubjectNiveauDropdown(
          availableSubjectNiveaus: widget.subject.niveauOptions,
          selectedSubjectNiveau: subjectNiveau,
          onSelected: (newSubjectNiveau) {
            setState(() {
              subjectNiveau = newSubjectNiveau;
            });
          },
        ),

        FormGap(),

        TermsMultipleChoice(
          selectedTerms: terms,
          onSelected: (newTerms) {
            setState(() {
              terms = newTerms;
              if (countingTerms > terms.length) {
                countingTerms = terms.length;
              }
            });
          },
        ),

        FormGap(),

        Text("Mindestens Einzubringende Halbjahre:"),

        Slider(
          min: 0,
          max: terms.length.toDouble(),
          divisions: terms.length,
          value: countingTerms.toDouble(),
          label: "$countingTerms",
          onChanged: (newCountingTerms) {
            setState(() {
              countingTerms = newCountingTerms.toInt();
            });
          },
          year2023: false,
        ),

        FormGap(),

        FutureBuilder(
          future: performances,
          builder: (context, asyncSnapshot) {
            if (!asyncSnapshot.hasData) return CircularProgressIndicator();
            return PerformanceForm(
              performances: asyncSnapshot.data!,
              onChanged: (data) {
                setState(() {
                  performances = Future.value(data);
                });
              },
            );
          },
        ),
      ],
    );
  }
}
