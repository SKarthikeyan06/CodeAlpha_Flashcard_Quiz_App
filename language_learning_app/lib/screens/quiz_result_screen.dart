import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../controllers/quiz_controller.dart';
import '../controllers/home_controller.dart';
import 'quiz_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final String lessonId;
  final int score;
  final int totalQuestions;
  final int correctCount;

  const QuizResultScreen({
    super.key,
    required this.lessonId,
    required this.score,
    required this.totalQuestions,
    required this.correctCount,
  });

  String _getGradeText() {
    if (score >= 80) return 'Excellent! 🌟';
    if (score >= 50) return 'Good Job! 👍';
    return 'Keep Practicing! 💪';
  }

  Color _getScoreColor() {
    if (score >= 80) return Colors.green.shade600;
    if (score >= 50) return Colors.amber.shade600;
    return Colors.red.shade600;
  }

  int _calculateXp() {
    int base = correctCount * 10;
    if (score == 100) {
      base += 20; // 100% bonus
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final gradeText = _getGradeText();
    final scoreColor = _getScoreColor();
    final xpEarned = _calculateXp();
    final quizController = context.read<QuizController>();
    final homeController = context.read<HomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(),
              // Floating XP Animation
              if (xpEarned > 0)
                Center(
                  child: Text(
                    '+$xpEarned XP!',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.amber.shade800,
                    ),
                  )
                      .animate()
                      .scale(duration: 400.ms, curve: Curves.bounceOut)
                      .slideY(begin: 0.6, end: -0.3, duration: 600.ms)
                      .fadeOut(delay: 900.ms, duration: 300.ms),
                ),
              
              const SizedBox(height: 12),

              // PieChart Doughnut Ring
              SizedBox(
                height: 160,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 60,
                        startDegreeOffset: 270,
                        sections: [
                          PieChartSectionData(
                            color: scoreColor,
                            value: score.toDouble(),
                            title: '',
                            radius: 14,
                          ),
                          PieChartSectionData(
                            color: Colors.grey.shade100,
                            value: (100 - score).toDouble(),
                            title: '',
                            radius: 12,
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$score%',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: scoreColor,
                            ),
                          ),
                          Text(
                            '$correctCount / $totalQuestions Correct',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                gradeText,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),

              const SizedBox(height: 8),

              if (score >= 80)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_open, color: Colors.green.shade800, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Next Lesson Unlocked!',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 300.ms)
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.orange.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade800, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Score 80% to unlock next lesson',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 300.ms),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),

              // Question Review Header
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'REVIEW QUESTIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Review List
              Expanded(
                child: ListView.builder(
                  itemCount: quizController.questions.length,
                  itemBuilder: (context, index) {
                    final q = quizController.questions[index];
                    final wasCorrect = quizController.answerResults.length > index
                        ? quizController.answerResults[index]
                        : false;

                    return Card(
                      elevation: 0,
                      color: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        dense: true,
                        leading: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: wasCorrect ? Colors.green.shade50 : Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            wasCorrect ? Icons.check : Icons.close,
                            color: wasCorrect ? Colors.green : Colors.red,
                            size: 16,
                          ),
                        ),
                        title: Text(
                          q.questionEn,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Ans: ${q.correctAns}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Bottom Button Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        // Reload and retry quiz
                        context.read<QuizController>().loadQuiz(lessonId);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(lessonId: lessonId),
                          ),
                        );
                      },
                      child: const Text('Retry Quiz'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        // Reload lessons list and home to capture progress
                        await homeController.loadHome();
                        Navigator.pop(context); // Go back to Tabbar LessonScreen
                      },
                      child: const Text('Back to Lesson'),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
