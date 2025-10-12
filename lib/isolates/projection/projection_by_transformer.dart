import 'dart:math';

import 'package:abitur/isolates/models/projection/projection_model.dart';
import 'package:abitur/isolates/projection/projection_isolate.dart';
import 'package:abitur/utils/constants.dart';
import 'package:abitur/utils/extensions/lists/iterable_extension.dart';
import 'package:abitur/utils/extensions/lists/nullable_num_list_extension.dart';

import '../../storage/entities/subject.dart';
import '../../storage/services/graduation_service.dart';
import '../../utils/enums/subject_type.dart';

class ProjectionByTransformer {

  static void transform(List<ProjectionSubjectBlock1Model> block1, ProjectionWorkModel workModel) {

    countSubjectSpecificMinAmount(block1, workModel);
    countGraduationSubjectsCompletely(block1, workModel);
    countWseminarProperly(block1, workModel);
    countFourLanguageNotes(block1, workModel);
    countFourScienceNotes(block1, workModel);
    optionRule(block1, workModel);
    countFortyNotes(block1, workModel);
  }

  static void countSubjectSpecificMinAmount(List<ProjectionSubjectBlock1Model> block1, ProjectionWorkModel workModel) {

    for (ProjectionSubjectBlock1Model subjectModel in block1) {
      List<int> countingTerms = subjectModel.terms.map((t) => t.note).toList().findNLargestIndices(workModel.subjects[subjectModel.subjectId]!.countingTermAmount);
      for (int countingIndex in countingTerms) {
        subjectModel.terms[countingIndex].counting = true;
      }
    }
  }

  static void countGraduationSubjectsCompletely(List<ProjectionSubjectBlock1Model> block1, ProjectionWorkModel workModel) {

    for (ProjectionSubjectBlock1Model subjectModel in block1) {
      Subject s = workModel.subjects[subjectModel.subjectId]!;
      if (s.graduationEvaluationId == null || s.subjectType == SubjectType.wSeminar) {
        continue;
      }
      for (int i = 0; i < 4; i++) {
        subjectModel.terms[i].counting = true;
      }
    }
  }

  static void countWseminarProperly(List<ProjectionSubjectBlock1Model> block1, ProjectionWorkModel workModel) {

    Subject wseminar = workModel.seminarSubject()!;
    ProjectionSubjectBlock1Model wseminarBlock1 = block1.firstWhere((model) => model.subjectId == wseminar.id);

    double? rawSeminararbeitNote = GraduationService.calculateNote(workModel.graduationEvaluations[wseminar.graduationEvaluationId]!);
    int? seminararbeitNote = rawSeminararbeitNote == null
        ? null
        : roundNote(rawSeminararbeitNote * 2);

    wseminarBlock1.terms[0].counting = true;
    wseminarBlock1.terms[1].counting = true;
    wseminarBlock1.terms[2].counting = false;
    wseminarBlock1.terms[3].counting = true;

    wseminarBlock1.terms[2].note = null;
    wseminarBlock1.terms[2].projection = false;
    if (seminararbeitNote == null) {
      wseminarBlock1.terms[3].note = workModel.defaultSubjectAvg(wseminar.id) * 2;
      wseminarBlock1.terms[3].projection = true;
    } else {
      wseminarBlock1.terms[3].note = seminararbeitNote;
      wseminarBlock1.terms[3].projection = false;
    }
  }

  static void countFourLanguageNotes(List<ProjectionSubjectBlock1Model> block1, ProjectionWorkModel workModel) {

    _countNoteAmountForSubjectTypes(block1, workModel,
      subjectType: SubjectType.fortgefuehrteFremdsprache,
      minCount: 4,
    );
  }

  static void countFourScienceNotes(List<ProjectionSubjectBlock1Model> block1, ProjectionWorkModel workModel) {

    _countNoteAmountForSubjectTypes(block1, workModel,
      subjectType: SubjectType.naturwissenschaftOhneInf,
      minCount: 4,
    );
  }

  static void _countNoteAmountForSubjectTypes(
      List<ProjectionSubjectBlock1Model> block1,
      ProjectionWorkModel workModel,
      {
        required SubjectType subjectType,
        required int minCount,
      }) {
    // relevante Fächer
    final subjects = block1.where((model) {
      final type = workModel.subjects[model.subjectId]!.subjectType;
      return type == subjectType;
    });

    // alle Terms dieser Fächer
    final terms = subjects.expand((m) => m.terms);

    // schon zählende
    final counting = terms.where((t) => t.counting).length;
    if (counting >= minCount) return;

    // nicht zählende, nach Note absteigend sortiert
    final notCounting = terms.where((t) => !t.counting && t.note != null).toList()
      ..sort((a, b) => b.note!.compareTo(a.note!));

    // auffüllen
    for (final t in notCounting.take(minCount - counting)) {
      t.counting = true;
    }
  }

  /// Schlechteste Note aus Nicht-Abiturfach gegen noch nicht zählende Note tauschen
  static void optionRule(List<ProjectionSubjectBlock1Model> block1, ProjectionWorkModel workModel) {

    // relevante Fächer
    final relevantSubjects = block1.where((model) {
      final noGraduationEvaluation = workModel.subjects[model.subjectId]!.graduationEvaluationId == null;
      final countingTermAmount = model.terms.countWhere((t) => t.counting);
      return noGraduationEvaluation && countingTermAmount > 1;
    });

    // alle Terms dieser Fächer
    final terms = relevantSubjects.expand((m) => m.terms).where((m) => m.counting && m.note != null).toList();

    // nicht zählende, nach Note aufsteigend sortiert
    terms.sort((a, b) => a.note!.compareTo(b.note!));

    terms.firstOrNull?.counting = false;
  }

  /// Insgesamt 40 Noten in Block 1 haben
  static void countFortyNotes(List<ProjectionSubjectBlock1Model> block1, ProjectionWorkModel workModel) {
    
    List<ProjectionTermModel> allTermNotes = block1.where((model) => workModel.subjects[model.subjectId]!.subjectType != SubjectType.wSeminar).expand((model) => model.terms).toList();

    int alreadyCountingNotes = allTermNotes.countWhere((note) => note.counting);

    var nonCountingNotes = allTermNotes.where((note) => !note.counting).toList();
    nonCountingNotes.sort((a,b) => (b.note ?? 0).compareTo(a.note ?? 0));

    int missingNotesAmount = min(((36)-alreadyCountingNotes), nonCountingNotes.length); // Ohne W-Seminar braucht man noch 36 Noten

    for (int i = 0; i < missingNotesAmount; i++) {
      nonCountingNotes[i].counting = true;
    }
  }

}