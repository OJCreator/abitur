import 'dart:math';

import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/services/subject_service.dart';

import '../../utils/constants.dart';
import '../entities/subject.dart';

class ProjectionService {

  static double get overallAvg => SubjectService.getCurrentAverage() ?? 15;

  static double getGraduationAvg() {
    return abiturAvg(resultBlock1() + resultBlock2());
  }

  static int resultBlock1() {
    List<TermNoteDto> termNotes = buildProjectionOverviewInformation().values.expandToList();
    return termNotes.where((note) => note.counting && note.note != null).sumBy((note) => note.note!).toInt();
  }
  static int resultBlock2() {
    List<Subject> abiSubjects = SettingsService.graduationSubjects().whereType<Subject>().toList();
    Iterable<int> examNotes = abiSubjects.map((s) => roundNote(SubjectService.getAverage(s) ?? overallAvg)!); // TODO Was wenn schon geschrieben?
    return examNotes.sum().toInt() * 4;
  }

  static Map<Subject, List<TermNoteDto>> buildProjectionOverviewInformation() {
    List<Subject> subjects = SubjectService.findAllGradable();
    Subject? wSeminar = subjects.where((it) => it.subjectType == SubjectType.seminar).firstOrNull;

    Map<Subject, List<TermNoteDto>> map = subjects.where((s) => s != wSeminar).toList().asMap().map((i, s) {
      return MapEntry(s, _buildTermNoteDtos(s));
    });

    List<TermNoteDto> allTermNotes = map.values.expandToList();

    // Optionsregel (schlechteste Note aus Nicht-Abiturfach gegen noch nicht zählende Note tauschen)
    List<Subject> subjectsWithOneNoteCounting = subjects.where((s) => s != wSeminar).where((s) => map[s]!.countWhere((n) => n.counting) == 1).toList();
    List<TermNoteDto> notesWithOptionRulePossible = allTermNotes.where((note) => !SettingsService.isGraduationSubject(note.subject) && note.note != null && !subjectsWithOneNoteCounting.contains(note.subject)).toList();
    notesWithOptionRulePossible.sort((a,b) => a.note!.compareTo(b.note!));
    notesWithOptionRulePossible.firstOrNull?.counting = false;

    // 40 Noten zählen lassen
    int alreadyCountingNotes = allTermNotes.countWhere((note) => note.counting);

    var nonCountingNotes = allTermNotes.where((note) => !note.counting).toList();
    nonCountingNotes.sort((a,b) => -(a.note ?? 0).compareTo(b.note ?? 0));

    int missingNotesAmount = min(((wSeminar == null ? 40 : 36)-alreadyCountingNotes), nonCountingNotes.length);

    for (int i = 0; i < missingNotesAmount; i++) {
      nonCountingNotes[i].counting = true;
    }

    if (wSeminar == null) {
      return map;
    }

    map[wSeminar] = _buildTermNoteDtos(wSeminar);
    Subject seminararbeit = Subject(name: "Seminararbeit", shortName: "Arbeit", countingTermAmount: 2, color: wSeminar.color);
    int? seminararbeitNote = roundNote(SubjectService.getAverage(wSeminar) ?? overallAvg); // todo was wenn schon geschireben?
    map[seminararbeit] = [
      TermNoteDto(note: seminararbeitNote, projection: true, counting: true, subject: wSeminar),
      TermNoteDto(note: seminararbeitNote, projection: true, counting: true, subject: wSeminar),
      TermNoteDto(note: null, projection: false, counting: false, subject: wSeminar),
      TermNoteDto(note: null, projection: false, counting: false, subject: wSeminar),
    ];

    return map;
  }

  static List<TermNoteDto> _buildTermNoteDtos(Subject s) {

    List<int?> notes = List.generate(4, (term) => _calcTermAverage(s, term));
    List<int> countingTerms = notes.findNLargestIndices(SettingsService.graduationSubjects().contains(s) ? 4 : s.countingTermAmount);

    return List.generate(4, (term) {
      if (!s.terms.contains(term)) {
        return TermNoteDto(note: null, projection: false, counting: false, subject: s);
      }

      final termAverage = notes[term] ?? roundNote(SubjectService.getAverage(s) ?? overallAvg);
      final projection = notes[term] == null;

      return TermNoteDto(
        note: termAverage,
        projection: projection,
        counting: countingTerms.contains(term),
        subject: s,
      );
    });
  }

  static int? _calcTermAverage(Subject s, int term) {
    double? avg = SubjectService.getAverageByTerm(s, term);
    return roundNote(avg);
  }
}

class TermNoteDto {
  final int? note;
  String get noteString => note?.toString() ?? "-";
  bool projection;
  bool counting;
  Subject subject;

  TermNoteDto({required this.note, required this.projection, required this.counting, required this.subject});
}