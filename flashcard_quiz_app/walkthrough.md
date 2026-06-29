# Walkthrough - Flashcard Quiz App (Multiple-Choice & Score Logs)

We have successfully refined the Flashcard Quiz App to support multiple-choice questions in Quiz Mode, log scores and attempt times, save quiz histories in SQLite, and present attempts on the Home Screen dashboard.

Here is a summary of the accomplishments, features, and verification results.

---

## 🌟 Key Enhancements

### 1. Multiple-Choice Quiz Options
- **Dynamic Distractors**: For each question in the quiz, the app dynamically generates 4 options: the correct answer and 3 incorrect distractors sampled from other flashcards in the deck (or as many as available if deck size < 4).
- **Interactive Option Grid**: Options are displayed as buttons. Clicking an option provides immediate visual feedback:
  - **Correct Choice**: Highlighted in Green.
  - **Incorrect Choice**: Highlighted in Red, while the correct answer flashes Green.
- **Auto-Flip Details**: Tapping a multiple-choice option automatically triggers the 3D card flip animation to reveal the detailed answer card for thorough learning.

### 2. Database Transition & Scored History (`quiz.db`)
- **Combined SQLite Storage**: Transitioned database filename to `quiz.db` which instantiates version 1 containing two tables:
  - `flashcards`: Stores the flashcard details and difficulty labels.
  - `quiz_attempts`: Tracks previous quiz sessions.
- **Log Parameters**: Saved attempts log:
  - **Correct ratio** (e.g. `4/5`)
  - **Percentage score** (e.g. `80%`)
  - **Attempt time** (exact timestamp)
- **Web Persistence fallback**: Attempt logs are fully stored and read from browser SharedPreferences on Chrome (Web) to ensure zero crashes and complete functionality.

### 3. Home Dashboard Score History
- **Recent Quiz Attempts**: Added a horizontal scroll container below the stats header displaying previous scores.
- **Visual indicators**:
  - Score percentage displayed inside a colored circular avatar (Green for >= 80%, Blue for >= 50%, Red for < 50%).
  - raw score ratio.
  - Date and time details (formatted as `YYYY-MM-DD HH:MM`).

### 4. Layout & UI Overflow Fixes
- Wrapped horizontal details in `Expanded` widgets and constraints inside [flashcard_tile.dart](file:///d:/Python%20Projects/Flutter%20App/Flashcard_Quiz_App/flashcard_quiz_app/lib/widgets/flashcard_tile.dart) to resolve horizontal RenderFlex overflow issues.

---

## 🛠️ Code Architecture

Files updated:
- [quiz_attempt.dart](file:///d:/Python%20Projects/Flutter%20App/Flashcard_Quiz_App/flashcard_quiz_app/lib/models/quiz_attempt.dart) [NEW]: Model describing attempt schema.
- [storage_service.dart](file:///d:/Python%20Projects/Flutter%20App/Flashcard_Quiz_App/flashcard_quiz_app/lib/services/storage_service.dart): Transferred to database `quiz.db` and added `quiz_attempts` SQLite and SharedPreferences CRUD hooks.
- [flashcard_provider.dart](file:///d:/Python%20Projects/Flutter%20App/Flashcard_Quiz_App/flashcard_quiz_app/lib/providers/flashcard_provider.dart): Integrated attempts caching and automatic loading on card refresh.
- [quiz_screen.dart](file:///d:/Python%20Projects/Flutter%20App/Flashcard_Quiz_App/flashcard_quiz_app/lib/screens/quiz_screen.dart): Added multiple-choice builder, option highlights, and database saving triggers on quiz completion.
- [home_screen.dart](file:///d:/Python%20Projects/Flutter%20App/Flashcard_Quiz_App/flashcard_quiz_app/lib/screens/home_screen.dart): Displayed recent attempt cards below the dashboard stats header.
- [flashcard_tile.dart](file:///d:/Python%20Projects/Flutter%20App/Flashcard_Quiz_App/flashcard_quiz_app/lib/widgets/flashcard_tile.dart): Solved horizontal layout overflow issues.

---

## 🔬 Verification Results

We verified code health using the Flutter SDK compiler:
- **Command**: `flutter analyze`
- **Result**: `No issues found! (ran in 5.2s)`
- Code compiles perfectly with zero deprecation warnings, type casting errors, or syntax issues.
