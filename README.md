# Flashcard Quiz App — Active Recall Study Companion

A feature-rich Flutter study tool developed as part of the **CodeAlpha Flutter Development Internship (Task 1)**. This application enables students to manage flashcards, study them using a beautiful 3D flip card view, and take interactive multiple-choice quizzes that log attempt scores and times in a dashboard history feed.

---

## 📸 Core Features

1. **Flashcard CRUD Manager**:
   - Create, edit, and delete custom flashcards with questions, answers, and difficulty levels.
   - Input validations ensure no blank fields can be submitted.
2. **Study Mode**:
   - Flip cards in a beautiful 3D rotation animation to toggle between the question and the detailed answer.
   - Previous and Next navigation controls to swipe or click through cards.
3. **Interactive Multiple-Choice Quiz**:
   - **Dynamic Distractor Generator**: For each card in the quiz, the app dynamically samples up to 3 incorrect answers from the rest of your flashcard deck to act as multiple-choice options.
   - **Real-Time Visual Validation**: Tapping an answer button highlights it immediately (Green for correct, Red for incorrect, and flashes the correct button in green).
   - Tapping an option automatically triggers the 3D flip to show the detailed explanation.
4. **Historical Score Logging**:
   - Automatically saves quiz attempts into the local database.
   - Logs correct answer ratios (e.g. `4/5`), overall percentages (e.g. `80%`), and exact timestamp logs.
5. **Dashboard Score History**:
   - The Home Screen features a horizontal feed showcasing previous attempts.
   - Circular score badges are color-coded depending on performance: Green (>= 80%), Blue (>= 50%), and Red (< 50%).
6. **Responsive Web & Mobile Layouts**:
   - Outfitted with responsive flex constraints preventing RenderFlex overflow errors on narrow phones or wide web browsers.

---

## 🛠️ Tech Stack & Dependencies

- **Framework**: Flutter (Dart) supporting Mobile and Web.
- **State Management**: `Provider` (using change-notifiers to maintain a decoupled and clean reactive data flow).
- **Local Databases**: SQLite (`sqflite`) for native mobile storage.
- **Web Persistence Fallback**: `shared_preferences` database mapping to save quiz logs and cards on Chrome/Web environments without crashing.
- **Utilities**: `uuid` for unique ID generation, `intl` for datetime formats.

---

## 🗄️ Database Architecture (`quiz.db`)

Contains a unified schema version with two tables:

### Table 1: `flashcards`
Stores study questions and answers.
```sql
CREATE TABLE flashcards (
  id          TEXT PRIMARY KEY,
  question    TEXT NOT NULL,
  answer      TEXT NOT NULL,
  difficulty  TEXT DEFAULT 'Medium'
);
```

### Table 2: `quiz_attempts`
Logs session results for the user dashboard.
```sql
CREATE TABLE quiz_attempts (
  id           TEXT PRIMARY KEY,
  score_ratio  TEXT NOT NULL,     -- e.g. "4/5"
  percentage   INTEGER NOT NULL,   -- e.g. 80
  timestamp    TEXT NOT NULL       -- YYYY-MM-DD HH:MM
);
```

---

## ⚙️ Getting Started & Run Instructions

To run the application locally:

1. **Install Dependencies**:
   ```bash
   cd flashcard_quiz_app
   flutter pub get
   ```

2. **Run on Mobile or Web**:
   - For Mobile:
     ```bash
     flutter run
     ```
   - For Web (Chrome):
     ```bash
     flutter run -d chrome
     ```

---

## 🏷️ Keywords & Tags
`#Flutter` `#Dart` `#SQLite` `#ActiveRecall` `#EdTech` `#MobileDevelopment` `#WebDevelopment` `#Provider` `#InteractiveQuiz` `#Material3` `#StudyApp`
