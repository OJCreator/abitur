import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../services/database/evaluation_type_service.dart';
import '../utils/enums/assessment_type.dart';
import 'entities/evaluation/evaluation_type.dart';

class SqliteStorage {

  static late Database database;

  static init() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'abitur_database.db'),
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY CHECK (id = 0),
            graduationYear TEXT NOT NULL,
            themeMode INTEGER NOT NULL,
            accentColor INTEGER NOT NULL,
            land TEXT NOT NULL,
            viewedWelcomeScreen INTEGER NOT NULL,
            calendarSynchronisation INTEGER NOT NULL,
            calendarFullDayEvents INTEGER NOT NULL,
            evaluationReminder INTEGER NOT NULL,
            evaluationReminderTimeInMinutes INTEGER NOT NULL,
            missingGradeReminder INTEGER NOT NULL,
            missingGradeReminderDelayDays INTEGER NOT NULL,
            missingGradeReminderTimeInMinutes INTEGER NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE graduation_evaluations (
            id TEXT PRIMARY KEY,
            subjectId TEXT NOT NULL,
            graduationEvaluationType TEXT NOT NULL,
            isDividedEvaluation INTEGER NOT NULL,
            notePartOne INTEGER,
            datePartOne TEXT,
            weightPartOne INTEGER NOT NULL,
            notePartTwo INTEGER,
            datePartTwo TEXT,
            weightPartTwo INTEGER NOT NULL,
            FOREIGN KEY (subjectId)
              REFERENCES subjects(id)
              ON DELETE CASCADE
          );
        ''');
        await db.execute('''
          CREATE TABLE performances (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            weighting REAL NOT NULL,
            subjectId TEXT NOT NULL,
            FOREIGN KEY (subjectId)
              REFERENCES subjects(id)
              ON DELETE CASCADE
          );
        ''');
        await db.execute('''
          CREATE TABLE subjects (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            shortName TEXT NOT NULL,
            color INTEGER NOT NULL,
            subjectNiveau TEXT NOT NULL,
            subjectType TEXT NOT NULL,
            terms TEXT NOT NULL,
            countingTermAmount INTEGER NOT NULL,
            manuallyEnteredTermNotes TEXT NOT NULL
          );
        ''');
        // EVALUATIONS
        await db.execute('''
          CREATE TABLE evaluation_types (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            assessmentType TEXT NOT NULL,
            showInCalendar INTEGER NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE evaluations (
            id TEXT PRIMARY KEY,
            subjectId TEXT NOT NULL,
            performanceId TEXT NOT NULL,
            evaluationTypeId TEXT NOT NULL,
            name TEXT NOT NULL,
            term INTEGER NOT NULL,
            FOREIGN KEY (subjectId)
              REFERENCES subjects(id)
              ON DELETE CASCADE,
            FOREIGN KEY (performanceId)
              REFERENCES performances(id) 
              ON DELETE SET NULL,
            FOREIGN KEY (evaluationTypeId)
              REFERENCES evaluation_types(id)
              ON DELETE SET NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE evaluation_dates (
            id TEXT PRIMARY KEY,
            evaluationId TEXT NOT NULL,
            date TEXT,
            note INTEGER,
            calendarId TEXT,
            weight INTEGER NOT NULL,
            description TEXT,
            FOREIGN KEY (evaluationId)
              REFERENCES evaluations(id)
              ON DELETE CASCADE
          );
        ''');
        // TIMETABLE
        await db.execute('''
          CREATE TABLE timetable_entries (
            id TEXT PRIMARY KEY,
            subjectId TEXT NOT NULL,
            term INTEGER NOT NULL,
            day INTEGER NOT NULL,
            hour INTEGER NOT NULL,
            room TEXT,
            teacher TEXT,
            FOREIGN KEY (subjectId)
              REFERENCES subjects(id)
              ON DELETE CASCADE
          );
        ''');
        return db.execute('''
          CREATE TABLE timetable_times (
            id TEXT PRIMARY KEY,
            slot INTEGER NOT NULL,
            "from" INTEGER NOT NULL,
            "to" INTEGER NOT NULL
          );
        ''');
      },
    );
    await initialValues();
  }

  static Future<void> initialValues() async {

    List<EvaluationType> evaluationTypes = await EvaluationTypeService.findAll();
    if (evaluationTypes.isEmpty) {
      EvaluationTypeService.newEvaluationType("Klausur", AssessmentType.written, true);
      EvaluationTypeService.newEvaluationType("Test", AssessmentType.written, true);
      EvaluationTypeService.newEvaluationType("Referat", AssessmentType.oral, true);
      EvaluationTypeService.newEvaluationType("Mündliche Note", AssessmentType.oral, false);
    }
  }
}