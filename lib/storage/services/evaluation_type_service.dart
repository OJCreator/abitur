import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/storage.dart';

import '../entities/evaluation_type.dart';

class EvaluationTypeService {

  static List<EvaluationType> findAll() {
    return Storage.loadEvaluationTypes();
  }
  static EvaluationType? findById(String evaluationTypeId) {
    for (var e in findAll()) {
      if (e.id == evaluationTypeId) {
        return e;
      }
    }
    return null;
  }

  static Future<EvaluationType> newEvaluationType(String name, AssessmentType assessmentType, bool showInCalendar) async {

    EvaluationType newEvaluationType = EvaluationType(
      name: name,
      assessmentType: assessmentType,
      showInCalendar: showInCalendar,
    );
    await Storage.saveEvaluationType(newEvaluationType);
    return newEvaluationType;
  }

  static Future<void> editEvaluationType(EvaluationType evaluationType, {String? name, AssessmentType? assessmentType, bool? showInCalendar}) async {
    name ??= evaluationType.name;
    assessmentType ??= evaluationType.assessmentType;
    showInCalendar ??= evaluationType.showInCalendar;
    evaluationType.name = name;
    evaluationType.assessmentType = assessmentType;
    evaluationType.showInCalendar = showInCalendar;
    await Storage.saveEvaluationType(evaluationType);
  }

  static Future<void> deleteEvaluationType(EvaluationType evaluationType) async {
    if (EvaluationService.findAll().any((it) => it.evaluationTypeId == evaluationType.id)) {
      return;
    }
    await Storage.deleteEvaluationType(evaluationType);
  }

  static Future<void> deleteAllEvaluationTypes(List<EvaluationType> evaluationTypes) async {
    for (var e in evaluationTypes) {
      deleteEvaluationType(e);
    }
  }

  static Future<void> buildFromJson(List<Map<String, dynamic>> jsonData) async {
    deleteAllEvaluationTypes(findAll());
    List<EvaluationType> evaluationTypes = jsonData.map((e) => EvaluationType.fromJson(e)).toList();
    for (EvaluationType e in evaluationTypes) {
      await Storage.saveEvaluationType(e);
    }
  }
}