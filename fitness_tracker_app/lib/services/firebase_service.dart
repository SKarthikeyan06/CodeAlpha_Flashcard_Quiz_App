import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_tracker_app/models/workout_log.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firestore path: users/{uid}/workout_logs/{logId}
  CollectionReference _logsRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('workout_logs');

  // Upload one log to Firestore
  Future<void> uploadLog(String uid, WorkoutLog log) async {
    await _logsRef(uid).doc(log.id).set(log.toFirestore());
  }

  // Delete one log from Firestore
  Future<void> deleteLog(String uid, String logId) async {
    await _logsRef(uid).doc(logId).delete();
  }

  // Fetch all logs from Firestore (used only on fresh install to restore data)
  Future<List<Map<String, dynamic>>> fetchAllLogs(String uid) async {
    final snapshot = await _logsRef(uid).get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }
}
