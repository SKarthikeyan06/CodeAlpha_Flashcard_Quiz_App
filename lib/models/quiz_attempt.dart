class QuizAttempt {
  final String id;
  final String score;
  final int correct;
  final int total;
  final DateTime attemptTime;

  QuizAttempt({
    required this.id,
    required this.score,
    required this.correct,
    required this.total,
    required this.attemptTime,
  });

  // Convert to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'score': score,
      'correct': correct,
      'total': total,
      'attempt_time': attemptTime.toIso8601String(),
    };
  }

  // Create from Map when loading from SQLite
  factory QuizAttempt.fromMap(Map<String, dynamic> map) {
    return QuizAttempt(
      id: map['id'],
      score: map['score'],
      correct: map['correct'],
      total: map['total'],
      attemptTime: DateTime.parse(map['attempt_time']),
    );
  }

  @override
  String toString() {
    return 'QuizAttempt(id: $id, score: $score, correct: $correct, total: $total, attemptTime: $attemptTime)';
  }
}
