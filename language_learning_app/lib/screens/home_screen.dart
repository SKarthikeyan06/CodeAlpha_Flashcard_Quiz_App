import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/home_controller.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/streak_badge.dart';
import '../widgets/level_badge.dart';
import 'profile_screen.dart';
import 'lesson_list_screen.dart';
import 'progress_screen.dart';
import 'lesson_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().loadHome();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning! 🌅';
    } else if (hour < 17) {
      return 'Good afternoon! ☀️';
    } else {
      return 'Good evening! 🌌';
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeController = context.watch<HomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learn Tamil',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: homeController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Greetings Header
                  Text(
                    _getGreeting(),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                  const SizedBox(height: 4),
                  Text(
                    "Ready to learn something new today?",
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                  const SizedBox(height: 20),

                  // Streak Card
                  _buildStreakCard(homeController),

                  const SizedBox(height: 28),

                  // Continue Learning Section
                  const Text(
                    'Continue Learning',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildRecentLessons(homeController),

                  const SizedBox(height: 28),

                  // Quick Actions Section
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionsGrid(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  Widget _buildStreakCard(HomeController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade800.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'STUDY STATS',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 11,
                ),
              ),
              LevelBadge(level: controller.currentLevel),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              StreakBadge(streak: controller.currentStreak),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${controller.totalXp}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'Total XP',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms, begin: const Offset(0.95, 0.95));
  }

  Widget _buildRecentLessons(HomeController controller) {
    if (controller.recentLessons.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.school_outlined, color: Colors.blue.shade600, size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start your first lesson!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unlock Beginner level lessons now.',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LessonListScreen()),
                  );
                },
                child: const Text('Start'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: controller.recentLessons.map((lesson) {
        final double progress = lesson.totalCards > 0 
            ? lesson.cardsLearned / lesson.totalCards 
            : 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          shadowColor: Colors.black12,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              lesson.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${lesson.category} • Level: ${lesson.level}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    valueColor: AlwaysStoppedAnimation(
                      lesson.isCompleted ? Colors.green : Colors.blue,
                    ),
                    backgroundColor: Colors.grey.shade100,
                  ),
                ),
              ],
            ),
            trailing: Icon(Icons.play_circle_fill, color: Colors.blue.shade700, size: 32),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LessonScreen(lesson: lesson)),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = [
      {
        'title': 'Start Lessons',
        'icon': Icons.menu_book,
        'color': Colors.teal,
        'action': () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LessonListScreen()),
          );
        }
      },
      {
        'title': 'All Progress',
        'icon': Icons.leaderboard,
        'color': Colors.purple,
        'action': () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProgressScreen()),
          );
        }
      },
      {
        'title': 'View Profile',
        'icon': Icons.badge,
        'color': Colors.orange,
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }
      },
      {
        'title': 'My Stats',
        'icon': Icons.pie_chart,
        'color': Colors.teal,
        'action': () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProgressScreen()),
          );
        }
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: actions.map((item) {
        final color = item['color'] as Color;
        return InkWell(
          onTap: item['action'] as VoidCallback,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              border: Border.all(color: color.withOpacity(0.2), width: 1.5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(item['icon'] as IconData, color: color, size: 28),
                Text(
                  item['title'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
