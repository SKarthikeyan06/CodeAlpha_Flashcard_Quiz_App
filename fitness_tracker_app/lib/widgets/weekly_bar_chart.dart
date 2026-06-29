import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fitness_tracker_app/models/workout_log.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<WorkoutLog> last7DaysLogs;

  const WeeklyBarChart({
    super.key,
    required this.last7DaysLogs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    // Generate list of last 7 days
    final List<DateTime> last7Days = List.generate(7, (index) {
      return today.subtract(Duration(days: 6 - index));
    });

    // Group logs by date and sum calories
    final Map<String, int> caloriesByDate = {};
    for (final log in last7DaysLogs) {
      caloriesByDate[log.date] = (caloriesByDate[log.date] ?? 0) + log.calories;
    }

    double maxCal = 500.0; // minimum vertical range
    final List<BarChartGroupData> barGroups = [];
    
    for (int i = 0; i < 7; i++) {
      final date = last7Days[i];
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final calories = (caloriesByDate[dateStr] ?? 0).toDouble();
      
      if (calories > maxCal) {
        maxCal = calories;
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: calories,
              color: theme.colorScheme.primary,
              width: 14,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxCal,
                color: theme.colorScheme.outlineVariant.withOpacity(0.3),
              ),
            ),
          ],
        ),
      );
    }

    // Add some padding to Y-axis max value
    maxCal = (maxCal * 1.15).ceilToDouble();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxCal,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => theme.colorScheme.inverseSurface,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.round()} kcal',
                  TextStyle(
                    color: theme.colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < 7) {
                    final date = last7Days[index];
                    final label = DateFormat('E').format(date);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }
}
