import 'package:connectivity_plus/connectivity_plus.dart';
import '../db/local_db.dart';
import 'firebase_service.dart';

class SyncService {
  final FirebaseService _firebaseService = FirebaseService();

  Future<bool> _isConnected() async {
    try {
      final dynamic result = await Connectivity().checkConnectivity();
      if (result is List) {
        return result.isNotEmpty && !result.contains(ConnectivityResult.none);
      } else {
        return result != ConnectivityResult.none;
      }
    } catch (e) {
      print("Connectivity check failed: $e");
      return false;
    }
  }

  Future<void> syncAll(String uid) async {
    if (uid.startsWith('local_')) return;
    if (!await _isConnected()) return;

    await syncProgress(uid);
    await syncProfile(uid);
  }

  Future<void> syncProgress(String uid) async {
    if (uid.startsWith('local_')) return;
    if (!await _isConnected()) return;

    try {
      final unsynced = await LocalDb.instance.getUnsyncedProgress();
      for (var progress in unsynced) {
        await _firebaseService.uploadProgress(uid, progress);
        await LocalDb.instance.markProgressSynced(progress.id);
      }
    } catch (e) {
      print("syncProgress failed: $e");
    }
  }

  Future<void> syncProfile(String uid) async {
    if (uid.startsWith('local_')) return;
    if (!await _isConnected()) return;

    try {
      final profile = await LocalDb.instance.getProfileData();
      if (profile != null) {
        await _firebaseService.uploadProfile(uid, profile);
      }
    } catch (e) {
      print("syncProfile failed: $e");
    }
  }
}
