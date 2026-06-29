import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../controllers/flashcard_controller.dart';
import '../controllers/quiz_controller.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Pre-load cards and quiz in controllers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlashcardController>().loadCards(widget.lesson.id);
      context.read<QuizController>().loadQuiz(widget.lesson.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flashcardController = context.watch<FlashcardController>();
    final progressVal = flashcardController.progressPercent;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lesson.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        bottom: TabBar(
          controller: _tabController,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: 'Study Cards'),
            Tab(text: 'Take Quiz'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Top overall progress indicator for card learning
          if (widget.lesson.totalCards > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressVal,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation(
                          progressVal == 1.0 ? Colors.green.shade600 : Colors.blue.shade600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(progressVal * 100).round()}% Completed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: progressVal == 1.0 ? Colors.green.shade800 : Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                FlashcardScreen(
                  lessonId: widget.lesson.id,
                  tabController: _tabController,
                ),
                QuizScreen(lessonId: widget.lesson.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
