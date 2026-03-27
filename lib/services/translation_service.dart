import 'package:translator/translator.dart';
import '../models/language_model.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final GoogleTranslator _translator = GoogleTranslator();
  
  Future<String> translate({
    required String text,
    required String from,
    required String to,
  }) async {
    try {
      if (text.trim().isEmpty) return '';
      
      // Convert 'auto' to empty string for Google Translate
      final fromLang = from == 'auto' ? '' : from;
      
      final translation = await _translator.translate(
        text,
        from: fromLang,
        to: to,
      );
      
      return translation.text;
    } catch (e) {
      throw TranslationException('Translation failed: ${e.toString()}');
    }
  }
  
  Future<String> detectLanguage(String text) async {
    try {
      if (text.trim().isEmpty) return 'en';
      
      // Use Google Translate's auto-detect feature
      final translation = await _translator.translate(text, from: '', to: 'en');
      
      // Return the detected source language
      return translation.sourceLanguage?.code ?? 'en';
    } catch (e) {
      print('Language detection failed: $e');
      return 'en'; // Default to English
    }
  }
  
  Future<List<String>> translateBatch({
    required List<String> texts,
    required String from,
    required String to,
  }) async {
    final results = <String>[];
    
    for (final text in texts) {
      try {
        final result = await translate(text: text, from: from, to: to);
        results.add(result);
      } catch (e) {
        results.add(text); // Return original text on error
      }
    }
    
    return results;
  }
  
  bool isSupportedLanguage(String languageCode) {
    return SupportedLanguages.all.any((lang) => lang.code == languageCode);
  }
  
  String? validateTranslationRequest({
    required String text,
    required String from,
    required String to,
  }) {
    if (text.trim().isEmpty) {
      return 'Text cannot be empty';
    }
    
    if (text.length > 5000) {
      return 'Text is too long (maximum 5000 characters)';
    }
    
    if (from != 'auto' && !isSupportedLanguage(from)) {
      return 'Source language not supported';
    }
    
    if (!isSupportedLanguage(to)) {
      return 'Target language not supported';
    }
    
    if (from == to && from != 'auto') {
      return 'Source and target languages cannot be the same';
    }
    
    return null; // No errors
  }
}

class TranslationException implements Exception {
  final String message;
  
  const TranslationException(this.message);
  
  @override
  String toString() => 'TranslationException: $message';
}

class TranslationResult {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;
  final double confidence;
  
  const TranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
    this.confidence = 1.0,
  });
  
  Map<String, dynamic> toJson() => {
    'originalText': originalText,
    'translatedText': translatedText,
    'sourceLanguage': sourceLanguage,
    'targetLanguage': targetLanguage,
    'timestamp': timestamp.toIso8601String(),
    'confidence': confidence,
  };
  
  factory TranslationResult.fromJson(Map<String, dynamic> json) =>
      TranslationResult(
        originalText: json['originalText'],
        translatedText: json['translatedText'],
        sourceLanguage: json['sourceLanguage'],
        targetLanguage: json['targetLanguage'],
        timestamp: DateTime.parse(json['timestamp']),
        confidence: json['confidence']?.toDouble() ?? 1.0,
      );
}