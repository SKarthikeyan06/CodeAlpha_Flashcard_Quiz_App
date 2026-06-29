class Lesson {
  final String id;
  final String title;
  final String description;
  final String category;
  final String level;
  final int orderIndex;
  final int totalCards;
  bool isUnlocked;

  // Progress fields (dynamically loaded from LEFT JOIN)
  int cardsSeen;
  int cardsLearned;
  int bestScore;
  bool isCompleted;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.orderIndex,
    required this.totalCards,
    this.isUnlocked = false,
    this.cardsSeen = 0,
    this.cardsLearned = 0,
    this.bestScore = 0,
    this.isCompleted = false,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) => Lesson(
        id:          map['id'] as String,
        title:       map['title'] as String,
        description: map['description'] as String,
        category:    map['category'] as String,
        level:       map['level'] as String,
        orderIndex:  map['order_index'] as int,
        totalCards:  map['total_cards'] as int,
        isUnlocked:  map['is_unlocked'] == 1,
        cardsSeen:    map['cards_seen'] != null ? map['cards_seen'] as int : 0,
        cardsLearned: map['cards_learned'] != null ? map['cards_learned'] as int : 0,
        bestScore:    map['best_score'] != null ? map['best_score'] as int : 0,
        isCompleted:  map['is_completed'] == 1,
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
