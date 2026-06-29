import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quote.dart';
import '../db/database_helper.dart';
import '../controllers/home_controller.dart';

class AddQuoteScreen extends StatefulWidget {
  final Quote? quote; // If non-null, we are in Edit Mode

  const AddQuoteScreen({super.key, this.quote});

  @override
  State<AddQuoteScreen> createState() => _AddQuoteScreenState();
}

class _AddQuoteScreenState extends State<AddQuoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _text;
  late String _author;
  late String _category;

  final List<String> _categories = [
    'Motivation',
    'Life',
    'Education',
    'Sports',
    'Entertainment',
    'Technology',
    'Leadership',
    'Friendship',
    'Success',
    'General',
  ];

  bool get isEditMode => widget.quote != null;

  @override
  void initState() {
    super.initState();
    _text = widget.quote?.text ?? '';
    _author = widget.quote?.author ?? '';
    _category = widget.quote?.category ?? 'General';
    // Ensure current category is in the drop down list
    if (!_categories.contains(_category)) {
      _categories.add(_category);
    }
  }

  Future<void> _saveQuote() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final homeController = context.read<HomeController>();

    final quote = Quote(
      id: widget.quote?.id,
      text: _text.trim(),
      author: _author.trim(),
      category: _category,
      isLiked: widget.quote?.isLiked ?? false,
      isUserAdded: widget.quote?.isUserAdded ?? true,
    );

    try {
      if (isEditMode) {
        await DatabaseHelper.instance.updateQuote(quote);
        // Refresh home quote if it's the same
        if (homeController.currentQuote?.id == quote.id) {
          homeController.currentQuote = quote;
          homeController.loadRandomQuote(); // Trigger refresh
        }
      } else {
        await DatabaseHelper.instance.insertQuote(quote);
      }

      if (mounted) {
        Navigator.pop(context, true); // Returns true to trigger refresh on previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving quote: $e')),
        );
      }
    }
  }

  Future<void> _deleteQuote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quote'),
        content: const Text('Are you sure you want to permanently delete this quote?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await DatabaseHelper.instance.deleteQuote(widget.quote!.id!);
      
      // Update HomeController if current quote is deleted
      if (mounted) {
        final homeController = context.read<HomeController>();
        if (homeController.currentQuote?.id == widget.quote!.id) {
          homeController.loadRandomQuote();
        }
        Navigator.pop(context, true); // Returns true to trigger refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting quote: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Quote' : 'Add New Quote'),
        actions: [
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_rounded),
              color: Colors.redAccent,
              tooltip: 'Delete Quote',
              onPressed: _deleteQuote,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          children: [
            // Quote Text Input
            TextFormField(
              initialValue: _text,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Quote Text',
                hintText: 'Enter the quote here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 50.0),
                  child: Icon(Icons.format_quote_rounded),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the quote text';
                }
                return null;
              },
              onSaved: (value) => _text = value!,
            ),
            const SizedBox(height: 24),
            // Author Input
            TextFormField(
              initialValue: _author,
              decoration: InputDecoration(
                labelText: 'Author Name',
                hintText: 'Who said this?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Icon(Icons.person_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the author\'s name';
                }
                return null;
              },
              onSaved: (value) => _author = value!,
            ),
            const SizedBox(height: 24),
            // Category Dropdown
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Icon(Icons.category_rounded),
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            // Save Button
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _saveQuote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isEditMode ? 'Update Quote' : 'Save Quote',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
