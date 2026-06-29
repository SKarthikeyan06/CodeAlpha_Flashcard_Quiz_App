import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    try {
      await _tts.setLanguage('ta-IN');   // Tamil
      await _tts.setSpeechRate(0.4);     // Slow for learning
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (e) {
      print("TTS Initialization error: $e");
    }
  }

  // Speak Tamil text
  Future<void> speakTamil(String text) async {
    try {
      await _tts.setLanguage('ta-IN');
      await _tts.speak(text);
    } catch (e) {
      print("TTS Tamil Speaking error: $e");
    }
  }

  // Speak English text
  Future<void> speakEnglish(String text) async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.speak(text);
    } catch (e) {
      print("TTS English Speaking error: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      print("TTS Stop error: $e");
    }
  }
}
