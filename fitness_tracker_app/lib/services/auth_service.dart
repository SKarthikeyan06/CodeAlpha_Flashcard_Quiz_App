import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in anonymously — gives each device a unique UID
  // Called once on app start from main.dart
  Future<String> getOrCreateUid() async {
    User? user = _auth.currentUser;
    user ??= (await _auth.signInAnonymously()).user;
    return user!.uid;
  }
}
