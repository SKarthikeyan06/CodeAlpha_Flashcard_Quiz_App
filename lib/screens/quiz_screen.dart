import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/flashcard.dart';
import '../models/quiz_attempt.dart';
import '../providers/flashcard_provider.dart';
import 'study_screen.dart' show FlipCard; // Reuse the premium 3D FlipCard widget we built

class QuizScreen extends StatefulWidget {
  final List<Flashcard> cards;

  const QuizScreen({
    Key? key,
    required this.cards,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Flashcard> _quizCards;
  int _currentIndex = 0;
  bool _showAnswer = false;
  
  // Multiple Choice state variables
  final Map<String, List<String>> _cardOptions = {};
  String? _selectedOption;
  bool _hasAnswered = false;

  // Track quiz score results (true = Correct, false = Incorrect)
  final List<bool> _results = [];
  bool _quizCompleted = false;

  @override
  void initState() {
    super.initState();
    _startNewQuiz();
  }

  void _startNewQuiz() {
    setState(() {
      // Shuffle cards randomly
      _quizCards = List.from(widget.cards)..shuffle();
      _currentIndex = 0;
      _showAnswer = false;
      _selectedOption = null;
      _hasAnswered = false;
      _results.clear();
      _quizCompleted = false;

      // Construct multiple choice options for each card
      _cardOptions.clear();
      for (var card in _quizCards) {
        // Find other cards' answers to act as distractors
        final otherAnswers = widget.cards
            .where((c) => c.id != card.id)
            .map((c) => c.answer)
            .toSet()
            .toList();
        
        otherAnswers.shuffle();
        
        // Take up to 3 distractors
        final distractors = otherAnswers.take(3).toList();
        
        // Combine distractor answers with the correct answer
        final options = [card.answer, ...distractors];
        options.shuffle(); // Randomize answer position
        
        _cardOptions[card.id] = options;
      }
    });
  }

  void _selectOption(String option, String correctAnswer) {
    if (_hasAnswered) return; // Prevent double answering

    setState(() {
      _selectedOption = option;
      _hasAnswered = true;
      _showAnswer = true; // Auto-flip the card to reveal details!
      
      final isCorrect = option == correctAnswer;
      _results.add(isCorrect);
    });
  }

  void _nextQuestion() async {
    if (_currentIndex < _quizCards.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _hasAnswered = false;
        _showAnswer = false;
      });
    } else {
      // Quiz completed! Save history.
      final correctCount = _results.where((r) => r).length;
      final totalCount = _results.length;

      final attempt = QuizAttempt(
        id: const Uuid().v4(),
        score: '$correctCount/$totalCount',
        correct: correctCount,
        total: totalCount,
        attemptTime: DateTime.now(),
      );

      // Save to SQLite & notify providers
      await context.read<FlashcardProvider>().saveQuizAttempt(attempt);

      setState(() {
        _quizCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_quizCompleted ? 'Quiz Results' : 'Quiz Session'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Exit Quiz',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: _quizCompleted ? _buildResultsView(context) : _buildQuizView(context, theme),
      ),
    );
  }

  Widget _buildQuizView(BuildContext context, ThemeData theme) {
    final card = _quizCards[_currentIndex];
    final progress = (_currentIndex + 1) / _quizCards.length;
    final options = _cardOptions[card.id] ?? [card.answer];

    return Column(
      children: [
        // Progress indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentIndex + 1} of ${_quizCards.length}',
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Score: ${_results.where((r) => r).length}/${_results.length}',
                    style: const TextStyle(
                      color: Color(0xFF15803D), // Green
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
            ],
          ),
        ),

        // 3D Card Area
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Center(
              child: AspectRatio(
                aspectRatio: 0.85,
                child: FlipCard(
                  showAnswer: _showAnswer,
                  front: _buildCardSide(
                    context,
                    title: 'QUIZ QUESTION',
                    content: card.question,
                    accentColor: theme.colorScheme.primary,
                    icon: Icons.help_outline_rounded,
                    difficulty: card.difficulty,
                    isFront: true,
                  ),
                  back: _buildCardSide(
                    context,
                    title: 'QUIZ ANSWER',
                    content: card.answer,
                    accentColor: theme.colorScheme.secondary,
                    icon: Icons.check_circle_outline_rounded,
                    difficulty: card.difficulty,
                    isFront: false,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Multiple Choice Options List
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_hasAnswered)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Choose the correct answer:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ...options.map((opt) {
                  final isSelected = _selectedOption == opt;
                  final isCorrectAnswer = opt == card.answer;
                  
                  // Visual highlights after grading
                  Color btnBorderColor = Colors.transparent;
                  Color btnBgColor = theme.cardColor;
                  Color btnTextColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

                  if (_hasAnswered) {
                    if (isCorrectAnswer) {
                      // Correct option is always highlighted green
                      btnBgColor = theme.brightness == Brightness.dark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7);
                      btnBorderColor = const Color(0xFF22C55E);
                      btnTextColor = const Color(0xFF15803D);
                    } else if (isSelected) {
                      // Selected incorrect option is highlighted red
                      btnBgColor = theme.brightness == Brightness.dark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
                      btnBorderColor = const Color(0xFFEF4444);
                      btnTextColor = const Color(0xFFB91C1C);
                    } else {
                      // Non-selected incorrect options are dimmed
                      btnBgColor = theme.brightness == Brightness.dark ? theme.cardColor.withValues(alpha: 0.5) : const Color(0xFFF8FAFC);
                      btnTextColor = const Color(0xFF94A3B8);
                    }
                  } else {
                    btnBorderColor = const Color(0xFFE2E8F0);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OutlinedButton(
                      onPressed: _hasAnswered ? null : () => _selectOption(opt, card.answer),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: btnBgColor,
                        foregroundColor: btnTextColor,
                        side: BorderSide(
                          color: btnBorderColor,
                          width: 2.0,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      child: Text(
                        opt,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: btnTextColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),

                // Next Button
                if (_hasAnswered) ...[
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _nextQuestion,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                    label: Text(
                      _currentIndex < _quizCards.length - 1
                          ? 'Next Question'
                          : 'Finish Quiz & Save',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardSide(
    BuildContext context, {
    required String title,
    required String content,
    required Color accentColor,
    required IconData icon,
    required String difficulty,
    required bool isFront,
  }) {
    Color diffBgColor;
    Color diffTextColor;
    switch (difficulty) {
      case 'Easy':
        diffBgColor = const Color(0xFFDCFCE7);
        diffTextColor = const Color(0xFF15803D);
        break;
      case 'Hard':
        diffBgColor = const Color(0xFFFEE2E2);
        diffTextColor = const Color(0xFFB91C1C);
        break;
      default:
        diffBgColor = const Color(0xFFFEF3C7);
        diffTextColor = const Color(0xFFB45309);
    }

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: accentColor.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          gradient: isFront
              ? null
              : LinearGradient(
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [const Color(0xFF3F1B2F), Theme.of(context).cardColor]
                      : [const Color(0xFFFDF2F8), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 12, color: accentColor),
                      const SizedBox(width: 4),
                      Text(
                        title,
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: diffBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    difficulty.toUpperCase(),
                    style: TextStyle(
                      color: diffTextColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Expanded(
              flex: 8,
              child: Center(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Text(
              isFront ? 'Select an option below' : 'Correct Answer details',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView(BuildContext context) {
    final theme = Theme.of(context);
    final correctCount = _results.where((r) => r).length;
    final totalCount = _results.length;
    final scorePercentage = totalCount > 0 ? correctCount / totalCount : 0.0;

    String feedbackMessage;
    IconData feedbackIcon;
    Color feedbackColor;
    if (scorePercentage >= 0.8) {
      feedbackMessage = 'Excellent work!';
      feedbackIcon = Icons.emoji_events_rounded;
      feedbackColor = const Color(0xFF22C55E); // Green
    } else if (scorePercentage >= 0.5) {
      feedbackMessage = 'Good job, keep studying!';
      feedbackIcon = Icons.thumb_up_rounded;
      feedbackColor = const Color(0xFF3B82F6); // Blue
    } else {
      feedbackMessage = 'Keep practicing, you\'ll get there!';
      feedbackIcon = Icons.sentiment_neutral_rounded;
      feedbackColor = const Color(0xFFEF4444); // Red
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Circular Score Visualizer Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Icon(feedbackIcon, size: 48, color: feedbackColor),
                  const SizedBox(height: 12),
                  Text(
                    feedbackMessage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Score Indicator Stack
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 140,
                          width: 140,
                          child: CircularProgressIndicator(
                            value: scorePercentage,
                            strokeWidth: 12,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(scorePercentage * 100).round()}%',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$correctCount of $totalCount',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatSummary('CORRECT', correctCount, const Color(0xFF22C55E)),
                      _buildStatSummary('INCORRECT', totalCount - correctCount, const Color(0xFFEF4444)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Question Breakdown / List
          const Text(
            'Question Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _quizCards.length,
            itemBuilder: (context, index) {
              final card = _quizCards[index];
              final gotCorrect = _results[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: gotCorrect ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                    width: 1,
                  ),
                ),
                color: gotCorrect
                    ? (theme.brightness == Brightness.dark ? const Color(0xFF14241B) : const Color(0xFFF0FDF4))
                    : (theme.brightness == Brightness.dark ? const Color(0xFF2A1717) : const Color(0xFFFEF2F2)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: gotCorrect ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                    radius: 14,
                    child: Icon(
                      gotCorrect ? Icons.check_rounded : Icons.close_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  title: Text(
                    card.question,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    card.answer,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      card.difficulty,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          // Action Buttons
          ElevatedButton.icon(
            onPressed: _startNewQuiz,
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Restart Quiz'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.home_rounded),
            label: const Text('Back to Home'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatSummary(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
