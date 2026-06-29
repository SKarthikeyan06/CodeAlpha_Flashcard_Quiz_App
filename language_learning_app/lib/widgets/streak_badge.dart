import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StreakBadge extends StatelessWidget {
  final int streak;

  const StreakBadge({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    if (streak >= 30) {
      badgeColor = Colors.red.shade600;
    } else if (streak >= 7) {
      badgeColor = Colors.orange.shade600;
    } else {
      badgeColor = Colors.amber.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        border: Border.all(color: badgeColor, width: 1.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🔥',
            style: TextStyle(fontSize: 18),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.85, 0.85),
                end: const Offset(1.25, 1.25),
                duration: 800.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(width: 6),
          Text(
            '$streak ${streak == 1 ? "Day" : "Days"} Streak',
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
