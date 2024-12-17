import 'package:abitur/storage/entities/settings.dart';
import 'package:abitur/storage/entities/subject.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/storage/storage.dart';
import 'package:abitur/utils/constants.dart';

class SettingsService {

  static DateTime get firstDayOfSchool => DateTime(loadSettings().graduationYear.year - 2, 8, 1);
  static DateTime get lastDayOfSchool =>  DateTime(loadSettings().graduationYear.year, 7, 31);

  static Settings loadSettings() {
    return Storage.loadSettings();
  }

  static int probableTerm(DateTime date) {
    int graduationYear = loadSettings().graduationYear.year;
    if (date.isAfter(DateTime(graduationYear, 2))) {
      return 3;
    }
    if (date.isAfter(DateTime(graduationYear-1, 8))) {
      return 2;
    }
    if (date.isAfter(DateTime(graduationYear-1, 2))) {
      return 1;
    }
    return 0;
  }

  static Future<void> buildFromJson(Map<String, dynamic> jsonData) async {
    Settings s = Settings.fromJson(jsonData);
    await Storage.saveSettings(s);
  }

  static void markWelcomeScreenAsViewed() {
    Settings s = loadSettings();
    s.viewedWelcomeScreen = true;
    Storage.saveSettings(s);
  }

  static List<Subject> graduationSubjects() {
    // TODO
    return SubjectService.findAllGradable().maxSize(5);
  }
}