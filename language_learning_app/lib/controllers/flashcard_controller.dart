import 'package:flutter/material.dart';
import '../db/local_db.dart';
import '../models/word_card.dart';

class FlashcardController extends ChangeNotifier {
  List<WordCard> cards = [];
  int currentIndex = 0;
  bool isFlipped = false;
  bool isLoading = false;
  int learnedCount = 0;

  WordCard? get currentCard => cards.isEmpty ? null : cards[currentIndex];

  bool get isLastCard => cards.isEmpty ? true : currentIndex == cards.length - 1;

  Future<void> loadCards(String lessonId) async {
    isLoading = true;
    notifyListeners();

    try {
      cards = await LocalDb.instance.getCardsForLesson(lessonId);
      currentIndex = 0;
      isFlipped = false;
      learnedCount = cards.where((c) => c.isLearned).length;

      // Update that the user has seen at least the first card (1 seen)
      if (cards.isNotEmpty) {
        await _updateSeenProgress();
      }
    } catch (e) {
      print("Error loading cards: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  void flipCard() {
    isFlipped = !isFlipped;
    notifyListeners();
  }

  Future<void> nextCard() async {
    if (currentIndex < cards.length - 1) {
      currentIndex++;
      isFlipped = false;
      await _updateSeenProgress();
      notifyListeners();
    }
  }

  void previousCard() {
    if (currentIndex > 0) {
      currentIndex--;
      isFlipped = false;
      notifyListeners();
    }
  }

  Future<void> markLearned(String cardId) async {
    if (cards.isEmpty) return;
    
    final card = cards[currentIndex];
    final wasLearned = card.isLearned;

    if (!wasLearned) {
      await LocalDb.instance.markCardLearned(cardId, true);
      card.isLearned = true;
      learnedCount = cards.where((c) => c.isLearned).length;
      
      // Update progress with learned count
      await _updateSeenProgress();
      
      // Reward 2 XP per learned card
      await LocalDb.instance.addXp(2);
      
      notifyListeners();
    }
  }

  Future<void> _updateSeenProgress() async {
    if (cards.isEmpty) return;
    final lessonId = cards[currentIndex].lessonId;
    final seen = currentIndex + 1;
    await LocalDb.instance.updateCardsSeen(lessonId, seen, learnedCount);
  }

  double get progressPercent => cards.isEmpty ? 0 : learnedCount / cards.length;
}
