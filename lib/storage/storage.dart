import 'package:abitur/storage/entities/evaluation_type.dart';
import 'package:abitur/storage/entities/graduation/graduation_evaluation.dart';
import 'package:abitur/storage/entities/settings.dart';
import 'package:abitur/storage/entities/subject_category.dart';
import 'package:abitur/storage/entities/timetable/timetable.dart';
import 'package:abitur/storage/entities/timetable/timetable_entry.dart';
import 'package:abitur/storage/services/evaluation_service.dart';
import 'package:abitur/storage/services/evaluation_type_service.dart';
import 'package:abitur/storage/services/graduation_service.dart';
import 'package:abitur/storage/services/settings_service.dart';
import 'package:abitur/storage/services/subject_service.dart';
import 'package:abitur/storage/services/subject_category_service.dart';
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
  static late Box<EvaluationType> _evaluationTypeBox;
  static late Box<Performance> _performanceBox;
  static late Box<Subject> _subjectBox;
  static late Box<SubjectCategory> _subjectCategoryBox;
  static late Box<Settings> _settingsBox;
  // static late Box<GraduationProfile> _graduationProfileBox;
  static late Box<GraduationEvaluation> _graduationEvaluationBox;
  static late Box<TimetableSettings> _timetableSettingsBox;
  static late Box<Timetable> _timetableBox;
  static late Box<TimetableEntry> _timetableEntryBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(EvaluationAdapter());
    Hive.registerAdapter(EvaluationDateAdapter());
    Hive.registerAdapter(EvaluationTypeAdapter());
    Hive.registerAdapter(PerformanceAdapter());
    Hive.registerAdapter(SubjectAdapter());
    Hive.registerAdapter(SubjectCategoryAdapter());
    Hive.registerAdapter(SettingsAdapter());
    // Hive.registerAdapter(GraduationProfileAdapter());
    Hive.registerAdapter(GraduationEvaluationAdapter());
    Hive.registerAdapter(TimetableSettingsAdapter());
    Hive.registerAdapter(TimetableAdapter());
    Hive.registerAdapter(TimetableEntryAdapter());

    _evaluationBox = await Hive.openBox<Evaluation>('evaluations');
    _evaluationDateBox = await Hive.openBox<EvaluationDate>('evaluationDates');
    _evaluationTypeBox = await Hive.openBox<EvaluationType>('evaluationTypes');
    _performanceBox = await Hive.openBox<Performance>('performances');
    _subjectBox = await Hive.openBox<Subject>('subjects');
    _subjectCategoryBox = await Hive.openBox<SubjectCategory>('subjectCategories');
    _settingsBox = await Hive.openBox<Settings>('settings');
    // _graduationProfileBox = await Hive.openBox<GraduationProfile>('graduationProfile');
    _graduationEvaluationBox = await Hive.openBox<GraduationEvaluation>('graduationEvaluations');
    _timetableSettingsBox = await Hive.openBox<TimetableSettings>('timetableSettings');
    _timetableBox = await Hive.openBox<Timetable>('timetables');
    _timetableEntryBox = await Hive.openBox<TimetableEntry>('timetableEntries');

    initialValues();
    filterUnreferencedObjects();
    // TODO überprüfen, ob es Objekte mit IDs gibt, auf die kein anderes Objekt verweist => Warnung!
  }

  static void initialValues() {
    TimetableSettings s = TimetableService.loadTimetableSettings();
    if (s.timetables.isEmpty) {
      List<Timetable> timetables = List.generate(4, (i) => Timetable());
      s.timetables = timetables.map((it) => it.id).toList();
      saveTimetableSettings(s);
      for (Timetable t in timetables) {
        Storage.saveTimetable(t);
      }
    }

    List<EvaluationType> evaluationTypes = EvaluationTypeService.findAll();
    if (evaluationTypes.isEmpty) {
      EvaluationTypeService.newEvaluationType("Klausur", AssessmentType.written, true);
      EvaluationTypeService.newEvaluationType("Test", AssessmentType.written, true);
      EvaluationTypeService.newEvaluationType("Referat", AssessmentType.oral, true);
      EvaluationTypeService.newEvaluationType("Mündliche Note", AssessmentType.oral, false);
    }

    List<SubjectCategory> subjectCategories = SubjectCategoryService.findAll();
    Land land = SettingsService.land;
    if (subjectCategories.isEmpty && land != Land.none) { // TODO das wird noch nicht initialisiert ganz am Anfang, weil kein Land ausgewählt ist!! Es sollte nach der Wahl des Landes initialisiert werden.
      if (land == Land.by) {
        SubjectCategoryService.newSubjectCategory("Fremdsprache", 4);
        SubjectCategoryService.newSubjectCategory("Naturwissenschaft", 4);
        SubjectCategoryService.newSubjectCategory("Gesellschaftswissenschaft", 4);
        SubjectCategoryService.newSubjectCategory("...", 4); // todo weitere & wie sollen die berechnet werden? Wenn es 2 Nat.Wiss sind, dann 7, sonst alle 4 Einbringungen
      }
      if (land == Land.nw) {
        SubjectCategoryService.newSubjectCategory("Sprachlich-Literarisch-Künstlerisch", 4);
        SubjectCategoryService.newSubjectCategory("Gesellschaftswissenschaftlich", 4);
        SubjectCategoryService.newSubjectCategory("Mathematisch-Naturwissenschaftlich-Technisch", 4);
        SubjectCategoryService.newSubjectCategory("...", 4); // todo weitere & wie sollen die berechnet werden? Wenn es 2 Nat.Wiss sind, dann 7, sonst alle 4 Einbringungen
      }
      // todo andere Bundesländer
    }

    List<Subject> seminarWithoutGraduationEvaluation = SubjectService.findAll().where((s) => s.subjectType == SubjectType.seminar && s.graduationEvaluation == null).toList();
    for (Subject seminar in seminarWithoutGraduationEvaluation) {
      GraduationService.setGraduationEvaluation(seminar, GraduationEvaluationType.seminar);
    }
  }

  static void filterUnreferencedObjects() {
    List<Evaluation> evals = loadEvaluations();
    Set<String> referencedIds = evals.expand((e) => e.evaluationDateIds).toSet();

    for (EvaluationDate e in loadEvaluationDates()) {
      if (!referencedIds.contains(e.id)) {
        print("$e wird nicht mehr referenziert und sollte gelöscht werden.");
        // deleteEvaluationDate(e);
      }
    }
  }

  // Evaluations
  static List<Evaluation> loadEvaluations() {
    return _evaluationBox.values.toList();
  }

  static Future<void> saveEvaluation(Evaluation e) async {
    await _evaluationBox.delete(e.id);
    await _evaluationBox.put(e.id, e);
  }

  static Future<void> deleteEvaluation(Evaluation e) async {
    await _evaluationBox.delete(e.id);
  }

  // EvaluationDates
  static List<EvaluationDate> loadEvaluationDates() {
    return _evaluationDateBox.values.toList();
  }

  static EvaluationDate loadEvaluationDate(String eId) {
    if (!_evaluationDateBox.containsKey(eId)) {
      //print("Fehler: EvaluationDate#$eId konnte nicht gefunden werden.");
      return EvaluationDate.empty();
    }
    return _evaluationDateBox.get(eId)!;
  }

  static Future<void> saveEvaluationDate(EvaluationDate e) async {
    await _evaluationDateBox.delete(e.id);
    await _evaluationDateBox.put(e.id, e);
  }

  static Future<void> deleteEvaluationDate(EvaluationDate e) async {
    await _evaluationDateBox.delete(e.id);
  }

  // EvaluationTypes
  static List<EvaluationType> loadEvaluationTypes() {
    return _evaluationTypeBox.values.toList();
  }

  static EvaluationType loadEvaluationType(String eId) {
    return _evaluationTypeBox.get(eId)!;
  }

  static Future<void> saveEvaluationType(EvaluationType e) async {
    await _evaluationTypeBox.delete(e.id);
    await _evaluationTypeBox.put(e.id, e);
  }

  static Future<void> deleteEvaluationType(EvaluationType e) async {
    await _evaluationTypeBox.delete(e.id);
  }

  // Subjects
  static List<Subject> loadSubjects() {
    return _subjectBox.values.toList();
  }
  static Subject? loadSubject(String id) {
    return _subjectBox.get(id);
  }

  static Future<void> saveSubject(Subject s) async {

    bool alreadyExists = _subjectBox.containsKey(s.id);
    if (alreadyExists) {
      await _subjectBox.delete(s.id);

      // Delete evaluations of terms that do not longer exist
      List<int> termsThatDoNotExist = [0,1,2,3].where((i) => !s.terms.contains(i)).toList();
      List<Evaluation> toDelete = EvaluationService.findAllBySubjectAndTerms(s, termsThatDoNotExist);
      EvaluationService.deleteAllEvaluations(toDelete);
    }

    await _subjectBox.put(s.id, s);
  }

  static Future<void> deleteSubject(Subject s) async {
    await _subjectBox.delete(s.id);
  }

  // SubjectTypes
  static List<SubjectCategory> loadSubjectCategories() {
    return _subjectCategoryBox.values.toList();
  }

  static SubjectCategory? loadSubjectCategory(String sId) {
    return _subjectCategoryBox.get(sId);
  }

  static Future<void> saveSubjectCategory(SubjectCategory s) async {
    await _subjectCategoryBox.delete(s.id);
    await _subjectCategoryBox.put(s.id, s);
  }

  static Future<void> deleteSubjectCategory(SubjectCategory s) async {
    await _subjectCategoryBox.delete(s.id);
  }

  // Performances
  static List<Performance> loadPerformances() {
    return _performanceBox.values.toList();
  }
  static Performance? loadPerformance(String id) {
    return _performanceBox.get(id);
  }

  static Future<void> savePerformance(Performance p) async {
    await _performanceBox.delete(p.id);
    await _performanceBox.put(p.id, p);
  }
  static Future<void> deletePerformance(Performance p) async {
    await _performanceBox.delete(p.id);
  }

  // GraduationProfile
  // static GraduationProfile loadGraduationProfile() {
  //   return _graduationProfileBox.get("data", defaultValue: GraduationProfile())!;
  // }
  //
  // static Future<void> saveGraduationProfile(GraduationProfile gp) async {
  //   await _graduationProfileBox.put("data", gp);
  // }

  // GraduationEvaluations
  static List<GraduationEvaluation> loadGraduationEvaluations() {
    return _graduationEvaluationBox.values.toList();
  }
  static GraduationEvaluation? loadGraduationEvaluation(String id) {
    return _graduationEvaluationBox.get(id);
  }

  static Future<void> saveGraduationEvaluation(GraduationEvaluation ge) async {
    await _graduationEvaluationBox.delete(ge.id);
    await _graduationEvaluationBox.put(ge.id, ge);
  }
  static Future<void> deleteGraduationEvaluation(GraduationEvaluation ge) async {
    await _graduationEvaluationBox.delete(ge.id);
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
