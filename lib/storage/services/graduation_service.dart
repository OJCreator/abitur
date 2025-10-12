import 'package:abitur/storage/entities/graduation/graduation_evaluation.dart';
import 'package:abitur/storage/services/settings_service.dart';

import '../../utils/enums/land.dart';
import '../../utils/enums/subject_type.dart';
import '../entities/subject.dart';
import '../storage.dart';

class GraduationService {

  static List<GraduationEvaluation> findAllEvaluations() {
    return Storage.loadGraduationEvaluations();
  }
  static List<GraduationEvaluation> findAllEvaluationsById(List<String> graduationEvaluationIds) {
    return graduationEvaluationIds.map((id) => findEvaluationById(id)).toList();
  }

  static GraduationEvaluation findEvaluationById(String graduationEvaluationId) {
    return Storage.loadGraduationEvaluation(graduationEvaluationId) ?? GraduationEvaluation.empty();
  }

  static GraduationEvaluation? findEvaluationBySubject(Subject s) {
    return findAllEvaluations().where((e) => e.subjectId == s.id).firstOrNull;
  }

  static bool hasGraduationEvaluation(Subject subject) {
    return findAllEvaluations().any((g) => g.subjectId == subject.id);
  }
  static bool isGraduationSubject(Subject subject) {
    return hasGraduationEvaluation(subject) && subject.subjectType != SubjectType.wSeminar;
  }
  static List<Subject> graduationSubjects() {
    return findAllEvaluations().map((e) => e.subject).toSet().where((s) => s.subjectType != SubjectType.wSeminar).toList();
  }
  static List<Subject> graduationSubjectsFiltered(GraduationEvaluationType filter) {
    return findAllEvaluations().where((e) => e.graduationEvaluationType == filter).map((e) => e.subject).toSet().where((s) => s.subjectType != SubjectType.wSeminar).toList();
  }


  static Future<void> deleteGraduationEvaluation(Subject s) async {
    GraduationEvaluation? g = findEvaluationBySubject(s);
    if (g != null && canDisableGraduation(s)) {
      await Storage.deleteGraduationEvaluation(g);
      s.graduationEvaluation = null;
      await Storage.saveSubject(s);
    }
  }
  static Future<void> setGraduationEvaluation(Subject s, GraduationEvaluationType graduation) async {
    GraduationEvaluation? g = findEvaluationBySubject(s);
    if (g == null) {
      g = GraduationEvaluation(
        subjectId: s.id,
        graduationEvaluationType: graduation,
        // TODO Welche Art? Zweigeteilt?
      );
      await Storage.saveGraduationEvaluation(g);
      s.graduationEvaluation = g;
      await Storage.saveSubject(s);
    } else if (g.graduationEvaluationType != graduation) {
      g.graduationEvaluationType = graduation;
      await Storage.saveGraduationEvaluation(g);
    }
  }


  static bool canDisableGraduation(Subject s) {
    if (s.subjectType == SubjectType.wSeminar) {
      return false;
    }
    return true;
    // TODO welche Prüfungen sind Pflicht?
  }

  static bool canAddSecondGraduationDate(GraduationEvaluation graduationEvaluation) {
    Land land = SettingsService.land;
    if (land == Land.by) {
      return graduationEvaluation.subject.subjectType == SubjectType.wSeminar;
    }
    if ([Land.bw, Land.nw, Land.rp, Land.hh].contains(land)) {
      return graduationEvaluation.graduationEvaluationType == GraduationEvaluationType.written;
    }
    return false; // TODO in welchen Bundesländern können welche Prüfungen mehrere Teile haben?
  }

  static double? calculateNote(GraduationEvaluation ge) {
    if (ge.notePartOne == null) {
      return ge.notePartTwo?.toDouble();
    }
    if (ge.isDividedEvaluation) {
      if (ge.notePartTwo == null) {
        return ge.notePartOne?.toDouble();
      }
      return (ge.notePartOne! * ge.weightPartOne + ge.notePartTwo! * ge.weightPartTwo).toDouble() / (ge.weightPartOne + ge.weightPartTwo);
    }
    return ge.notePartOne?.toDouble();
  }

  static Future<void> buildFromJson(List<Map<String, dynamic>> jsonData) async {
    for (GraduationEvaluation e in findAllEvaluations()) {
      Storage.deleteGraduationEvaluation(e);
    }
    List<GraduationEvaluation> evaluations = jsonData.map((e) => GraduationEvaluation.fromJson(e)).toList();
    for (GraduationEvaluation e in evaluations) {
      await Storage.saveGraduationEvaluation(e);
    }
  }

  static Future<void> editEvaluation(GraduationEvaluation graduationEvaluation, {int? notePartOne, required int weightPartOne, DateTime? datePartOne, required bool divideEvaluation, int? notePartTwo, required int weightPartTwo, DateTime? datePartTwo}) async {
    graduationEvaluation.notePartOne = notePartOne;
    graduationEvaluation.weightPartOne = weightPartOne;
    graduationEvaluation.datePartOne = datePartOne;
    graduationEvaluation.isDividedEvaluation = divideEvaluation;
    graduationEvaluation.notePartTwo = notePartTwo;
    graduationEvaluation.weightPartTwo = weightPartTwo;
    graduationEvaluation.datePartTwo = datePartTwo;

    await Storage.saveGraduationEvaluation(graduationEvaluation);
  }

  // static Future<void> removeSecondGraduationDate(Subject s) async {
  //   if (s.graduationEvaluation == null || s.graduationEvaluation!.evaluationDates.length <= 1) {
  //     return;
  //   }
  //   EvaluationDateService.deleteEvaluationDate(
  //     s.graduationEvaluation!.evaluationDates[1],
  //   );
  //   return;
  // }
}