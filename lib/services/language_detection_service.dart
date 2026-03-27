import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import '../models/language_model.dart';

class LanguageDetectionService {
  static final LanguageDetectionService _instance = LanguageDetectionService._internal();
  factory LanguageDetectionService() => _instance;
  LanguageDetectionService._internal();

  final LanguageIdentifier _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
  bool _isInitialized = false;
  
  bool get isInitialized => _isInitialized;
  
  Future<bool> initialize() async {
    try {
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Error initializing language detection: $e');
      return false;
    }
  }
  
  Future<String> detectLanguage(String text) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (text.trim().isEmpty) {
      return 'en'; // Default to English for empty text
    }
    
    try {
      final languageCode = await _languageIdentifier.identifyLanguage(text);
      
      // Map detected language to supported languages
      final mappedCode = _mapToSupportedLanguage(languageCode);
      
      // Validate that the detected language is in our supported list
      if (SupportedLanguages.all.any((lang) => lang.code == mappedCode)) {
        return mappedCode;
      }
      
      return 'en'; // Fallback to English
    } catch (e) {
      print('Language detection error: $e');
      return 'en'; // Fallback to English on error
    }
  }
  
  Future<List<IdentifiedLanguage>> detectPossibleLanguages(String text) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (text.trim().isEmpty) {
      return [];
    }
    
    try {
      final languages = await _languageIdentifier.identifyPossibleLanguages(text);
      
      // Filter and map to supported languages
      final supportedLanguages = <IdentifiedLanguage>[];
      
      for (final lang in languages) {
        final mappedCode = _mapToSupportedLanguage(lang.languageTag);
        if (SupportedLanguages.all.any((supportedLang) => supportedLang.code == mappedCode)) {
          supportedLanguages.add(IdentifiedLanguage(
            languageTag: mappedCode,
            confidence: lang.confidence,
          ));
        }
      }
      
      // Sort by confidence
      supportedLanguages.sort((a, b) => b.confidence.compareTo(a.confidence));
      
      return supportedLanguages;
    } catch (e) {
      print('Language detection error: $e');
      return [];
    }
  }
  
  String _mapToSupportedLanguage(String detectedCode) {
    // Direct mapping for exact matches
    if (SupportedLanguages.all.any((lang) => lang.code == detectedCode)) {
      return detectedCode;
    }
    
    // Language code mappings for different formats
    final mappings = <String, String>{
      // Arabic variants
      'ar-SA': 'ar',
      'ar-EG': 'ar',
      'ar-AE': 'ar',
      'ar-JO': 'ar',
      'ar-LB': 'ar',
      'ar-SY': 'ar',
      'ar-IQ': 'ar',
      'ar-KW': 'ar',
      'ar-QA': 'ar',
      'ar-BH': 'ar',
      'ar-OM': 'ar',
      'ar-YE': 'ar',
      'ara': 'ar',
      
      // English variants
      'en-US': 'en',
      'en-GB': 'en',
      'en-AU': 'en',
      'en-CA': 'en',
      'en-NZ': 'en',
      'en-IE': 'en',
      'en-ZA': 'en',
      'eng': 'en',
      
      // French variants
      'fr-FR': 'fr',
      'fr-CA': 'fr',
      'fr-BE': 'fr',
      'fr-CH': 'fr',
      'fra': 'fr',
      
      // Spanish variants
      'es-ES': 'es',
      'es-US': 'es',
      'es-MX': 'es',
      'es-AR': 'es',
      'es-CO': 'es',
      'es-CL': 'es',
      'es-PE': 'es',
      'es-VE': 'es',
      'spa': 'es',
      
      // German variants
      'de-DE': 'de',
      'de-AT': 'de',
      'de-CH': 'de',
      'deu': 'de',
      'ger': 'de',
      
      // Turkish variants
      'tr-TR': 'tr',
      'tur': 'tr',
      
      // Chinese variants
      'zh-CN': 'zh',
      'zh-TW': 'zh',
      'zh-HK': 'zh',
      'zh-SG': 'zh',
      'zho': 'zh',
      'chi': 'zh',
      'cmn': 'zh',
      
      // Japanese variants
      'ja-JP': 'ja',
      'jpn': 'ja',
      
      // Korean variants
      'ko-KR': 'ko',
      'kor': 'ko',
      
      // Russian variants
      'ru-RU': 'ru',
      'rus': 'ru',
      
      // Portuguese variants
      'pt-PT': 'pt',
      'pt-BR': 'pt',
      'por': 'pt',
      
      // Italian variants
      'it-IT': 'it',
      'ita': 'it',
      
      // Hindi variants
      'hi-IN': 'hi',
      'hin': 'hi',
      
      // Urdu variants
      'ur-PK': 'ur',
      'urd': 'ur',
      
      // Persian variants
      'fa-IR': 'fa',
      'fas': 'fa',
      'per': 'fa',
      
      // Indonesian variants
      'id-ID': 'id',
      'ind': 'id',
      
      // Thai variants
      'th-TH': 'th',
      'tha': 'th',
      
      // Vietnamese variants
      'vi-VN': 'vi',
      'vie': 'vi',
      
      // Dutch variants
      'nl-NL': 'nl',
      'nl-BE': 'nl',
      'nld': 'nl',
      'dut': 'nl',
      
      // Polish variants
      'pl-PL': 'pl',
      'pol': 'pl',
    };
    
    final mapped = mappings[detectedCode];
    if (mapped != null) {
      return mapped;
    }
    
    // Try prefix matching for language-region codes
    final prefix = detectedCode.split('-').first.split('_').first;
    if (SupportedLanguages.all.any((lang) => lang.code == prefix)) {
      return prefix;
    }
    
    // Fallback to English
    return 'en';
  }
  
  Future<bool> isLanguageSupported(String text) async {
    final detectedLanguage = await detectLanguage(text);
    return SupportedLanguages.all.any((lang) => lang.code == detectedLanguage);
  }
  
  Future<double> getLanguageConfidence(String text, String languageCode) async {
    final possibleLanguages = await detectPossibleLanguages(text);
    
    for (final lang in possibleLanguages) {
      if (lang.languageTag == languageCode) {
        return lang.confidence;
      }
    }
    
    return 0.0;
  }
  
  Language? getLanguageByCode(String code) {
    try {
      return SupportedLanguages.all.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }
  
  Future<String> smartDetectLanguage(String text, {String? hint}) async {
    if (text.trim().isEmpty) {
      return hint ?? 'en';
    }
    
    // For very short text, use hint if provided
    if (text.trim().length < 10 && hint != null) {
      return hint;
    }
    
    final detectedLanguage = await detectLanguage(text);
    
    // If confidence is low and hint is provided, consider the hint
    if (hint != null) {
      final confidence = await getLanguageConfidence(text, detectedLanguage);
      if (confidence < 0.7) {
        final hintConfidence = await getLanguageConfidence(text, hint);
        if (hintConfidence > confidence - 0.2) {
          return hint;
        }
      }
    }
    
    return detectedLanguage;
  }
  
  void dispose() {
    _languageIdentifier.close();
    _isInitialized = false;
  }
}

class LanguageDetectionException implements Exception {
  final String message;
  
  const LanguageDetectionException(this.message);
  
  @override
  String toString() => 'LanguageDetectionException: $message';
}