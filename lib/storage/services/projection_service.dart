import 'dart:math';

import 'package:abitur/isolates/models/projection/projection_model.dart';
import 'package:abitur/isolates/projection_isolate.dart';
import 'package:abitur/isolates/serializer.dart';
import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/services/performance_service.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:flutter/foundation.dart';

import '../../isolates/models/projection/evaluations_subjects_performances_evaluation_dates_model.dart';
import '../../utils/constants.dart';
import '../entities/evaluation.dart';
import '../entities/evaluation_date.dart';
import '../entities/performance.dart';
import '../entities/settings.dart';
import '../entities/subject.dart';
import 'evaluation_date_service.dart';

class ProjectionService {

  static double get overallAvg => SubjectService.getCurrentAverage() ?? 15;

  static double getGraduationAvg() {
    return abiturAvg(resultBlock1() + resultBlock2());
  }

  static int resultBlock1() {
    List<TermNoteDto> termNotes = buildProjectionOverviewInformation().values.expandToList();
    return termNotes.where((note) => note.counting && note.note != null).toList().sumBy((note) => note.note! * note.weight).toInt();
  }
  static int resultBlock2() {
    List<Subject> abiSubjects = SubjectService.graduationSubjects();
    Iterable<int> examNotes = abiSubjects.map((s) {
      if (s.graduationEvaluation != null) {
        int? note = EvaluationService.calculateNote(s.graduationEvaluation!);
        if (note != null) {
          return note;
        }
      }
      return roundNote(SubjectService.getAverage(s) ?? overallAvg)!;
    });
    return examNotes.sum().toInt() * 4;
  }

  static Map<Subject, List<TermNoteDto>> buildProjectionOverviewInformation() {
    List<Subject> subjects = SubjectService.findAllGradable();
    Land land = SettingsService.land;
    Subject? wSeminar = subjects.where((it) => it.subjectType == SubjectType.seminar).firstOrNull;

    Map<Subject, List<TermNoteDto>> map = subjects.where((s) => s != wSeminar).toList().asMap().map((i, s) {
      return MapEntry(s, _buildTermNoteDtos(s));
    });

    if (land == Land.bw) { // TODO In BW zählen aus FS und NWS insgesamt mindestens 4
      // 2 der drei Leistungskurse doppelt gewichten
      List<Subject> advancedSubjects = subjects.where((it) => it.subjectType == SubjectType.advanced).toList();
      Map<Subject, int> weightedSums = advancedSubjects.mapWith((s) => map[s]!.sumBy((entry) => entry.note!).toInt());
      List<MapEntry<Subject, int>> sorted = weightedSums.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (int i = 0; i < 2; i++) {
        if (i >= sorted.length) {
          continue;
        }
        for (TermNoteDto termNote in map[sorted[i].key]!) {
          termNote.weight = 2;
        }
      }
    }

    List<TermNoteDto> allTermNotes = map.values.expandToList();

    // Optionsregel (schlechteste Note aus Nicht-Abiturfach gegen noch nicht zählende Note tauschen) TODO nur Bayern
    List<Subject> subjectsWithOneNoteCounting = subjects.where((s) => s != wSeminar).where((s) => map[s]!.countWhere((n) => n.counting) == 1).toList();
    List<TermNoteDto> notesWithOptionRulePossible = allTermNotes.where((note) => !SubjectService.isGraduationSubject(note.subject) && note.note != null && !subjectsWithOneNoteCounting.contains(note.subject)).toList();
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
    int? seminararbeitNote = wSeminar.graduationEvaluation?.evaluationDates.first.note;
    map[seminararbeit] = [
      TermNoteDto(note: seminararbeitNote ?? subjectOverallAverage(wSeminar), projection: seminararbeitNote == null, counting: true, subject: wSeminar),
      TermNoteDto(note: seminararbeitNote ?? subjectOverallAverage(wSeminar), projection: seminararbeitNote == null, counting: true, subject: wSeminar),
      TermNoteDto(note: null, projection: false, counting: false, subject: wSeminar),
      TermNoteDto(note: null, projection: false, counting: false, subject: wSeminar),
    ];

    return map;
  }

  static List<TermNoteDto> _buildTermNoteDtos(Subject s) {

    List<int?> notes = List.generate(4, (term) => _calcTermAverage(s, term));
    List<int> countingTerms = notes.findNLargestIndices(SubjectService.isGraduationSubject(s) ? 4 : s.countingTermAmount);

    return List.generate(4, (term) {
      if (!s.terms.contains(term)) {
        return TermNoteDto(note: null, projection: false, counting: false, subject: s);
      }

      final termAverage = notes[term] ?? subjectOverallAverage(s);
      final projection = notes[term] == null;

      return TermNoteDto(
        note: termAverage,
        projection: projection,
        counting: countingTerms.contains(term),
        subject: s,
      );
    });
  }

  static TermNoteDto graduationProjection(Subject subject) {
    int? note = (subject.graduationEvaluation != null) ? EvaluationService.calculateNote(subject.graduationEvaluation!) : null;
    return TermNoteDto(
      note: note ?? subjectOverallAverage(subject),
      projection: note == null,
      counting: true,
      subject: subject,
    );
  }

  static int subjectOverallAverage(Subject subject) {
    return roundNote(SubjectService.getAverage(subject) ?? overallAvg)!;
  }

  static int? _calcTermAverage(Subject s, int term) {
    double? avg = SubjectService.getAverageByTerm(s, term);
    return roundNote(avg);
  }

  static Future<ProjectionModel> computeProjectionIsolated() async {

    Land land = SettingsService.land;
    List<Evaluation> evaluations = EvaluationService.findAll();
    List<Subject> subjects = SubjectService.findAll();
    List<Performance> performances = PerformanceService.findAll();
    List<EvaluationDate> evaluationDates = EvaluationDateService.findAll();

    EvaluationsSubjectsPerformancesEvaluationDatesModel model = EvaluationsSubjectsPerformancesEvaluationDatesModel(
      land: land,
      evaluations: evaluations.serialize(),
      subjects: subjects.serialize(),
      performances: performances.serialize(),
      evaluationDates: evaluationDates.serialize(),
    );
    return compute(ProjectionIsolate.calculateProjection, model);
  }
}

class TermNoteDto {
  final int? note;
  String get noteString => note?.toString() ?? "-";
  bool projection;
  bool counting;
  Subject subject;
  int weight;

  TermNoteDto({required this.note, required this.projection, required this.counting, required this.subject, this.weight = 1});
}