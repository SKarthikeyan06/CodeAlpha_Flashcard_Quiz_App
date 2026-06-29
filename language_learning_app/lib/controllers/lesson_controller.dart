import 'package:flutter/material.dart';
import '../db/local_db.dart';
import '../models/lesson.dart';

class LessonController extends ChangeNotifier {
  List<Lesson> lessons = [];
  List<Lesson> filteredLessons = [];
  String selectedLevel = 'Beginner';
  String selectedCategory = 'All';
  bool isLoading = false;

  final List<String> levels = [
    'Beginner',
    'Elementary',
    'Intermediate',
    'Advanced',
  ];

  List<String> categories = ['All'];

  Future<void> loadLessons() async {
    isLoading = true;
    notifyListeners();

    try {
      final rawLessons = await LocalDb.instance.getLessonsWithProgress(selectedLevel);
      lessons = rawLessons.map((m) => Lesson.fromMap(m)).toList();

      // Extract unique categories for the filter row
      final Set<String> cats = {'All'};
      for (var l in lessons) {
        cats.add(l.category);
      }
      categories = cats.toList();

      _filterLessons();
    } catch (e) {
      print("Error loading lessons: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  void setLevel(String level) {
    selectedLevel = level;
    selectedCategory = 'All';
    loadLessons();
  }

  void setCategory(String category) {
    selectedCategory = category;
    _filterLessons();
    notifyListeners();
  }

  void _filterLessons() {
    if (selectedCategory == 'All') {
      filteredLessons = List.from(lessons);
    } else {
      filteredLessons = lessons.where((l) => l.category == selectedCategory).toList();
    }
  }

  // Force database unlock check
  Future<void> checkAndUnlockLessons() async {
    // Reload to pick up any unlocks
    await loadLessons();
  }
}
