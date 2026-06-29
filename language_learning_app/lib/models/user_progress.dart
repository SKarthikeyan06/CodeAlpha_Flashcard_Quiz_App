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
        id:           map['id'] as String,
        lessonId:     map['lesson_id'] as String,
        cardsSeen:    map['cards_seen'] as int,
        cardsLearned: map['cards_learned'] as int,
        quizScore:    map['quiz_score'] as int,
        quizAttempts: map['quiz_attempts'] as int,
        bestScore:    map['best_score'] as int,
        isCompleted:  map['is_completed'] == 1,
        lastStudied:  map['last_studied'] ?? '',
        isSynced:     map['is_synced'] == 1,
      );

  Map<String, dynamic> toMap() => {
        'id':            id,
        'lesson_id':     lessonId,
        'cards_seen':    cardsSeen,
        'cards_learned': cardsLearned,
        'quiz_score':    quizScore,
        'quiz_attempts': quizAttempts,
        'best_score':    bestScore,
        'is_completed':  isCompleted ? 1 : 0,
        'last_studied':  lastStudied,
        'is_synced':     isSynced ? 1 : 0,
      };
}
