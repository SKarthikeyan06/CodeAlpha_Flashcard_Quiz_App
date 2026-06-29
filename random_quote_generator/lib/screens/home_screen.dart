import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/home_controller.dart';
import '../widgets/quote_card.dart';
import '../widgets/generate_button.dart';
import 'liked_screen.dart';
import 'add_quote_screen.dart';
import 'translate_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().loadRandomQuote();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Quotes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_rounded),
            color: theme.colorScheme.primary,
            tooltip: 'Liked Quotes',
            onPressed: () async {
              final controller = context.read<HomeController>();
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LikedScreen()),
              );
              if (controller.currentQuote != null) {
                controller.loadRandomQuote();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<HomeController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.currentQuote == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Finding the perfect quote...',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          }

          final quote = controller.currentQuote;
          if (quote == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    size: 64,
                    color: theme.colorScheme.primary.withAlpha(80),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No quotes found.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => controller.loadRandomQuote(),
                    child: const Text('Reload Seed Data'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: QuoteCard(
                        quote: quote,
                        onLike: () => controller.toggleLike(),
                        onShare: () {
                          Share.share('"${quote.text}"\n— ${quote.author}');
                        },
                        onTranslate: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TranslateScreen(quote: quote),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GenerateButton(
                  onPressed: () => controller.loadRandomQuote(),
                  isLoading: controller.isLoading,
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          final controller = context.read<HomeController>();
          final saved = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddQuoteScreen()),
          );
          if (saved == true) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Quote saved successfully!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            controller.loadRandomQuote();
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Quote'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
      ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }
}
