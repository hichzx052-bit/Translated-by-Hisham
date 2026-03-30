import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_model.dart';
import 'voice_model.dart';
import '../utils/constants.dart';
import '../utils/api_config.dart';
import '../services/translation_service.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';

class TranslationHistory {
  final String id;
  final String sourceText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final DateTime timestamp;
  final String type;

  TranslationHistory({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.timestamp,
    required this.type,
  });
}

class AppState extends ChangeNotifier {
  // Services
  final TranslationService _translationService = TranslationService();
  final SpeechService _speechService = SpeechService();
  final TtsService _ttsService = TtsService();

  // Language settings
  LanguageModel _sourceLang = LanguageModel.autoDetect;
  LanguageModel _targetLang = LanguageModel.fromCode('ar');
  bool _autoDetectSource = true;

  // Voice settings
  VoiceModel _selectedVoice = VoiceModel.defaultVoices.first;
  double _speechRate = 0.5;
  double _speechPitch = 1.0;
  double _speechVolume = 1.0;

  // App state
  bool _isListening = false;
  bool _isTranslating = false;
  bool _isSpeaking = false;
  bool _isLiveModeActive = false;
  bool _isBubbleActive = false;
  bool _appEnabled = true;
  bool _isDarkMode = true;

  // Settings toggles
  bool _autoDetectLanguage = true;
  bool _autoSpeak = false;
  bool _fastMode = false;
  bool _autoStartOverlay = false;
  bool _hapticFeedback = true;
  bool _showNotification = true;
  bool _batterySaver = false;

  // Translation data
  String _currentSourceText = '';
  String _currentTranslatedText = '';
  String _detectedLanguage = '';
  List<TranslationHistory> _history = [];

  // Feature flags
  Map<String, bool> _featureFlags = {
    'voice_translation': true,
    'live_mode': true,
    'video_translation': true,
    'floating_bubble': true,
    'bidirectional': true,
    'auto_detect': true,
  };

  // === GETTERS ===
  LanguageModel get sourceLang => _sourceLang;
  LanguageModel get targetLang => _targetLang;
  LanguageModel get sourceLanguage => _sourceLang;
  LanguageModel get targetLanguage => _targetLang;
  bool get autoDetectSource => _autoDetectSource;
  VoiceModel get selectedVoice => _selectedVoice;
  double get speechRate => _speechRate;
  double get speechPitch => _speechPitch;
  double get speechVolume => _speechVolume;
  bool get isListening => _isListening;
  bool get isTranslating => _isTranslating;
  bool get isSpeaking => _isSpeaking;
  bool get isLiveModeActive => _isLiveModeActive;
  bool get isBubbleActive => _isBubbleActive;
  bool get appEnabled => _appEnabled;
  bool get isDarkMode => _isDarkMode;
  String get currentSourceText => _currentSourceText;
  String get currentTranslatedText => _currentTranslatedText;
  String get sourceText => _currentSourceText;
  String get translatedText => _currentTranslatedText;
  String get detectedLanguage => _detectedLanguage;
  List<TranslationHistory> get history => List.unmodifiable(_history);
  Map<String, bool> get featureFlags => Map.unmodifiable(_featureFlags);

  // Settings getters
  bool get autoDetectLanguage => _autoDetectLanguage;
  bool get autoSpeak => _autoSpeak;
  bool get fastMode => _fastMode;
  bool get autoStartOverlay => _autoStartOverlay;
  bool get hapticFeedback => _hapticFeedback;
  bool get showNotification => _showNotification;
  bool get batterySaver => _batterySaver;

  bool isFeatureEnabled(String feature) => _featureFlags[feature] ?? false;

  // === INITIALIZATION ===
  Future<void> initialize() async {
    await ApiConfig.loadConfig();
    final prefs = await SharedPreferences.getInstance();

    final sourceLangCode = prefs.getString(AppConstants.keySourceLang) ?? 'auto';
    final targetLangCode = prefs.getString(AppConstants.keyTargetLang) ?? 'ar';

    _sourceLang = LanguageModel.fromCode(sourceLangCode);
    _targetLang = LanguageModel.fromCode(targetLangCode);
    _autoDetectSource = sourceLangCode == 'auto';
    _appEnabled = ApiConfig.appEnabled;
    _isDarkMode = prefs.getBool(AppConstants.keyDarkMode) ?? true;
    _featureFlags = Map.from(ApiConfig.featureFlags);
    _autoDetectLanguage = prefs.getBool('autoDetectLanguage') ?? true;
    _autoSpeak = prefs.getBool('autoSpeak') ?? false;
    _fastMode = prefs.getBool('fastMode') ?? false;
    _autoStartOverlay = prefs.getBool('autoStartOverlay') ?? false;
    _hapticFeedback = prefs.getBool('hapticFeedback') ?? true;
    _showNotification = prefs.getBool('showNotification') ?? true;
    _batterySaver = prefs.getBool('batterySaver') ?? false;

    final voiceId = prefs.getString(AppConstants.keySelectedVoice);
    if (voiceId != null) {
      _selectedVoice = VoiceModel.defaultVoices
          .firstWhere((v) => v.id == voiceId, orElse: () => VoiceModel.defaultVoices.first);
    }

    notifyListeners();
  }

  // === LANGUAGE SETTERS ===
  void setSourceLang(LanguageModel lang) {
    _sourceLang = lang;
    _autoDetectSource = lang.code == 'auto';
    _savePrefs();
    notifyListeners();
  }

  void setTargetLang(LanguageModel lang) {
    _targetLang = lang;
    _savePrefs();
    notifyListeners();
  }

  void setSourceLanguage(LanguageModel lang) => setSourceLang(lang);
  void setTargetLanguage(LanguageModel lang) => setTargetLang(lang);

  void swapLanguages() {
    if (_sourceLang.code == 'auto') return;
    final temp = _sourceLang;
    _sourceLang = _targetLang;
    _targetLang = temp;
    final tempText = _currentSourceText;
    _currentSourceText = _currentTranslatedText;
    _currentTranslatedText = tempText;
    _savePrefs();
    notifyListeners();
  }

  // === VOICE SETTERS ===
  void setSelectedVoice(VoiceModel voice) {
    _selectedVoice = voice;
    SharedPreferences.getInstance().then((p) => p.setString(AppConstants.keySelectedVoice, voice.id));
    notifyListeners();
  }

  void setVoice(VoiceModel voice) => setSelectedVoice(voice);

  void setSpeechRate(double rate) { _speechRate = rate; notifyListeners(); }
  void setSpeechPitch(double pitch) { _speechPitch = pitch; notifyListeners(); }

  // === STATE SETTERS ===
  void setListening(bool v) { _isListening = v; notifyListeners(); }
  void setTranslating(bool v) { _isTranslating = v; notifyListeners(); }
  void setSpeaking(bool v) { _isSpeaking = v; notifyListeners(); }
  void setLiveModeActive(bool v) { _isLiveModeActive = v; notifyListeners(); }
  void setBubbleActive(bool v) { _isBubbleActive = v; notifyListeners(); }
  void setAppEnabled(bool v) { _appEnabled = v; notifyListeners(); }

  void setCurrentTexts(String source, String translated) {
    _currentSourceText = source;
    _currentTranslatedText = translated;
    notifyListeners();
  }

  void setDetectedLanguage(String langCode) {
    _detectedLanguage = langCode;
    if (_autoDetectSource && langCode.isNotEmpty) {
      _sourceLang = LanguageModel.fromCode(langCode);
    }
    notifyListeners();
  }

  // === SETTINGS SETTERS ===
  void setAutoDetect(bool v) { _autoDetectLanguage = v; _saveBool('autoDetectLanguage', v); notifyListeners(); }
  void setAutoSpeak(bool v) { _autoSpeak = v; _saveBool('autoSpeak', v); notifyListeners(); }
  void setFastMode(bool v) { _fastMode = v; _saveBool('fastMode', v); notifyListeners(); }
  void setAutoStartOverlay(bool v) { _autoStartOverlay = v; _saveBool('autoStartOverlay', v); notifyListeners(); }
  void setHapticFeedback(bool v) { _hapticFeedback = v; _saveBool('hapticFeedback', v); notifyListeners(); }
  void setShowNotification(bool v) { _showNotification = v; _saveBool('showNotification', v); notifyListeners(); }
  void setBatterySaver(bool v) { _batterySaver = v; _saveBool('batterySaver', v); notifyListeners(); }

  Future<void> checkForUpdates() async {
    // Placeholder for update check logic
  }

  // === CORE METHODS ===
  Future<void> startListening({Function(String)? onResult}) async {
    await _speechService.initialize();
    _speechService.onResult = (text, isFinal) {
      _currentSourceText = text;
      notifyListeners();
      onResult?.call(text);
      if (isFinal && _autoSpeak) {
        translateText(text);
      }
    };
    _speechService.onError = (error) {
      setListening(false);
    };
    await _speechService.startListening(
      localeId: _sourceLang.code == 'auto' ? null : _sourceLang.code,
    );
    setListening(true);
  }

  void stopListening() {
    _speechService.stopListening();
    setListening(false);
  }

  Future<void> speakText(String text, String langCode) async {
    if (text.trim().isEmpty) return;
    setSpeaking(true);
    try {
      await _ttsService.speak(text, language: langCode);
    } finally {
      setSpeaking(false);
    }
  }

  Future<String> translateText(String text) async {
    if (text.trim().isEmpty) return '';
    setTranslating(true);
    try {
      final result = await _translationService.translate(
        text: text,
        targetLang: _targetLang.code,
        sourceLang: _sourceLang.code,
      );
      _currentTranslatedText = result.translatedText;
      _detectedLanguage = result.detectedSourceLang;
      notifyListeners();
      return result.translatedText;
    } catch (e) {
      return '';
    } finally {
      setTranslating(false);
    }
  }

  // === HISTORY ===
  void addToHistory(TranslationHistory entry) {
    _history.insert(0, entry);
    if (_history.length > 50) _history = _history.take(50).toList();
    notifyListeners();
  }

  void clearHistory() { _history.clear(); notifyListeners(); }

  void updateFeatureFlags(Map<String, bool> flags) {
    _featureFlags.addAll(flags);
    notifyListeners();
  }

  // === PERSISTENCE ===
  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keySourceLang, _sourceLang.code);
    await prefs.setString(AppConstants.keyTargetLang, _targetLang.code);
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}
