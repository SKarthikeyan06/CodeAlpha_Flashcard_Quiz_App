import 'package:flutter/foundation.dart';
import '../models/quote.dart';
import '../db/database_helper.dart';

class HomeController extends ChangeNotifier {
  Quote? currentQuote;
  bool isLoading = false;

  Future<void> loadRandomQuote() async {
    isLoading = true;
    notifyListeners();

    try {
      currentQuote = await DatabaseHelper.instance.getRandomQuote();
    } catch (e) {
      if (kDebugMode) {
        print("Error loading quote: $e");
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike() async {
    if (currentQuote == null || currentQuote!.id == null) return;
    
    final newLikedStatus = !currentQuote!.isLiked;
    currentQuote!.isLiked = newLikedStatus;
    notifyListeners();

    try {
      await DatabaseHelper.instance.toggleLike(
        currentQuote!.id!,
        newLikedStatus,
      );
    } catch (e) {
      // Revert if error
      currentQuote!.isLiked = !newLikedStatus;
      notifyListeners();
      if (kDebugMode) {
        print("Error toggling like: $e");
      }
    }
  }

  Future<void> addOrUpdateQuote(Quote quote) async {
    try {
      if (quote.id == null) {
        await DatabaseHelper.instance.insertQuote(quote);
      } else {
        await DatabaseHelper.instance.updateQuote(quote);
        if (currentQuote?.id == quote.id) {
          currentQuote = quote;
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving quote: $e");
      }
    }
  }

  Future<void> deleteQuote(int id) async {
    try {
      await DatabaseHelper.instance.deleteQuote(id);
      if (currentQuote?.id == id) {
        await loadRandomQuote();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting quote: $e");
      }
    }
  }
}
