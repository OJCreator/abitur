import 'package:abitur/mappers/models/analytics_page_model.dart';

import '../../services/database/settings_service.dart';
import '../../services/database/subject_service.dart';
import '../../sqlite/entities/subject.dart';

class AnalyticsMapper {

  static Future<AnalyticsPageModel> generateAnalyticsPageModel() async {

    DateTime dayToShowReview = await SettingsService.dayToShowReview();
    DateTime dayToChoseGraduationSubjects = await SettingsService.dayToChoseGraduationSubjects();

    int graduationSubjectsAmount = (await SubjectService.getGraduationSubjects()).length;

    double? currentAverage = await SubjectService.getCurrentAverage();
    bool reviewEnabled = !DateTime.now().isBefore(dayToShowReview);
    bool choseGraduationSubjects = (!DateTime.now().isBefore(dayToChoseGraduationSubjects)) && graduationSubjectsAmount == 0;

    return AnalyticsPageModel(
      currentAverage: currentAverage,
      reviewEnabled: reviewEnabled,
      choseGraduationSubjects: choseGraduationSubjects,
    );
  }
}
