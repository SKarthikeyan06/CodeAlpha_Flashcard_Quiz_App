import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fitness_tracker_app/models/workout_log.dart';

class ActivityCard extends StatelessWidget {
  final WorkoutLog log;
  final VoidCallback? onDelete; // Optional, useful if we delete inside card

  const ActivityCard({
    super.key,
    required this.log,
    this.onDelete,
  });

  IconData _getIcon() {
    switch (log.exerciseType) {
      case 'Running':
        return Icons.directions_run;
      case 'Walking':
        return Icons.directions_walk;
      case 'Cycling':
        return Icons.directions_bike;
      case 'Gym':
        return Icons.fitness_center;
      case 'Yoga':
        return Icons.self_improvement;
      case 'Swimming':
        return Icons.pool;
      default:
        return Icons.sports;
    }
  }

  Color _getColor() {
    switch (log.exerciseType) {
      case 'Running':
        return Colors.red.shade400;
      case 'Walking':
        return Colors.green.shade400;
      case 'Cycling':
        return Colors.blue.shade400;
      case 'Gym':
        return Colors.orange.shade400;
      case 'Yoga':
        return Colors.purple.shade400;
      case 'Swimming':
        return Colors.cyan.shade400;
      default:
        return Colors.grey.shade500;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final parsedDate = DateTime.parse(dateStr);
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      if (DateFormat('yyyy-MM-dd').format(parsedDate) == DateFormat('yyyy-MM-dd').format(today)) {
        return 'Today';
      } else if (DateFormat('yyyy-MM-dd').format(parsedDate) == DateFormat('yyyy-MM-dd').format(yesterday)) {
        return 'Yesterday';
      } else {
        return DateFormat('MMM d, y').format(parsedDate);
      }
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = _getColor();

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(),
                color: cardColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.exerciseType,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${log.durationMins} mins • ${log.calories} kcal' + 
                    (log.steps > 0 ? ' • ${log.steps} steps' : ''),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (log.notes.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      log.notes,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(log.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: log.isSynced
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : theme.colorScheme.outline.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        log.isSynced ? Icons.cloud_done : Icons.cloud_queue,
                        size: 12,
                        color: log.isSynced
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        log.isSynced ? 'Synced' : 'Local',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: log.isSynced
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                      ),
                    ],
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
