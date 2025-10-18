import 'package:sqflite/sqflite.dart';
import '../../sqlite/entities/evaluation/evaluation_type.dart';
import '../../sqlite/sqlite_storage.dart';
import '../../utils/enums/assessment_type.dart';

class EvaluationTypeService {

  /// Alle EvaluationTypes laden
  static Future<List<EvaluationType>> findAll() async {
    final db = SqliteStorage.database;
    final List<Map<String, dynamic>> maps = await db.query('evaluation_types', orderBy: 'name');

    return maps.map((m) => EvaluationType.fromJson(m)).toList();
  }

  /// Alle EvaluationTypes als Map mit ID als Key laden
  static Future<Map<String, EvaluationType>> findAllAsMap() async {
    final db = SqliteStorage.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'evaluation_types',
      orderBy: 'name',
    );

    return {
      for (final m in maps)
        m['id'] as String: EvaluationType.fromJson(m),
    };
  }

  /// Nach ID suchen
  static Future<EvaluationType?> findById(String id) async {
    final db = SqliteStorage.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'evaluation_types',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return EvaluationType.fromJson(maps.first);
  }

  /// Neuen EvaluationType erstellen
  static Future<EvaluationType> newEvaluationType(String name, AssessmentType assessmentType, bool showInCalendar) async {

    final newType = EvaluationType(
      name: name,
      assessmentType: assessmentType,
      showInCalendar: showInCalendar,
    );

    await SqliteStorage.database.insert(
      'evaluation_types',
      newType.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return newType;
  }

  /// Bestehenden EvaluationType bearbeiten
  static Future<void> editEvaluationType(EvaluationType type, {String? name, AssessmentType? assessmentType, bool? showInCalendar}) async {

    name ??= type.name;
    assessmentType ??= type.assessmentType;
    showInCalendar ??= type.showInCalendar;

    type.name = name;
    type.assessmentType = assessmentType;
    type.showInCalendar = showInCalendar;

    await SqliteStorage.database.update(
      'evaluation_types',
      type.toJson(),
      where: 'id = ?',
      whereArgs: [type.id],
    );
  }

  /// EvaluationType löschen (nur, wenn keine Evaluation referenziert)
  static Future<void> deleteEvaluationType(EvaluationType type) async {
    final db = SqliteStorage.database;

    final List<Map<String, dynamic>> linked = await db.query(
      'evaluations',
      where: 'evaluationTypeId = ?',
      whereArgs: [type.id],
      limit: 1,
    );

    if (linked.isNotEmpty) return; // noch verwendet, nicht löschen

    await db.delete(
      'evaluation_types',
      where: 'id = ?',
      whereArgs: [type.id],
    );
  }

  /// Mehrere EvaluationTypes löschen
  static Future<void> deleteAllEvaluationTypes(List<EvaluationType> types) async {
    for (final t in types) {
      await deleteEvaluationType(t);
    }
  }

  /// EvaluationTypes aus JSON importieren
  static Future<void> buildFromJson(List<Map<String, dynamic>> jsonData) async {
    final all = await findAll();
    await deleteAllEvaluationTypes(all);

    for (final e in jsonData) {
      final type = EvaluationType.fromJson(e);
      await SqliteStorage.database.insert(
        'evaluation_types',
        type.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
