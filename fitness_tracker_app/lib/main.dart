import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitness_tracker_app/services/auth_service.dart';
import 'package:fitness_tracker_app/services/sync_service.dart';
import 'package:fitness_tracker_app/controllers/dashboard_controller.dart';
import 'package:fitness_tracker_app/controllers/log_controller.dart';
import 'package:fitness_tracker_app/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  String uid = 'local_user';
  
  try {
    await Firebase.initializeApp();
    // Sign in anonymously to get UID
    uid = await AuthService().getOrCreateUid();
    // Sync any pending logs from last offline session
    await SyncService().syncPendingLogs(uid);
  } catch (e) {
    debugPrint('Firebase initialization failed/skipped: $e');
    debugPrint('Running in local-only mode. Connect Firebase to enable background synchronization.');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => LogController()),
      ],
      child: MyApp(uid: uid),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String uid;
  const MyApp({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D9E75),
          primary: const Color(0xFF1D9E75),
        ),
        useMaterial3: true,
      ),
      home: DashboardScreen(uid: uid),
    );
  }
}
