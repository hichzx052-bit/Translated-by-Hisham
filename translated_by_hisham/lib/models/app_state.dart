import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_model.dart';
import 'voice_model.dart';
import '../utils/constants.dart';
import '../utils/api_config.dart';

class TranslationHistory {
  final String id;
  final String sourceText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final DateTime timestamp;
  final String type; // 'text', 'voice', 'live'

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

  // Getters
  LanguageModel get sourceLang => _sourceLang;
  LanguageModel get targetLang => _targetLang;
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
  String get detectedLanguage => _detectedLanguage;
  List<TranslationHistory> get history => List.unmodifiable(_history);
  Map<String, bool> get featureFlags => Map.unmodifiable(_featureFlags);

  bool isFeatureEnabled(String feature) => _featureFlags[feature] ?? false;

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

    final voiceId = prefs.getString(AppConstants.keySelectedVoice);
    if (voiceId != null) {
      _selectedVoice = VoiceModel.defaultVoices
          .firstWhere((v) => v.id == voiceId, orElse: () => VoiceModel.defaultVoices.first);
    }

    notifyListeners();
  }

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

  void setSelectedVoice(VoiceModel voice) {
    _selectedVoice = voice;
    SharedPreferences.getInstance().then((p) => p.setString(AppConstants.keySelectedVoice, voice.id));
    notifyListeners();
  }

  void setSpeechRate(double rate) {
    _speechRate = rate;
    notifyListeners();
  }

  void setSpeechPitch(double pitch) {
    _speechPitch = pitch;
    notifyListeners();
  }

  void setListening(bool listening) {
    _isListening = listening;
    notifyListeners();
  }

  void setTranslating(bool translating) {
    _isTranslating = translating;
    notifyListeners();
  }

  void setSpeaking(bool speaking) {
    _isSpeaking = speaking;
    notifyListeners();
  }

  void setLiveModeActive(bool active) {
    _isLiveModeActive = active;
    notifyListeners();
  }

  void setBubbleActive(bool active) {
    _isBubbleActive = active;
    notifyListeners();
  }

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

  void addToHistory(TranslationHistory entry) {
    _history.insert(0, entry);
    if (_history.length > 50) {
      _history = _history.take(50).toList();
    }
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void updateFeatureFlags(Map<String, bool> flags) {
    _featureFlags.addAll(flags);
    notifyListeners();
  }

  void setAppEnabled(bool enabled) {
    _appEnabled = enabled;
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keySourceLang, _sourceLang.code);
    await prefs.setString(AppConstants.keyTargetLang, _targetLang.code);
  }
}
