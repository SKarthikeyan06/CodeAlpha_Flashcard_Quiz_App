import 'package:flutter/material.dart';

class LevelBadge extends StatelessWidget {
  final String level;

  const LevelBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    IconData iconData;

    switch (level) {
      case 'Beginner':
        badgeColor = Colors.teal;
        iconData = Icons.emoji_emotions_outlined;
        break;
      case 'Elementary':
        badgeColor = Colors.blue.shade600;
        iconData = Icons.school_outlined;
        break;
      case 'Intermediate':
        badgeColor = Colors.purple.shade600;
        iconData = Icons.psychology_outlined;
        break;
      case 'Advanced':
        badgeColor = Colors.deepOrange.shade600;
        iconData = Icons.workspace_premium_outlined;
        break;
      default:
        badgeColor = Colors.grey;
        iconData = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            level,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
