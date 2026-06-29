# Fitness Tracker App — Flutter Implementation Plan
## CodeAlpha Internship — Task 3

---

## App overview

A Flutter fitness tracking app where users manually log daily workouts,
track calories burned, steps walked, and workout duration. Features a
dashboard with progress rings and weekly bar chart. Data is stored
locally in SQLite and synced to Firebase Firestore when internet is
available — satisfying both storage options mentioned in the task PDF.

---

## Decision: SQLite + Firebase (both)

- SQLite — offline-first, instant saves, always works
- Firebase Firestore — cloud backup, synced when internet available
- App works 100% without internet, syncs silently in background

---

## Tech stack

| Layer | Package |
|---|---|
| Framework | Flutter (Dart) |
| Local storage | sqflite ^2.3.0 |
| Cloud backend | cloud_firestore ^4.15.0 |
| Authentication | firebase_auth ^4.17.0 |
| Firebase core | firebase_core ^2.27.0 |
| State management | provider ^6.1.1 |
| Charts | fl_chart ^0.67.0 |
| Date formatting | intl ^0.19.0 |
| Goals storage | shared_preferences ^2.2.2 |
| Connectivity | connectivity_plus ^5.0.2 |
| Unique ID | uuid ^4.3.3 |

---

## pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.9.0
  firebase_core: ^2.27.0
  firebase_auth: ^4.17.0
  cloud_firestore: ^4.15.0
  fl_chart: ^0.67.0
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  intl: ^0.19.0
  connectivity_plus: ^5.0.2
  uuid: ^4.3.3
```

---

## Firebase setup (do this before writing code)

1. Go to console.firebase.google.com
2. Create new project — name it FitnessTrackerApp
3. Add Android app — enter your Flutter package name
4. Download google-services.json → place at android/app/google-services.json
5. In Firebase console → Build → Firestore Database → Create database → Start in test mode
6. In Firebase console → Build → Authentication → Sign-in method → Anonymous → Enable
7. In android/build.gradle add: classpath 'com.google.gms:google-services:4.4.0'
8. In android/app/build.gradle add at bottom: apply plugin: 'com.google.gms.google-services'

---

## File structure

```
lib/
├── main.dart
├── models/
│   └── workout_log.dart
├── db/
│   └── local_db.dart
├── services/
│   ├── firebase_service.dart
│   ├── sync_service.dart
│   └── auth_service.dart
├── controllers/
│   ├── dashboard_controller.dart
│   └── log_controller.dart
├── screens/
│   ├── dashboard_screen.dart
│   ├── log_workout_screen.dart
│   ├── history_screen.dart
│   └── goals_screen.dart
└── widgets/
    ├── calorie_ring.dart
    ├── weekly_bar_chart.dart
    ├── activity_card.dart
    └── stat_tile.dart
```

---

## Model — workout_log.dart

```dart
import 'package:uuid/uuid.dart';

class WorkoutLog {
  final String id;
  final String date;          // format: YYYY-MM-DD
  final String exerciseType;  // Running, Walking, Cycling, Gym, Yoga, Swimming, Other
  final int durationMins;
  final int calories;
  final int steps;
  final String notes;
  final bool isSynced;

  WorkoutLog({
    String? id,
    required this.date,
    required this.exerciseType,
    required this.durationMins,
    required this.calories,
    this.steps = 0,
    this.notes = '',
    this.isSynced = false,
  }) : id = id ?? const Uuid().v4();

  factory WorkoutLog.fromMap(Map<String, dynamic> map) => WorkoutLog(
        id:           map['id'],
        date:         map['date'],
        exerciseType: map['exercise_type'],
        durationMins: map['duration_mins'],
        calories:     map['calories'],
        steps:        map['steps'] ?? 0,
        notes:        map['notes'] ?? '',
        isSynced:     map['is_synced'] == 1,
      );

  Map<String, dynamic> toMap() => {
        'id':            id,
        'date':          date,
        'exercise_type': exerciseType,
        'duration_mins': durationMins,
        'calories':      calories,
        'steps':         steps,
        'notes':         notes,
        'is_synced':     isSynced ? 1 : 0,
      };

  // Used when pushing to Firestore — no is_synced field needed in cloud
  Map<String, dynamic> toFirestore() => {
        'date':          date,
        'exercise_type': exerciseType,
        'duration_mins': durationMins,
        'calories':      calories,
        'steps':         steps,
        'notes':         notes,
        'created_at':    DateTime.now().toIso8601String(),
      };
}
```

---

## SQLite layer — local_db.dart

### Table SQL

```sql
CREATE TABLE workout_logs (
  id             TEXT PRIMARY KEY,
  date           TEXT NOT NULL,
  exercise_type  TEXT NOT NULL,
  duration_mins  INTEGER DEFAULT 0,
  calories       INTEGER DEFAULT 0,
  steps          INTEGER DEFAULT 0,
  notes          TEXT DEFAULT '',
  is_synced      INTEGER DEFAULT 0
);
```

### Full class structure

```dart
class LocalDb {
  static final LocalDb instance = LocalDb._();
  static Database? _db;
  LocalDb._();

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'fitness.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workout_logs (
        id             TEXT PRIMARY KEY,
        date           TEXT NOT NULL,
        exercise_type  TEXT NOT NULL,
        duration_mins  INTEGER DEFAULT 0,
        calories       INTEGER DEFAULT 0,
        steps          INTEGER DEFAULT 0,
        notes          TEXT DEFAULT '',
        is_synced      INTEGER DEFAULT 0
      )
    ''');
  }

  // Insert new workout log
  Future<void> insertLog(WorkoutLog log) async {
    final db = await database;
    await db.insert('workout_logs', log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get all logs for a specific date (used by dashboard today summary)
  Future<List<WorkoutLog>> getLogsForDate(String date) async {
    final db = await database;
    final rows = await db.query('workout_logs',
        where: 'date = ?', whereArgs: [date], orderBy: 'rowid DESC');
    return rows.map(WorkoutLog.fromMap).toList();
  }

  // Get logs for last 7 days (used by weekly bar chart)
  Future<List<WorkoutLog>> getLast7Days() async {
    final db = await database;
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 6));
    final cutoff = DateFormat('yyyy-MM-dd').format(sevenDaysAgo);
    final rows = await db.query('workout_logs',
        where: 'date >= ?', whereArgs: [cutoff], orderBy: 'date ASC');
    return rows.map(WorkoutLog.fromMap).toList();
  }

  // Get all logs for history screen
  Future<List<WorkoutLog>> getAllLogs() async {
    final db = await database;
    final rows =
        await db.query('workout_logs', orderBy: 'date DESC, rowid DESC');
    return rows.map(WorkoutLog.fromMap).toList();
  }

  // Delete a log by id
  Future<void> deleteLog(String id) async {
    final db = await database;
    await db.delete('workout_logs', where: 'id = ?', whereArgs: [id]);
  }

  // Get all logs not yet synced to Firebase
  Future<List<WorkoutLog>> getUnsyncedLogs() async {
    final db = await database;
    final rows = await db
        .query('workout_logs', where: 'is_synced = 0');
    return rows.map(WorkoutLog.fromMap).toList();
  }

  // Mark a log as synced after successful Firebase upload
  Future<void> markSynced(String id) async {
    final db = await database;
    await db.update('workout_logs', {'is_synced': 1},
        where: 'id = ?', whereArgs: [id]);
  }
}
```

---

## Auth service — auth_service.dart

```dart
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
```

---

## Firebase service — firebase_service.dart

```dart
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
```

---

## Sync service — sync_service.dart

```dart
class SyncService {
  final LocalDb _localDb = LocalDb.instance;
  final FirebaseService _firebaseService = FirebaseService();
  final ConnectivityResult _connectivity = ConnectivityResult.none;

  // Called on app start and after every new log is saved
  Future<void> syncPendingLogs(String uid) async {
    // Check internet connectivity
    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) return;

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
```

---

## main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Sign in anonymously to get UID
  final uid = await AuthService().getOrCreateUid();

  // Sync any pending logs from last offline session
  await SyncService().syncPendingLogs(uid);

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D9E75)),
        useMaterial3: true,
      ),
      home: DashboardScreen(uid: uid),
    );
  }
}
```

---

## Controllers

### dashboard_controller.dart

```dart
class DashboardController extends ChangeNotifier {
  List<WorkoutLog> todayLogs = [];
  List<WorkoutLog> last7DaysLogs = [];
  int totalCaloriesToday = 0;
  int totalMinutesToday = 0;
  int totalStepsToday = 0;
  bool isLoading = false;

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    todayLogs      = await LocalDb.instance.getLogsForDate(today);
    last7DaysLogs  = await LocalDb.instance.getLast7Days();

    // Aggregate today totals
    totalCaloriesToday = todayLogs.fold(0, (sum, l) => sum + l.calories);
    totalMinutesToday  = todayLogs.fold(0, (sum, l) => sum + l.durationMins);
    totalStepsToday    = todayLogs.fold(0, (sum, l) => sum + l.steps);

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteLog(String id, String uid) async {
    await LocalDb.instance.deleteLog(id);
    await FirebaseService().deleteLog(uid, id);
    await loadDashboard();
  }
}
```

### log_controller.dart

```dart
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
```

---

## Screen 1 — dashboard_screen.dart

### Widget tree

```
DashboardScreen
├── AppBar
│   ├── Title — "Fitness Tracker"
│   ├── IconButton(history icon) → HistoryScreen
│   └── IconButton(flag icon) → GoalsScreen
├── Body — SingleChildScrollView → Column
│   ├── DateHeader
│   │   └── Text — "Today, Wednesday 25 June"
│   ├── Row — 3 StatTile widgets
│   │   ├── StatTile(icon: flame, label: Calories, value: totalCaloriesToday)
│   │   ├── StatTile(icon: timer, label: Minutes, value: totalMinutesToday)
│   │   └── StatTile(icon: steps, label: Steps, value: totalStepsToday)
│   ├── CalorieRing(caloriestoday, dailyGoal)
│   ├── SectionHeader — "Weekly Progress"
│   ├── WeeklyBarChart(last7DaysLogs)
│   ├── SectionHeader — "Today's Activities"
│   └── ListView
│       └── ActivityCard per item in todayLogs
└── FAB(+ icon) → LogWorkoutScreen
```

### Behaviour

- `initState` calls `dashboardController.loadDashboard()`
- After returning from `LogWorkoutScreen` use `Navigator.push.then((_) => loadDashboard())`
- Show `CircularProgressIndicator` centered when `isLoading` is true
- Show empty state text "No activities logged today. Tap + to add." when `todayLogs` is empty

---

## Screen 2 — log_workout_screen.dart

### Widget tree

```
LogWorkoutScreen
├── AppBar — "Log Workout"
└── Body — SingleChildScrollView → Column
    ├── DropdownButtonFormField
    │   └── Items: Running, Walking, Cycling, Gym, Yoga, Swimming, Other
    ├── TextFormField — Duration (minutes) — number keyboard
    ├── TextFormField — Calories burned — number keyboard
    ├── TextFormField — Steps (optional) — number keyboard
    ├── TextFormField — Notes (optional) — multiline
    └── ElevatedButton — "Save Workout"
        └── Shows CircularProgressIndicator when isSaving is true
```

### Behaviour

- Validate duration and calories are not empty and are greater than 0 before saving
- On save: create `WorkoutLog` with today's date, call `logController.saveLog(log, uid)`
- On success: show `SnackBar("Workout saved!")` then `Navigator.pop()`
- Use `Form` widget with `GlobalKey<FormState>` for validation

---

## Screen 3 — history_screen.dart

### Widget tree

```
HistoryScreen
├── AppBar — "Workout History"
└── Body
    └── FutureBuilder → loads getAllLogs() from SQLite
        ├── Loading → CircularProgressIndicator
        ├── Empty → Center text "No workouts logged yet"
        └── Data → ListView.builder
            └── Dismissible → ActivityCard (swipe left to delete)
```

### Behaviour

- `Dismissible` direction is `DismissDirection.endToStart`
- On dismiss: call `LocalDb.instance.deleteLog(id)` and `FirebaseService().deleteLog(uid, id)`
- Show red delete background with trash icon when swiping
- Group logs by date using a `Map<String, List<WorkoutLog>>` and show date headers between groups

---

## Screen 4 — goals_screen.dart

### Widget tree

```
GoalsScreen
├── AppBar — "My Goals"
└── Body — Column
    ├── Text — "Set your daily targets"
    ├── GoalSlider — Daily calorie goal (100–2000, step 50)
    ├── GoalSlider — Daily minutes goal (10–180, step 5)
    ├── GoalSlider — Daily steps goal (1000–20000, step 500)
    └── ElevatedButton — "Save Goals"
```

### Behaviour

- Load existing goals from `SharedPreferences` on init
- On save: write all three values to `SharedPreferences`
- Show `SnackBar("Goals updated!")` on save
- These values are read by `CalorieRing` and `StatTile` on the dashboard

---

## Widget — calorie_ring.dart

```dart
// Uses fl_chart PieChart with two sections
// Section 1 (filled): caloriestoday / dailyGoal * 360 degrees
// Section 2 (empty): remainder
// Center shows: "320\nkcal" in two lines
// Color logic:
//   >= goal     → Colors.green
//   50% to 99%  → Colors.amber
//   below 50%   → Color(0xFF1D9E75) app primary color
// Parameters: int caloriesToday, int dailyGoal
```

---

## Widget — weekly_bar_chart.dart

```dart
// Uses fl_chart BarChart
// X axis: last 7 days shown as Mon, Tue, Wed etc using intl DateFormat('E')
// Y axis: calories burned per day
// Build data: group last7DaysLogs by date, sum calories per date
// Fill missing dates with 0 so all 7 bars always appear
// Touched bar shows tooltip with exact calorie value
// Bar color: primary green, touched bar: darker green
// Parameters: List<WorkoutLog> last7DaysLogs
```

---

## Widget — stat_tile.dart

```dart
// StatTile is a StatelessWidget inside a Card
// Shows: icon (top), animated number value (middle), label text (bottom)
// Uses TweenAnimationBuilder<int> to count up from 0 to value on load
// Duration: 800ms, curve: Curves.easeOut
// Parameters: IconData icon, String label, int value, Color color
```

---

## Widget — activity_card.dart

```dart
// ActivityCard is a StatelessWidget
// Shows one WorkoutLog as a ListTile inside a Card
// Leading: colored circle icon based on exercise type
//   Running → red, Walking → green, Cycling → blue,
//   Gym → orange, Yoga → purple, Swimming → cyan, Other → grey
// Title: exercise type name
// Subtitle: "30 mins  •  250 kcal  •  2000 steps"
// Trailing: time or date text
// Parameters: WorkoutLog log
```

---

## Firestore data structure

```
Firestore/
└── users/
    └── {uid}/
        └── workout_logs/
            └── {logId}/
                ├── date:          "2026-06-25"
                ├── exercise_type: "Running"
                ├── duration_mins: 30
                ├── calories:      250
                ├── steps:         3000
                ├── notes:         "Morning run"
                └── created_at:    "2026-06-25T07:30:00"
```

---

## SharedPreferences keys

| Key | Type | Default |
|---|---|---|
| `goal_calories` | int | 500 |
| `goal_minutes` | int | 45 |
| `goal_steps` | int | 8000 |

---

## Exercise type → icon mapping

| Exercise | Icon | Color |
|---|---|---|
| Running | directions_run | Red |
| Walking | directions_walk | Green |
| Cycling | directions_bike | Blue |
| Gym | fitness_center | Orange |
| Yoga | self_improvement | Purple |
| Swimming | pool | Cyan |
| Other | sports | Grey |

---

## Build order (fastest path)

1. `workout_log.dart` — model
2. `local_db.dart` — SQLite with all methods
3. `auth_service.dart` — anonymous sign in
4. `firebase_service.dart` — Firestore upload/delete
5. `sync_service.dart` — offline sync logic
6. `log_controller.dart` — save logic
7. `dashboard_controller.dart` — aggregation logic
8. `main.dart` — Firebase init + providers
9. `stat_tile.dart` widget
10. `activity_card.dart` widget
11. `calorie_ring.dart` widget
12. `weekly_bar_chart.dart` widget
13. `log_workout_screen.dart` — app works end-to-end here
14. `dashboard_screen.dart` — full dashboard with all widgets
15. `history_screen.dart`
16. `goals_screen.dart`

---

## Polish UI checklist

- [ ] `TweenAnimationBuilder` count-up on stat tiles when dashboard loads
- [ ] `AnimatedSwitcher` on calorie ring value change
- [ ] `Dismissible` swipe-to-delete with red background in history
- [ ] `SnackBar` confirmation after saving workout
- [ ] Empty state illustration on history screen when no logs exist
- [ ] Colored exercise type icons in activity cards
- [ ] `CircularProgressIndicator` inside save button while saving
- [ ] Date grouping headers in history screen
- [ ] Tooltip on bar chart bars showing exact calorie value
- [ ] Consistent padding: 16px horizontal, 12px vertical throughout
- [ ] `ThemeData` with green `ColorScheme.fromSeed` matching fitness theme

---

## Sync behaviour summary

| Situation | What happens |
|---|---|
| User saves workout, online | Saved to SQLite + immediately synced to Firebase |
| User saves workout, offline | Saved to SQLite only, is_synced = 0 |
| User opens app next day, online | Sync service pushes all unsynced logs to Firebase |
| User opens app, still offline | Sync skipped silently, app works normally from SQLite |
| User deletes a log, online | Deleted from SQLite + deleted from Firebase |
| User deletes a log, offline | Deleted from SQLite only — Firebase stale until next sync |
