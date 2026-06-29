import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard.dart';
import '../models/quiz_attempt.dart';
import '../services/storage_service.dart';

class FlashcardProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Flashcard> _cards = [];
  List<QuizAttempt> _attempts = [];
  bool _isDarkMode = false;

  List<Flashcard> get cards => _cards;
  List<QuizAttempt> get attempts => _attempts;
  bool get isDarkMode => _isDarkMode;

  // Load theme preference
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // Load all cards and quiz attempts from database
  Future<void> loadCards() async {
    _cards = await _storageService.getAllCards();
    _attempts = await _storageService.getQuizAttempts();
    notifyListeners();
  }

  // Add a new card
  Future<void> addCard(Flashcard flashcard) async {
    await _storageService.addCard(flashcard);
    _cards.add(flashcard);
    notifyListeners();
  }

  // Update a card
  Future<void> updateCard(Flashcard flashcard) async {
    await _storageService.updateCard(flashcard);
    final index = _cards.indexWhere((c) => c.id == flashcard.id);
    if (index >= 0) {
      _cards[index] = flashcard;
      notifyListeners();
    }
  }

  // Delete a card
  Future<void> deleteCard(String id) async {
    await _storageService.deleteCard(id);
    _cards.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // Save a quiz attempt
  Future<void> saveQuizAttempt(QuizAttempt attempt) async {
    await _storageService.saveQuizAttempt(attempt);
    _attempts.insert(0, attempt);
    notifyListeners();
  }
}
