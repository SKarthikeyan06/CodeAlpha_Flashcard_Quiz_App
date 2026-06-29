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
        id:              map['id'] as String,
        lessonId:        map['lesson_id'] as String,
        english:         map['english'] as String,
        tamil:           map['tamil'] as String,
        transliteration: map['transliteration'] as String,
        exampleEn:       map['example_en'] as String,
        exampleTa:       map['example_ta'] as String,
        category:        map['category'] as String,
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
