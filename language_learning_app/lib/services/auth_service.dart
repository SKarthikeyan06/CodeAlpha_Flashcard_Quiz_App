import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  // Use a getter to avoid throwing exceptions immediately if Firebase is not initialized
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      return null;
    }
  }

  Future<String> getOrCreateUid() async {
    final auth = _auth;
    if (auth != null) {
      try {
        User? user = auth.currentUser;
        if (user == null) {
          final credential = await auth.signInAnonymously();
          user = credential.user;
        }
        if (user != null) {
          return user.uid;
        }
      } catch (e) {
        print("Firebase Anonymous Auth failed: $e");
      }
    }

    // Fallback to local UUID in SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      String? localUid = prefs.getString('local_user_uid');
      if (localUid == null) {
        localUid = 'local_${const Uuid().v4()}';
        await prefs.setString('local_user_uid', localUid);
      }
      return localUid;
    } catch (e) {
      print("Error getting local UUID: $e");
      return 'local_fallback_user';
    }
  }
}
