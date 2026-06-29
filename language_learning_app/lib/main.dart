import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Controllers
import 'controllers/home_controller.dart';
import 'controllers/lesson_controller.dart';
import 'controllers/flashcard_controller.dart';
import 'controllers/quiz_controller.dart';
import 'controllers/progress_controller.dart';

// Services
import 'services/auth_service.dart';
import 'services/tts_service.dart';
import 'services/sync_service.dart';

// Screens
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try-caught Firebase core init for safe local-only fallback
  try {
    if (!kIsWeb) {
      await Firebase.initializeApp();
      print("Firebase initialized successfully on mobile.");
    } else {
      print("Firebase initialization on Web skipped (requires firebase_options.dart). Operating in Local Web Fallback Mode.");
    }
  } catch (e) {
    print("Firebase initialization skipped or failed: $e");
  }

  // Initialize Text-To-Speech engine
  final tts = TtsService();
  await tts.init();

  // Retrieve or generate persistent user ID
  final uid = await AuthService().getOrCreateUid();
  print("Current User ID: $uid");

  // Attempt background cloud synchronization
  try {
    await SyncService().syncAll(uid);
  } catch (e) {
    print("Initial sync failed: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => LessonController()),
        ChangeNotifierProvider(create: (_) => FlashcardController()),
        ChangeNotifierProvider(create: (_) => QuizController()),
        ChangeNotifierProvider(create: (_) => ProgressController()),
        Provider<TtsService>.value(value: tts),
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
      title: 'Tamil Language App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F9D58), // Growth Green
          primary: const Color(0xFF0F9D58),
          secondary: const Color(0xFF4285F4),
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
