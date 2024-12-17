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
    List<Subject> subjects = SubjectService.findAllGradable();
    List<TermNoteDto> termNotes = subjects.map((s) {
      return _buildTermNoteDtos(s);
    }).expandToList();

    int alreadyCountingNotes = termNotes.countWhere((note) => note.counting);


    var nonCountingNotes = termNotes.where((note) => !note.counting).toList();
    nonCountingNotes.sort((a,b) => -(a.note ?? 0).compareTo(b.note ?? 0));

    for (int i = 0; i < (40-alreadyCountingNotes); i++) { // todo anpassen mit W-Seminararbeit
      nonCountingNotes[i].counting = true;
    }

    return termNotes.where((note) => note.counting).sumBy((note) => note.note!).toInt();
  }
  static int resultBlock2() {
    List<Subject> abiSubjects = SettingsService.graduationSubjects();
    Iterable<int> examNotes = abiSubjects.map((s) => roundNote(SubjectService.getAverage(s) ?? overallAvg)!);
    return examNotes.sum().toInt() * 4;
  }

  static Map<Subject, List<TermNoteDto>> buildProjectionOverviewInformation() {
    List<Subject> subjects = SubjectService.findAllGradable();
    return subjects.asMap().map((i, s) {
      return MapEntry(s, _buildTermNoteDtos(s));
    });
  }

  static List<TermNoteDto> _buildTermNoteDtos(Subject s) {

    List<int?> notes = List.generate(4, (term) => _calcTermAverage(s, term));
    List<int> countingTerms = notes.findNLargestIndices(s.countingTermAmount);

    return List.generate(4, (term) {
      if (!s.terms.contains(term)) {
        return TermNoteDto(note: null, projection: false, counting: false);
      }

      final termAverage = notes[term] ?? roundNote(SubjectService.getAverage(s) ?? overallAvg);
      final projection = notes[term] == null;

      return TermNoteDto(
        note: termAverage,
        projection: projection,
        counting: countingTerms.contains(term),
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

  TermNoteDto({required this.note, required this.projection, required this.counting});
}