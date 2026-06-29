import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/quote.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback onTranslate;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.onLike,
    required this.onShare,
    required this.onTranslate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey<int>(quote.id ?? 0),
        width: double.infinity,
        padding: const EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    theme.colorScheme.surfaceContainerHighest,
                    theme.colorScheme.surface,
                  ]
                : [
                    theme.colorScheme.primaryContainer.withAlpha(50),
                    theme.colorScheme.primaryContainer.withAlpha(20),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: theme.colorScheme.primary.withAlpha(isDark ? 50 : 30),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withAlpha(isDark ? 30 : 15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withAlpha(55),
                  width: 0.8,
                ),
              ),
              child: Text(
                quote.category.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.5,
                ),
              ),
            ).animate().fade(duration: 400.ms).slideX(begin: -0.1),
            const SizedBox(height: 24),
            // Quote Symbol
            Icon(
              Icons.format_quote_rounded,
              size: 48,
              color: theme.colorScheme.primary.withAlpha(60),
            ).animate().scale(delay: 100.ms, duration: 300.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 8),
            // Quote Text
            Text(
              quote.text,
              style: TextStyle(
                fontSize: 22,
                height: 1.5,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
                fontFamily: 'serif',
              ),
            ).animate().fade(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 20),
            // Author Text
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "— ${quote.author}",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ).animate().fade(delay: 300.ms, duration: 400.ms),
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Like Button
                IconButton(
                  onPressed: onLike,
                  tooltip: 'Like Quote',
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      quote.isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                      key: ValueKey<bool>(quote.isLiked),
                      color: quote.isLiked ? Colors.redAccent : theme.colorScheme.onSurfaceVariant,
                      size: 26,
                    ),
                  ),
                ),
                // Share Button
                IconButton(
                  onPressed: onShare,
                  tooltip: 'Share Quote',
                  icon: Icon(
                    Icons.share_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                // Translate Button
                IconButton(
                  onPressed: onTranslate,
                  tooltip: 'Translate Quote',
                  icon: Icon(
                    Icons.g_translate_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
