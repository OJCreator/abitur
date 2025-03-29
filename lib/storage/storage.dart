import 'package:abitur/storage/entities/settings.dart';
import 'package:abitur/storage/entities/timetable/timetable.dart';
import 'package:abitur/storage/entities/timetable/timetable_entry.dart';
import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/services/timetable_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'entities/evaluation.dart';
import 'entities/evaluation_date.dart';
import 'entities/performance.dart';
import 'entities/subject.dart';
import 'entities/timetable/timetable_settings.dart';

class Storage {

  static late Box<Evaluation> _evaluationBox;
  static late Box<EvaluationDate> _evaluationDateBox;
  static late Box<Performance> _performanceBox;
  static late Box<Subject> _subjectBox;
  static late Box<Settings> _settingsBox;
  static late Box<TimetableSettings> _timetableSettingsBox;
  static late Box<Timetable> _timetableBox;
  static late Box<TimetableEntry> _timetableEntryBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(EvaluationAdapter());
    Hive.registerAdapter(EvaluationDateAdapter());
    Hive.registerAdapter(PerformanceAdapter());
    Hive.registerAdapter(SubjectAdapter());
    Hive.registerAdapter(SettingsAdapter());
    Hive.registerAdapter(TimetableSettingsAdapter());
    Hive.registerAdapter(TimetableAdapter());
    Hive.registerAdapter(TimetableEntryAdapter());

    _evaluationBox = await Hive.openBox<Evaluation>('evaluations');
    _evaluationDateBox = await Hive.openBox<EvaluationDate>('evaluationDates');
    _performanceBox = await Hive.openBox<Performance>('performances');
    _subjectBox = await Hive.openBox<Subject>('subjects');
    _settingsBox = await Hive.openBox<Settings>('settings');
    _timetableSettingsBox = await Hive.openBox<TimetableSettings>('timetableSettings');
    _timetableBox = await Hive.openBox<Timetable>('timetables');
    _timetableEntryBox = await Hive.openBox<TimetableEntry>('timetableEntries');

    initialValues();
  }

  static void initialValues() {
    TimetableSettings s = TimetableService.loadTimetableSettings();
    if (s.timetables.length == 4) {
      return;
    }
    List<Timetable> timetables = List.generate(4, (i) => Timetable());
    s.timetables = timetables.map((it) => it.id).toList();
    saveTimetableSettings(s);
    for (Timetable t in timetables) {
      Storage.saveTimetable(t);
    }
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

  // EvaluationDates
  static List<EvaluationDate> loadEvaluationDates() {
    return _evaluationDateBox.values.toList();
  }

  static EvaluationDate loadEvaluationDate(String eId) {
    return _evaluationDateBox.get(eId)!;
  }

  static Future<void> saveEvaluationDate(EvaluationDate e) async {
    await _evaluationDateBox.delete(e.id);
    await _evaluationDateBox.put(e.id, e);
  }

  static Future<void> deleteEvaluationDate(EvaluationDate e) async {
    await _evaluationDateBox.delete(e.id);
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

  // TimetableSettings
  static TimetableSettings loadTimetableSettings() {
    return _timetableSettingsBox.get("data", defaultValue: TimetableSettings())!;
  }

  static Future<void> saveTimetableSettings(TimetableSettings t) async {
    await _timetableSettingsBox.put("data", t);
  }

  // Timetables
  static List<Timetable> loadTimetables() {
    return _timetableBox.values.toList();
  }

  static Future<void> saveTimetable(Timetable t) async {
    int index = loadTimetables().indexOf(t);
    if (index == -1) {
      await _timetableBox.add(t);
    }
    else {
      await _timetableBox.deleteAt(index);
      await _timetableBox.add(t);
    }
  }

  // TimetableEntries
  static List<TimetableEntry> loadTimetableEntries() {
    return _timetableEntryBox.values.toList();
  }

  static TimetableEntry loadTimetableEntry(String entryId) {
    return _timetableEntryBox.get(entryId)!;
  }

  static Future<void> saveTimetableEntry(TimetableEntry t) async {
    await _timetableEntryBox.delete(t.id);
    await _timetableEntryBox.put(t.id, t);
  }

  static Future<void> deleteTimetableEntry(String entryId) async {
    await _timetableEntryBox.delete(entryId);
  }
}
