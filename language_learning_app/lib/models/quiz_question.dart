class QuizQuestion {
  final String id;
  final String lessonId;
  final String questionType; // multiple_choice, fill_blank, true_false
  final String questionEn;
  final String questionTa;
  final String correctAns;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;

  QuizQuestion({
    required this.id,
    required this.lessonId,
    required this.questionType,
    required this.questionEn,
    required this.questionTa,
    required this.correctAns,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) => QuizQuestion(
        id:           map['id'] as String,
        lessonId:     map['lesson_id'] as String,
        questionType: map['question_type'] as String,
        questionEn:   map['question_en'] as String,
        questionTa:   map['question_ta'] as String,
        correctAns:   map['correct_ans'] as String,
        optionA:      map['option_a'] as String,
        optionB:      map['option_b'] as String,
        optionC:      map['option_c'] as String,
        optionD:      map['option_d'] as String,
      );

  Map<String, dynamic> toMap() => {
        'id':            id,
        'lesson_id':     lessonId,
        'question_type': questionType,
        'question_en':   questionEn,
        'question_ta':   questionTa,
        'correct_ans':   correctAns,
        'option_a':      optionA,
        'option_b':      optionB,
        'option_c':      optionC,
        'option_d':      optionD,
      };
}
