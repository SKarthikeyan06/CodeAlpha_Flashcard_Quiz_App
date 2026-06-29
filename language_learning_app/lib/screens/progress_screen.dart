import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/progress_controller.dart';
import '../widgets/bottom_nav.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _HomeScreenState extends State<ProgressScreen> {
  // Not used, State class name corrected below
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressController>().loadProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProgressController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Overall completion section
                  _buildOverallCompletion(controller),

                  const SizedBox(height: 24),
                  // Stat cards row
                  _buildStatCardsRow(controller),

                  const SizedBox(height: 28),
                  // Weekly activity chart
                  const Text(
                    'Weekly Activity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'XP earned over the last 7 days',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  _buildWeeklyBarChart(controller),

                  const SizedBox(height: 28),
                  // Category mastery
                  const Text(
                    'Category Mastery',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryMastery(controller),
                  const SizedBox(height: 24),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }

  Widget _buildOverallCompletion(ProgressController controller) {
    final int percent = (controller.overallPercent * 100).round();

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 36,
                      startDegreeOffset: 270,
                      sections: [
                        PieChartSectionData(
                          color: Theme.of(context).colorScheme.primary,
                          value: controller.overallPercent * 100,
                          radius: 10,
                          title: '',
                        ),
                        PieChartSectionData(
                          color: Colors.grey.shade100,
                          value: (1.0 - controller.overallPercent) * 100,
                          radius: 8,
                          title: '',
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You have completed $percent% of all pre-seeded lessons in the curriculum.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCardsRow(ProgressController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            title: 'Learned',
            value: controller.totalCardsLearned,
            label: 'Cards',
            icon: Icons.bookmark,
            color: Colors.blue.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatTile(
            title: 'Quizzes',
            value: controller.totalQuizzesTaken,
            label: 'Attempts',
            icon: Icons.quiz,
            color: Colors.orange.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatTile(
            title: 'XP Points',
            value: controller.totalXp,
            label: 'Earned',
            icon: Icons.stars,
            color: Colors.amber.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String title,
    required int value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: value),
              duration: const Duration(seconds: 1),
              builder: (context, val, child) {
                return Text(
                  '$val',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                );
              },
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyBarChart(ProgressController controller) {
    final activity = controller.weeklyActivity;
    if (activity.isEmpty) return const SizedBox(height: 100);

    // Calculate maximum Y value dynamically
    final double maxVal = activity
        .map((e) => (e['xp'] as int).toDouble())
        .fold(30.0, (prev, val) => val > prev ? val : prev);
    final double maxY = maxVal + 10;

    return Container(
      height: 180,
      padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.blue.shade900,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.round()} XP',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                  final int index = value.toInt();
                  if (index >= 0 && index < activity.length) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        activity[index]['day'] as String,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(activity.length, (index) {
            final double xp = (activity[index]['xp'] as int).toDouble();
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: xp,
                  color: xp > 0 ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                  width: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCategoryMastery(ProgressController controller) {
    if (controller.categoryCompletion.isEmpty) {
      return const Center(child: Text('No categories available yet.'));
    }

    final entries = controller.categoryCompletion.entries.toList();

    return Column(
      children: entries.map((entry) {
        final cat = entry.key;
        final double rate = entry.value;
        final int percent = (rate * 100).round();

        Color barColor = Colors.blue.shade600;
        if (percent >= 100) {
          barColor = Colors.green.shade600;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade100, width: 1.5),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cat,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: percent >= 100 ? Colors.green.shade800 : Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: rate,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation(barColor),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
