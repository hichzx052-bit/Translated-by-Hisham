import 'package:flutter_tts/flutter_tts.dart';
import '../models/voice_model.dart';
import '../models/language_model.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  List<Voice> _availableVoices = [];
  
  // Callbacks
  Function()? onSpeakStart;
  Function()? onSpeakComplete;
  Function(String)? onError;
  Function(String, int, int)? onProgress;
  
  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;
  List<Voice> get availableVoices => _availableVoices;
  
  Future<bool> initialize() async {
    try {
      // Set TTS callbacks
      await _tts.setStartHandler(() {
        _isSpeaking = true;
        onSpeakStart?.call();
      });
      
      await _tts.setCompletionHandler(() {
        _isSpeaking = false;
        onSpeakComplete?.call();
      });
      
      await _tts.setErrorHandler((msg) {
        _isSpeaking = false;
        onError?.call(msg);
      });
      
      await _tts.setProgressHandler((text, start, end, word) {
        onProgress?.call(text, start, end);
      });
      
      // Load available voices
      await _loadAvailableVoices();
      
      // Set default settings
      await _tts.setVolume(0.8);
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.0);
      
      _isInitialized = true;
      return true;
    } catch (e) {
      throw TTSException('Failed to initialize TTS: ${e.toString()}');
    }
  }
  
  Future<void> _loadAvailableVoices() async {
    try {
      final voices = await _tts.getVoices;
      _availableVoices = [];
      
      if (voices != null) {
        for (final voice in voices) {
          final voiceMap = voice as Map<String, dynamic>;
          
          _availableVoices.add(Voice(
            name: voiceMap['name'] ?? 'Unknown',
            locale: voiceMap['locale'] ?? 'en-US',
            language: (voiceMap['locale'] as String? ?? 'en').split('-').first,
            country: (voiceMap['locale'] as String? ?? '').contains('-') 
                ? (voiceMap['locale'] as String).split('-').last 
                : null,
          ));
        }
      }
      
      // Sort voices by language and name
      _availableVoices.sort((a, b) {
        final langCompare = a.language.compareTo(b.language);
        if (langCompare != 0) return langCompare;
        return a.name.compareTo(b.name);
      });
      
    } catch (e) {
      print('Error loading voices: $e');
    }
  }
  
  Future<void> speak({
    required String text,
    String? languageCode,
    Voice? voice,
    double? volume,
    double? rate,
    double? pitch,
  }) async {
    if (!_isInitialized) {
      throw TTSException('TTS service not initialized');
    }
    
    if (text.trim().isEmpty) {
      throw TTSException('Text cannot be empty');
    }
    
    try {
      // Stop current speech if any
      if (_isSpeaking) {
        await stop();
      }
      
      // Set voice if provided
      if (voice != null) {
        await _setVoice(voice);
      } else if (languageCode != null) {
        await _setLanguage(languageCode);
      }
      
      // Set speech parameters
      if (volume != null) {
        await _tts.setVolume(volume.clamp(0.0, 1.0));
      }
      
      if (rate != null) {
        await _tts.setSpeechRate(rate.clamp(0.1, 1.0));
      }
      
      if (pitch != null) {
        await _tts.setPitch(pitch.clamp(0.5, 2.0));
      }
      
      // Start speaking
      await _tts.speak(text);
      
    } catch (e) {
      _isSpeaking = false;
      throw TTSException('Failed to speak: ${e.toString()}');
    }
  }
  
  Future<void> _setVoice(Voice voice) async {
    try {
      await _tts.setVoice({
        'name': voice.name,
        'locale': voice.locale,
      });
    } catch (e) {
      print('Error setting voice: $e');
      // Fallback to language if voice setting fails
      await _setLanguage(voice.language);
    }
  }
  
  Future<void> _setLanguage(String languageCode) async {
    try {
      final locale = _findBestLocale(languageCode);
      if (locale != null) {
        await _tts.setLanguage(locale);
      }
    } catch (e) {
      print('Error setting language: $e');
    }
  }
  
  String? _findBestLocale(String languageCode) {
    // Find voices for the language
    final languageVoices = _availableVoices
        .where((voice) => voice.language == languageCode)
        .toList();
    
    if (languageVoices.isEmpty) {
      return null;
    }
    
    // Language-specific preferred locales
    final preferredLocales = <String, List<String>>{
      'ar': ['ar-SA', 'ar-EG'],
      'en': ['en-US', 'en-GB'],
      'fr': ['fr-FR', 'fr-CA'],
      'es': ['es-ES', 'es-US'],
      'de': ['de-DE'],
      'tr': ['tr-TR'],
      'zh': ['zh-CN', 'zh-TW'],
      'ja': ['ja-JP'],
      'ko': ['ko-KR'],
      'ru': ['ru-RU'],
      'pt': ['pt-BR', 'pt-PT'],
      'it': ['it-IT'],
      'hi': ['hi-IN'],
      'ur': ['ur-PK'],
      'fa': ['fa-IR'],
      'id': ['id-ID'],
      'th': ['th-TH'],
      'vi': ['vi-VN'],
      'nl': ['nl-NL'],
      'pl': ['pl-PL'],
    };
    
    final preferred = preferredLocales[languageCode] ?? [];
    
    // Try preferred locales first
    for (final locale in preferred) {
      final voice = languageVoices.where((v) => v.locale == locale).firstOrNull;
      if (voice != null) return voice.locale;
    }
    
    // Return first available locale for the language
    return languageVoices.first.locale;
  }
  
  Future<void> stop() async {
    if (_isSpeaking) {
      await _tts.stop();
      _isSpeaking = false;
    }
  }
  
  Future<void> pause() async {
    if (_isSpeaking) {
      await _tts.pause();
    }
  }
  
  Future<void> setVolume(double volume) async {
    await _tts.setVolume(volume.clamp(0.0, 1.0));
  }
  
  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate.clamp(0.1, 1.0));
  }
  
  Future<void> setPitch(double pitch) async {
    await _tts.setPitch(pitch.clamp(0.5, 2.0));
  }
  
  List<Voice> getVoicesForLanguage(String languageCode) {
    return _availableVoices
        .where((voice) => voice.language == languageCode)
        .toList();
  }
  
  Voice? getBestVoiceForLanguage(String languageCode) {
    final voices = getVoicesForLanguage(languageCode);
    if (voices.isEmpty) return null;
    
    // Try to find a female voice first (often better quality)
    final femaleVoice = voices.where((voice) => 
        voice.name.toLowerCase().contains('female') ||
        voice.name.toLowerCase().contains('woman') ||
        voice.name.toLowerCase().contains('f ')
    ).firstOrNull;
    
    if (femaleVoice != null) return femaleVoice;
    
    // Return first available voice
    return voices.first;
  }
  
  Future<void> previewVoice(Voice voice, {String? sampleText}) async {
    final text = sampleText ?? _getSampleTextForLanguage(voice.language);
    await speak(
      text: text,
      voice: voice,
      volume: 0.8,
      rate: 0.5,
      pitch: 1.0,
    );
  }
  
  String _getSampleTextForLanguage(String languageCode) {
    final samples = <String, String>{
      'ar': 'مرحبا، هذا اختبار للصوت',
      'en': 'Hello, this is a voice test',
      'fr': 'Bonjour, ceci est un test vocal',
      'es': 'Hola, esta es una prueba de voz',
      'de': 'Hallo, das ist ein Sprachtest',
      'tr': 'Merhaba, bu bir ses testidir',
      'zh': '你好，这是语音测试',
      'ja': 'こんにちは、これは音声テストです',
      'ko': '안녕하세요, 음성 테스트입니다',
      'ru': 'Привет, это тест голоса',
      'pt': 'Olá, este é um teste de voz',
      'it': 'Ciao, questo è un test vocale',
      'hi': 'नमस्ते, यह एक आवाज़ परीक्षण है',
      'ur': 'ہیلو، یہ آواز کا ٹیسٹ ہے',
      'fa': 'سلام، این یک تست صدا است',
      'id': 'Halo, ini adalah tes suara',
      'th': 'สวัสดี นี่คือการทดสอบเสียง',
      'vi': 'Xin chào, đây là bài kiểm tra giọng nói',
      'nl': 'Hallo, dit is een stemtest',
      'pl': 'Cześć, to jest test głosu',
    };
    
    return samples[languageCode] ?? 'Hello, this is a voice test';
  }
  
  void dispose() {
    if (_isSpeaking) {
      _tts.stop();
    }
    _isSpeaking = false;
    onSpeakStart = null;
    onSpeakComplete = null;
    onError = null;
    onProgress = null;
  }
}

class TTSException implements Exception {
  final String message;
  
  const TTSException(this.message);
  
  @override
  String toString() => 'TTSException: $message';
}