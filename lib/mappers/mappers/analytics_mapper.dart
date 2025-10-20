import 'package:abitur/mappers/models/analytics_page_model.dart';

import '../../services/database/settings_service.dart';
import '../../services/database/subject_service.dart';

class AnalyticsMapper {

  static Future<AnalyticsPageModel> generateAnalyticsPageModel() async {

    DateTime dayToShowReview = await SettingsService.dayToShowReview();
    DateTime dayToChoseGraduationSubjects = await SettingsService.dayToChoseGraduationSubjects();

    double? currentAverage = await SubjectService.getCurrentAverage();
    bool reviewEnabled = !DateTime.now().isBefore(dayToShowReview);
    bool choseGraduationSubjects = !DateTime.now().isBefore(dayToChoseGraduationSubjects);

    return AnalyticsPageModel(
      currentAverage: currentAverage,
      reviewEnabled: reviewEnabled,
      choseGraduationSubjects: choseGraduationSubjects,
    );
  }
}