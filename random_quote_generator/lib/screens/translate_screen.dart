import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/quote.dart';
import '../db/database_helper.dart';

class TranslateScreen extends StatefulWidget {
  final Quote quote;

  const TranslateScreen({super.key, required this.quote});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  String _selectedLanguageCode = 'fr'; // default French
  String _translatedText = '';
  bool _isLoading = false;
  String _errorMessage = '';

  final Map<String, String> _languages = {
    'French': 'fr',
    'Spanish': 'es',
    'German': 'de',
    'Japanese': 'ja',
    'Arabic': 'ar',
    'Tamil': 'ta',
    'Hindi': 'hi',
    'Telugu': 'te',
    'Kannada': 'kn',
    'Malayalam': 'ml',
  };

  @override
  void initState() {
    super.initState();
    _performTranslation();
  }

  Future<void> _performTranslation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _translatedText = '';
    });

    final int? quoteId = widget.quote.id;
    final String langCode = _selectedLanguageCode;
    final String quoteText = widget.quote.text;

    try {
      // 1. Check local cache
      if (quoteId != null) {
        final cached = await DatabaseHelper.instance.getTranslation(quoteId, langCode);
        if (cached != null && cached.isNotEmpty) {
          if (mounted) {
            setState(() {
              _translatedText = cached;
              _isLoading = false;
            });
          }
          return;
        }
      }

      // 2. Fetch from translation API (MyMemory)
      final encoded = Uri.encodeComponent(quoteText);
      final url = 'https://api.mymemory.translated.net/get?q=$encoded&langpair=en|$langCode';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String translated = data['responseData']['translatedText'] ?? '';
        
        if (translated.isNotEmpty) {
          // 3. Cache translation locally
          if (quoteId != null) {
            await DatabaseHelper.instance.saveTranslation(quoteId, langCode, translated);
          }
          
          if (mounted) {
            setState(() {
              _translatedText = translated;
            });
          }
        } else {
          throw Exception('Empty translation response');
        }
      } else {
        throw Exception('Translation request failed: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not fetch translation. Please check your internet connection and try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _shareTranslation() {
    final languageName = _languages.keys.firstWhere(
      (k) => _languages[k] == _selectedLanguageCode,
      orElse: () => 'Selected Language',
    );
    Share.share(
      'Translation ($languageName):\n"$_translatedText"\n\nOriginal Quote:\n"${widget.quote.text}"\n— ${widget.quote.author}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedLanguageName = _languages.keys.firstWhere(
      (k) => _languages[k] == _selectedLanguageCode,
      orElse: () => 'French',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Translate Quote',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Original Quote Preview
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 80 : 120),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORIGINAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurfaceVariant.withAlpha(160),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.quote.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'serif',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "— ${widget.quote.author}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Language selector & Downward Arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.arrow_downward_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ).animate(onPlay: (controller) => controller.repeat())
                 .slideY(begin: -0.1, end: 0.1, duration: 1.seconds, curve: Curves.easeInOut)
                 .then()
                 .slideY(begin: 0.1, end: -0.1, duration: 1.seconds, curve: Curves.easeInOut),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.primary.withAlpha(80)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguageCode,
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary),
                      dropdownColor: theme.colorScheme.surface,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null && newValue != _selectedLanguageCode) {
                          setState(() {
                            _selectedLanguageCode = newValue;
                          });
                          _performTranslation();
                        }
                      },
                      items: _languages.entries.map<DropdownMenuItem<String>>((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.value,
                          child: Text(entry.key),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Translation Card Output
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          theme.colorScheme.surfaceContainer,
                          theme.colorScheme.surface,
                        ]
                      : [
                          theme.colorScheme.primaryContainer.withAlpha(30),
                          theme.colorScheme.primaryContainer.withAlpha(10),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: theme.colorScheme.primary.withAlpha(isDark ? 40 : 20),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    selectedLanguageName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Translating quote...'),
                          ],
                        ),
                      ),
                    )
                  else if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.orange, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _performTranslation,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _translatedText,
                          style: TextStyle(
                            fontSize: 20,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                            fontFamily: 'serif',
                          ),
                        ).animate().fade(duration: 400.ms),
                        const SizedBox(height: 24),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: _shareTranslation,
                              tooltip: 'Share Translation',
                              icon: Icon(
                                Icons.share_rounded,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
