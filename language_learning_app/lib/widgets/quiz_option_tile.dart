import 'package:flutter/material.dart';

class QuizOptionTile extends StatelessWidget {
  final String option;
  final String label;
  final bool isSelected;
  final bool isAnswered;
  final bool isCorrect;
  final VoidCallback onTap;

  const QuizOptionTile({
    super.key,
    required this.option,
    required this.label,
    required this.isSelected,
    required this.isAnswered,
    required this.isCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Color textColor = Colors.black87;
    Widget? trailingWidget;

    if (isAnswered) {
      if (isCorrect) {
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green.shade500;
        textColor = Colors.green.shade800;
        trailingWidget = const Icon(Icons.check_circle, color: Colors.green, size: 24);
      } else if (isSelected) {
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red.shade500;
        textColor = Colors.red.shade800;
        trailingWidget = const Icon(Icons.cancel, color: Colors.red, size: 24);
      } else {
        backgroundColor = Colors.grey.shade50;
        borderColor = Colors.grey.shade200;
        textColor = Colors.grey.shade400;
      }
    } else {
      if (isSelected) {
        backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.06);
        borderColor = Theme.of(context).colorScheme.primary;
        textColor = Theme.of(context).colorScheme.primary;
      }
    }

    return GestureDetector(
      onTap: isAnswered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected && !isAnswered
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isAnswered
                    ? (isCorrect
                        ? Colors.green.shade600
                        : (isSelected ? Colors.red.shade600 : Colors.grey.shade300))
                    : (isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: isAnswered || isSelected ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            if (trailingWidget != null) trailingWidget,
          ],
        ),
      ),
    );
  }
}
