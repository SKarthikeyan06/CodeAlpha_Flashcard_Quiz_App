import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/quiz_controller.dart';
import '../controllers/home_controller.dart';
import '../models/quiz_question.dart';
import '../widgets/quiz_option_tile.dart';
import '../services/tts_service.dart';
import 'quiz_result_screen.dart';
import '../services/auth_service.dart';

class QuizScreen extends StatefulWidget {
  final String lessonId;

  const QuizScreen({super.key, required this.lessonId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuizController>();
    final homeController = context.read<HomeController>();
    final tts = context.read<TtsService>();

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.questions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'To take this quiz, first study the flashcards and complete the lesson!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ),
      );
    }

    final question = controller.currentQuestion!;
    final progress = controller.questions.isEmpty
        ? 0.0
        : (controller.currentIndex + 1) / controller.questions.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sub-progress bar inside quiz
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${controller.currentIndex + 1} of ${controller.questions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                'Score: ${controller.correctCount}/${controller.currentIndex + (controller.isAnswered ? 1 : 0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation(Colors.orange.shade600),
            ),
          ),
          const SizedBox(height: 20),

          // Question Card
          Expanded(
            child: SingleChildScrollView(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                shadowColor: Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.quiz, color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            question.questionType.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        question.questionEn,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (question.questionTa.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          question.questionTa,
                          style: GoogleFonts.notoSansTamil(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 16),
                      // TTS audio button
                      Material(
                        color: Colors.orange.shade50,
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: Icon(Icons.volume_up, color: Colors.orange.shade800),
                          onPressed: () {
                            if (question.questionTa.isNotEmpty) {
                              tts.speakTamil(question.questionTa);
                            } else {
                              tts.speakEnglish(question.questionEn);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Answer options or Textfield
          if (question.questionType == 'fill_blank')
            _buildFillBlankInput(controller)
          else if (question.questionType == 'true_false')
            _buildTrueFalseOptions(controller, question)
          else
            _buildMultipleChoiceOptions(controller, question),

          const SizedBox(height: 16),

          // Next Question Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              backgroundColor: controller.isAnswered ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
              foregroundColor: controller.isAnswered ? Colors.white : Colors.grey.shade500,
            ),
            onPressed: controller.isAnswered
                ? () async {
                    if (controller.isLastQuestion) {
                      final uid = await AuthService().getOrCreateUid();
                      await controller.saveResult(widget.lessonId, uid);
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizResultScreen(
                              lessonId: widget.lessonId,
                              score: (controller.scorePercent * 100).round(),
                              totalQuestions: controller.questions.length,
                              correctCount: controller.correctCount,
                            ),
                          ),
                        );
                      }
                    } else {
                      _textController.clear();
                      controller.nextQuestion();
                    }
                  }
                : null,
            child: Text(
              controller.isLastQuestion ? 'View Results' : 'Next Question',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceOptions(QuizController controller, QuizQuestion question) {
    final options = [
      {'label': 'A', 'text': question.optionA},
      {'label': 'B', 'text': question.optionB},
      {'label': 'C', 'text': question.optionC},
      {'label': 'D', 'text': question.optionD},
    ];

    return Column(
      children: options.map((opt) {
        final optionText = opt['text']!;
        if (optionText.isEmpty) return const SizedBox.shrink();

        final isSelected = controller.selectedAnswer == optionText;
        final isCorrect = optionText == question.correctAns;

        return QuizOptionTile(
          option: optionText,
          label: opt['label']!,
          isSelected: isSelected,
          isAnswered: controller.isAnswered,
          isCorrect: isCorrect,
          onTap: () => controller.selectAnswer(optionText),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalseOptions(QuizController controller, QuizQuestion question) {
    final options = [
      {'label': 'T', 'text': 'True'},
      {'label': 'F', 'text': 'False'},
    ];

    return Column(
      children: options.map((opt) {
        final optionText = opt['text']!;
        final isSelected = controller.selectedAnswer == optionText;
        final isCorrect = optionText == question.correctAns;

        return QuizOptionTile(
          option: optionText,
          label: opt['label']!,
          isSelected: isSelected,
          isAnswered: controller.isAnswered,
          isCorrect: isCorrect,
          onTap: () => controller.selectAnswer(optionText),
        );
      }).toList(),
    );
  }

  Widget _buildFillBlankInput(QuizController controller) {
    if (controller.isAnswered) {
      final userAns = controller.selectedAnswer ?? '';
      final correctAns = controller.currentQuestion!.correctAns;
      final isCorrect = userAns.trim().toLowerCase() == correctAns.trim().toLowerCase();

      return Card(
        color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isCorrect ? Colors.green.shade300 : Colors.red.shade300, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCorrect ? 'Correct! Excellent.' : 'Incorrect Answer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green.shade900 : Colors.red.shade900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Your answer: "$userAns"',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Correct answer: "$correctAns"',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: 'Type the correct Tamil word...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: GoogleFonts.notoSansTamil(),
          textInputAction: TextInputAction.done,
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              controller.selectAnswer(val.trim());
            }
          },
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            foregroundColor: Colors.orange.shade900,
            side: BorderSide(color: Colors.orange.shade200),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          onPressed: () {
            if (_textController.text.trim().isNotEmpty) {
              controller.selectAnswer(_textController.text.trim());
            }
          },
          icon: const Icon(Icons.send),
          label: const Text('Submit Answer', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
