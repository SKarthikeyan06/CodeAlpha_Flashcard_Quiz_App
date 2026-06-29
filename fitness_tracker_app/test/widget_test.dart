import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fitness_tracker_app/main.dart';
import 'package:fitness_tracker_app/controllers/dashboard_controller.dart';
import 'package:fitness_tracker_app/controllers/log_controller.dart';

void main() {
  testWidgets('Smoke test - Fitness Tracker App loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DashboardController()),
          ChangeNotifierProvider(create: (_) => LogController()),
        ],
        child: const MyApp(uid: 'test_user'),
      ),
    );

    // Verify that the title is displayed.
    expect(find.text('Fitness Tracker'), findsOneWidget);
  });
}
