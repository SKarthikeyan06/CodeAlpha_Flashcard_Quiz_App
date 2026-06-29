import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CalorieRing extends StatelessWidget {
  final int caloriesToday;
  final int dailyGoal;

  const CalorieRing({
    super.key,
    required this.caloriesToday,
    required this.dailyGoal,
  });

  Color _getColor(double percentage) {
    if (percentage >= 1.0) {
      return Colors.green.shade600;
    } else if (percentage >= 0.5) {
      return Colors.amber.shade600;
    } else {
      return const Color(0xFF1D9E75); // App primary
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double percent = dailyGoal > 0 ? caloriesToday / dailyGoal : 0.0;
    final Color ringColor = _getColor(percent);

    final double displayPercent = percent.clamp(0.0, 1.0);
    final double filledValue = displayPercent * 100;
    final double remainingValue = (1.0 - displayPercent) * 100;

    return Center(
      child: Container(
        height: 180,
        width: 180,
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: Stack(
          children: [
            PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 65,
                startDegreeOffset: 270,
                sections: [
                  PieChartSectionData(
                    color: ringColor,
                    value: filledValue > 0 ? filledValue : 0.0001, // fl_chart likes non-zero values
                    title: '',
                    radius: 12,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                    value: remainingValue > 0 ? remainingValue : 0.0001,
                    title: '',
                    radius: 10,
                    showTitle: false,
                  ),
                ],
              ),
            ),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: caloriesToday.toDouble()),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        value.toInt().toString(),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'of $dailyGoal kcal',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
