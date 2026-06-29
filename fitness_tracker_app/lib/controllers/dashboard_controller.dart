import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fitness_tracker_app/models/workout_log.dart';
import 'package:fitness_tracker_app/db/local_db.dart';
import 'package:fitness_tracker_app/services/firebase_service.dart';

class DashboardController extends ChangeNotifier {
  List<WorkoutLog> todayLogs = [];
  List<WorkoutLog> last7DaysLogs = [];
  int totalCaloriesToday = 0;
  int totalMinutesToday = 0;
  int totalStepsToday = 0;
  bool isLoading = false;

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    todayLogs      = await LocalDb.instance.getLogsForDate(today);
    last7DaysLogs  = await LocalDb.instance.getLast7Days();

    // Aggregate today totals
    totalCaloriesToday = todayLogs.fold(0, (sum, l) => sum + l.calories);
    totalMinutesToday  = todayLogs.fold(0, (sum, l) => sum + l.durationMins);
    totalStepsToday    = todayLogs.fold(0, (sum, l) => sum + l.steps);

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteLog(String id, String uid) async {
    await LocalDb.instance.deleteLog(id);
    try {
      await FirebaseService().deleteLog(uid, id);
    } catch (_) {
      // Ignore network errors for deletion (offline first, Firestore will sync or user is offline)
    }
    await loadDashboard();
  }
}
