import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_tracker_app/controllers/dashboard_controller.dart';
import 'package:fitness_tracker_app/screens/log_workout_screen.dart';
import 'package:fitness_tracker_app/screens/history_screen.dart';
import 'package:fitness_tracker_app/screens/goals_screen.dart';
import 'package:fitness_tracker_app/widgets/stat_tile.dart';
import 'package:fitness_tracker_app/widgets/calorie_ring.dart';
import 'package:fitness_tracker_app/widgets/weekly_bar_chart.dart';
import 'package:fitness_tracker_app/widgets/activity_card.dart';

class DashboardScreen extends StatefulWidget {
  final String uid;

  const DashboardScreen({super.key, required this.uid});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _calorieGoal = 500;
  int _minuteGoal = 45;
  int _stepGoal = 8000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _calorieGoal = prefs.getInt('goal_calories') ?? 500;
        _minuteGoal = prefs.getInt('goal_minutes') ?? 45;
        _stepGoal = prefs.getInt('goal_steps') ?? 8000;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadGoals();
    if (mounted) {
      await Provider.of<DashboardController>(context, listen: false).loadDashboard();
    }
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat("EEEE, d MMMM").format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fitness Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Workout History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(uid: widget.uid),
                ),
              ).then((_) => _refreshData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.outlined_flag),
            tooltip: 'My Goals',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GoalsScreen(),
                ),
              ).then((shouldReload) {
                if (shouldReload == true) {
                  _refreshData();
                }
              });
            },
          ),
        ],
      ),
      body: Consumer<DashboardController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            color: theme.colorScheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Date Header
                  Text(
                    'Today, $formattedDate',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      StatTile(
                        icon: Icons.local_fire_department,
                        label: 'Calories\n($_calorieGoal kcal)',
                        value: controller.totalCaloriesToday,
                        color: Colors.red.shade400,
                      ),
                      StatTile(
                        icon: Icons.timer,
                        label: 'Minutes\n($_minuteGoal mins)',
                        value: controller.totalMinutesToday,
                        color: Colors.amber.shade600,
                      ),
                      StatTile(
                        icon: Icons.directions_walk,
                        label: 'Steps\n($_stepGoal steps)',
                        value: controller.totalStepsToday,
                        color: Colors.blue.shade400,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Calorie Goal Ring
                  CalorieRing(
                    caloriesToday: controller.totalCaloriesToday,
                    dailyGoal: _calorieGoal,
                  ),

                  // Weekly Progress Chart
                  _buildSectionHeader(theme, 'Weekly Progress'),
                  WeeklyBarChart(last7DaysLogs: controller.last7DaysLogs),

                  // Today's Activities
                  _buildSectionHeader(theme, "Today's Activities"),
                  controller.todayLogs.isEmpty
                      ? Card(
                          elevation: 0,
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.fitness_center_outlined,
                                    size: 40,
                                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No activities logged today.\nTap + to add your first workout.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: controller.todayLogs
                              .map((log) => Dismissible(
                                    key: Key('today-${log.id}'),
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
                                    onDismissed: (direction) async {
                                      await controller.deleteLog(log.id, widget.uid);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('${log.exerciseType} workout deleted'),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    },
                                    child: ActivityCard(log: log),
                                  ))
                              .toList(),
                        ),
                  const SizedBox(height: 80), // spacer for FAB overlay
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LogWorkoutScreen(uid: widget.uid),
            ),
          ).then((shouldReload) {
            if (shouldReload == true) {
              _refreshData();
            }
          });
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
