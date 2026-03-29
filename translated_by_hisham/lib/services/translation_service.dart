import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class TranslationResult {
  final String translatedText;
  final String detectedSourceLang;
  final bool success;
  final String? error;

  const TranslationResult({
    required this.translatedText,
    required this.detectedSourceLang,
    required this.success,
    this.error,
  });
}

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  // Primary: MyMemory API (free, no key needed)
  // Fallback: Lingva API
  Future<TranslationResult> translate({
    required String text,
    required String targetLang,
    String sourceLang = 'auto',
  }) async {
    if (text.trim().isEmpty) {
      return const TranslationResult(
        translatedText: '',
        detectedSourceLang: '',
        success: true,
      );
    }

    // Try MyMemory first
    try {
      final result = await _translateWithMyMemory(
        text: text,
        targetLang: targetLang,
        sourceLang: sourceLang,
      );
      if (result.success) return result;
    } catch (e) {
      // Fall through to next provider
    }

    // Fallback: Lingva
    try {
      final result = await _translateWithLingva(
        text: text,
        targetLang: targetLang,
        sourceLang: sourceLang == 'auto' ? 'auto' : sourceLang,
      );
      if (result.success) return result;
    } catch (e) {
      // Fall through
    }

    return TranslationResult(
      translatedText: text,
      detectedSourceLang: sourceLang,
      success: false,
      error: 'Translation failed. Please check your connection.',
    );
  }

  Future<TranslationResult> _translateWithMyMemory({
    required String text,
    required String targetLang,
    String sourceLang = 'auto',
  }) async {
    final langPair = sourceLang == 'auto' ? 'auto|$targetLang' : '$sourceLang|$targetLang';
    final uri = Uri.parse(
      '${AppConstants.myMemoryApiBase}/get?q=${Uri.encodeComponent(text)}&langpair=$langPair',
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['responseStatus'] == 200) {
        final translated = data['responseData']['translatedText'] as String;
        final detectedLang = data['responseData']['detectedLanguage'] as String? ?? sourceLang;

        return TranslationResult(
          translatedText: translated,
          detectedSourceLang: detectedLang,
          success: true,
        );
      }
    }
    throw Exception('MyMemory API failed');
  }

  Future<TranslationResult> _translateWithLingva({
    required String text,
    required String targetLang,
    String sourceLang = 'auto',
  }) async {
    final src = sourceLang == 'auto' ? 'auto' : sourceLang;
    final uri = Uri.parse(
      '${AppConstants.lingvaApiBase}/$src/$targetLang/${Uri.encodeComponent(text)}',
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final translated = data['translation'] as String?;

      if (translated != null && translated.isNotEmpty) {
        return TranslationResult(
          translatedText: translated,
          detectedSourceLang: sourceLang,
          success: true,
        );
      }
    }
    throw Exception('Lingva API failed');
  }

  Future<List<TranslationResult>> translateBatch({
    required List<String> texts,
    required String targetLang,
    String sourceLang = 'auto',
  }) async {
    final futures = texts.map((text) => translate(
          text: text,
          targetLang: targetLang,
          sourceLang: sourceLang,
        ));
    return Future.wait(futures);
  }
}
