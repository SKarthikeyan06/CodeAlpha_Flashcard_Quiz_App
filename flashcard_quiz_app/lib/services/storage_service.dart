import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/flashcard.dart';
import '../models/quiz_attempt.dart';

class StorageService {
  static Database? _database;
  static const String _tableName = 'flashcards';
  static const String _attemptsTableName = 'quiz_attempts';

  // Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite database is not supported on web. Use SharedPreferences fallback instead.');
    }
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'quiz.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create Flashcards table
        await db.execute(
          '''
          CREATE TABLE $_tableName(
            id TEXT PRIMARY KEY,
            question TEXT NOT NULL,
            answer TEXT NOT NULL,
            difficulty TEXT NOT NULL DEFAULT 'Medium'
          )
          ''',
        );

        // Create Quiz Attempts table
        await db.execute(
          '''
          CREATE TABLE $_attemptsTableName(
            id TEXT PRIMARY KEY,
            score TEXT NOT NULL,
            correct INTEGER NOT NULL,
            total INTEGER NOT NULL,
            attempt_time TEXT NOT NULL
          )
          ''',
        );
      },
    );
  }

  // Get all flashcards
  Future<List<Flashcard>> getAllCards() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final List<String> list = prefs.getStringList(_tableName) ?? [];
      return list.map((item) => Flashcard.fromMap(jsonDecode(item))).toList();
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) => Flashcard.fromMap(maps[i]));
  }

  // Add a new flashcard
  Future<void> addCard(Flashcard flashcard) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final List<String> list = prefs.getStringList(_tableName) ?? [];
      final List<Flashcard> cards = list.map((item) => Flashcard.fromMap(jsonDecode(item))).toList();
      cards.add(flashcard);
      final List<String> newList = cards.map((c) => jsonEncode(c.toMap())).toList();
      await prefs.setStringList(_tableName, newList);
      return;
    }

    final db = await database;
    await db.insert(
      _tableName,
      flashcard.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update a flashcard
  Future<void> updateCard(Flashcard flashcard) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final List<String> list = prefs.getStringList(_tableName) ?? [];
      final List<Flashcard> cards = list.map((item) => Flashcard.fromMap(jsonDecode(item))).toList();
      final index = cards.indexWhere((c) => c.id == flashcard.id);
      if (index >= 0) {
        cards[index] = flashcard;
        final List<String> newList = cards.map((c) => jsonEncode(c.toMap())).toList();
        await prefs.setStringList(_tableName, newList);
      }
      return;
    }

    final db = await database;
    await db.update(
      _tableName,
      flashcard.toMap(),
      where: 'id = ?',
      whereArgs: [flashcard.id],
    );
  }

  // Delete a flashcard
  Future<void> deleteCard(String id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final List<String> list = prefs.getStringList(_tableName) ?? [];
      final List<Flashcard> cards = list.map((item) => Flashcard.fromMap(jsonDecode(item))).toList();
      cards.removeWhere((c) => c.id == id);
      final List<String> newList = cards.map((c) => jsonEncode(c.toMap())).toList();
      await prefs.setStringList(_tableName, newList);
      return;
    }

    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear all flashcards
  Future<void> clearAllCards() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tableName);
      return;
    }

    final db = await database;
    await db.delete(_tableName);
  }

  // Get all quiz attempts
  Future<List<QuizAttempt>> getQuizAttempts() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final List<String> list = prefs.getStringList(_attemptsTableName) ?? [];
      return list.map((item) => QuizAttempt.fromMap(jsonDecode(item))).toList();
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _attemptsTableName,
      orderBy: 'attempt_time DESC',
    );
    return List.generate(maps.length, (i) => QuizAttempt.fromMap(maps[i]));
  }

  // Save a quiz attempt
  Future<void> saveQuizAttempt(QuizAttempt attempt) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final List<String> list = prefs.getStringList(_attemptsTableName) ?? [];
      final List<QuizAttempt> attempts = list.map((item) => QuizAttempt.fromMap(jsonDecode(item))).toList();
      
      // Keep attempts sorted by time descending, inserting at index 0 is clean
      attempts.insert(0, attempt);
      
      final List<String> newList = attempts.map((a) => jsonEncode(a.toMap())).toList();
      await prefs.setStringList(_attemptsTableName, newList);
      return;
    }

    final db = await database;
    await db.insert(
      _attemptsTableName,
      attempt.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
