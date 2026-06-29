import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/local_db.dart';
import '../models/user_progress.dart';

class ProgressController extends ChangeNotifier {
  List<UserProgress> allProgress = [];
  Map<String, double> categoryCompletion = {}; // Category -> Completion Percentage (0.0 to 1.0)
  List<Map<String, dynamic>> weeklyActivity = []; // List of {'day': 'Mon', 'xp': 20}
  int totalCardsLearned = 0;
  int totalQuizzesTaken = 0;
  int totalXp = 0;
  double overallPercent = 0.0;
  bool isLoading = false;

  Future<void> loadProgress() async {
    isLoading = true;
    notifyListeners();

    try {
      // Load Profile statistics
      final profile = await LocalDb.instance.getProfileData();
      if (profile != null) {
        totalXp = profile['total_xp'] as int;
        totalQuizzesTaken = profile['total_quizzes'] as int;
      }

      // Load progress rows
      allProgress = await LocalDb.instance.getAllProgress();

      // Load all lessons to group by categories
      final rawLessons = await LocalDb.instance.getAllLessons();
      
      // 1. Calculate cards learned
      totalCardsLearned = await LocalDb.instance.getLearnedCardsCount();

      // 2. Calculate category completion
      final Map<String, List<String>> categoryLessons = {}; // Category -> Lesson IDs
      for (var row in rawLessons) {
        final cat = row['category'] as String;
        final id = row['id'] as String;
        categoryLessons.putIfAbsent(cat, () => []).add(id);
      }

      categoryCompletion.clear();
      int completedLessonsCount = 0;

      categoryLessons.forEach((cat, lessonIds) {
        int completedInCat = 0;
        for (var lid in lessonIds) {
          final isDone = allProgress.any((p) => p.lessonId == lid && p.isCompleted);
          if (isDone) {
            completedInCat++;
            completedLessonsCount++;
          }
        }
        categoryCompletion[cat] = completedInCat / lessonIds.length;
      });

      // 3. Overall completion percentage
      if (rawLessons.isNotEmpty) {
        overallPercent = completedLessonsCount / rawLessons.length;
      } else {
        overallPercent = 0.0;
      }

      // 4. Calculate last 7 days activity
      final today = DateTime.now();
      weeklyActivity = List.generate(7, (index) {
        final date = today.subtract(Duration(days: 6 - index));
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        final label = DateFormat('E').format(date); // Mon, Tue, etc.

        int xp = 0;
        // Check if there is studied activity on this date
        for (var p in allProgress) {
          if (p.lastStudied == dateStr) {
            // Estimate XP generated on that day
            xp += p.cardsLearned * 2;
            xp += p.isCompleted ? 50 : 0;
            xp += p.quizAttempts * 10;
          }
        }
        
        // Ensure there is at least some base XP visible on the chart for streak days if they have any streak
        if (profile != null && profile['last_login_date'] == dateStr) {
          xp += 5; // Login bonus
        }

        return {
          'day': label,
          'xp': xp,
        };
      });

    } catch (e) {
      print("Error loading progress: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
