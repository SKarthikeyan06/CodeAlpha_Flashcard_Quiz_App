# Random Quote Generator — Flutter Implementation Plan

## App overview

A Flutter app that displays random quotes from a local SQLite database.
Users can generate new quotes, like them, share them, translate them,
and add their own quotes. Four screens total.

---

## Tech stack

| Layer | Tool |
|---|---|
| Framework | Flutter (Dart) |
| Local database | sqflite |
| State management | provider (ChangeNotifier) |
| Share | share_plus |
| Animation | flutter_animate |
| Path helper | path |

---

## pubspec.yaml dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.9.0
  share_plus: ^7.2.1
  provider: ^6.1.1
  flutter_animate: ^4.5.0
```

---

## File structure

```
lib/
├── main.dart
├── models/
│   └── quote.dart
├── db/
│   └── database_helper.dart
├── controllers/
│   └── home_controller.dart
├── screens/
│   ├── home_screen.dart
│   ├── liked_screen.dart
│   ├── translate_screen.dart
│   └── add_quote_screen.dart
└── widgets/
    ├── quote_card.dart
    └── generate_button.dart
```

---

## SQLite table — quotes

```sql
CREATE TABLE quotes (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  text           TEXT NOT NULL,
  author         TEXT NOT NULL,
  category       TEXT DEFAULT 'General',
  is_liked       INTEGER DEFAULT 0,
  is_user_added  INTEGER DEFAULT 0
);
```

Seed 50 pre-loaded quotes inside `onCreate` using batch insert.

---

## Model — quote.dart

```dart
class Quote {
  final int id;
  final String text;
  final String author;
  final String category;
  bool isLiked;
  final bool isUserAdded;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
    required this.isLiked,
    required this.isUserAdded,
  });

  factory Quote.fromMap(Map<String, dynamic> map) => Quote(
    id:          map['id'],
    text:        map['text'],
    author:      map['author'],
    category:    map['category'] ?? 'General',
    isLiked:     map['is_liked'] == 1,
    isUserAdded: map['is_user_added'] == 1,
  );

  Map<String, dynamic> toMap() => {
    'text':          text,
    'author':        author,
    'category':      category,
    'is_liked':      isLiked ? 1 : 0,
    'is_user_added': isUserAdded ? 1 : 0,
  };
}
```

---

## Database helper — database_helper.dart

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/quote.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;

  DatabaseHelper._();

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'quotes.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE quotes (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        text           TEXT NOT NULL,
        author         TEXT NOT NULL,
        category       TEXT DEFAULT 'General',
        is_liked       INTEGER DEFAULT 0,
        is_user_added  INTEGER DEFAULT 0
      )
    ''');
    await _seedQuotes(db);
  }

  Future<void> _seedQuotes(Database db) async {
    final batch = db.batch();
    for (final q in _seedData) {
      batch.insert('quotes', q);
    }
    await batch.commit(noResult: true);
  }

  // Queries used by screens
  Future<Quote?> getRandomQuote() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT * FROM quotes ORDER BY RANDOM() LIMIT 1',
    );
    if (rows.isEmpty) return null;
    return Quote.fromMap(rows.first);
  }

  Future<List<Quote>> getLikedQuotes() async {
    final db = await database;
    final rows = await db.query(
      'quotes',
      where: 'is_liked = 1',
      orderBy: 'category ASC',
    );
    return rows.map(Quote.fromMap).toList();
  }

  Future<void> toggleLike(int id, bool isLiked) async {
    final db = await database;
    await db.update(
      'quotes',
      {'is_liked': isLiked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertQuote(Quote quote) async {
    final db = await database;
    await db.insert('quotes', quote.toMap());
  }

  Future<void> deleteQuote(int id) async {
    final db = await database;
    await db.delete('quotes', where: 'id = ?', whereArgs: [id]);
  }

  // Seed data — add at least 50 quotes here
  static const List<Map<String, dynamic>> _seedData = [
    {'text': 'The only way to do great work is to love what you do.', 'author': 'Steve Jobs', 'category': 'Motivation'},
    {'text': 'In the middle of every difficulty lies opportunity.', 'author': 'Albert Einstein', 'category': 'Life'},
    {'text': 'It does not matter how slowly you go as long as you do not stop.', 'author': 'Confucius', 'category': 'Motivation'},
    // ... add more quotes
  ];
}
```

---

## Controller — home_controller.dart

```dart
import 'package:flutter/foundation.dart';
import '../models/quote.dart';
import '../db/database_helper.dart';

class HomeController extends ChangeNotifier {
  Quote? currentQuote;
  bool isLoading = false;

  Future<void> loadRandomQuote() async {
    isLoading = true;
    notifyListeners();

    currentQuote = await DatabaseHelper.instance.getRandomQuote();

    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleLike() async {
    if (currentQuote == null) return;
    currentQuote!.isLiked = !currentQuote!.isLiked;
    notifyListeners();
    await DatabaseHelper.instance.toggleLike(
      currentQuote!.id,
      currentQuote!.isLiked,
    );
  }
}
```

---

## main.dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/home_controller.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => HomeController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Quotes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF534AB7)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
```

---

## Screen 1 — home_screen.dart

### Widget tree

```
HomeScreen
├── AppBar
│   ├── title: "Daily Quotes"
│   └── actions: IconButton(heart) → LikedScreen
├── Scaffold body — Column
│   ├── Spacer
│   ├── QuoteCard(quote, onLike, onShare, onTranslate)
│   ├── Spacer
│   └── GenerateButton(onPressed, isLoading)
└── FloatingActionButton(+) → AddQuoteScreen
```

### Behaviour

- `initState` calls `controller.loadRandomQuote()`
- `GenerateButton` tap calls `controller.loadRandomQuote()`
- `QuoteCard` uses `AnimatedSwitcher` with `ValueKey(quote.id)` for fade transition
- Like tap calls `controller.toggleLike()`
- Share tap calls `Share.share('"${quote.text}" — ${quote.author}')`
- Translate tap calls `Navigator.push` to `TranslateScreen(quote: quote)`
- FAB tap calls `Navigator.push` to `AddQuoteScreen`, then reloads on return

---

## Widget — quote_card.dart

```dart
// QuoteCard is a StatelessWidget
// Parameters: Quote quote, VoidCallback onLike, onShare, onTranslate
// Uses AnimatedSwitcher with FadeTransition, key: ValueKey(quote.id)
// Card layout:
//   - Large serif quote text (fontSize 20, fontStyle italic)
//   - Muted author text below (fontSize 14, "— Author")
//   - Row of 3 IconButtons at bottom: heart, share, translate
// Heart icon: filled color when isLiked, outline when not
```

---

## Widget — generate_button.dart

```dart
// GenerateButton is a StatelessWidget
// Parameters: VoidCallback onPressed, bool isLoading
// Full-width ElevatedButton, height 52
// Shows CircularProgressIndicator when isLoading is true
// Shows "Generate quote" text when isLoading is false
```

---

## Screen 2 — liked_screen.dart

### Behaviour

- Queries `DatabaseHelper.getLikedQuotes()` on init
- Groups quotes by `category` using `Map<String, List<Quote>>`
- Renders one `ExpansionTile` per category
- Each tile shows quotes as `ListTile` with text + author
- Long press on a quote → navigate to `AddQuoteScreen` in edit mode
- Swipe to dismiss → calls `DatabaseHelper.toggleLike(id, false)`
- FAB(+) → `AddQuoteScreen`

---

## Screen 3 — translate_screen.dart

### Behaviour

- Receives `Quote quote` as constructor argument
- Shows a `DropdownButton` with language options:
  Tamil, Hindi, Telugu, Kannada, Malayalam, French, Spanish
- On language select → calls translation API or shows pre-stored translation
- Translated text displayed in same card style as `QuoteCard`
- Share button shares the translated text
- Back button returns to `HomeScreen`

### Translation approach (two options)

Option A — API (requires internet):
Use `http` package to call LibreTranslate or MyMemory free API.

Option B — Offline (recommended for internship):
Store translations for all seed quotes in a `translations` table in SQLite
with columns `quote_id`, `language`, `translated_text`.

---

## Screen 4 — add_quote_screen.dart

### Behaviour

- Two `TextFormField` widgets: Quote text, Author name
- One `DropdownButtonFormField`: Category (Motivation, Life, Friendship, Success, General)
- Validates both fields are non-empty before save
- On save → calls `DatabaseHelper.insertQuote(quote)` with `isUserAdded: true`
- Pops back to previous screen on success
- If opened in edit mode (receives existing quote) → pre-fills fields, shows Delete button

---

## Navigation map

```
HomeScreen
├── → LikedScreen       (AppBar heart icon)
├── → TranslateScreen   (quote card translate icon, passes current quote)
└── → AddQuoteScreen    (FAB +)

LikedScreen
└── → AddQuoteScreen    (FAB + or long press to edit)

AddQuoteScreen
└── ← pop on save
```

---

## Polish UI checklist

- [ ] `AnimatedSwitcher` fade on quote change
- [ ] Heart icon changes color instantly on tap (optimistic UI)
- [ ] `CircularProgressIndicator` inside generate button while loading
- [ ] `SnackBar` confirmation after saving a new quote
- [ ] `Dismissible` widget for swipe-to-unlike in liked screen
- [ ] Empty state widget in liked screen when no likes yet
- [ ] Consistent padding: 24px horizontal, 16px vertical throughout
- [ ] `ThemeData` with `ColorScheme.fromSeed` for consistent colors

---

## Build order (fastest path)

1. `quote.dart` model
2. `database_helper.dart` with seed data
3. `home_controller.dart`
4. `main.dart` with provider setup
5. `generate_button.dart` widget
6. `quote_card.dart` widget
7. `home_screen.dart` — app is working at this point
8. `liked_screen.dart`
9. `add_quote_screen.dart`
10. `translate_screen.dart`
