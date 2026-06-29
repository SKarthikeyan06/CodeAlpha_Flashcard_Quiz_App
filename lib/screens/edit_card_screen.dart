import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';

class EditCardScreen extends StatefulWidget {
  final Flashcard flashcard;

  const EditCardScreen({
    Key? key,
    required this.flashcard,
  }) : super(key: key);

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.flashcard.question);
    _answerController = TextEditingController(text: widget.flashcard.answer);
    _selectedDifficulty = widget.flashcard.difficulty;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _updateCard() async {
    if (_formKey.currentState!.validate()) {
      final updatedCard = widget.flashcard.copyWith(
        question: _questionController.text,
        answer: _answerController.text,
        difficulty: _selectedDifficulty,
      );

      await context.read<FlashcardProvider>().updateCard(updatedCard);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card updated successfully')),
        );
      }
    }
  }

  void _deleteCard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<FlashcardProvider>().deleteCard(widget.flashcard.id);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card deleted successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Card'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Modify Flashcard',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Update the question or answer text, or delete this flashcard from your deck.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 28),
              
              // Question Field
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  hintText: 'Enter the flashcard question...',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Question cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Answer Field
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(
                  labelText: 'Answer',
                  hintText: 'Enter the correct answer...',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Answer cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Difficulty Selector
              const Text(
                'Difficulty Level',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: ['Easy', 'Medium', 'Hard'].map((diff) {
                  Color activeColor;
                  Color textColor;
                  switch (diff) {
                    case 'Easy':
                      activeColor = const Color(0xFFDCFCE7); // Soft Green
                      textColor = const Color(0xFF15803D);
                      break;
                    case 'Hard':
                      activeColor = const Color(0xFFFEE2E2); // Soft Red
                      textColor = const Color(0xFFB91C1C);
                      break;
                    default:
                      activeColor = const Color(0xFFFEF3C7); // Soft Amber
                      textColor = const Color(0xFFB45309);
                  }
                  final isSelected = _selectedDifficulty == diff;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(
                        diff,
                        style: TextStyle(
                          color: isSelected ? textColor : const Color(0xFF64748B),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedDifficulty = diff;
                          });
                        }
                      },
                      selectedColor: activeColor,
                      backgroundColor: const Color(0xFFF1F5F9),
                      side: BorderSide(
                        color: isSelected ? textColor.withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              ElevatedButton.icon(
                onPressed: _updateCard,
                icon: const Icon(Icons.check_rounded, size: 20),
                label: const Text('Update Card'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _deleteCard,
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                label: const Text(
                  'Delete Card',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

