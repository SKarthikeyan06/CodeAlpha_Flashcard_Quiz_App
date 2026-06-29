import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class StudyScreen extends StatefulWidget {
  final List<Flashcard> cards;
  final int initialIndex;

  const StudyScreen({
    Key? key,
    required this.cards,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.cards.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleShowAnswer() {
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study')),
        body: const Center(child: Text('No cards available to study')),
      );
    }

    final isFirstCard = _currentIndex == 0;
    final isLastCard = _currentIndex == widget.cards.length - 1;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Card ${_currentIndex + 1}/${widget.cards.length}',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Study Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (widget.cards.isNotEmpty)
                      ? (_currentIndex + 1) / widget.cards.length
                      : 0.0,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
            ),

            // Main swipable card area
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.cards.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    _showAnswer = false; // Reset answer showing state on swipe
                  });
                },
                itemBuilder: (context, index) {
                  final card = widget.cards[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Center(
                      child: GestureDetector(
                        onTap: _toggleShowAnswer,
                        child: AspectRatio(
                          aspectRatio: 0.75, // Make the card look like a regular flashcard
                          child: FlipCard(
                            showAnswer: index == _currentIndex ? _showAnswer : false,
                            front: _buildCardSide(
                              context,
                              title: 'QUESTION',
                              content: card.question,
                              accentColor: theme.colorScheme.primary,
                              icon: Icons.help_outline_rounded,
                              isFront: true,
                              difficulty: card.difficulty,
                            ),
                            back: _buildCardSide(
                              context,
                              title: 'ANSWER',
                              content: card.answer,
                              accentColor: theme.colorScheme.secondary,
                              icon: Icons.check_circle_outline_rounded,
                              isFront: false,
                              difficulty: card.difficulty,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation and Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Show/Hide Answer Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _toggleShowAnswer,
                      icon: Icon(
                        _showAnswer ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      ),
                      label: Text(_showAnswer ? 'Hide Answer' : 'Show Answer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _showAnswer
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Next / Previous buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isFirstCard ? null : _goToPrevious,
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Previous'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            side: BorderSide(
                              color: isFirstCard
                                  ? theme.disabledColor.withValues(alpha: 0.2)
                                  : theme.colorScheme.primary.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isLastCard ? null : _goToNext,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Next'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            side: BorderSide(
                              color: isLastCard
                                  ? theme.disabledColor.withValues(alpha: 0.2)
                                  : theme.colorScheme.primary.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSide(
    BuildContext context, {
    required String title,
    required String content,
    required Color accentColor,
    required IconData icon,
    required bool isFront,
    required String difficulty,
  }) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: accentColor.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: isFront
                ? [Colors.white, const Color(0xFFF8FAFC)]
                : [const Color(0xFFFDF2F8), Colors.white], // Pink tint for answer card
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top row with QUESTION/ANSWER badge and Difficulty badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 16, color: accentColor),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStudyDifficultyBadge(difficulty),
              ],
            ),
            const Spacer(),
            // Main Text Scrollable if long
            Expanded(
              flex: 8,
              child: Center(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                          height: 1.4,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Bottom Action Tip
            Text(
              'Tap card to flip',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyDifficultyBadge(String difficulty) {
    Color bgColor;
    Color textColor;
    switch (difficulty) {
      case 'Easy':
        bgColor = const Color(0xFFDCFCE7); // Green 100
        textColor = const Color(0xFF15803D); // Green 700
        break;
      case 'Hard':
        bgColor = const Color(0xFFFEE2E2); // Red 100
        textColor = const Color(0xFFB91C1C); // Red 700
        break;
      default:
        bgColor = const Color(0xFFFEF3C7); // Amber 100
        textColor = const Color(0xFFB45309); // Amber 700
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// Custom 3D Card Flip Widget
class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool showAnswer;

  const FlipCard({
    Key? key,
    required this.front,
    required this.back,
    required this.showAnswer,
  }) : super(key: key);

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.showAnswer) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAnswer != oldWidget.showAnswer) {
      if (widget.showAnswer) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double value = _animation.value;
        final double rotationAngle = value * 3.1415926535897932; // pi

        final isFrontFacing = rotationAngle < 3.1415926535897932 / 2;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(rotationAngle),
          alignment: Alignment.center,
          child: isFrontFacing
              ? widget.front
              : Transform(
                  transform: Matrix4.identity()..rotateY(3.1415926535897932),
                  alignment: Alignment.center,
                  child: widget.back,
                ),
        );
      },
    );
  }
}

