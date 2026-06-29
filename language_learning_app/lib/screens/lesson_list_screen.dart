import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/lesson_controller.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/lesson_card.dart';

class LessonListScreen extends StatefulWidget {
  const LessonListScreen({super.key});

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonController>().loadLessons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lessonController = context.watch<LessonController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lessons',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Difficulty level chips
          _buildDifficultySelector(lessonController),
          
          // Category chips
          _buildCategoryFilter(lessonController),
          
          const Divider(height: 1),
          
          // Lesson List
          Expanded(
            child: lessonController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : lessonController.filteredLessons.isEmpty
                    ? Center(
                        child: Text(
                          'No lessons found in this category.',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: lessonController.filteredLessons.length,
                        itemBuilder: (context, index) {
                          final lesson = lessonController.filteredLessons[index];
                          return LessonCard(lesson: lesson);
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }

  Widget _buildDifficultySelector(LessonController controller) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.levels.length,
        itemBuilder: (context, index) {
          final level = controller.levels[index];
          final isSelected = controller.selectedLevel == level;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                level,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  controller.setLevel(level);
                }
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.grey.shade100,
              elevation: isSelected ? 2 : 0,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter(LessonController controller) {
    if (controller.categories.length <= 1) {
      return const SizedBox.shrink();
    }
    
    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          final isSelected = controller.selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(
                category,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue.shade900 : Colors.black54,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                controller.setCategory(category);
              },
              backgroundColor: Colors.transparent,
              selectedColor: Colors.blue.shade50,
              checkmarkColor: Colors.blue.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? Colors.blue.shade200 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
