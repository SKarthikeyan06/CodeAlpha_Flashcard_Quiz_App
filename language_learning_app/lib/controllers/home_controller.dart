import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/local_db.dart';
import '../models/lesson.dart';

class HomeController extends ChangeNotifier {
  int currentStreak = 0;
  int longestStreak = 0;
  int totalXp = 0;
  int totalLessonsCompleted = 0;
  int totalQuizzesTaken = 0;
  String currentLevel = 'Beginner';
  List<Lesson> recentLessons = [];
  bool isLoading = false;

  Future<void> loadHome() async {
    isLoading = true;
    notifyListeners();

    await checkAndUpdateStreak();
    await _loadStats();

    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadStats() async {
    final profile = await LocalDb.instance.getProfileData();
    if (profile != null) {
      currentStreak = profile['current_streak'] as int;
      longestStreak = profile['longest_streak'] as int;
      totalXp = profile['total_xp'] as int;
      totalLessonsCompleted = profile['total_lessons'] as int;
      totalQuizzesTaken = profile['total_quizzes'] as int;
      currentLevel = profile['current_level'] as String;
    }

    final recentData = await LocalDb.instance.getRecentLessons();
    recentLessons = recentData.map((m) => Lesson.fromMap(m)).toList();
  }

  Future<void> checkAndUpdateStreak() async {
    await LocalDb.instance.checkAndUpdateStreak();
    
    // Refresh local metrics
    final updatedProfile = await LocalDb.instance.getProfileData();
    if (updatedProfile != null) {
      currentStreak = updatedProfile['current_streak'] as int;
      longestStreak = updatedProfile['longest_streak'] as int;
      totalXp = updatedProfile['total_xp'] as int;
      currentLevel = updatedProfile['current_level'] as String;
    }
  }

  // Helper method to add XP directly and refresh
  Future<void> rewardXp(int xp) async {
    await LocalDb.instance.addXp(xp);
    await _loadStats();
    notifyListeners();
  }
}
