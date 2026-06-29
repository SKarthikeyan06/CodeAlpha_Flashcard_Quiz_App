import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../screens/lesson_screen.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;

  const LessonCard({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final double progress = lesson.totalCards > 0 
        ? lesson.cardsLearned / lesson.totalCards 
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            leading: _buildLeading(),
            title: Text(
              lesson.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: lesson.isUnlocked ? Colors.black87 : Colors.grey.shade500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${lesson.category} • ${lesson.totalCards} Cards',
                  style: TextStyle(
                    color: lesson.isUnlocked ? Colors.grey.shade600 : Colors.grey.shade400,
                    fontSize: 13,
                  ),
                ),
                if (lesson.isUnlocked && lesson.totalCards > 0) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        lesson.isCompleted ? Colors.green.shade600 : Colors.blue.shade600,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ],
            ),
            trailing: _buildTrailing(context),
            onTap: lesson.isUnlocked
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LessonScreen(lesson: lesson),
                      ),
                    );
                  }
                : null,
          ),

          // Lock overlay
          if (!lesson.isUnlocked)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.55),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.grey,
                    size: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeading() {
    if (lesson.isCompleted) {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_circle,
          color: Colors.green.shade600,
          size: 30,
        ),
      );
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: lesson.isUnlocked ? Colors.blue.shade50 : Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '${lesson.orderIndex}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: lesson.isUnlocked ? Colors.blue.shade700 : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    if (!lesson.isUnlocked) {
      return const SizedBox.shrink();
    }
    if (lesson.isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '100%',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    if (lesson.bestScore > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.shade600,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${lesson.bestScore}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return const Icon(
      Icons.chevron_right,
      color: Colors.grey,
    );
  }
}
