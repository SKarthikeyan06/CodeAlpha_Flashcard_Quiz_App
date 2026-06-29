# Language Learning App — Flutter Implementation Plan
## CodeAlpha Internship — Task 4 (Full Featured — Intermediate Level)

---

## App overview

A Flutter language learning app that teaches Tamil to English speakers
(and English to Tamil speakers). Users progress through daily lessons,
study flashcards with Tamil translations and pronunciation guides, take
quizzes to test their knowledge, track progress with streaks and scores,
and earn badges. All learning data is stored in SQLite locally and
synced to Firebase so progress is never lost.

---

## Language pair

| Teaching | From | To |
|---|---|---|
| Primary | English | Tamil |
| Reverse | Tamil | English |

---

## App level structure

The app has 4 levels of difficulty:

| Level | Description |
|---|---|
| Beginner | Basic greetings, numbers, colours, family words |
| Elementary | Common phrases, food, daily routines |
| Intermediate | Sentences, grammar rules, verbs, tenses |
| Advanced | Conversations, idioms, complex sentences |

Default on first launch: Beginner.
User unlocks next level after completing 80% of current level lessons.

---

## Tech stack

| Layer | Package |
|---|---|
| Framework | Flutter (Dart) |
| Local database | sqflite ^2.3.0 |
| Path helper | path ^1.9.0 |
| Cloud backend | cloud_firestore ^4.15.0 |
| Authentication | firebase_auth ^4.17.0 |
| Firebase core | firebase_core ^2.27.0 |
| State management | provider ^6.1.1 |
| Text to speech | flutter_tts ^3.8.5 |
| Charts / progress | fl_chart ^0.67.0 |
| Connectivity | connectivity_plus ^5.0.2 |
| Animations | flutter_animate ^4.5.0 |
| Unique ID | uuid ^4.3.3 |
| Date formatting | intl ^0.19.0 |
| Local preferences | shared_preferences ^2.2.2 |

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
  provider: ^6.1.1
  flutter_tts: ^3.8.5
  fl_chart: ^0.67.0
  connectivity_plus: ^5.0.2
  flutter_animate: ^4.5.0
  uuid: ^4.3.3
  intl: ^0.19.0
  shared_preferences: ^2.2.2
```

---

## Firebase setup

1. Go to console.firebase.google.com
2. Create project — name it LanguageLearningApp
3. Add Android app — enter Flutter package name
4. Download google-services.json → place at android/app/
5. Enable Firestore Database → Start in test mode
6. Enable Anonymous Authentication
7. Add google-services plugin to both build.gradle files

---

## File structure

```
lib/
├── main.dart
├── models/
│   ├── lesson.dart
│   ├── word_card.dart
│   ├── quiz_question.dart
│   └── user_progress.dart
├── db/
│   └── local_db.dart
├── services/
│   ├── auth_service.dart
│   ├── firebase_service.dart
│   ├── sync_service.dart
│   └── tts_service.dart
├── controllers/
│   ├── home_controller.dart
│   ├── lesson_controller.dart
│   ├── flashcard_controller.dart
│   ├── quiz_controller.dart
│   └── progress_controller.dart
├── screens/
│   ├── home_screen.dart
│   ├── lesson_list_screen.dart
│   ├── lesson_screen.dart
│   ├── flashcard_screen.dart
│   ├── quiz_screen.dart
│   ├── quiz_result_screen.dart
│   ├── progress_screen.dart
│   └── profile_screen.dart
└── widgets/
    ├── lesson_card.dart
    ├── flashcard_widget.dart
    ├── quiz_option_tile.dart
    ├── progress_ring.dart
    ├── streak_badge.dart
    ├── level_badge.dart
    └── bottom_nav.dart
```

---

## SQLite tables — local_db.dart

### Table 1 — lessons

Stores all lesson content. Seeded on first app launch.

```sql
CREATE TABLE lessons (
  id            TEXT PRIMARY KEY,
  title         TEXT NOT NULL,
  description   TEXT NOT NULL,
  category      TEXT NOT NULL,
  level         TEXT NOT NULL,
  order_index   INTEGER NOT NULL,
  total_cards   INTEGER DEFAULT 0,
  is_unlocked   INTEGER DEFAULT 0
);
```

### Table 2 — word_cards

Each lesson contains multiple word cards — English word, Tamil translation,
pronunciation guide, and example sentence.

```sql
CREATE TABLE word_cards (
  id              TEXT PRIMARY KEY,
  lesson_id       TEXT NOT NULL,
  english         TEXT NOT NULL,
  tamil           TEXT NOT NULL,
  transliteration TEXT NOT NULL,
  example_en      TEXT NOT NULL,
  example_ta      TEXT NOT NULL,
  category        TEXT NOT NULL,
  is_learned      INTEGER DEFAULT 0
);
```

### Table 3 — quiz_questions

Each lesson has quiz questions. Three types: multiple choice,
fill in the blank, true or false.

```sql
CREATE TABLE quiz_questions (
  id            TEXT PRIMARY KEY,
  lesson_id     TEXT NOT NULL,
  question_type TEXT NOT NULL,
  question_en   TEXT NOT NULL,
  question_ta   TEXT NOT NULL,
  correct_ans   TEXT NOT NULL,
  option_a      TEXT NOT NULL,
  option_b      TEXT NOT NULL,
  option_c      TEXT NOT NULL,
  option_d      TEXT NOT NULL
);
```

### Table 4 — user_progress

Tracks what the user has done per lesson. One row per lesson per user.

```sql
CREATE TABLE user_progress (
  id              TEXT PRIMARY KEY,
  lesson_id       TEXT NOT NULL,
  cards_seen      INTEGER DEFAULT 0,
  cards_learned   INTEGER DEFAULT 0,
  quiz_score      INTEGER DEFAULT 0,
  quiz_attempts   INTEGER DEFAULT 0,
  best_score      INTEGER DEFAULT 0,
  is_completed    INTEGER DEFAULT 0,
  last_studied    TEXT DEFAULT '',
  is_synced       INTEGER DEFAULT 0,
  UNIQUE(lesson_id)
);
```

### Table 5 — daily_streak

Tracks daily login streak and XP points.

```sql
CREATE TABLE daily_streak (
  id              INTEGER PRIMARY KEY,
  current_streak  INTEGER DEFAULT 0,
  longest_streak  INTEGER DEFAULT 0,
  last_login_date TEXT DEFAULT '',
  total_xp        INTEGER DEFAULT 0,
  total_lessons   INTEGER DEFAULT 0,
  total_quizzes   INTEGER DEFAULT 0,
  current_level   TEXT DEFAULT 'Beginner'
);
```

---

## Models

### lesson.dart

```dart
class Lesson {
  final String id;
  final String title;
  final String description;
  final String category;
  final String level;
  final int orderIndex;
  final int totalCards;
  bool isUnlocked;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.orderIndex,
    required this.totalCards,
    this.isUnlocked = false,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) => Lesson(
        id:          map['id'],
        title:       map['title'],
        description: map['description'],
        category:    map['category'],
        level:       map['level'],
        orderIndex:  map['order_index'],
        totalCards:  map['total_cards'],
        isUnlocked:  map['is_unlocked'] == 1,
      );

  Map<String, dynamic> toMap() => {
        'id':          id,
        'title':       title,
        'description': description,
        'category':    category,
        'level':       level,
        'order_index': orderIndex,
        'total_cards': totalCards,
        'is_unlocked': isUnlocked ? 1 : 0,
      };
}
```

### word_card.dart

```dart
class WordCard {
  final String id;
  final String lessonId;
  final String english;
  final String tamil;
  final String transliteration;
  final String exampleEn;
  final String exampleTa;
  final String category;
  bool isLearned;

  WordCard({
    required this.id,
    required this.lessonId,
    required this.english,
    required this.tamil,
    required this.transliteration,
    required this.exampleEn,
    required this.exampleTa,
    required this.category,
    this.isLearned = false,
  });

  factory WordCard.fromMap(Map<String, dynamic> map) => WordCard(
        id:              map['id'],
        lessonId:        map['lesson_id'],
        english:         map['english'],
        tamil:           map['tamil'],
        transliteration: map['transliteration'],
        exampleEn:       map['example_en'],
        exampleTa:       map['example_ta'],
        category:        map['category'],
        isLearned:       map['is_learned'] == 1,
      );

  Map<String, dynamic> toMap() => {
        'id':              id,
        'lesson_id':       lessonId,
        'english':         english,
        'tamil':           tamil,
        'transliteration': transliteration,
        'example_en':      exampleEn,
        'example_ta':      exampleTa,
        'category':        category,
        'is_learned':      isLearned ? 1 : 0,
      };
}
```

### quiz_question.dart

```dart
class QuizQuestion {
  final String id;
  final String lessonId;
  final String questionType; // multiple_choice, fill_blank, true_false
  final String questionEn;
  final String questionTa;
  final String correctAns;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;

  QuizQuestion({
    required this.id,
    required this.lessonId,
    required this.questionType,
    required this.questionEn,
    required this.questionTa,
    required this.correctAns,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) => QuizQuestion(
        id:           map['id'],
        lessonId:     map['lesson_id'],
        questionType: map['question_type'],
        questionEn:   map['question_en'],
        questionTa:   map['question_ta'],
        correctAns:   map['correct_ans'],
        optionA:      map['option_a'],
        optionB:      map['option_b'],
        optionC:      map['option_c'],
        optionD:      map['option_d'],
      );
}
```

### user_progress.dart

```dart
class UserProgress {
  final String id;
  final String lessonId;
  int cardsSeen;
  int cardsLearned;
  int quizScore;
  int quizAttempts;
  int bestScore;
  bool isCompleted;
  String lastStudied;
  bool isSynced;

  UserProgress({
    required this.id,
    required this.lessonId,
    this.cardsSeen = 0,
    this.cardsLearned = 0,
    this.quizScore = 0,
    this.quizAttempts = 0,
    this.bestScore = 0,
    this.isCompleted = false,
    this.lastStudied = '',
    this.isSynced = false,
  });

  factory UserProgress.fromMap(Map<String, dynamic> map) => UserProgress(
        id:           map['id'],
        lessonId:     map['lesson_id'],
        cardsSeen:    map['cards_seen'],
        cardsLearned: map['cards_learned'],
        quizScore:    map['quiz_score'],
        quizAttempts: map['quiz_attempts'],
        bestScore:    map['best_score'],
        isCompleted:  map['is_completed'] == 1,
        lastStudied:  map['last_studied'] ?? '',
        isSynced:     map['is_synced'] == 1,
      );

  Map<String, dynamic> toMap() => {
        'id':           id,
        'lesson_id':    lessonId,
        'cards_seen':   cardsSeen,
        'cards_learned':cardsLearned,
        'quiz_score':   quizScore,
        'quiz_attempts':quizAttempts,
        'best_score':   bestScore,
        'is_completed': isCompleted ? 1 : 0,
        'last_studied': lastStudied,
        'is_synced':    isSynced ? 1 : 0,
      };
}
```

---

## Seed content structure

### Lesson categories

| Category | Lessons | Level |
|---|---|---|
| Greetings | Vanakkam, Introductions, Farewells | Beginner |
| Numbers | 1–10, 11–100, Ordinals | Beginner |
| Colours | Basic colours, Shades | Beginner |
| Family | Parents, Siblings, Relations | Beginner |
| Food | Fruits, Vegetables, Meals | Elementary |
| Daily Routine | Morning, Afternoon, Evening | Elementary |
| Body Parts | Head, Hands, Internal | Elementary |
| Animals | Pets, Farm, Wild | Elementary |
| Verbs | Action words, Movement | Intermediate |
| Grammar | Sentence structure, Tenses | Intermediate |
| Conversations | Shop, Hospital, Travel | Intermediate |
| Idioms | Common Tamil idioms | Advanced |

### Sample word card data

```dart
// Lesson: Greetings → Beginner
{
  'english':         'Hello',
  'tamil':           'வணக்கம்',
  'transliteration': 'Vanakkam',
  'example_en':      'Hello, how are you?',
  'example_ta':      'வணக்கம், நீங்கள் எப்படி இருக்கிறீர்கள்?',
  'category':        'Greetings',
},
{
  'english':         'Thank you',
  'tamil':           'நன்றி',
  'transliteration': 'Nandri',
  'example_en':      'Thank you very much.',
  'example_ta':      'மிக்க நன்றி.',
  'category':        'Greetings',
},
{
  'english':         'Good morning',
  'tamil':           'காலை வணக்கம்',
  'transliteration': 'Kaalai vanakkam',
  'example_en':      'Good morning, sir.',
  'example_ta':      'காலை வணக்கம், ஐயா.',
  'category':        'Greetings',
},
{
  'english':         'What is your name?',
  'tamil':           'உங்கள் பெயர் என்ன?',
  'transliteration': 'Ungal peyar enna?',
  'example_en':      'Hello, what is your name?',
  'example_ta':      'வணக்கம், உங்கள் பெயர் என்ன?',
  'category':        'Greetings',
},
```

---

## TTS service — tts_service.dart

```dart
class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    await _tts.setLanguage('ta-IN');   // Tamil
    await _tts.setSpeechRate(0.5);     // Slow for learning
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  // Speak Tamil text
  Future<void> speakTamil(String text) async {
    await _tts.setLanguage('ta-IN');
    await _tts.speak(text);
  }

  // Speak English text
  Future<void> speakEnglish(String text) async {
    await _tts.setLanguage('en-US');
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
```

---

## Auth service — auth_service.dart

```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getOrCreateUid() async {
    User? user = _auth.currentUser;
    user ??= (await _auth.signInAnonymously()).user;
    return user!.uid;
  }
}
```

---

## Firebase service — firebase_service.dart

### Firestore structure

```
Firestore/
└── users/
    └── {uid}/
        ├── profile/
        │   └── data/
        │       ├── current_level: "Beginner"
        │       ├── current_streak: 7
        │       ├── longest_streak: 14
        │       ├── total_xp: 350
        │       ├── total_lessons: 5
        │       └── total_quizzes: 12
        └── progress/
            └── {lessonId}/
                ├── cards_seen: 10
                ├── cards_learned: 8
                ├── best_score: 90
                ├── is_completed: true
                └── last_studied: "2026-06-25"
```

### Methods

```dart
// Upload one lesson progress document
Future<void> uploadProgress(String uid, UserProgress progress)

// Upload full profile / streak data
Future<void> uploadProfile(String uid, Map<String, dynamic> profile)

// Fetch all progress from Firestore (fresh install restore)
Future<List<Map<String, dynamic>>> fetchAllProgress(String uid)

// Fetch profile from Firestore
Future<Map<String, dynamic>?> fetchProfile(String uid)
```

---

## Sync service — sync_service.dart

```dart
// On app start:
// 1. Check connectivity
// 2. Get all unsynced progress rows from SQLite
// 3. Push each to Firestore users/{uid}/progress/{lessonId}
// 4. Push streak data to Firestore users/{uid}/profile/data
// 5. Mark all pushed rows as is_synced = 1 in SQLite
// 6. If offline → skip silently

Future<void> syncAll(String uid)
Future<void> syncProgress(String uid)
Future<void> syncProfile(String uid)
```

---

## Controllers

### home_controller.dart

```dart
class HomeController extends ChangeNotifier {
  int currentStreak = 0;
  int longestStreak = 0;
  int totalXp = 0;
  int totalLessonsCompleted = 0;
  int totalQuizzesTaken = 0;
  String currentLevel = 'Beginner';
  List<Lesson> recentLessons = [];    // last 3 studied
  bool isLoading = false;

  Future<void> loadHome() async {
    isLoading = true;
    notifyListeners();

    // Load streak data from SQLite daily_streak table
    // Update streak: if last_login_date != today → increment streak
    // If last_login_date was 2+ days ago → reset streak to 1
    // Load 3 most recently studied lessons

    isLoading = false;
    notifyListeners();
  }

  // Called every time app opens to update streak
  Future<void> checkAndUpdateStreak() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // Compare today with last_login_date in daily_streak table
    // Update accordingly
  }
}
```

### lesson_controller.dart

```dart
class LessonController extends ChangeNotifier {
  List<Lesson> lessons = [];
  String selectedLevel = 'Beginner';
  String selectedCategory = 'All';
  bool isLoading = false;

  // Levels available
  final List<String> levels = [
    'Beginner', 'Elementary', 'Intermediate', 'Advanced'
  ];

  Future<void> loadLessons() async {
    isLoading = true;
    notifyListeners();
    // Query SQLite for lessons filtered by selectedLevel
    // Join with user_progress to show completion status
    isLoading = false;
    notifyListeners();
  }

  void setLevel(String level) {
    selectedLevel = level;
    loadLessons();
  }

  // Check if a lesson should be unlocked
  // First lesson of each level is always unlocked
  // Subsequent lessons unlock after previous is 80% complete
  Future<void> checkAndUnlockLessons() async {}
}
```

### flashcard_controller.dart

```dart
class FlashcardController extends ChangeNotifier {
  List<WordCard> cards = [];
  int currentIndex = 0;
  bool isFlipped = false;
  bool isLoading = false;
  int learnedCount = 0;

  WordCard? get currentCard =>
      cards.isEmpty ? null : cards[currentIndex];

  Future<void> loadCards(String lessonId) async {
    isLoading = true;
    notifyListeners();
    cards = await LocalDb.instance.getCardsForLesson(lessonId);
    currentIndex = 0;
    isFlipped = false;
    learnedCount = cards.where((c) => c.isLearned).length;
    isLoading = false;
    notifyListeners();
  }

  void flipCard() {
    isFlipped = !isFlipped;
    notifyListeners();
  }

  void nextCard() {
    if (currentIndex < cards.length - 1) {
      currentIndex++;
      isFlipped = false;
      notifyListeners();
    }
  }

  void previousCard() {
    if (currentIndex > 0) {
      currentIndex--;
      isFlipped = false;
      notifyListeners();
    }
  }

  Future<void> markLearned(String cardId) async {
    await LocalDb.instance.markCardLearned(cardId, true);
    cards[currentIndex].isLearned = true;
    learnedCount = cards.where((c) => c.isLearned).length;
    notifyListeners();
  }

  // Progress percentage for this lesson
  double get progressPercent =>
      cards.isEmpty ? 0 : learnedCount / cards.length;
}
```

### quiz_controller.dart

```dart
class QuizController extends ChangeNotifier {
  List<QuizQuestion> questions = [];
  int currentIndex = 0;
  String? selectedAnswer;
  bool isAnswered = false;
  int correctCount = 0;
  bool isLoading = false;
  List<bool> answerResults = [];  // true = correct, false = wrong

  QuizQuestion? get currentQuestion =>
      questions.isEmpty ? null : questions[currentIndex];

  bool get isLastQuestion => currentIndex == questions.length - 1;

  double get scorePercent =>
      questions.isEmpty ? 0 : correctCount / questions.length;

  Future<void> loadQuiz(String lessonId) async {
    isLoading = true;
    notifyListeners();
    final all = await LocalDb.instance.getQuestionsForLesson(lessonId);
    // Shuffle and take max 10 questions
    all.shuffle();
    questions = all.take(10).toList();
    currentIndex = 0;
    correctCount = 0;
    answerResults = [];
    isLoading = false;
    notifyListeners();
  }

  void selectAnswer(String answer) {
    if (isAnswered) return;
    selectedAnswer = answer;
    isAnswered = true;
    final correct = answer == currentQuestion!.correctAns;
    if (correct) correctCount++;
    answerResults.add(correct);
    notifyListeners();
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      currentIndex++;
      selectedAnswer = null;
      isAnswered = false;
      notifyListeners();
    }
  }

  // Save quiz result to SQLite + trigger sync
  Future<void> saveResult(String lessonId, String uid) async {
    final score = (scorePercent * 100).round();
    await LocalDb.instance.saveQuizResult(lessonId, score);
    await SyncService().syncAll(uid);
  }
}
```

### progress_controller.dart

```dart
class ProgressController extends ChangeNotifier {
  List<UserProgress> allProgress = [];
  Map<String, int> categoryCompletion = {};
  List<Map<String, dynamic>> weeklyActivity = [];
  int totalCardsLearned = 0;
  int totalQuizzesTaken = 0;
  double overallPercent = 0;
  bool isLoading = false;

  Future<void> loadProgress() async {
    isLoading = true;
    notifyListeners();
    // Load all progress rows from SQLite
    // Calculate per-category completion percentages
    // Calculate last 7 days activity for bar chart
    isLoading = false;
    notifyListeners();
  }
}
```

---

## main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await TtsService().init();

  final uid = await AuthService().getOrCreateUid();
  await SyncService().syncAll(uid);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => LessonController()),
        ChangeNotifierProvider(create: (_) => FlashcardController()),
        ChangeNotifierProvider(create: (_) => QuizController()),
        ChangeNotifierProvider(create: (_) => ProgressController()),
        Provider<TtsService>(create: (_) => TtsService()),
      ],
      child: MyApp(uid: uid),
    ),
  );
}
```

---

## Screen 1 — home_screen.dart

### Widget tree

```
HomeScreen
├── AppBar
│   ├── Title — "Learn Tamil"
│   └── IconButton(person) → ProfileScreen
├── Body — SingleChildScrollView → Column
│   ├── GreetingHeader
│   │   ├── Text — "Good morning! 🌅"
│   │   └── Text — "Day streak: 🔥 7 days"
│   ├── StreakCard
│   │   ├── StreakBadge(currentStreak)
│   │   ├── Text — Total XP: 350
│   │   └── LevelBadge(currentLevel)
│   ├── SectionHeader — "Continue Learning"
│   ├── Row — 3 RecentLessonCard widgets
│   │   └── Each shows lesson title + progress bar
│   ├── SectionHeader — "Quick Actions"
│   └── Row — 4 QuickActionButton widgets
│       ├── Lessons button → LessonListScreen
│       ├── Flashcards button → LessonListScreen (flashcard mode)
│       ├── Quiz button → LessonListScreen (quiz mode)
│       └── Progress button → ProgressScreen
└── BottomNav widget
```

### Behaviour

- `initState` calls `homeController.loadHome()` and `checkAndUpdateStreak()`
- Streak card animates in with `flutter_animate` slide + fade
- Recent lessons show last 3 studied with `LinearProgressIndicator`

---

## Screen 2 — lesson_list_screen.dart

### Widget tree

```
LessonListScreen
├── AppBar — "Lessons"
├── LevelSelector
│   └── Row of 4 level chips — Beginner, Elementary, Intermediate, Advanced
│       Locked levels show lock icon
├── Body — ListView.builder
│   └── LessonCard per lesson
│       ├── Leading — number badge or checkmark if completed
│       ├── Title — lesson title
│       ├── Subtitle — category + card count
│       ├── Trailing — LinearProgressIndicator
│       └── Locked overlay if is_unlocked = false
└── BottomNav widget
```

### Behaviour

- `initState` calls `lessonController.loadLessons()`
- Level chip tap calls `lessonController.setLevel(level)`
- Locked lesson card shows grey overlay + lock icon — not tappable
- Unlocked lesson tap → navigate to `LessonScreen(lesson: lesson)`
- Completed lessons show green checkmark badge

---

## Screen 3 — lesson_screen.dart

### Widget tree

```
LessonScreen
├── AppBar — lesson title
└── Body — Column
    ├── ProgressBar — cards learned / total cards
    ├── TabBar — 2 tabs
    │   ├── Tab 1 — "Flashcards"
    │   └── Tab 2 — "Quiz"
    └── TabBarView
        ├── Tab 1 → FlashcardScreen(lessonId)
        └── Tab 2 → QuizScreen(lessonId)
```

---

## Screen 4 — flashcard_screen.dart

### Widget tree

```
FlashcardScreen
├── Body — Column
│   ├── ProgressRow
│   │   ├── Text — "Card 3 of 10"
│   │   └── Text — "Learned: 2"
│   ├── Spacer
│   ├── FlashcardWidget
│   │   └── AnimatedSwitcher (flip animation)
│   │       ├── Front face
│   │       │   ├── Category chip
│   │       │   ├── English word (large, bold)
│   │       │   ├── Pronunciation hint text
│   │       │   └── Speaker icon button → TtsService.speakEnglish()
│   │       └── Back face
│   │           ├── Tamil text (large, Tamil font)
│   │           ├── Transliteration text (muted)
│   │           ├── Speaker icon → TtsService.speakTamil()
│   │           ├── Example EN sentence
│   │           └── Example TA sentence
│   ├── Spacer
│   ├── ActionRow
│   │   ├── IconButton — flip card
│   │   └── IconButton — mark as learned (checkmark)
│   └── NavigationRow
│       ├── OutlinedButton — Previous
│       └── ElevatedButton — Next
```

### Behaviour

- Card flip uses `TweenAnimationBuilder` rotating on Y-axis 180 degrees
- Speaker icon calls `TtsService.speakTamil(card.tamil)` or `speakEnglish(card.english)`
- Mark as learned → calls `flashcardController.markLearned(cardId)`
- Learned card shows green checkmark on corner
- On last card → show completion bottom sheet with XP earned and option to take quiz

---

## Screen 5 — quiz_screen.dart

### Widget tree

```
QuizScreen
├── AppBar
│   ├── Text — "Question 3 / 10"
│   └── LinearProgressIndicator (top)
└── Body — Column
    ├── QuestionCard
    │   ├── Category chip
    │   ├── Question text in English (large)
    │   └── Question text in Tamil (muted, smaller)
    ├── SpeakerButton → TtsService.speakEnglish(question)
    ├── Spacer
    ├── AnswerOptions — Column of 4 QuizOptionTile widgets
    │   ├── Option A tile
    │   ├── Option B tile
    │   ├── Option C tile
    │   └── Option D tile
    └── NextButton — "Next" (enabled only after answer selected)
```

### Behaviour

- Question type `multiple_choice` → shows 4 option tiles
- Question type `true_false` → shows only 2 option tiles (True / False)
- Question type `fill_blank` → shows `TextField` instead of options
- On answer tap → `quizController.selectAnswer(option)`
- After answer selected:
  - Correct answer tile turns green with checkmark icon
  - Wrong answer tile turns red with X icon
  - Correct answer tile also highlighted if user picked wrong
- Next button appears after answer selected
- On last question → navigate to `QuizResultScreen`

---

## Screen 6 — quiz_result_screen.dart

### Widget tree

```
QuizResultScreen
├── AppBar — "Quiz Result"
└── Body — Column
    ├── Spacer
    ├── ScoreRing
    │   └── fl_chart PieChart showing score percentage
    ├── ScoreText — "8 / 10 correct"
    ├── GradeText — "Excellent!" / "Good!" / "Keep Practicing!"
    ├── XPEarned — "+40 XP earned"
    ├── SizedBox
    ├── ResultList — scrollable list showing each question result
    │   └── Row: question text + correct/wrong icon
    ├── Spacer
    └── Row — 2 buttons
        ├── OutlinedButton — "Retry Quiz"
        └── ElevatedButton — "Back to Lesson"
```

### Behaviour

- Score >= 80% → "Excellent!" → green ring → unlock next lesson
- Score 50–79% → "Good!" → amber ring
- Score < 50% → "Keep Practicing!" → red ring
- XP calculation: 10 XP per correct answer
- On screen load → `quizController.saveResult(lessonId, uid)` called
- Retry → `Navigator.pushReplacement` to `QuizScreen`

---

## Screen 7 — progress_screen.dart

### Widget tree

```
ProgressScreen
├── AppBar — "My Progress"
└── Body — SingleChildScrollView → Column
    ├── OverallProgressRing
    │   └── fl_chart PieChart — lessons completed / total
    ├── StatRow
    │   ├── StatTile(cards learned, book icon)
    │   ├── StatTile(quizzes taken, quiz icon)
    │   └── StatTile(XP earned, star icon)
    ├── SectionHeader — "Weekly Activity"
    ├── WeeklyBarChart
    │   └── fl_chart BarChart — 7 days, height = XP earned per day
    ├── SectionHeader — "Category Progress"
    └── CategoryProgressList
        └── Per category:
            ├── Category name
            └── LinearProgressIndicator — lessons done / total
```

---

## Screen 8 — profile_screen.dart

### Widget tree

```
ProfileScreen
├── AppBar — "Profile"
└── Body — Column
    ├── AvatarCircle — initials avatar
    ├── LevelBadge(currentLevel)
    ├── StreakRow — fire icon + streak count
    ├── XPBar — current XP toward next level
    ├── SectionHeader — "Achievements"
    └── BadgeGrid — earned badges
        ├── FirstLesson badge
        ├── Streak7 badge
        ├── Streak30 badge
        ├── Quiz100 badge (100% on a quiz)
        ├── LevelUp badge
        └── WordMaster badge (50 cards learned)
```

---

## Widget — flashcard_widget.dart

```dart
// FlashcardWidget — StatefulWidget
// Uses AnimatedSwitcher with custom FlipTransition
// Front shows English word + pronunciation hint + speaker button
// Back shows Tamil word (Tamil font) + transliteration + example sentences
// Entire card is tappable to flip
// Card has shadow, rounded corners, gradient background
// Front gradient: light blue to white
// Back gradient: light amber to white (different color signals flip)
```

---

## Widget — quiz_option_tile.dart

```dart
// QuizOptionTile — StatelessWidget
// Parameters: String option, String label (A/B/C/D),
//             bool isSelected, bool isAnswered,
//             bool isCorrect, VoidCallback onTap
//
// State colors (shown only after isAnswered = true):
//   isCorrect = true  → green background + checkmark
//   isSelected + wrong → red background + X icon
//   not selected + not correct → grey (no change)
//
// Before answering: all tiles show white/outlined style
// Uses AnimatedContainer for smooth color transition
```

---

## Widget — streak_badge.dart

```dart
// StreakBadge — StatelessWidget
// Shows fire emoji + streak number
// Color changes by streak length:
//   1–6 days   → amber
//   7–29 days  → orange
//   30+ days   → red (on fire)
// Pulses with flutter_animate repeat animation
```

---

## Widget — bottom_nav.dart

```dart
// BottomNav — StatelessWidget
// Standard BottomNavigationBar with 4 items:
//   Home (house icon)     → HomeScreen
//   Lessons (book icon)   → LessonListScreen
//   Progress (chart icon) → ProgressScreen
//   Profile (person icon) → ProfileScreen
// Selected item shows filled icon + primary color label
```

---

## Navigation map

```
HomeScreen
├── Quick action: Lessons   → LessonListScreen
├── Quick action: Progress  → ProgressScreen
├── AppBar person icon      → ProfileScreen
└── Recent lesson card      → LessonScreen(lesson)

LessonListScreen
└── Lesson card tap         → LessonScreen(lesson)

LessonScreen (tabs)
├── Tab 1: Flashcards       → FlashcardScreen(lessonId)
└── Tab 2: Quiz             → QuizScreen(lessonId)

QuizScreen
└── Last question next      → QuizResultScreen(score, lessonId)

QuizResultScreen
├── Retry button            → QuizScreen(lessonId) replace
└── Back to lesson          → LessonScreen pop

ProgressScreen             (BottomNav)
ProfileScreen              (BottomNav)
```

---

## XP and progression system

| Action | XP earned |
|---|---|
| Complete a flashcard session | 20 XP |
| Mark a card as learned | 2 XP per card |
| Complete a quiz | 10 XP |
| Score 100% on quiz | Bonus 20 XP |
| Login streak day | 5 XP per day |
| Complete a full lesson | 50 XP |

### Level thresholds

| Level | XP required |
|---|---|
| Beginner | 0 |
| Elementary | 200 |
| Intermediate | 500 |
| Advanced | 1000 |

---

## Key SQLite queries reference

| Purpose | Query |
|---|---|
| All lessons by level | `SELECT * FROM lessons WHERE level = ? ORDER BY order_index` |
| Cards for lesson | `SELECT * FROM word_cards WHERE lesson_id = ?` |
| Questions for lesson | `SELECT * FROM quiz_questions WHERE lesson_id = ?` |
| Progress for lesson | `SELECT * FROM user_progress WHERE lesson_id = ?` |
| All unsynced progress | `SELECT * FROM user_progress WHERE is_synced = 0` |
| Mark card learned | `UPDATE word_cards SET is_learned = 1 WHERE id = ?` |
| Save quiz score | `INSERT OR REPLACE INTO user_progress ...` |
| Update streak | `UPDATE daily_streak SET current_streak = ?, last_login_date = ?` |
| Unlock lesson | `UPDATE lessons SET is_unlocked = 1 WHERE id = ?` |

---

## Build order (fastest path)

1. All 4 models — `lesson.dart`, `word_card.dart`, `quiz_question.dart`, `user_progress.dart`
2. `local_db.dart` — all 5 tables + seed data + all query methods
3. `auth_service.dart`
4. `firebase_service.dart`
5. `sync_service.dart`
6. `tts_service.dart`
7. All 5 controllers
8. `main.dart` — Firebase init + all providers
9. `bottom_nav.dart` widget
10. `streak_badge.dart` + `level_badge.dart` widgets
11. `flashcard_widget.dart`
12. `quiz_option_tile.dart`
13. `progress_ring.dart`
14. `home_screen.dart` — skeleton works at this point
15. `lesson_list_screen.dart`
16. `flashcard_screen.dart` — core learning feature works
17. `quiz_screen.dart`
18. `quiz_result_screen.dart`
19. `lesson_screen.dart` — connects flashcard + quiz with tabs
20. `progress_screen.dart`
21. `profile_screen.dart`

---

## Polish UI checklist

- [ ] Card flip animation with Y-axis rotation on flashcard
- [ ] `AnimatedContainer` color transition on quiz option tiles after answer
- [ ] `StreakBadge` pulse animation using `flutter_animate` repeat
- [ ] `TweenAnimationBuilder` count-up on stat tiles in progress screen
- [ ] `LinearProgressIndicator` on each lesson card in list
- [ ] Lock overlay with grey tint on locked lesson cards
- [ ] Green checkmark overlay on completed lesson cards
- [ ] Score ring animation on quiz result screen (fl_chart PieChart draw animation)
- [ ] Completion bottom sheet after finishing all flashcards
- [ ] XP earned animation (+40 XP floating up) on quiz result screen
- [ ] `SnackBar` when a lesson is unlocked
- [ ] Tamil font — use Google Fonts Noto Sans Tamil for proper rendering
- [ ] Speaker button feedback — ripple + brief color change on tap
- [ ] Consistent padding 16px horizontal throughout
- [ ] Green `ColorScheme.fromSeed` to match learning / growth theme

---

## Tamil font setup

Add to pubspec.yaml:

```yaml
flutter:
  fonts:
    - family: NotoSansTamil
      fonts:
        - asset: assets/fonts/NotoSansTamil-Regular.ttf
        - asset: assets/fonts/NotoSansTamil-Bold.ttf
          weight: 700
```

Use in Tamil text widgets:

```dart
Text(
  card.tamil,
  style: const TextStyle(
    fontFamily: 'NotoSansTamil',
    fontSize: 28,
    fontWeight: FontWeight.bold,
  ),
)
```

Download NotoSansTamil from fonts.google.com and place in assets/fonts/.
