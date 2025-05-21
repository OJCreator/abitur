import 'package:abitur/storage/services/evaluation_date_service.dart';
import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/services/subject_service.dart';

import '../entities/evaluation.dart';
import '../entities/settings.dart';
import '../entities/subject.dart';
import '../storage.dart';

class GraduationService {

  static Future<void> setGraduationEvaluation(Subject s) async {
    if (s.graduationEvaluation != null) {
      return;
    }
    Evaluation e = await EvaluationService.newGraduationEvaluation(s);
    s.graduationEvaluation = e;
    Storage.saveSubject(s);
  }

  static Future<void> removeGraduationEvaluation(Subject s) async {
    if (s.graduationEvaluation == null || s.subjectType == SubjectType.seminar) {
      return;
    }
    EvaluationService.deleteEvaluation(s.graduationEvaluation!);
    s.graduationEvaluation = null;
    Storage.saveSubject(s);
  }

  static bool isGraduationSubject(Subject subject) {
    return subject.graduationEvaluation != null && subject.subjectType != SubjectType.seminar;
  }

  static List<Subject> graduationSubjects() {
    return SubjectService.findAll().where((s) => s.graduationEvaluation != null && s.subjectType != SubjectType.seminar).toList();
  }

  static Future<void> addSecondGraduationDate(Subject s, int weight, String description) async {
    Land land = SettingsService.land;
    if (![Land.bw, Land.by].contains(land) || s.graduationEvaluation == null) { // TODO Vielleicht auch noch für andere Länder möglich
      return;
    }
    if (land == Land.by && s.subjectType != SubjectType.seminar) {
      return;
    }
    if (s.graduationEvaluation!.evaluationDates.length > 1) {
      return;
    }
    await EvaluationDateService.newEvaluationDate(
      s.graduationEvaluation!,
      weight: weight,
      description: description,
    );
    return;
  }

  static Future<void> removeSecondGraduationDate(Subject s) async {
    if (s.graduationEvaluation == null || s.graduationEvaluation!.evaluationDates.length <= 1) {
      return;
    }
    EvaluationDateService.deleteEvaluationDate(
      s.graduationEvaluation!.evaluationDates[1],
    );
    return;
  }
}