import 'package:abitur/storage/entities/settings.dart';
import 'package:abitur/storage/entities/timetable.dart';
import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'entities/evaluation.dart';
import 'entities/performance.dart';
import 'entities/subject.dart';

class Storage {

  static late Box<Evaluation> _evaluationBox;
  static late Box<Performance> _performanceBox;
  static late Box<Subject> _subjectBox;
  static late Box<Settings> _settingsBox;
  static late Box<Timetable> _timetableBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(EvaluationAdapter());
    Hive.registerAdapter(PerformanceAdapter());
    Hive.registerAdapter(SubjectAdapter());
    Hive.registerAdapter(SettingsAdapter());
    Hive.registerAdapter(TimetableAdapter());

    _evaluationBox = await Hive.openBox<Evaluation>('evaluations');
    _performanceBox = await Hive.openBox<Performance>('performances');
    _subjectBox = await Hive.openBox<Subject>('subjects');
    _settingsBox = await Hive.openBox<Settings>('settings');
    _timetableBox = await Hive.openBox<Timetable>('timetable');
  }

  // Evaluations
  static List<Evaluation> loadEvaluations() {
    return _evaluationBox.values.toList();
  }

  static Future<void> saveEvaluation(Evaluation e) async {
    int index = loadEvaluations().indexOf(e);
    if (index == -1) {
      await _evaluationBox.add(e);
    }
    else {
      await _evaluationBox.deleteAt(index);
      await _evaluationBox.add(e);
    }
  }

  static Future<void> deleteEvaluation(Evaluation e) async {
    int index = loadEvaluations().indexOf(e);
    if (index == -1) {
      return;
    }
    await _evaluationBox.deleteAt(index);
  }

  // Subjects
  static List<Subject> loadSubjects() {
    return _subjectBox.values.toList();
  }

  static Future<void> saveSubject(Subject s) async {
    int index = loadSubjects().indexOf(s);
    if (index == -1) {
      await _subjectBox.add(s);
    }
    else {
      await _subjectBox.deleteAt(index);
      await _subjectBox.add(s);

      // Delete evaluations of terms that do not longer exist
      List<int> termsThatDoNotExist = [0,1,2,3].where((i) => !s.terms.contains(i)).toList();
      List<Evaluation> toDelete = EvaluationService.findAllBySubjectAndTerms(s, termsThatDoNotExist);
      EvaluationService.deleteAllEvaluations(toDelete);
    }
  }

  static Future<void> deleteSubject(Subject s) async {
    int index = loadSubjects().indexOf(s);
    if (index == -1) {
      return;
    }
    await _subjectBox.deleteAt(index);
  }

  // Performances
  static List<Performance> loadPerformances() {
    return _performanceBox.values.toList();
  }

  static Future<void> savePerformance(Performance p) async {
    int index = loadPerformances().indexOf(p);
    if (index == -1) {
      await _performanceBox.add(p);
    }
    else {
      await _performanceBox.deleteAt(index);
      await _performanceBox.add(p);
    }
  }
  static Future<void> deletePerformance(Performance p) async {
    int index = loadPerformances().indexOf(p);
    if (index == -1) {
      return;
    }
    await _performanceBox.deleteAt(index);
  }

  // Settings
  static Settings loadSettings() {
    DateTime inTwoYears = DateTime(DateTime.now().year + 2);
    return _settingsBox.get("data", defaultValue: Settings(graduationYear: inTwoYears))!;
  }

  static Future<void> saveSettings(Settings s) async {
    await _settingsBox.put("data", s);
  }

  // Timetable
  static Timetable loadTimetable() {
    return _timetableBox.get("data", defaultValue: Timetable())!;
  }

  static Future<void> saveTimetable(Timetable t) async {
    await _timetableBox.put("data", t);
  }
}
