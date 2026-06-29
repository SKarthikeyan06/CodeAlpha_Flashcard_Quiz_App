import 'package:flutter/material.dart';
import 'package:fitness_tracker_app/models/workout_log.dart';
import 'package:fitness_tracker_app/db/local_db.dart';
import 'package:fitness_tracker_app/services/sync_service.dart';

class LogController extends ChangeNotifier {
  String selectedExercise = 'Running';
  bool isSaving = false;

  final List<String> exerciseTypes = [
    'Running', 'Walking', 'Cycling',
    'Gym', 'Yoga', 'Swimming', 'Other'
  ];

  void setExercise(String type) {
    selectedExercise = type;
    notifyListeners();
  }

  Future<void> saveLog(WorkoutLog log, String uid) async {
    isSaving = true;
    notifyListeners();

    // Save to SQLite first — always works offline
    await LocalDb.instance.insertLog(log);

    // Try to sync to Firebase immediately
    await SyncService().syncPendingLogs(uid);

    isSaving = false;
    notifyListeners();
  }
}
