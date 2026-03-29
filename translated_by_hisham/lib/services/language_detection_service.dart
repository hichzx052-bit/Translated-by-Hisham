import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

class LanguageDetectionService {
  static final LanguageDetectionService _instance = LanguageDetectionService._internal();
  factory LanguageDetectionService() => _instance;
  LanguageDetectionService._internal();

  LanguageIdentifier? _languageIdentifier;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
    _isInitialized = true;
  }

  Future<String> detectLanguage(String text) async {
    if (text.trim().isEmpty) return 'und';

    try {
      if (!_isInitialized) await initialize();
      final lang = await _languageIdentifier!.identifyLanguage(text);
      return lang == 'und' ? await _heuristicDetect(text) : lang;
    } catch (e) {
      return await _heuristicDetect(text);
    }
  }

  Future<List<IdentifiedLanguage>> detectPossibleLanguages(String text) async {
    if (text.trim().isEmpty) return [];

    try {
      if (!_isInitialized) await initialize();
      return await _languageIdentifier!.identifyPossibleLanguages(text);
    } catch (e) {
      return [];
    }
  }

  // Heuristic detection as fallback
  Future<String> _heuristicDetect(String text) async {
    if (text.isEmpty) return 'en';

    // Check for Arabic script
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    if (arabicRegex.hasMatch(text)) {
      // Could be Arabic, Persian, Urdu
      final persianChars = RegExp(r'[پچژگ]');
      if (persianChars.hasMatch(text)) return 'fa';
      return 'ar';
    }

    // Check for Hebrew
    final hebrewRegex = RegExp(r'[\u0590-\u05FF]');
    if (hebrewRegex.hasMatch(text)) return 'he';

    // Check for Chinese
    final chineseRegex = RegExp(r'[\u4E00-\u9FFF]');
    if (chineseRegex.hasMatch(text)) return 'zh';

    // Check for Japanese
    final japaneseRegex = RegExp(r'[\u3040-\u30FF]');
    if (japaneseRegex.hasMatch(text)) return 'ja';

    // Check for Korean
    final koreanRegex = RegExp(r'[\uAC00-\uD7FF]');
    if (koreanRegex.hasMatch(text)) return 'ko';

    // Check for Russian/Cyrillic
    final cyrillicRegex = RegExp(r'[\u0400-\u04FF]');
    if (cyrillicRegex.hasMatch(text)) return 'ru';

    // Check for Greek
    final greekRegex = RegExp(r'[\u0370-\u03FF]');
    if (greekRegex.hasMatch(text)) return 'el';

    // Default to English for Latin script
    return 'en';
  }

  void dispose() {
    _languageIdentifier?.close();
    _isInitialized = false;
  }
}
