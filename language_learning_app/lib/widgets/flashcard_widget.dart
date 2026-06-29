import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/word_card.dart';
import '../services/tts_service.dart';

class FlashcardWidget extends StatelessWidget {
  final WordCard card;
  final bool isFlipped;
  final VoidCallback onFlip;
  final TtsService tts;

  const FlashcardWidget({
    super.key,
    required this.card,
    required this.isFlipped,
    required this.onFlip,
    required this.tts,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFlip,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: isFlipped ? pi : 0.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        builder: (context, val, child) {
          final isBack = val >= pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015) // perspective depth
              ..rotateY(val),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              shadowColor: Colors.black26,
              clipBehavior: Clip.antiAlias,
              child: isBack
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi), // mirror text back
                      child: _buildBackCard(context),
                    )
                  : _buildFrontCard(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(
                  card.category,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                backgroundColor: Colors.blue.shade100,
                elevation: 0,
                side: BorderSide.none,
              ),
              if (card.isLearned)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 28,
                ),
            ],
          ),
          const Spacer(),
          Text(
            card.english,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Pronunciation hint: "${card.transliteration}"',
            style: TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // English Speaker Icon Button
          Material(
            color: Colors.blue.shade100.withOpacity(0.5),
            shape: const CircleBorder(),
            child: IconButton(
              icon: Icon(Icons.volume_up, color: Colors.blue.shade800, size: 28),
              onPressed: () => tts.speakEnglish(card.english),
              tooltip: 'Listen English',
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flip_camera_android, color: Colors.grey.shade400, size: 16),
              const SizedBox(width: 6),
              Text(
                'Tap card to reveal Tamil translation',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(
                  card.category,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                backgroundColor: Colors.amber.shade200,
                elevation: 0,
                side: BorderSide.none,
              ),
              if (card.isLearned)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 28,
                ),
            ],
          ),
          const Spacer(),
          Text(
            card.tamil,
            style: GoogleFonts.notoSansTamil(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            card.transliteration,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Tamil Speaker Icon Button
          Material(
            color: Colors.amber.shade200.withOpacity(0.5),
            shape: const CircleBorder(),
            child: IconButton(
              icon: Icon(Icons.volume_up, color: Colors.amber.shade800, size: 28),
              onPressed: () => tts.speakTamil(card.tamil),
              tooltip: 'Listen Tamil',
            ),
          ),
          const Spacer(),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'EXAMPLE SENTENCE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: Colors.grey,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            card.exampleEn,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            card.exampleTa,
            style: GoogleFonts.notoSansTamil(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flip_camera_android, color: Colors.grey.shade400, size: 16),
              const SizedBox(width: 6),
              Text(
                'Tap to flip back',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
