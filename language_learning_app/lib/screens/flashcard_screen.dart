import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/flashcard_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/flashcard_widget.dart';
import '../services/tts_service.dart';

class FlashcardScreen extends StatelessWidget {
  final String lessonId;
  final TabController? tabController;

  const FlashcardScreen({super.key, required this.lessonId, this.tabController});

  void _showCompletionSheet(BuildContext context) {
    // Reward 20 XP for finishing study session
    final homeController = context.read<HomeController>();
    homeController.rewardXp(20);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉 Great Job!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'You finished studying all the cards in this lesson!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber.shade800, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '+20 XP Study Bonus!',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetContext); // Close sheet
                        Navigator.pop(context);      // Go back to lessons list
                      },
                      child: const Text('Back to Lessons'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        // Animate TabController to Quiz Tab (index 1)
                        if (tabController != null) {
                          tabController!.animateTo(1);
                        } else {
                          try {
                            final defaultTabController = DefaultTabController.of(context);
                            defaultTabController.animateTo(1);
                          } catch (_) {}
                        }
                      },
                      child: const Text('Take Quiz'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FlashcardController>();
    final tts = context.read<TtsService>();

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.cards.isEmpty) {
      return const Center(
        child: Text('No cards available in this lesson.'),
      );
    }

    final card = controller.currentCard!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress text row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Card ${controller.currentIndex + 1} of ${controller.cards.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  'Learned: ${controller.learnedCount}/${controller.cards.length}',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3D Flip Card Widget
          Expanded(
            child: FlashcardWidget(
              card: card,
              isFlipped: controller.isFlipped,
              onFlip: controller.flipCard,
              tts: tts,
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons: flip and mark learned
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.outlined(
                icon: const Icon(Icons.flip_camera_android, size: 28),
                onPressed: controller.flipCard,
                tooltip: 'Flip Card',
              ),
              const SizedBox(width: 24),
              IconButton.filled(
                icon: Icon(card.isLearned ? Icons.check_circle : Icons.check, size: 28),
                style: IconButton.styleFrom(
                  backgroundColor: card.isLearned ? Colors.green.shade600 : Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => controller.markLearned(card.id),
                tooltip: 'Mark as Learned',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Navigation buttons: previous & next
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: controller.currentIndex > 0 ? controller.previousCard : null,
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (controller.isLastCard) {
                      _showCompletionSheet(context);
                    } else {
                      await controller.nextCard();
                    }
                  },
                  child: Text(controller.isLastCard ? 'Finish Study' : 'Next Card'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
