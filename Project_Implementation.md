# Flashcard Quiz App - Flutter Implementation Plan

## Project Goal

Build a Flashcard Quiz App for studying.

Users should be able to:

- Add flashcards
- View flashcards
- Study flashcards
- Show answer
- Navigate using Next/Previous
- Edit flashcards
- Delete flashcards
- Store data locally

Authentication is NOT required.

---

# Tech Stack

Framework: Flutter

State Management:
- Provider

Local Database:
- Sqlite

Architecture:
- Feature Based

---

# UI Screens

## Screen 1 - Home Screen

Purpose:
Display all flashcards.

Requirements:

- AppBar title:
  "Flashcard Quiz"

- If no cards:
  Show:
    "No cards yet"

- Floating Action Button:
    "+"
    Navigate to Add Card Screen

- Show flashcards in ListView

Card item should display:
- Question
- Tap to Study
- Long Press to Edit
- Swipe to Delete

---

## Screen 2 - Add Card Screen

Purpose:
Create new flashcard.

UI:

Question TextField

Answer TextField

Save Card Button

Validation:

- Question cannot be empty
- Answer cannot be empty

On Save:

- Create Flashcard object
- Store in sqlite
- Refresh Provider
- Return to Home Screen

---

## Screen 3 - Study Screen

Purpose:
Study selected flashcard.

State:

showAnswer = false

Display:

Question

Button:
Show Answer

When clicked:

Display Answer

Bottom Navigation:

Previous Button

Next Button

Rules:

Previous disabled at first card

Next disabled at last card

Changing card should:

showAnswer = false

---

## Screen 4 - Edit Card Screen

Purpose:
Update existing card.

UI:

Question TextField

Answer TextField

Update Button

Delete Button

Update:

Save changes to sqlite

Delete:

Remove card from sqlite

Return to Home Screen

---

# Data Model

Flashcard

Fields:

id
question
answer

Example:

{
  "id":"123",
  "question":"What is Flutter?",
  "answer":"Google UI Toolkit"
}

---

# Folder Structure

lib/

main.dart

models/
  flashcard.dart

services/
  storage_service.dart

providers/
  flashcard_provider.dart

screens/
  home_screen.dart
  add_card_screen.dart
  study_screen.dart
  edit_card_screen.dart

widgets/
  flashcard_tile.dart

---

# Hive Storage Service

Create StorageService.

Functions:

initialize()

getAllCards()

addCard()

updateCard()

deleteCard()

clearAllCards()

---

# Provider Requirements

Create FlashcardProvider.

State:

List<Flashcard> cards

Functions:

loadCards()

addCard()

updateCard()

deleteCard()

notifyListeners()

---

# Navigation Flow

Home Screen
    |
    +----> Add Card Screen
    |
    +----> Study Screen
    |
    +----> Edit Card Screen

---

# UI Design Guidelines

Use Material 3

Card widgets

Rounded corners

Consistent spacing

Responsive layout

Clean modern appearance

No unnecessary animations

---

# Required Dependencies

provider

uuid

---

# Development Phases

PHASE 1

Create project structure.

Create all screens.

Implement navigation.

Do not implement Hive.

---

PHASE 2

Create Flashcard model.

Create Sqlite storage service.

Initialize Sqlite.

---

PHASE 3

Implement Provider.

Connect Provider with Sqlite.

---

PHASE 4

Implement Add Card functionality.

Persist data locally.

---

PHASE 5

Implement Home Screen card listing.

---

PHASE 6

Implement Study Screen.

Show Answer.

Next.

Previous.

---

PHASE 7

Implement Edit functionality.

Implement Delete functionality.

---

PHASE 8

UI refinement.

Validation.

Error handling.

Testing.

---

# Acceptance Criteria

The application is complete only if:

✓ Add flashcard works

✓ Flashcards persist after app restart

✓ Show Answer works

✓ Previous works

✓ Next works

✓ Edit works

✓ Delete works

✓ Empty state works

✓ No crashes occur

✓ Clean UI
