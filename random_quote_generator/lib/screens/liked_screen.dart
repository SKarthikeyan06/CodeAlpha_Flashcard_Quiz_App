import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../db/database_helper.dart';
import '../models/quote.dart';
import '../controllers/home_controller.dart';
import 'add_quote_screen.dart';

class LikedScreen extends StatefulWidget {
  const LikedScreen({super.key});

  @override
  State<LikedScreen> createState() => _LikedScreenState();
}

class _LikedScreenState extends State<LikedScreen> {
  List<Quote> _likedQuotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLikedQuotes();
  }

  Future<void> _loadLikedQuotes() async {
    setState(() => _isLoading = true);
    try {
      final quotes = await DatabaseHelper.instance.getLikedQuotes();
      setState(() {
        _likedQuotes = quotes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading quotes: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Map<String, List<Quote>> _groupQuotesByCategory() {
    final Map<String, List<Quote>> groups = {};
    for (final quote in _likedQuotes) {
      groups.putIfAbsent(quote.category, () => []).add(quote);
    }
    return groups;
  }

  Future<void> _unlikeQuote(Quote quote) async {
    final originalLikedStatus = quote.isLiked;
    // Optimistic state update
    setState(() {
      _likedQuotes.removeWhere((q) => q.id == quote.id);
    });

    try {
      await DatabaseHelper.instance.toggleLike(quote.id!, false);
      // Synchronize with HomeController if it holds the currently displayed quote
      if (mounted) {
        final homeController = context.read<HomeController>();
        if (homeController.currentQuote?.id == quote.id) {
          homeController.currentQuote!.isLiked = false;
        }
      }
    } catch (e) {
      // Revert on error
      quote.isLiked = originalLikedStatus;
      _loadLikedQuotes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to unlike: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final grouped = _groupQuotesByCategory();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _likedQuotes.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 72,
                          color: theme.colorScheme.primary.withAlpha(80),
                        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 24),
                        const Text(
                          'No favorites yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                         Text(
                          'Tap the heart icon on any quote to save it here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Find Quotes'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  itemCount: grouped.keys.length,
                  itemBuilder: (context, index) {
                    final category = grouped.keys.elementAt(index);
                    final quotes = grouped[category]!;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant.withAlpha(isDark ? 80 : 150),
                          width: 1,
                        ),
                      ),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        title: Text(
                          category,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        shape: const Border(), // Removes standard divider line from tile
                        children: quotes.map((quote) {
                          return Dismissible(
                            key: ValueKey<int>(quote.id!),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.shade100.withAlpha(40),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                color: Colors.redAccent,
                              ),
                            ),
                            onDismissed: (direction) {
                              _unlikeQuote(quote);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Removed from favorites'),
                                  behavior: SnackBarBehavior.floating,
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () async {
                                      final homeController = context.read<HomeController>();
                                      await DatabaseHelper.instance.toggleLike(quote.id!, true);
                                      _loadLikedQuotes();
                                      if (homeController.currentQuote?.id == quote.id) {
                                        homeController.currentQuote!.isLiked = true;
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  title: Text(
                                    quote.text,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontFamily: 'serif',
                                      fontSize: 15,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      "— ${quote.author}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  onLongPress: () {
                                    // Navigate to edit mode in AddQuoteScreen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddQuoteScreen(quote: quote),
                                      ),
                                    ).then((changed) {
                                      if (changed == true) {
                                        _loadLikedQuotes();
                                      }
                                    });
                                  },
                                ),
                                if (quote != quotes.last)
                                  const Divider(indent: 16, endIndent: 16, height: 1),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ).animate().fade(delay: (index * 100).ms, duration: 300.ms).slideY(begin: 0.05);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddQuoteScreen()),
          ).then((saved) {
            if (saved == true) {
              _loadLikedQuotes();
            }
          });
        },
        tooltip: 'Add Quote',
        child: const Icon(Icons.add),
      ),
    );
  }
}
