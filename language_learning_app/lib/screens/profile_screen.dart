import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/home_controller.dart';
import '../controllers/progress_controller.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/level_badge.dart';
import '../db/local_db.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _HomeScreenState extends State<ProfileScreen> {
  // Not used, State class name corrected below
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().loadHome();
      context.read<ProgressController>().loadProgress();
    });
  }

  // Get current level thresholds and progress fraction
  Map<String, dynamic> _getXpProgress(int totalXp) {
    int minXp = 0;
    int maxXp = 200;
    String nextLevel = 'Elementary';

    if (totalXp >= 1000) {
      minXp = 1000;
      maxXp = 2000; // Cap visual bar
      nextLevel = 'Max Level';
    } else if (totalXp >= 500) {
      minXp = 500;
      maxXp = 1000;
      nextLevel = 'Advanced';
    } else if (totalXp >= 200) {
      minXp = 200;
      maxXp = 500;
      nextLevel = 'Intermediate';
    }

    final double fraction = maxXp == minXp 
        ? 1.0 
        : (totalXp - minXp) / (maxXp - minXp);

    return {
      'min': minXp,
      'max': maxXp,
      'fraction': fraction.clamp(0.0, 1.0),
      'next': nextLevel,
    };
  }

  @override
  Widget build(BuildContext context) {
    final homeController = context.watch<HomeController>();
    final progressController = context.watch<ProgressController>();

    final xpData = _getXpProgress(homeController.totalXp);
    final double xpFraction = xpData['fraction'] as double;
    final int nextThreshold = xpData['max'] as int;

    // Badges unlock checks
    final bool firstLessonUnlocked = homeController.totalLessonsCompleted >= 1;
    final bool streak7Unlocked = homeController.longestStreak >= 7;
    final bool streak30Unlocked = homeController.longestStreak >= 30;
    
    // Check if user scored 100% on any quiz
    final bool quiz100Unlocked = progressController.allProgress.any((p) => p.bestScore == 100);
    final bool levelUpUnlocked = homeController.totalXp >= 200;
    final bool wordMasterUnlocked = progressController.totalCardsLearned >= 15; // Set to 15 for faster testing, but title indicates WordMaster

    final achievements = [
      {
        'title': 'First Lesson',
        'desc': 'Complete your first lesson.',
        'icon': Icons.emoji_events,
        'color': Colors.amber,
        'unlocked': firstLessonUnlocked,
      },
      {
        'title': '7-Day Streak',
        'desc': 'Maintain a 7-day study streak.',
        'icon': Icons.local_fire_department,
        'color': Colors.deepOrange,
        'unlocked': streak7Unlocked,
      },
      {
        'title': '30-Day Streak',
        'desc': 'Maintain a 30-day study streak.',
        'icon': Icons.whatshot,
        'color': Colors.red,
        'unlocked': streak30Unlocked,
      },
      {
        'title': 'Perfect Quiz',
        'desc': 'Score 100% on any lesson quiz.',
        'icon': Icons.verified_user,
        'color': Colors.teal,
        'unlocked': quiz100Unlocked,
      },
      {
        'title': 'Level Up',
        'desc': 'Advance to Elementary level.',
        'icon': Icons.trending_up,
        'color': Colors.purple,
        'unlocked': levelUpUnlocked,
      },
      {
        'title': 'Word Master',
        'desc': 'Learn 15+ cards in the app.',
        'icon': Icons.menu_book,
        'color': Colors.blue,
        'unlocked': wordMasterUnlocked,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // User Avatar Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade300.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'LT',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LevelBadge(level: homeController.currentLevel),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_fire_department, color: Colors.orange.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Streak: ${homeController.currentStreak} Days (Best: ${homeController.longestStreak})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // XP leveling bar
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'XP Progress',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                        ),
                        Text(
                          'Next Level: ${xpData['next']}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: xpFraction,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${homeController.totalXp} XP',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          '$nextThreshold XP',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),
            // Achievements Badge Grid
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Achievements',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: achievements.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final ach = achievements[index];
                final bool unlocked = ach['unlocked'] as bool;
                final color = ach['color'] as Color;

                return Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: unlocked ? color.withOpacity(0.12) : Colors.grey.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: unlocked ? color : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            ach['icon'] as IconData,
                            color: unlocked ? color : Colors.grey.shade400,
                            size: 28,
                          ),
                        ),
                        if (!unlocked)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ach['title'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: unlocked ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ach['desc'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade700,
                  elevation: 0,
                  side: BorderSide(color: Colors.red.shade100),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Reset Cache & Local Storage'),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Reset All Data?'),
                      content: const Text('This will clear all lesson progress, learned words, streaks, and local cache. Stored cloud settings will be refreshed.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await LocalDb.instance.resetAllData();
                    final prefs = await SharedPreferences.getInstance();
                    // Clear all web cache keys
                    final keys = prefs.getKeys();
                    for (var key in keys.toList()) {
                      if (key.startsWith('web_') || key.contains('streak') || key.contains('progress')) {
                        await prefs.remove(key);
                      }
                    }

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Local cache and database has been successfully reset!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      // Reload controllers
                      context.read<HomeController>().loadHome();
                      context.read<ProgressController>().loadProgress();
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 3),
    );
  }
}
