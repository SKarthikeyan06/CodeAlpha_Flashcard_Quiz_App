class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String difficulty; // 'Easy', 'Medium', 'Hard'

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.difficulty = 'Medium',
  });

  // Convert to Map for storing in database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'difficulty': difficulty,
    };
  }

  // Create from Map when retrieving from database
  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'],
      question: map['question'],
      answer: map['answer'],
      difficulty: map['difficulty'] ?? 'Medium',
    );
  }

  // Create a copy with modified fields
  Flashcard copyWith({
    String? id,
    String? question,
    String? answer,
    String? difficulty,
  }) {
    return Flashcard(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  String toString() => 'Flashcard(id: $id, question: $question, answer: $answer, difficulty: $difficulty)';
}
