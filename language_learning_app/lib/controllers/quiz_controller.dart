import 'package:flutter/material.dart';
import '../db/local_db.dart';
import '../models/quiz_question.dart';
import '../services/sync_service.dart';

class QuizController extends ChangeNotifier {
  List<QuizQuestion> questions = [];
  int currentIndex = 0;
  String? selectedAnswer;
  bool isAnswered = false;
  int correctCount = 0;
  bool isLoading = false;
  List<bool> answerResults = []; // Tracks true = correct, false = wrong for each question

  QuizQuestion? get currentQuestion => questions.isEmpty ? null : questions[currentIndex];

  bool get isLastQuestion => questions.isEmpty ? true : currentIndex == questions.length - 1;

  double get scorePercent => questions.isEmpty ? 0 : correctCount / questions.length;

  Future<void> loadQuiz(String lessonId) async {
    isLoading = true;
    notifyListeners();

    try {
      final all = await LocalDb.instance.getQuestionsForLesson(lessonId);
      final shuffled = List<QuizQuestion>.from(all)..shuffle();
      questions = shuffled.take(10).toList();
      currentIndex = 0;
      correctCount = 0;
      selectedAnswer = null;
      isAnswered = false;
      answerResults = [];
    } catch (e) {
      print("Error loading quiz: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  void selectAnswer(String answer) {
    if (isAnswered || questions.isEmpty) return;
    
    selectedAnswer = answer;
    isAnswered = true;
    
    // Check answer correctness (trim and case-insensitive check for fill in the blanks)
    final isCorrect = answer.trim().toLowerCase() == currentQuestion!.correctAns.trim().toLowerCase();
    
    if (isCorrect) {
      correctCount++;
    }
    answerResults.add(isCorrect);
    notifyListeners();
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      currentIndex++;
      selectedAnswer = null;
      isAnswered = false;
      notifyListeners();
    }
  }

  // Save quiz result to SQLite + trigger sync
  Future<void> saveResult(String lessonId, String uid) async {
    if (questions.isEmpty) return;

    final score = (scorePercent * 100).round();
    
    // Save to SQLite
    await LocalDb.instance.saveQuizResult(lessonId, score);

    // Reward XP: 10 XP per correct answer. If 100%, bonus 20 XP!
    int xpEarned = correctCount * 10;
    if (score == 100) {
      xpEarned += 20; // 100% bonus
    }
    
    if (xpEarned > 0) {
      await LocalDb.instance.addXp(xpEarned);
    }

    // Trigger Firestore sync in the background
    try {
      await SyncService().syncAll(uid);
    } catch (e) {
      print("Background sync failed: $e");
    }

    notifyListeners();
  }
}
