import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fitness_tracker_app/db/local_db.dart';
import 'package:fitness_tracker_app/models/workout_log.dart';
import 'package:fitness_tracker_app/services/firebase_service.dart';
import 'package:fitness_tracker_app/widgets/activity_card.dart';

abstract class HistoryItem {}

class HeaderItem extends HistoryItem {
  final String date;
  HeaderItem(this.date);
}

class LogItem extends HistoryItem {
  final WorkoutLog log;
  LogItem(this.log);
}

class HistoryScreen extends StatefulWidget {
  final String uid;

  const HistoryScreen({super.key, required this.uid});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<WorkoutLog>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    setState(() {
      _historyFuture = LocalDb.instance.getAllLogs();
    });
  }

  Map<String, List<WorkoutLog>> _groupLogsByDate(List<WorkoutLog> logs) {
    final Map<String, List<WorkoutLog>> groups = {};
    for (final log in logs) {
      if (groups[log.date] == null) {
        groups[log.date] = [];
      }
      groups[log.date]!.add(log);
    }
    return groups;
  }

  List<HistoryItem> _buildFlatList(List<WorkoutLog> logs) {
    final List<HistoryItem> items = [];
    final grouped = _groupLogsByDate(logs);
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    for (final date in sortedDates) {
      items.add(HeaderItem(date));
      for (final log in grouped[date]!) {
        items.add(LogItem(log));
      }
    }
    return items;
  }

  String _formatHeaderDate(String dateStr) {
    try {
      final parsedDate = DateTime.parse(dateStr);
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      final dateOnly = DateFormat('yyyy-MM-dd').format(parsedDate);
      final todayOnly = DateFormat('yyyy-MM-dd').format(today);
      final yesterdayOnly = DateFormat('yyyy-MM-dd').format(yesterday);

      if (dateOnly == todayOnly) {
        return 'Today';
      } else if (dateOnly == yesterdayOnly) {
        return 'Yesterday';
      } else {
        return DateFormat('EEEE, MMMM d, y').format(parsedDate);
      }
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _deleteWorkout(WorkoutLog log) async {
    // Delete from SQLite
    await LocalDb.instance.deleteLog(log.id);
    // Try to delete from Firebase Firestore
    try {
      await FirebaseService().deleteLog(widget.uid, log.id);
    } catch (_) {
      // Offline deletion silent fallback
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${log.exerciseType} workout deleted'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
      _refreshHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<WorkoutLog>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No workouts logged yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          final flatItems = _buildFlatList(logs);

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: flatItems.length,
            itemBuilder: (context, index) {
              final item = flatItems[index];

              if (item is HeaderItem) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 12.0, left: 4.0),
                  child: Text(
                    _formatHeaderDate(item.date),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                );
              } else if (item is LogItem) {
                final log = item.log;
                return Dismissible(
                  key: Key(log.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.onErrorContainer,
                      size: 28,
                    ),
                  ),
                  onDismissed: (direction) => _deleteWorkout(log),
                  child: ActivityCard(log: log),
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
