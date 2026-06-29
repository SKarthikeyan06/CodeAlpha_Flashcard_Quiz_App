import 'package:flutter_test/flutter_test.dart';
import 'package:language_learning_app/models/lesson.dart';
import 'package:language_learning_app/models/word_card.dart';
import 'package:language_learning_app/controllers/home_controller.dart';
import 'package:language_learning_app/controllers/lesson_controller.dart';

void main() {
  test('Models compilation and serialization unit test', () {
    final lesson = Lesson(
      id: 'b_greetings',
      title: 'Vanakkam & Greetings',
      description: 'Say hello in Tamil.',
      category: 'Greetings',
      level: 'Beginner',
      orderIndex: 1,
      totalCards: 4,
      isUnlocked: true,
    );

    expect(lesson.id, 'b_greetings');
    expect(lesson.isUnlocked, true);
    expect(lesson.cardsSeen, 0);

    final card = WordCard(
      id: 'wc_1',
      lessonId: 'b_greetings',
      english: 'Hello',
      tamil: 'வணக்கம்',
      transliteration: 'Vanakkam',
      exampleEn: 'Hello, how are you?',
      exampleTa: 'வணக்கம், நீங்கள் எப்படி இருக்கிறீர்கள்?',
      category: 'Greetings',
    );

    expect(card.english, 'Hello');
    expect(card.isLearned, false);
  });

  test('Controllers state initialization test', () {
    final homeController = HomeController();
    expect(homeController.isLoading, false);
    expect(homeController.totalXp, 0);
    expect(homeController.currentStreak, 0);

    final lessonController = LessonController();
    expect(lessonController.isLoading, false);
    expect(lessonController.selectedLevel, 'Beginner');
    expect(lessonController.lessons, isEmpty);
  });
}
