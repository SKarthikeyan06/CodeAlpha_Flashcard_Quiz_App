import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:fitness_tracker_app/models/workout_log.dart';

class LocalDb {
  static final LocalDb instance = LocalDb._();
  static Database? _db;
  LocalDb._();

  // In-memory mock database for Web platforms
  final List<WorkoutLog> _webDb = [];

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on Web. Using web memory database.');
    }
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'fitness.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workout_logs (
        id             TEXT PRIMARY KEY,
        date           TEXT NOT NULL,
        exercise_type  TEXT NOT NULL,
        duration_mins  INTEGER DEFAULT 0,
        calories       INTEGER DEFAULT 0,
        steps          INTEGER DEFAULT 0,
        notes          TEXT DEFAULT '',
        is_synced      INTEGER DEFAULT 0
      )
    ''');
  }

  // Insert new workout log
  Future<void> insertLog(WorkoutLog log) async {
    if (kIsWeb) {
      _webDb.removeWhere((item) => item.id == log.id);
      _webDb.add(log);
      return;
    }
    final db = await database;
    await db.insert('workout_logs', log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get all logs for a specific date (used by dashboard today summary)
  Future<List<WorkoutLog>> getLogsForDate(String date) async {
    if (kIsWeb) {
      return _webDb.where((log) => log.date == date).toList()..sort((a, b) => b.id.compareTo(a.id));
    }
    final db = await database;
    final rows = await db.query('workout_logs',
        where: 'date = ?', whereArgs: [date], orderBy: 'rowid DESC');
    return rows.map(WorkoutLog.fromMap).toList();
  }

  // Get logs for last 7 days (used by weekly bar chart)
  Future<List<WorkoutLog>> getLast7Days() async {
    if (kIsWeb) {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 6));
      final cutoff = DateFormat('yyyy-MM-dd').format(sevenDaysAgo);
      return _webDb.where((log) => log.date.compareTo(cutoff) >= 0).toList()..sort((a, b) => a.date.compareTo(b.date));
    }
    final db = await database;
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 6));
    final cutoff = DateFormat('yyyy-MM-dd').format(sevenDaysAgo);
    final rows = await db.query('workout_logs',
        where: 'date >= ?', whereArgs: [cutoff], orderBy: 'date ASC');
    return rows.map(WorkoutLog.fromMap).toList();
  }

  // Get all logs for history screen
  Future<List<WorkoutLog>> getAllLogs() async {
    if (kIsWeb) {
      return List<WorkoutLog>.from(_webDb)..sort((a, b) => b.date.compareTo(a.date));
    }
    final db = await database;
    final rows =
        await db.query('workout_logs', orderBy: 'date DESC, rowid DESC');
    return rows.map(WorkoutLog.fromMap).toList();
  }

  // Delete a log by id
  Future<void> deleteLog(String id) async {
    if (kIsWeb) {
      _webDb.removeWhere((log) => log.id == id);
      return;
    }
    final db = await database;
    await db.delete('workout_logs', where: 'id = ?', whereArgs: [id]);
  }

  // Get all logs not yet synced to Firebase
  Future<List<WorkoutLog>> getUnsyncedLogs() async {
    if (kIsWeb) {
      return _webDb.where((log) => !log.isSynced).toList();
    }
    final db = await database;
    final rows = await db
        .query('workout_logs', where: 'is_synced = 0');
    return rows.map(WorkoutLog.fromMap).toList();
  }

  // Mark a log as synced after successful Firebase upload
  Future<void> markSynced(String id) async {
    if (kIsWeb) {
      final index = _webDb.indexWhere((log) => log.id == id);
      if (index != -1) {
        final log = _webDb[index];
        _webDb[index] = WorkoutLog(
          id: log.id,
          date: log.date,
          exerciseType: log.exerciseType,
          durationMins: log.durationMins,
          calories: log.calories,
          steps: log.steps,
          notes: log.notes,
          isSynced: true,
        );
      }
      return;
    }
    final db = await database;
    await db.update('workout_logs', {'is_synced': 1},
        where: 'id = ?', whereArgs: [id]);
  }
}
