import 'package:abitur/services/database/evaluation_type_service.dart';
import 'package:abitur/services/database/performance_service.dart';
import 'package:abitur/utils/extensions/lists/expand_to_list_extension.dart';

import '../../services/database/evaluation_date_service.dart';
import '../../services/database/settings_service.dart';
import '../../services/database/subject_service.dart';
import '../../services/database/timetable_entry_service.dart';
import '../../sqlite/entities/evaluation/evaluation.dart';
import '../../sqlite/entities/evaluation/evaluation_date.dart';
import '../../sqlite/entities/evaluation/evaluation_type.dart';
import '../../utils/constants.dart';
import '../models/evaluation_input_page_model.dart';

class EvaluationsMapper {

  static Future<EvaluationInputPageModel> generateEvaluationInputModel({
    Evaluation? evaluation,
    DateTime? dateTime,
    String? subjectId,
    int? term,
  }) async {

    final subjects = await SubjectService.findAllGradableAsMap();
    final evaluationTypes = await EvaluationTypeService.findAllAsMap();
    final timetableSubject = await TimetableEntryService.findLatestGradableSubject();
    final selectedSubjectId = subjectId ?? evaluation?.subjectId ?? timetableSubject.id;
    final seedColor = subjects[selectedSubjectId]?.color ?? primaryColor;

    final performances = await PerformanceService.findAllBySubjectId(selectedSubjectId);

    final evaluationDates = evaluation == null
        ? [EvaluationDate(date: dateTime ?? DateTime.now())]
        : (await EvaluationDateService.findAllByEvaluationIds([evaluation.id])).values.expandToList();

    final probableTerm = await SettingsService.probableTerm(
      evaluationDates.firstOrNull?.date ?? DateTime.now(),
    );

    return EvaluationInputPageModel(
      subjects: subjects,
      evaluationTypes: evaluationTypes,
      initialPerformances: performances,

      evaluation: evaluation,
      initialName: evaluation?.name ?? "",
      initialEvaluationType: evaluationTypes[evaluation?.evaluationTypeId] ??
          evaluationTypes.values.firstOrNull ??
          EvaluationType.empty(),
      initialSubjectId: selectedSubjectId,
      initialPerformanceId: evaluation?.performanceId ?? (performances.isNotEmpty ? performances.first.id : ""),
      initialEvaluationDates: evaluationDates,
      initialTerm: term ?? evaluation?.term ?? probableTerm,

      seedColor: seedColor,
      editMode: evaluation != null,
    );
  }
}