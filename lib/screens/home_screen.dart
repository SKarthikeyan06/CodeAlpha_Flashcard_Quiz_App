import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard.dart';
import '../models/quiz_attempt.dart';
import '../providers/flashcard_provider.dart';
import '../widgets/flashcard_tile.dart';
import 'add_card_screen.dart';
import 'study_screen.dart';
import 'edit_card_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load cards when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlashcardProvider>().loadCards();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Quiz'),
        actions: [
          Consumer<FlashcardProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: Icon(
                  provider.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
                tooltip: 'Toggle Theme',
                onPressed: () {
                  provider.toggleTheme();
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<FlashcardProvider>().loadCards();
            },
          ),
        ],
      ),
      body: Consumer<FlashcardProvider>(
        builder: (context, provider, _) {
          final allCards = provider.cards;
          final filteredCards = allCards.where((card) {
            final q = card.question.toLowerCase();
            final a = card.answer.toLowerCase();
            return q.contains(_searchQuery) || a.contains(_searchQuery);
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Statistics Dashboard Header
              _buildDashboardHeader(context, allCards),

              // Recent Quiz Attempts
              _buildRecentAttempts(context, provider.attempts),

              // Search Bar
              if (allCards.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search flashcards...',
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B)),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),

              // Cards List / Empty State
              Expanded(
                child: allCards.isEmpty
                    ? _buildEmptyState(context, isSearch: false)
                    : filteredCards.isEmpty
                        ? _buildEmptyState(context, isSearch: true)
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: filteredCards.length,
                            itemBuilder: (context, index) {
                              final card = filteredCards[index];
                              // Find actual index in allCards for navigation
                              final originalIndex = allCards.indexOf(card);
                              return FlashcardTile(
                                flashcard: card,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudyScreen(
                                        cards: allCards,
                                        initialIndex: originalIndex,
                                      ),
                                    ),
                                  );
                                },
                                onLongPress: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditCardScreen(
                                        flashcard: card,
                                      ),
                                    ),
                                  );
                                },
                                onSwipe: () {
                                  provider.deleteCard(card.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Card deleted'),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCardScreen(),
            ),
          );
          if (result == true) {
            if (mounted) {
              context.read<FlashcardProvider>().loadCards();
            }
          }
        },
        tooltip: 'Add Card',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildDashboardHeader(BuildContext context, List<Flashcard> cards) {
    final theme = Theme.of(context);
    final count = cards.length;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withRed(100).withBlue(220),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Study Session',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      count == 1 ? '1 Flashcard' : '$count Flashcards',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Easy: ${cards.where((c) => c.difficulty == 'Easy').length}  •  Medium: ${cards.where((c) => c.difficulty == 'Medium').length}  •  Hard: ${cards.where((c) => c.difficulty == 'Hard').length}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    count == 0
                        ? 'Add some cards to begin your learning journey!'
                        : 'Ready to test your knowledge?',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                if (count > 0) ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudyScreen(
                            cards: cards,
                            initialIndex: 0,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      foregroundColor: Colors.white,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.white30, width: 1),
                      ),
                    ),
                    child: const Text('Study', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(cards: cards),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Quiz', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        SizedBox(width: 4),
                        Icon(Icons.assignment_turned_in_rounded, size: 14),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool isSearch}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isSearch ? Colors.orange.shade50 : theme.colorScheme.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearch ? Icons.search_off_rounded : Icons.library_add_rounded,
                size: 64,
                color: isSearch ? Colors.orange : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearch ? 'No Results Found' : 'No Cards Yet',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isSearch
                  ? 'We couldn\'t find any flashcards matching "$_searchQuery". Try a different search term.'
                  : 'Start learning by creating cards. Tap the "+" button below to add your first question and answer.',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAttempts(BuildContext context, List<QuizAttempt> attempts) {
    if (attempts.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'Recent Quiz Attempts',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleMedium?.color ?? const Color(0xFF1E293B),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 96,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: attempts.length,
            itemBuilder: (context, index) {
              final attempt = attempts[index];
              final percent = attempt.total > 0 ? attempt.correct / attempt.total : 0.0;
              
              Color scoreColor;
              if (percent >= 0.8) {
                scoreColor = const Color(0xFF22C55E); // Green
              } else if (percent >= 0.5) {
                scoreColor = const Color(0xFF3B82F6); // Blue
              } else {
                scoreColor = const Color(0xFFEF4444); // Red
              }

              return Container(
                width: 170,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: scoreColor.withValues(alpha: 0.25), width: 1.5),
                  ),
                  color: scoreColor.withValues(alpha: 0.06),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: scoreColor,
                          child: Text(
                            '${(percent * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Score: ${attempt.score}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: scoreColor,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _formatDateTime(attempt.attemptTime),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6) ?? const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    final year = local.year;
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }
}

