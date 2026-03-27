import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/language_model.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  List<LocaleName> _availableLocales = [];
  
  // Callbacks
  Function(String)? onResult;
  Function(String)? onPartialResult;
  Function(String)? onError;
  Function()? onListeningStart;
  Function()? onListeningStop;
  
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  List<LocaleName> get availableLocales => _availableLocales;
  
  Future<bool> initialize() async {
    try {
      // Request microphone permission
      final permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        throw SpeechException('Microphone permission denied');
      }
      
      _isInitialized = await _speech.initialize(
        onError: (error) {
          _isListening = false;
          onError?.call(error.errorMsg);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            onListeningStop?.call();
          }
        },
      );
      
      if (_isInitialized) {
        _availableLocales = await _speech.locales();
      }
      
      return _isInitialized;
    } catch (e) {
      throw SpeechException('Failed to initialize speech recognition: ${e.toString()}');
    }
  }
  
  Future<void> startListening({
    String? languageCode,
    bool partialResults = true,
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    if (!_isInitialized) {
      throw SpeechException('Speech service not initialized');
    }
    
    if (_isListening) {
      await stopListening();
    }
    
    try {
      String? localeId;
      
      if (languageCode != null && languageCode != 'auto') {
        localeId = _findBestLocale(languageCode);
      }
      
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult?.call(result.recognizedWords);
          } else if (partialResults) {
            onPartialResult?.call(result.recognizedWords);
          }
        },
        localeId: localeId,
        partialResults: partialResults,
        listenFor: listenFor ?? const Duration(seconds: 30),
        pauseFor: pauseFor ?? const Duration(seconds: 3),
        cancelOnError: true,
        onSoundLevelChange: null,
      );
      
      _isListening = true;
      onListeningStart?.call();
    } catch (e) {
      _isListening = false;
      throw SpeechException('Failed to start listening: ${e.toString()}');
    }
  }
  
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      onListeningStop?.call();
    }
  }
  
  Future<void> cancelListening() async {
    if (_isListening) {
      await _speech.cancel();
      _isListening = false;
      onListeningStop?.call();
    }
  }
  
  String? _findBestLocale(String languageCode) {
    // First, try to find exact match
    var locale = _availableLocales.where((l) => l.localeId == languageCode).firstOrNull;
    if (locale != null) return locale.localeId;
    
    // Try to find by language prefix
    locale = _availableLocales
        .where((l) => l.localeId.startsWith(languageCode))
        .firstOrNull;
    if (locale != null) return locale.localeId;
    
    // Language-specific fallbacks
    switch (languageCode) {
      case 'ar':
        return _findLocale(['ar-SA', 'ar-EG', 'ar']);
      case 'en':
        return _findLocale(['en-US', 'en-GB', 'en']);
      case 'fr':
        return _findLocale(['fr-FR', 'fr-CA', 'fr']);
      case 'es':
        return _findLocale(['es-ES', 'es-US', 'es']);
      case 'de':
        return _findLocale(['de-DE', 'de']);
      case 'tr':
        return _findLocale(['tr-TR', 'tr']);
      case 'zh':
        return _findLocale(['zh-CN', 'zh-TW', 'zh']);
      case 'ja':
        return _findLocale(['ja-JP', 'ja']);
      case 'ko':
        return _findLocale(['ko-KR', 'ko']);
      case 'ru':
        return _findLocale(['ru-RU', 'ru']);
      case 'pt':
        return _findLocale(['pt-BR', 'pt-PT', 'pt']);
      case 'it':
        return _findLocale(['it-IT', 'it']);
      case 'hi':
        return _findLocale(['hi-IN', 'hi']);
      case 'ur':
        return _findLocale(['ur-PK', 'ur']);
      case 'fa':
        return _findLocale(['fa-IR', 'fa']);
      case 'id':
        return _findLocale(['id-ID', 'id']);
      case 'th':
        return _findLocale(['th-TH', 'th']);
      case 'vi':
        return _findLocale(['vi-VN', 'vi']);
      case 'nl':
        return _findLocale(['nl-NL', 'nl']);
      case 'pl':
        return _findLocale(['pl-PL', 'pl']);
      default:
        return null;
    }
  }
  
  String? _findLocale(List<String> candidates) {
    for (final candidate in candidates) {
      final locale = _availableLocales
          .where((l) => l.localeId == candidate)
          .firstOrNull;
      if (locale != null) return locale.localeId;
    }
    return null;
  }
  
  List<String> getSupportedLanguages() {
    final languages = <String>{};
    
    for (final locale in _availableLocales) {
      final langCode = locale.localeId.split('-').first;
      if (SupportedLanguages.all.any((lang) => lang.code == langCode)) {
        languages.add(langCode);
      }
    }
    
    return languages.toList();
  }
  
  bool isLanguageSupported(String languageCode) {
    return getSupportedLanguages().contains(languageCode);
  }
  
  double get lastSoundLevel => _speech.lastSoundLevel;
  
  SpeechRecognitionError? get lastError => _speech.lastError;
  
  void dispose() {
    if (_isListening) {
      _speech.stop();
    }
    _isListening = false;
    onResult = null;
    onPartialResult = null;
    onError = null;
    onListeningStart = null;
    onListeningStop = null;
  }
}

class SpeechException implements Exception {
  final String message;
  
  const SpeechException(this.message);
  
  @override
  String toString() => 'SpeechException: $message';
}