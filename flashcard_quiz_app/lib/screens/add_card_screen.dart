import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({Key? key}) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedDifficulty = 'Medium';

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController();
    _answerController = TextEditingController();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _saveCard() async {
    if (_formKey.currentState!.validate()) {
      final flashcard = Flashcard(
        id: const Uuid().v4(),
        question: _questionController.text,
        answer: _answerController.text,
        difficulty: _selectedDifficulty,
      );

      await context.read<FlashcardProvider>().addCard(flashcard);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card added successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Card'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create Flashcard',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Fill in the question and answer to add a new card to your study deck.',
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
                  hintText: 'What is the question you want to study?',
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
                  hintText: 'What is the correct answer to the question?',
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

              // Save Button
              ElevatedButton.icon(
                onPressed: _saveCard,
                icon: const Icon(Icons.save_rounded, size: 20),
                label: const Text('Save Card'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

