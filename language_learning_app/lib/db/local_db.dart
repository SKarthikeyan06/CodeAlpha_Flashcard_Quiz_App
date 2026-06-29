import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/lesson.dart';
import '../models/word_card.dart';
import '../models/quiz_question.dart';
import '../models/user_progress.dart';

class LocalDb {
  static final LocalDb instance = LocalDb._init();
  static Database? _database;

  LocalDb._init();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError("SQLite database is not supported on web platforms.");
    }
    if (_database != null) return _database!;
    _database = await _initDB('language_learning.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lessons (
        id            TEXT PRIMARY KEY,
        title         TEXT NOT NULL,
        description   TEXT NOT NULL,
        category      TEXT NOT NULL,
        level         TEXT NOT NULL,
        order_index   INTEGER NOT NULL,
        total_cards   INTEGER DEFAULT 0,
        is_unlocked   INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
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
      )
    ''');

    await db.execute('''
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
      )
    ''');

    await db.execute('''
      CREATE TABLE user_progress (
        id              TEXT PRIMARY KEY,
        lesson_id       TEXT NOT NULL UNIQUE,
        cards_seen      INTEGER DEFAULT 0,
        cards_learned   INTEGER DEFAULT 0,
        quiz_score      INTEGER DEFAULT 0,
        quiz_attempts   INTEGER DEFAULT 0,
        best_score      INTEGER DEFAULT 0,
        is_completed    INTEGER DEFAULT 0,
        last_studied    TEXT DEFAULT '',
        is_synced       INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_streak (
        id              INTEGER PRIMARY KEY,
        current_streak  INTEGER DEFAULT 0,
        longest_streak  INTEGER DEFAULT 0,
        last_login_date TEXT DEFAULT '',
        total_xp        INTEGER DEFAULT 0,
        total_lessons   INTEGER DEFAULT 0,
        total_quizzes   INTEGER DEFAULT 0,
        current_level   TEXT DEFAULT 'Beginner'
      )
    ''');

    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    await db.rawInsert('''
      INSERT INTO daily_streak (id, current_streak, longest_streak, last_login_date, total_xp, total_lessons, total_quizzes, current_level)
      VALUES (1, 0, 0, '', 0, 0, 0, 'Beginner')
    ''');

    for (var l in seededLessons) {
      await db.insert('lessons', l);
    }
    for (var c in seededCards) {
      await db.insert('word_cards', c);
    }
    for (var q in seededQuestions) {
      await db.insert('quiz_questions', q);
    }
  }

  // ----------------------------------------------------
  // STATIC SEED DATA (Used by both SQLite and Web Fallback)
  // ----------------------------------------------------
  static const List<Map<String, dynamic>> seededLessons = [
    {'id': 'b_greetings', 'title': 'Vanakkam & Greetings', 'description': 'Say hello, goodbye, and express gratitude in Tamil.', 'category': 'Greetings', 'level': 'Beginner', 'order_index': 1, 'total_cards': 4, 'is_unlocked': 1},
    {'id': 'b_numbers', 'title': 'Numbers 1 to 10', 'description': 'Learn to count from one to ten in Tamil.', 'category': 'Numbers', 'level': 'Beginner', 'order_index': 2, 'total_cards': 5, 'is_unlocked': 0},
    {'id': 'b_colours', 'title': 'Basic Colours', 'description': 'Learn primary colours like red, green, and blue in Tamil.', 'category': 'Colours', 'level': 'Beginner', 'order_index': 3, 'total_cards': 4, 'is_unlocked': 0},
    {'id': 'b_family', 'title': 'Family Relations', 'description': 'Talk about key family members.', 'category': 'Family', 'level': 'Beginner', 'order_index': 4, 'total_cards': 4, 'is_unlocked': 0},
    {'id': 'e_food', 'title': 'Fruits & Vegetables', 'description': 'Learn words for standard fruits and vegetables.', 'category': 'Food', 'level': 'Elementary', 'order_index': 1, 'total_cards': 4, 'is_unlocked': 1},
    {'id': 'e_routine', 'title': 'Daily Routine Tasks', 'description': 'Describe your morning and evening activities.', 'category': 'Daily Routine', 'level': 'Elementary', 'order_index': 2, 'total_cards': 4, 'is_unlocked': 0},
    {'id': 'e_animals', 'title': 'Common Animals', 'description': 'Identify pets, farm, and wild animals.', 'category': 'Animals', 'level': 'Elementary', 'order_index': 3, 'total_cards': 4, 'is_unlocked': 0},
    {'id': 'i_verbs', 'title': 'Essential Verbs', 'description': 'Learn basic action and movement words.', 'category': 'Verbs', 'level': 'Intermediate', 'order_index': 1, 'total_cards': 4, 'is_unlocked': 1},
    {'id': 'i_grammar', 'title': 'Basic Sentence Structure', 'description': 'Learn Subject-Object-Verb (SOV) structure.', 'category': 'Grammar', 'level': 'Intermediate', 'order_index': 2, 'total_cards': 4, 'is_unlocked': 0},
    {'id': 'a_idioms', 'title': 'Common Tamil Idioms', 'description': 'Speak fluently using cultural proverbs and idioms.', 'category': 'Idioms', 'level': 'Advanced', 'order_index': 1, 'total_cards': 4, 'is_unlocked': 1},
  ];

  static const List<Map<String, dynamic>> seededCards = [
    {'id': 'wc_1', 'lesson_id': 'b_greetings', 'english': 'Hello', 'tamil': 'வணக்கம்', 'transliteration': 'Vanakkam', 'example_en': 'Hello, how are you?', 'example_ta': 'வணக்கம், நீங்கள் எப்படி இருக்கிறீர்கள்?', 'category': 'Greetings'},
    {'id': 'wc_2', 'lesson_id': 'b_greetings', 'english': 'Thank you', 'tamil': 'நன்றி', 'transliteration': 'Nandri', 'example_en': 'Thank you very much.', 'example_ta': 'மிக்க நன்றி.', 'category': 'Greetings'},
    {'id': 'wc_3', 'lesson_id': 'b_greetings', 'english': 'Good morning', 'tamil': 'காலை வணக்கம்', 'transliteration': 'Kaalai vanakkam', 'example_en': 'Good morning, sir.', 'example_ta': 'காலை வணக்கம், ஐயா.', 'category': 'Greetings'},
    {'id': 'wc_4', 'lesson_id': 'b_greetings', 'english': 'Goodbye', 'tamil': 'போய் வருகிறேன்', 'transliteration': 'Poi varugiren', 'example_en': 'Goodbye, see you tomorrow.', 'example_ta': 'போய் வருகிறேன், நாளை சந்திப்போம்.', 'category': 'Greetings'},
    {'id': 'wc_5', 'lesson_id': 'b_numbers', 'english': 'One', 'tamil': 'ஒன்று', 'transliteration': 'Ondru', 'example_en': 'I have one book.', 'example_ta': 'என்னிடம் ஒரு புத்தகம் உள்ளது.', 'category': 'Numbers'},
    {'id': 'wc_6', 'lesson_id': 'b_numbers', 'english': 'Two', 'tamil': 'இரண்டு', 'transliteration': 'Irandu', 'example_en': 'He has two eyes.', 'example_ta': 'அவருக்கு இரண்டு கண்கள் உள்ளன.', 'category': 'Numbers'},
    {'id': 'wc_7', 'lesson_id': 'b_numbers', 'english': 'Three', 'tamil': 'மூன்று', 'transliteration': 'Moondru', 'example_en': 'A triangle has three sides.', 'example_ta': 'ஒரு முக்கோணத்திற்கு மூன்று பக்கங்கள் உள்ளன.', 'category': 'Numbers'},
    {'id': 'wc_8', 'lesson_id': 'b_numbers', 'english': 'Five', 'tamil': 'ஐந்து', 'transliteration': 'Aindhu', 'example_en': 'Give me five rupees.', 'example_ta': 'எனக்கு ஐந்து ரூபாய் கொடுங்கள்.', 'category': 'Numbers'},
    {'id': 'wc_9', 'lesson_id': 'b_numbers', 'english': 'Ten', 'tamil': 'பத்து', 'transliteration': 'Pathu', 'example_en': 'It is ten o\'clock.', 'example_ta': 'இப்போது பத்து மணி.', 'category': 'Numbers'},
    {'id': 'wc_10', 'lesson_id': 'b_colours', 'english': 'Red', 'tamil': 'சிவப்பு', 'transliteration': 'Sivappu', 'example_en': 'The rose is red.', 'example_ta': 'ரோஜா சிவப்பு நிறத்தில் உள்ளது.', 'category': 'Colours'},
    {'id': 'wc_11', 'lesson_id': 'b_colours', 'english': 'Green', 'tamil': 'பச்சை', 'transliteration': 'Pachai', 'example_en': 'Leaves are green.', 'example_ta': 'இலைகள் பச்சையாக இருக்கும்.', 'category': 'Colours'},
    {'id': 'wc_12', 'lesson_id': 'b_colours', 'english': 'Blue', 'tamil': 'நீலம்', 'transliteration': 'Neelam', 'example_en': 'The sky is blue.', 'example_ta': 'வானம் நீலமாக உள்ளது.', 'category': 'Colours'},
    {'id': 'wc_13', 'lesson_id': 'b_colours', 'english': 'White', 'tamil': 'வெள்ளை', 'transliteration': 'Vellai', 'example_en': 'Milk is white.', 'example_ta': 'பால் வெள்ளையாக இருக்கும்.', 'category': 'Colours'},
    {'id': 'wc_14', 'lesson_id': 'b_family', 'english': 'Father', 'tamil': 'அப்பா', 'transliteration': 'Appa', 'example_en': 'My father is a teacher.', 'example_ta': 'என் அப்பா ஒரு ஆசிரியர்.', 'category': 'Family'},
    {'id': 'wc_15', 'lesson_id': 'b_family', 'english': 'Mother', 'tamil': 'அம்மா', 'transliteration': 'Amma', 'example_en': 'I love my mother.', 'example_ta': 'நான் என் அம்மாவை நேசிக்கிறேன்.', 'category': 'Family'},
    {'id': 'wc_16', 'lesson_id': 'b_family', 'english': 'Elder Brother', 'tamil': 'அண்ணன்', 'transliteration': 'Annan', 'example_en': 'My elder brother is studying.', 'example_ta': 'என் அண்ணன் படித்துக் கொண்டிருக்கிறார்.', 'category': 'Family'},
    {'id': 'wc_17', 'lesson_id': 'b_family', 'english': 'Elder Sister', 'tamil': 'அக்கா', 'transliteration': 'Akka', 'example_en': 'My elder sister helps me.', 'example_ta': 'என் அக்கா எனக்கு உதவுகிறாள்.', 'category': 'Family'},
    {'id': 'wc_18', 'lesson_id': 'e_food', 'english': 'Apple', 'tamil': 'ஆப்பிள்', 'transliteration': 'Aappil', 'example_en': 'An apple a day keeps the doctor away.', 'example_ta': 'தினமும் ஒரு ஆப்பிள் மருத்துவரை விலக்கி வைக்கும்.', 'category': 'Food'},
    {'id': 'wc_19', 'lesson_id': 'e_food', 'english': 'Banana', 'tamil': 'வாழைப்பழம்', 'transliteration': 'Vaazhaippazham', 'example_en': 'The banana is yellow.', 'example_ta': 'வாழைப்பழம் மஞ்சள் நிறத்தில் உள்ளது.', 'category': 'Food'},
    {'id': 'wc_20', 'lesson_id': 'e_food', 'english': 'Onion', 'tamil': 'வெங்காயம்', 'transliteration': 'Vengaayam', 'example_en': 'Cut the onion.', 'example_ta': 'வெங்காயத்தை நறுக்குங்கள்.', 'category': 'Food'},
    {'id': 'wc_21', 'lesson_id': 'e_food', 'english': 'Water', 'tamil': 'தண்ணீர்', 'transliteration': 'Thanneer', 'example_en': 'Drink enough water.', 'example_ta': 'தேவையான அளவு தண்ணீர் குடியுங்கள்.', 'category': 'Food'},
    {'id': 'wc_22', 'lesson_id': 'e_routine', 'english': 'To wake up', 'tamil': 'விழித்தெழு', 'transliteration': 'Vizhithezhu', 'example_en': 'I wake up early.', 'example_ta': 'நான் சீக்கிரம் விழித்தெழுகிறேன்.', 'category': 'Daily Routine'},
    {'id': 'wc_23', 'lesson_id': 'e_routine', 'english': 'To bathe', 'tamil': 'குளி', 'transliteration': 'Kuli', 'example_en': 'Take a bath daily.', 'example_ta': 'தினமும் குளியுங்கள்.', 'category': 'Daily Routine'},
    {'id': 'wc_24', 'lesson_id': 'e_routine', 'english': 'To eat breakfast', 'tamil': 'காலை உணவு உண்', 'transliteration': 'Kaalai unavu un', 'example_en': 'I eat breakfast at 8 AM.', 'example_ta': 'நான் காலை 8 மணிக்கு காலை உணவு உண்கிறேன்.', 'category': 'Daily Routine'},
    {'id': 'wc_25', 'lesson_id': 'e_routine', 'english': 'To sleep', 'tamil': 'தூங்கு', 'transliteration': 'Thoongu', 'example_en': 'Sleep eight hours a night.', 'example_ta': 'இரவில் எட்டு மணி நேரம் தூங்குங்கள்.', 'category': 'Daily Routine'},
    {'id': 'wc_26', 'lesson_id': 'e_animals', 'english': 'Dog', 'tamil': 'நாய்', 'transliteration': 'Naai', 'example_en': 'The dog barks.', 'example_ta': 'நாய் குரைக்கிறது.', 'category': 'Animals'},
    {'id': 'wc_27', 'lesson_id': 'e_animals', 'english': 'Cat', 'tamil': 'பூனை', 'transliteration': 'Poonai', 'example_en': 'The cat drinks milk.', 'example_ta': 'பூனை பால் குடிக்கிறது.', 'category': 'Animals'},
    {'id': 'wc_28', 'lesson_id': 'e_animals', 'english': 'Cow', 'tamil': 'பசு', 'transliteration': 'Pasu', 'example_en': 'The cow gives milk.', 'example_ta': 'பசு பால் தருகிறது.', 'category': 'Animals'},
    {'id': 'wc_29', 'lesson_id': 'e_animals', 'english': 'Tiger', 'tamil': 'புலி', 'transliteration': 'Puli', 'example_en': 'The tiger is our national animal.', 'example_ta': 'புலி நமது தேசிய விலங்கு ஆகும்.', 'category': 'Animals'},
    {'id': 'wc_30', 'lesson_id': 'i_verbs', 'english': 'To run', 'tamil': 'ஓடு', 'transliteration': 'Odu', 'example_en': 'Run fast!', 'example_ta': 'வேகமாக ஓடு!', 'category': 'Verbs'},
    {'id': 'wc_31', 'lesson_id': 'i_verbs', 'english': 'To write', 'tamil': 'எழுது', 'transliteration': 'Ezhuthu', 'example_en': 'Write a letter.', 'example_ta': 'ஒரு கடிதம் எழுதுங்கள்.', 'category': 'Verbs'},
    {'id': 'wc_32', 'lesson_id': 'i_verbs', 'english': 'To speak', 'tamil': 'பேசு', 'transliteration': 'Pesu', 'example_en': 'Speak clearly.', 'example_ta': 'தெளிவாகப் பேசுங்கள்.', 'category': 'Verbs'},
    {'id': 'wc_33', 'lesson_id': 'i_verbs', 'english': 'To listen', 'tamil': 'கேள்', 'transliteration': 'Kel', 'example_en': 'Listen to the music.', 'example_ta': 'இசையைக் கேளுங்கள்.', 'category': 'Verbs'},
    {'id': 'wc_34', 'lesson_id': 'i_grammar', 'english': 'I ate', 'tamil': 'நான் சாப்பிட்டேன்', 'transliteration': 'Naan saapitten', 'example_en': 'I ate a fruit.', 'example_ta': 'நான் ஒரு பழம் சாப்பிட்டேன்.', 'category': 'Grammar'},
    {'id': 'wc_35', 'lesson_id': 'i_grammar', 'english': 'I am eating', 'tamil': 'நான் சாப்பிடுகிறேன்', 'transliteration': 'Naan saapidugiren', 'example_en': 'I am eating dinner.', 'example_ta': 'நான் இரவு உணவு சாப்பிடுகிறேன்.', 'category': 'Grammar'},
    {'id': 'wc_36', 'lesson_id': 'i_grammar', 'english': 'I will eat', 'tamil': 'நான் சாப்பிடுவேன்', 'transliteration': 'Naan saapiduven', 'example_en': 'I will eat later.', 'example_ta': 'நான் பின்னர் சாப்பிடுவேன்.', 'category': 'Grammar'},
    {'id': 'wc_37', 'lesson_id': 'i_grammar', 'english': 'He went', 'tamil': 'அவன் சென்றான்', 'transliteration': 'Avan sendraan', 'example_en': 'He went home.', 'example_ta': 'அவன் வீட்டுக்குச் சென்றான்.', 'category': 'Grammar'},
    {'id': 'wc_38', 'lesson_id': 'a_idioms', 'english': 'Slow and steady wins the race', 'tamil': 'சித்திரமும் கைப்பழக்கம் செந்தமிழும் நாப்பழக்கம்', 'transliteration': 'Chithiramum kaippazhakkam senthamizhum naappazhakkam', 'example_en': 'Practice makes perfect.', 'example_ta': 'தொடர் பயிற்சி மூலம் எதையும் சாதிக்கலாம்.', 'category': 'Idioms'},
    {'id': 'wc_39', 'lesson_id': 'a_idioms', 'english': 'Out of the frying pan into the fire', 'tamil': 'அடுப்பை விட்டு ஓடி கொள்ளியில் விழுந்தது போல', 'transliteration': 'Aduppai vittu odi kolliyil vizhundhadhu pola', 'example_en': 'He escaped one crisis only to fall into a worse one.', 'example_ta': 'அவன் ஒரு ஆபத்திலிருந்து தப்பித்து அதை விடப் பெரிய ஆபத்தில் விழுந்தான்.', 'category': 'Idioms'},
    {'id': 'wc_40', 'lesson_id': 'a_idioms', 'english': 'Deep waters run quiet', 'tamil': 'நிறைகுடம் நீர் தளும்பாது', 'transliteration': 'Niraikudam neer thalumbaadhu', 'example_en': 'Wise people talk less.', 'example_ta': 'அறிவாளிகள் ஆரவாரம் செய்ய மாட்டார்கள்.', 'category': 'Idioms'},
    {'id': 'wc_41', 'lesson_id': 'a_idioms', 'english': 'Drop by drop makes an ocean', 'tamil': 'சிறுதுளி பெருவெள்ளம்', 'transliteration': 'Sirudhuli peru vellam', 'example_en': 'Little savings accumulate to form a big fortune.', 'example_ta': 'சிறு சேமிப்பு பிற்காலத்தில் பெரிய பலனைத் தரும்.', 'category': 'Idioms'},
  ];

  static const List<Map<String, dynamic>> seededQuestions = [
    {'id': 'q_1', 'lesson_id': 'b_greetings', 'question_type': 'multiple_choice', 'question_en': 'What is the Tamil translation of "Hello"?', 'question_ta': '"Hello" என்பதன் தமிழ் மொழிபெயர்ப்பு என்ன?', 'correct_ans': 'வணக்கம் (Vanakkam)', 'option_a': 'நன்றி (Nandri)', 'option_b': 'வணக்கம் (Vanakkam)', 'option_c': 'அம்மா (Amma)', 'option_d': 'காலை வணக்கம் (Kaalai vanakkam)'},
    {'id': 'q_2', 'lesson_id': 'b_greetings', 'question_type': 'multiple_choice', 'question_en': 'How do you say "Thank you" in Tamil?', 'question_ta': 'தமிழில் "Thank you" என்று எப்படி கூறுவீர்கள்?', 'correct_ans': 'நன்றி (Nandri)', 'option_a': 'நன்றி (Nandri)', 'option_b': 'வணக்கம் (Vanakkam)', 'option_c': 'போய் வருகிறேன் (Poi varugiren)', 'option_d': 'அப்பா (Appa)'},
    {'id': 'q_3', 'lesson_id': 'b_greetings', 'question_type': 'true_false', 'question_en': 'True or False: "Poi varugiren" means Good Morning.', 'question_ta': 'சரியா தவறா: "போய் வருகிறேன்" என்றால் காலை வணக்கம்.', 'correct_ans': 'False', 'option_a': 'True', 'option_b': 'False', 'option_c': '', 'option_d': ''},
    {'id': 'q_4', 'lesson_id': 'b_greetings', 'question_type': 'fill_blank', 'question_en': '"Good morning" in Tamil is "Kaalai _______".', 'question_ta': 'தமிழில் "Good morning" என்பது "காலை _______".', 'correct_ans': 'வணக்கம்', 'option_a': '', 'option_b': '', 'option_c': '', 'option_d': ''},
    {'id': 'q_5', 'lesson_id': 'b_numbers', 'question_type': 'multiple_choice', 'question_en': 'What does "Ondru" mean in English?', 'question_ta': '"ஒன்று" என்றால் ஆங்கிலத்தில் என்ன?', 'correct_ans': 'One', 'option_a': 'One', 'option_b': 'Two', 'option_c': 'Three', 'option_d': 'Five'},
    {'id': 'q_6', 'lesson_id': 'b_numbers', 'question_type': 'multiple_choice', 'question_en': 'What is the Tamil word for "Ten"?', 'question_ta': '"Ten" என்பதற்கான தமிழ் சொல் என்ன?', 'correct_ans': 'பத்து (Pathu)', 'option_a': 'இரண்டு (Irandu)', 'option_b': 'மூன்று (Moondru)', 'option_c': 'பத்து (Pathu)', 'option_d': 'ஐந்து (Aindhu)'},
    {'id': 'q_7', 'lesson_id': 'b_numbers', 'question_type': 'true_false', 'question_en': 'True or False: "Irandu" translates to Five.', 'question_ta': 'சரியா தவறா: "இரண்டு" என்றால் ஐந்து.', 'correct_ans': 'False', 'option_a': 'True', 'option_b': 'False', 'option_c': '', 'option_d': ''},
    {'id': 'q_8', 'lesson_id': 'b_colours', 'question_type': 'multiple_choice', 'question_en': 'Which Tamil word means "Red"?', 'question_ta': '"Red" குறிக்கும் தமிழ் வார்த்தை எது?', 'correct_ans': 'சிவப்பு (Sivappu)', 'option_a': 'பச்சை (Pachai)', 'option_b': 'நீலம் (Neelam)', 'option_c': 'சிவப்பு (Sivappu)', 'option_d': 'வெள்ளை (Vellai)'},
    {'id': 'q_9', 'lesson_id': 'b_colours', 'question_type': 'fill_blank', 'question_en': '"White" in Tamil is _______.', 'question_ta': '"White" என்பது தமிழில் _______.', 'correct_ans': 'வெள்ளை', 'option_a': '', 'option_b': '', 'option_c': '', 'option_d': ''},
    {'id': 'q_10', 'lesson_id': 'b_family', 'question_type': 'multiple_choice', 'question_en': 'What is the translation of "Amma"?', 'question_ta': '"அம்மா" என்பதன் ஆங்கில அர்த்தம் என்ன?', 'correct_ans': 'Mother', 'option_a': 'Father', 'option_b': 'Mother', 'option_c': 'Brother', 'option_d': 'Sister'},
    {'id': 'q_11', 'lesson_id': 'b_family', 'question_type': 'true_false', 'question_en': 'True or False: "Appa" means Father.', 'question_ta': 'சரியா தவறா: "அப்பா" என்றால் தந்தை.', 'correct_ans': 'True', 'option_a': 'True', 'option_b': 'False', 'option_c': '', 'option_d': ''},
    {'id': 'q_12', 'lesson_id': 'e_food', 'question_type': 'multiple_choice', 'question_en': 'What is "Vaazhaippazham" in English?', 'question_ta': '"வாழைப்பழம்" ஆங்கிலத்தில் என்ன?', 'correct_ans': 'Banana', 'option_a': 'Apple', 'option_b': 'Banana', 'option_c': 'Onion', 'option_d': 'Water'},
    {'id': 'q_13', 'lesson_id': 'e_routine', 'question_type': 'multiple_choice', 'question_en': 'What does "Thoongu" mean?', 'question_ta': '"தூங்கு" என்பதன் பொருள் என்ன?', 'correct_ans': 'To sleep', 'option_a': 'To wake up', 'option_b': 'To bathe', 'option_c': 'To sleep', 'option_d': 'To eat'},
    {'id': 'q_14', 'lesson_id': 'e_animals', 'question_type': 'multiple_choice', 'question_en': 'What is the Tamil word for "Dog"?', 'question_ta': '"Dog" என்பதன் தமிழ் வார்த்தை என்ன?', 'correct_ans': 'நாய் (Naai)', 'option_a': 'பூனை (Poonai)', 'option_b': 'நாய் (Naai)', 'option_c': 'பசு (Pasu)', 'option_d': 'புலி (Puli)'},
    {'id': 'q_15', 'lesson_id': 'i_verbs', 'question_type': 'multiple_choice', 'question_en': 'What is the Tamil word for "To write"?', 'question_ta': '"To write" என்பதன் தமிழ் வார்த்தை என்ன?', 'correct_ans': 'எழுது (Ezhuthu)', 'option_a': 'ஓடு (Odu)', 'option_b': 'எழுது (Ezhuthu)', 'option_c': 'பேசு (Pesu)', 'option_d': 'கேள் (Kel)'},
    {'id': 'q_16', 'lesson_id': 'i_grammar', 'question_type': 'multiple_choice', 'question_en': 'Translate: "Naan saapiduven".', 'question_ta': '"நான் சாப்பிடுவேன்" என்பதை மொழிபெயர்க்கவும்.', 'correct_ans': 'I will eat', 'option_a': 'I ate', 'option_b': 'I am eating', 'option_c': 'I will eat', 'option_d': 'He went'},
    {'id': 'q_17', 'lesson_id': 'a_idioms', 'question_type': 'multiple_choice', 'question_en': 'What is the meaning of "Sirudhuli peru vellam"?', 'question_ta': '"சிறுதுளி பெருவெள்ளம்" என்பதன் பொருள் என்ன?', 'correct_ans': 'Drop by drop makes an ocean', 'option_a': 'Drop by drop makes an ocean', 'option_b': 'Slow and steady wins the race', 'option_c': 'Wise people talk less', 'option_d': 'Practice makes perfect'}
  ];

  // ----------------------------------------------------
  // WEB FALLBACK IN-MEMORY STORAGE & HELPERS
  // ----------------------------------------------------
  static final Map<String, Map<String, dynamic>> _webProgress = {};
  static final Map<String, dynamic> _webProfile = {
    'current_streak': 0,
    'longest_streak': 0,
    'last_login_date': '',
    'total_xp': 0,
    'total_lessons': 0,
    'total_quizzes': 0,
    'current_level': 'Beginner',
  };
  static bool _webInitialized = false;

  Future<void> _initWeb() async {
    if (_webInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Profile stats
      _webProfile['total_xp'] = prefs.getInt('web_xp') ?? 0;
      _webProfile['current_streak'] = prefs.getInt('web_streak') ?? 0;
      _webProfile['longest_streak'] = prefs.getInt('web_longest_streak') ?? 0;
      _webProfile['last_login_date'] = prefs.getString('web_last_login') ?? '';
      _webProfile['total_lessons'] = prefs.getInt('web_lessons') ?? 0;
      _webProfile['total_quizzes'] = prefs.getInt('web_quizzes') ?? 0;
      _webProfile['current_level'] = prefs.getString('web_current_level') ?? 'Beginner';

      // Load Progress list
      final progressList = prefs.getStringList('web_progress_list') ?? [];
      _webProgress.clear();
      for (var jsonStr in progressList) {
        try {
          final Map<String, dynamic> map = json.decode(jsonStr);
          final String lessonId = map['lesson_id'] as String;
          _webProgress[lessonId] = map;
        } catch (e) {
          print("Error decoding web progress item: $e");
        }
      }
      _webInitialized = true;
    } catch (e) {
      print("Error initializing Web fallback database: $e");
    }
  }

  Future<void> _saveWebProgressToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save profile variables
      await prefs.setInt('web_xp', _webProfile['total_xp']);
      await prefs.setInt('web_streak', _webProfile['current_streak']);
      await prefs.setInt('web_longest_streak', _webProfile['longest_streak']);
      await prefs.setString('web_last_login', _webProfile['last_login_date']);
      await prefs.setInt('web_lessons', _webProfile['total_lessons']);
      await prefs.setInt('web_quizzes', _webProfile['total_quizzes']);
      await prefs.setString('web_current_level', _webProfile['current_level']);

      // Serialize and save progress records list
      final List<String> progressStrings = [];
      _webProgress.forEach((key, value) {
        progressStrings.add(json.encode(value));
      });
      await prefs.setStringList('web_progress_list', progressStrings);
    } catch (e) {
      print("Error saving Web progress to SharedPreferences: $e");
    }
  }

  // ----------------------------------------------------
  // DATABASE METHODS (SQLite with Web Safe Fallbacks)
  // ----------------------------------------------------

  Future<List<Map<String, dynamic>>> getLessonsWithProgress(String level) async {
    if (kIsWeb) {
      await _initWeb();
      final prefs = await SharedPreferences.getInstance();
      
      final levelLessons = seededLessons.where((l) => l['level'] == level).toList();
      final List<Map<String, dynamic>> result = [];

      for (var l in levelLessons) {
        final String id = l['id'] as String;
        final progress = _webProgress[id] ?? {};
        
        final defaultUnlocked = l['is_unlocked'] == 1;
        final isUnlocked = prefs.getBool('web_lesson_unlocked_$id') ?? defaultUnlocked;

        final map = Map<String, dynamic>.from(l);
        map['cards_seen'] = progress['cards_seen'] ?? 0;
        map['cards_learned'] = progress['cards_learned'] ?? 0;
        map['quiz_score'] = progress['quiz_score'] ?? 0;
        map['is_completed'] = progress['is_completed'] ?? 0;
        map['best_score'] = progress['best_score'] ?? 0;
        map['quiz_attempts'] = progress['quiz_attempts'] ?? 0;
        map['is_unlocked'] = isUnlocked ? 1 : 0;
        
        result.add(map);
      }
      result.sort((a, b) => (a['order_index'] as int).compareTo(b['order_index'] as int));
      return result;
    }

    final db = await instance.database;
    return await db.rawQuery('''
      SELECT l.*, p.cards_seen, p.cards_learned, p.quiz_score, p.is_completed, p.best_score, p.quiz_attempts
      FROM lessons l
      LEFT OUTER JOIN user_progress p ON l.id = p.lesson_id
      WHERE l.level = ?
      ORDER BY l.order_index
    ''', [level]);
  }

  Future<List<Map<String, dynamic>>> getRecentLessons() async {
    if (kIsWeb) {
      await _initWeb();
      final List<Map<String, dynamic>> result = [];

      _webProgress.forEach((lessonId, progress) {
        final lastStudied = progress['last_studied'] as String? ?? '';
        if (lastStudied.isNotEmpty) {
          final lesson = seededLessons.firstWhere((l) => l['id'] == lessonId, orElse: () => {});
          if (lesson.isNotEmpty) {
            final map = Map<String, dynamic>.from(lesson);
            map['cards_seen'] = progress['cards_seen'] ?? 0;
            map['cards_learned'] = progress['cards_learned'] ?? 0;
            map['quiz_score'] = progress['quiz_score'] ?? 0;
            map['is_completed'] = progress['is_completed'] ?? 0;
            map['best_score'] = progress['best_score'] ?? 0;
            map['last_studied'] = lastStudied;
            result.add(map);
          }
        }
      });

      result.sort((a, b) => (b['last_studied'] as String).compareTo(a['last_studied'] as String));
      return result.take(3).toList();
    }

    final db = await instance.database;
    return await db.rawQuery('''
      SELECT l.*, p.cards_seen, p.cards_learned, p.quiz_score, p.is_completed, p.best_score
      FROM user_progress p
      JOIN lessons l ON l.id = p.lesson_id
      ORDER BY p.last_studied DESC
      LIMIT 3
    ''');
  }

  Future<List<WordCard>> getCardsForLesson(String lessonId) async {
    if (kIsWeb) {
      await _initWeb();
      final list = seededCards.where((c) => c['lesson_id'] == lessonId).toList();
      final prefs = await SharedPreferences.getInstance();
      final List<WordCard> result = [];

      for (var c in list) {
        final String id = c['id'] as String;
        final isLearned = prefs.getBool('web_card_learned_$id') ?? false;
        final map = Map<String, dynamic>.from(c);
        map['is_learned'] = isLearned ? 1 : 0;
        result.add(WordCard.fromMap(map));
      }
      return result;
    }

    final db = await instance.database;
    final res = await db.query(
      'word_cards',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
    return res.map((m) => WordCard.fromMap(m)).toList();
  }

  Future<List<QuizQuestion>> getQuestionsForLesson(String lessonId) async {
    if (kIsWeb) {
      final list = seededQuestions.where((q) => q['lesson_id'] == lessonId).toList();
      return list.map((m) => QuizQuestion.fromMap(m)).toList();
    }

    final db = await instance.database;
    final res = await db.query(
      'quiz_questions',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
    return res.map((m) => QuizQuestion.fromMap(m)).toList();
  }

  Future<UserProgress?> getProgressForLesson(String lessonId) async {
    if (kIsWeb) {
      await _initWeb();
      final progress = _webProgress[lessonId];
      if (progress == null) return null;
      return UserProgress.fromMap(progress);
    }

    final db = await instance.database;
    final res = await db.query(
      'user_progress',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
    if (res.isEmpty) return null;
    return UserProgress.fromMap(res.first);
  }

  Future<Map<String, dynamic>?> getProfileData() async {
    if (kIsWeb) {
      await _initWeb();
      return _webProfile;
    }

    final db = await instance.database;
    final res = await db.query('daily_streak', where: 'id = 1');
    if (res.isEmpty) return null;
    return res.first;
  }

  Future<void> saveProfileData(Map<String, dynamic> data) async {
    if (kIsWeb) {
      await _initWeb();
      _webProfile['current_streak'] = data['current_streak'] ?? 0;
      _webProfile['longest_streak'] = data['longest_streak'] ?? 0;
      _webProfile['last_login_date'] = data['last_login_date'] ?? '';
      _webProfile['total_xp'] = data['total_xp'] ?? 0;
      _webProfile['total_lessons'] = data['total_lessons'] ?? 0;
      _webProfile['total_quizzes'] = data['total_quizzes'] ?? 0;
      _webProfile['current_level'] = data['current_level'] ?? 'Beginner';
      await _saveWebProgressToPrefs();
      return;
    }

    final db = await instance.database;
    await db.update(
      'daily_streak',
      {
        'current_streak': data['current_streak'] ?? 0,
        'longest_streak': data['longest_streak'] ?? 0,
        'last_login_date': data['last_login_date'] ?? '',
        'total_xp': data['total_xp'] ?? 0,
        'total_lessons': data['total_lessons'] ?? 0,
        'total_quizzes': data['total_quizzes'] ?? 0,
        'current_level': data['current_level'] ?? 'Beginner',
      },
      where: 'id = 1',
    );
  }

  Future<List<UserProgress>> getUnsyncedProgress() async {
    if (kIsWeb) {
      return []; // Skip sync on web fallback simple persistence
    }

    final db = await instance.database;
    final res = await db.query('user_progress', where: 'is_synced = 0');
    return res.map((m) => UserProgress.fromMap(m)).toList();
  }

  Future<void> markProgressSynced(String id) async {
    if (kIsWeb) return;
    final db = await instance.database;
    await db.update(
      'user_progress',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> saveCloudProgress(Map<String, dynamic> map) async {
    if (kIsWeb) {
      await _initWeb();
      _webProgress[map['lesson_id']] = map;
      await _saveWebProgressToPrefs();
      return;
    }

    final db = await instance.database;
    await db.insert(
      'user_progress',
      {
        'id': map['id'],
        'lesson_id': map['lesson_id'],
        'cards_seen': map['cards_seen'],
        'cards_learned': map['cards_learned'],
        'quiz_score': map['quiz_score'],
        'quiz_attempts': map['quiz_attempts'] ?? 1,
        'best_score': map['best_score'] ?? map['quiz_score'],
        'is_completed': map['is_completed'] ?? 0,
        'last_studied': map['last_studied'] ?? '',
        'is_synced': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> markCardLearned(String cardId, bool isLearned) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('web_card_learned_$cardId', isLearned);
      return;
    }

    final db = await instance.database;
    await db.update(
      'word_cards',
      {'is_learned': isLearned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [cardId],
    );
  }

  Future<void> updateCardsSeen(String lessonId, int seen, int learned) async {
    if (kIsWeb) {
      await _initWeb();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final progress = _webProgress[lessonId] ?? {};
      final currentSeen = progress['cards_seen'] as int? ?? 0;
      final currentLearned = progress['cards_learned'] as int? ?? 0;

      final updated = {
        'id': 'up_$lessonId',
        'lesson_id': lessonId,
        'cards_seen': seen > currentSeen ? seen : currentSeen,
        'cards_learned': learned > currentLearned ? learned : currentLearned,
        'quiz_score': progress['quiz_score'] ?? 0,
        'quiz_attempts': progress['quiz_attempts'] ?? 0,
        'best_score': progress['best_score'] ?? 0,
        'is_completed': progress['is_completed'] ?? 0,
        'last_studied': today,
        'is_synced': 0
      };

      _webProgress[lessonId] = updated;
      await _saveWebProgressToPrefs();
      return;
    }

    final db = await instance.database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final progress = await getProgressForLesson(lessonId);

    if (progress == null) {
      await db.insert('user_progress', {
        'id': 'up_$lessonId',
        'lesson_id': lessonId,
        'cards_seen': seen,
        'cards_learned': learned,
        'quiz_score': 0,
        'quiz_attempts': 0,
        'best_score': 0,
        'is_completed': 0,
        'last_studied': today,
        'is_synced': 0
      });
    } else {
      await db.update(
        'user_progress',
        {
          'cards_seen': seen > progress.cardsSeen ? seen : progress.cardsSeen,
          'cards_learned': learned > progress.cardsLearned ? learned : progress.cardsLearned,
          'last_studied': today,
          'is_synced': 0
        },
        where: 'lesson_id = ?',
        whereArgs: [lessonId],
      );
    }
  }

  Future<void> saveQuizResult(String lessonId, int score) async {
    if (kIsWeb) {
      await _initWeb();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final progress = _webProgress[lessonId] ?? {};
      final currentAttempts = progress['quiz_attempts'] as int? ?? 0;
      final currentBest = progress['best_score'] as int? ?? 0;
      final currentCompleted = progress['is_completed'] as int? ?? 0;

      final completed = score >= 80 ? 1 : 0;
      final isCompleted = (currentCompleted == 1 || completed == 1) ? 1 : 0;
      final best = score > currentBest ? score : currentBest;

      final updated = {
        'id': 'up_$lessonId',
        'lesson_id': lessonId,
        'cards_seen': progress['cards_seen'] ?? 0,
        'cards_learned': progress['cards_learned'] ?? 0,
        'quiz_score': score,
        'quiz_attempts': currentAttempts + 1,
        'best_score': best,
        'is_completed': isCompleted,
        'last_studied': today,
        'is_synced': 0
      };

      _webProgress[lessonId] = updated;
      _webProfile['total_quizzes'] = (_webProfile['total_quizzes'] as int) + 1;

      int completedCount = 0;
      _webProgress.forEach((key, val) {
        if (val['is_completed'] == 1) completedCount++;
      });
      _webProfile['total_lessons'] = completedCount;

      await _saveWebProgressToPrefs();

      if (completed == 1) {
        await unlockNextLesson(lessonId);
      }
      return;
    }

    final db = await instance.database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final progress = await getProgressForLesson(lessonId);

    final completed = score >= 80 ? 1 : 0;

    if (progress == null) {
      await db.insert('user_progress', {
        'id': 'up_$lessonId',
        'lesson_id': lessonId,
        'cards_seen': 0,
        'cards_learned': 0,
        'quiz_score': score,
        'quiz_attempts': 1,
        'best_score': score,
        'is_completed': completed,
        'last_studied': today,
        'is_synced': 0
      });
    } else {
      final isCompleted = (progress.isCompleted || completed == 1) ? 1 : 0;
      final best = score > progress.bestScore ? score : progress.bestScore;
      await db.update(
        'user_progress',
        {
          'quiz_score': score,
          'quiz_attempts': progress.quizAttempts + 1,
          'best_score': best,
          'is_completed': isCompleted,
          'last_studied': today,
          'is_synced': 0
        },
        where: 'lesson_id = ?',
        whereArgs: [lessonId],
      );
    }

    await db.rawUpdate('''
      UPDATE daily_streak
      SET total_quizzes = total_quizzes + 1
      WHERE id = 1
    ''');

    final countRes = await db.rawQuery('''
      SELECT COUNT(*) as count FROM user_progress WHERE is_completed = 1
    ''');
    final completedCount = countRes.first['count'] as int;
    await db.rawUpdate('''
      UPDATE daily_streak
      SET total_lessons = ?
      WHERE id = 1
    ''', [completedCount]);

    if (completed == 1) {
      await unlockNextLesson(lessonId);
    }
  }

  Future<void> addXp(int xp) async {
    if (kIsWeb) {
      await _initWeb();
      final currentXp = (_webProfile['total_xp'] as int) + xp;
      _webProfile['total_xp'] = currentXp;

      String newLevel = _webProfile['current_level'] as String;
      if (currentXp >= 1000) {
        newLevel = 'Advanced';
      } else if (currentXp >= 500) {
        newLevel = 'Intermediate';
      } else if (currentXp >= 200) {
        newLevel = 'Elementary';
      }
      _webProfile['current_level'] = newLevel;

      await _saveWebProgressToPrefs();
      return;
    }

    final db = await instance.database;
    await db.rawUpdate('''
      UPDATE daily_streak
      SET total_xp = total_xp + ?
      WHERE id = 1
    ''', [xp]);

    final profile = await getProfileData();
    if (profile != null) {
      final totalXp = profile['total_xp'] as int;
      String newLevel = profile['current_level'] as String;

      if (totalXp >= 1000) {
        newLevel = 'Advanced';
      } else if (totalXp >= 500) {
        newLevel = 'Intermediate';
      } else if (totalXp >= 200) {
        newLevel = 'Elementary';
      }

      if (newLevel != profile['current_level']) {
        await db.rawUpdate('''
          UPDATE daily_streak
          SET current_level = ?
          WHERE id = 1
        ''', [newLevel]);
      }
    }
  }

  Future<void> unlockNextLesson(String currentLessonId) async {
    if (kIsWeb) {
      await _initWeb();
      final current = seededLessons.firstWhere((l) => l['id'] == currentLessonId, orElse: () => {});
      if (current.isEmpty) return;

      final level = current['level'] as String;
      final order = current['order_index'] as int;

      final next = seededLessons.firstWhere(
        (l) => l['level'] == level && l['order_index'] == order + 1,
        orElse: () => {},
      );

      if (next.isNotEmpty) {
        final nextId = next['id'] as String;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('web_lesson_unlocked_$nextId', true);
      }
      return;
    }

    final db = await instance.database;
    final currentList = await db.query('lessons', where: 'id = ?', whereArgs: [currentLessonId]);
    if (currentList.isEmpty) return;

    final current = currentList.first;
    final level = current['level'] as String;
    final order = current['order_index'] as int;

    final nextInLevel = await db.query(
      'lessons',
      where: 'level = ? AND order_index = ?',
      whereArgs: [level, order + 1],
    );

    if (nextInLevel.isNotEmpty) {
      final nextId = nextInLevel.first['id'] as String;
      await db.update('lessons', {'is_unlocked': 1}, where: 'id = ?', whereArgs: [nextId]);
    }
  }

  Future<void> resetAllData() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (var key in keys.toList()) {
        if (key.startsWith('web_')) {
          await prefs.remove(key);
        }
      }
      _webProgress.clear();
      _webProfile['current_streak'] = 0;
      _webProfile['longest_streak'] = 0;
      _webProfile['last_login_date'] = '';
      _webProfile['total_xp'] = 0;
      _webProfile['total_lessons'] = 0;
      _webProfile['total_quizzes'] = 0;
      _webProfile['current_level'] = 'Beginner';
      return;
    }

    final db = await instance.database;
    await db.delete('user_progress');
    await db.rawUpdate('UPDATE word_cards SET is_learned = 0');
    await db.rawUpdate('''
      UPDATE lessons 
      SET is_unlocked = CASE 
        WHEN id IN ('b_greetings', 'e_food', 'i_verbs', 'a_idioms') THEN 1 
        ELSE 0 
      END
    ''');
    await db.rawUpdate('''
      UPDATE daily_streak 
      SET current_streak = 0, longest_streak = 0, last_login_date = '', total_xp = 0, total_lessons = 0, total_quizzes = 0, current_level = 'Beginner'
    ''');
  }

  Future<List<UserProgress>> getAllProgress() async {
    if (kIsWeb) {
      await _initWeb();
      return _webProgress.values.map((m) => UserProgress.fromMap(m)).toList();
    }

    final db = await instance.database;
    final res = await db.query('user_progress');
    return res.map((m) => UserProgress.fromMap(m)).toList();
  }

  Future<List<Map<String, dynamic>>> getAllLessons() async {
    if (kIsWeb) {
      return seededLessons;
    }
    final db = await database;
    return await db.query('lessons');
  }

  Future<int> getLearnedCardsCount() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      int count = 0;
      for (var c in seededCards) {
        final id = c['id'] as String;
        if (prefs.getBool('web_card_learned_$id') ?? false) {
          count++;
        }
      }
      return count;
    }
    final db = await database;
    final res = await db.rawQuery('SELECT COUNT(*) as count FROM word_cards WHERE is_learned = 1');
    return res.first['count'] as int;
  }

  Future<void> checkAndUpdateStreak() async {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    if (kIsWeb) {
      await _initWeb();
      final lastLogin = _webProfile['last_login_date'] as String? ?? '';
      int current = _webProfile['current_streak'] as int? ?? 0;
      int longest = _webProfile['longest_streak'] as int? ?? 0;

      if (lastLogin.isEmpty) {
        current = 1;
        longest = 1;
        _webProfile['current_streak'] = current;
        _webProfile['longest_streak'] = longest;
        _webProfile['last_login_date'] = todayStr;
        _webProfile['total_xp'] = (_webProfile['total_xp'] as int) + 5;
      } else if (lastLogin == todayStr) {
        // Do nothing
      } else {
        final lastDate = DateFormat('yyyy-MM-dd').parse(lastLogin);
        final todayDate = DateFormat('yyyy-MM-dd').parse(todayStr);
        final difference = todayDate.difference(lastDate).inDays;

        if (difference == 1) {
          current += 1;
          if (current > longest) longest = current;
          _webProfile['current_streak'] = current;
          _webProfile['longest_streak'] = longest;
          _webProfile['last_login_date'] = todayStr;
          _webProfile['total_xp'] = (_webProfile['total_xp'] as int) + 5;
        } else if (difference > 1) {
          current = 1;
          _webProfile['current_streak'] = current;
          _webProfile['last_login_date'] = todayStr;
          _webProfile['total_xp'] = (_webProfile['total_xp'] as int) + 5;
        }
      }
      await _saveWebProgressToPrefs();
      return;
    }

    final db = await database;
    final profile = await getProfileData();
    if (profile == null) return;

    final lastLogin = profile['last_login_date'] as String;
    int current = profile['current_streak'] as int;
    int longest = profile['longest_streak'] as int;

    if (lastLogin.isEmpty) {
      current = 1;
      longest = 1;
      await db.rawUpdate('''
        UPDATE daily_streak
        SET current_streak = ?, longest_streak = ?, last_login_date = ?, total_xp = total_xp + 5
        WHERE id = 1
      ''', [current, longest, todayStr]);
    } else if (lastLogin == todayStr) {
      // Do nothing
    } else {
      final lastDate = DateFormat('yyyy-MM-dd').parse(lastLogin);
      final todayDate = DateFormat('yyyy-MM-dd').parse(todayStr);
      final difference = todayDate.difference(lastDate).inDays;

      if (difference == 1) {
        current += 1;
        if (current > longest) {
          longest = current;
        }
        await db.rawUpdate('''
          UPDATE daily_streak
          SET current_streak = ?, longest_streak = ?, last_login_date = ?, total_xp = total_xp + 5
          WHERE id = 1
        ''', [current, longest, todayStr]);
      } else if (difference > 1) {
        current = 1;
        await db.rawUpdate('''
          UPDATE daily_streak
          SET current_streak = ?, last_login_date = ?, total_xp = total_xp + 5
          WHERE id = 1
        ''', [current, todayStr]);
      }
    }
  }
}
