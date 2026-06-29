import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_progress.dart';

class FirebaseService {
  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      return null;
    }
  }

  bool get isAvailable => _db != null;

  // Upload one lesson progress document
  Future<void> uploadProgress(String uid, UserProgress progress) async {
    final db = _db;
    if (db == null || uid.startsWith('local_')) return;
    try {
      await db
          .collection('users')
          .doc(uid)
          .collection('progress')
          .doc(progress.lessonId)
          .set(progress.toMap());
    } catch (e) {
      print("Firebase uploadProgress failed: $e");
    }
  }

  // Upload full profile / streak data
  Future<void> uploadProfile(String uid, Map<String, dynamic> profile) async {
    final db = _db;
    if (db == null || uid.startsWith('local_')) return;
    try {
      await db
          .collection('users')
          .doc(uid)
          .collection('profile')
          .doc('data')
          .set(profile);
    } catch (e) {
      print("Firebase uploadProfile failed: $e");
    }
  }

  // Fetch all progress from Firestore (fresh install restore)
  Future<List<Map<String, dynamic>>> fetchAllProgress(String uid) async {
    final db = _db;
    if (db == null || uid.startsWith('local_')) return [];
    try {
      final snapshot = await db
          .collection('users')
          .doc(uid)
          .collection('progress')
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Firebase fetchAllProgress failed: $e");
      return [];
    }
  }

  // Fetch profile from Firestore
  Future<Map<String, dynamic>?> fetchProfile(String uid) async {
    final db = _db;
    if (db == null || uid.startsWith('local_')) return null;
    try {
      final doc = await db
          .collection('users')
          .doc(uid)
          .collection('profile')
          .doc('data')
          .get();
      return doc.data();
    } catch (e) {
      print("Firebase fetchProfile failed: $e");
      return null;
    }
  }
}
