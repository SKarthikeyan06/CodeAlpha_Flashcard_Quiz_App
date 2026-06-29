import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fitness_tracker_app/db/local_db.dart';
import 'package:fitness_tracker_app/services/firebase_service.dart';

class SyncService {
  final LocalDb _localDb = LocalDb.instance;
  final FirebaseService _firebaseService = FirebaseService();

  // Called on app start and after every new log is saved
  Future<void> syncPendingLogs(String uid) async {
    // Check internet connectivity
    final dynamic result = await Connectivity().checkConnectivity();
    bool isConnected = false;
    
    // Support older and newer connectivity_plus return types (single or list)
    if (result is List) {
      isConnected = result.isNotEmpty && !result.contains(ConnectivityResult.none);
    } else {
      isConnected = result != ConnectivityResult.none;
    }
    
    if (!isConnected) return;

    // Get all unsynced logs from SQLite
    final unsyncedLogs = await _localDb.getUnsyncedLogs();
    if (unsyncedLogs.isEmpty) return;

    // Push each one to Firestore
    for (final log in unsyncedLogs) {
      try {
        await _firebaseService.uploadLog(uid, log);
        await _localDb.markSynced(log.id);
      } catch (_) {
        // Skip failed log — will retry next time
        continue;
      }
    }
  }
}
