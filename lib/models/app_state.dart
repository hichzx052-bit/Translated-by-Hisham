import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'language_model.dart';
import 'voice_model.dart';

enum AppMode {
  voice,
  text,
  live,
  overlay
}

enum TranslationState {
  idle,
  listening,
  processing,
  speaking,
  error
}

class AppState extends ChangeNotifier {
  // Translation State
  Language _sourceLanguage = SupportedLanguages.all.first; // Auto detect
  Language _targetLanguage = SupportedLanguages.all[1]; // English
  AppMode _currentMode = AppMode.voice;
  TranslationState _translationState = TranslationState.idle;
  
  // Text & Audio
  String _inputText = '';
  String _translatedText = '';
  String _errorMessage = '';
  bool _isListening = false;
  bool _isSpeaking = false;
  
  // Voice Preferences
  VoicePreferences _voicePreferences = const VoicePreferences();
  List<Voice> _availableVoices = [];
  
  // Settings
  bool _overlayEnabled = false;
  bool _backgroundServiceEnabled = false;
  bool _autoDetectLanguage = true;
  bool _continuousListening = false;
  double _speechVolume = 0.8;
  bool _vibrationEnabled = true;
  
  // Developer Settings
  bool _developerModeEnabled = false;
  String _apiEndpoint = 'https://api.translate.google.com';
  int _translationCount = 0;
  DateTime? _lastTranslation;
  
  // Live Mode
  bool _liveTranslationActive = false;
  bool _twoWayMode = false;
  String _liveStatus = '';

  // Getters
  Language get sourceLanguage => _sourceLanguage;
  Language get targetLanguage => _targetLanguage;
  AppMode get currentMode => _currentMode;
  TranslationState get translationState => _translationState;
  String get inputText => _inputText;
  String get translatedText => _translatedText;
  String get errorMessage => _errorMessage;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  VoicePreferences get voicePreferences => _voicePreferences;
  List<Voice> get availableVoices => _availableVoices;
  bool get overlayEnabled => _overlayEnabled;
  bool get backgroundServiceEnabled => _backgroundServiceEnabled;
  bool get autoDetectLanguage => _autoDetectLanguage;
  bool get continuousListening => _continuousListening;
  double get speechVolume => _speechVolume;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get developerModeEnabled => _developerModeEnabled;
  String get apiEndpoint => _apiEndpoint;
  int get translationCount => _translationCount;
  DateTime? get lastTranslation => _lastTranslation;
  bool get liveTranslationActive => _liveTranslationActive;
  bool get twoWayMode => _twoWayMode;
  String get liveStatus => _liveStatus;

  // Setters
  void setSourceLanguage(Language language) {
    _sourceLanguage = language;
    notifyListeners();
    _saveSettings();
  }

  void setTargetLanguage(Language language) {
    _targetLanguage = language;
    notifyListeners();
    _saveSettings();
  }

  void swapLanguages() {
    if (_sourceLanguage.code == 'auto') return;
    
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;
    notifyListeners();
    _saveSettings();
  }

  void setCurrentMode(AppMode mode) {
    _currentMode = mode;
    notifyListeners();
  }

  void setTranslationState(TranslationState state) {
    _translationState = state;
    notifyListeners();
  }

  void setInputText(String text) {
    _inputText = text;
    notifyListeners();
  }

  void setTranslatedText(String text) {
    _translatedText = text;
    _incrementTranslationCount();
    notifyListeners();
  }

  void setErrorMessage(String error) {
    _errorMessage = error;
    setTranslationState(TranslationState.error);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    if (_translationState == TranslationState.error) {
      setTranslationState(TranslationState.idle);
    }
    notifyListeners();
  }

  void setListening(bool listening) {
    _isListening = listening;
    notifyListeners();
  }

  void setSpeaking(bool speaking) {
    _isSpeaking = speaking;
    notifyListeners();
  }

  void setAvailableVoices(List<Voice> voices) {
    _availableVoices = voices;
    notifyListeners();
  }

  void updateVoicePreferences(VoicePreferences preferences) {
    _voicePreferences = preferences;
    notifyListeners();
    _saveSettings();
  }

  void setOverlayEnabled(bool enabled) {
    _overlayEnabled = enabled;
    notifyListeners();
    _saveSettings();
  }

  void setBackgroundServiceEnabled(bool enabled) {
    _backgroundServiceEnabled = enabled;
    notifyListeners();
    _saveSettings();
  }

  void setAutoDetectLanguage(bool enabled) {
    _autoDetectLanguage = enabled;
    notifyListeners();
    _saveSettings();
  }

  void setContinuousListening(bool enabled) {
    _continuousListening = enabled;
    notifyListeners();
    _saveSettings();
  }

  void setSpeechVolume(double volume) {
    _speechVolume = volume;
    notifyListeners();
    _saveSettings();
  }

  void setVibrationEnabled(bool enabled) {
    _vibrationEnabled = enabled;
    notifyListeners();
    _saveSettings();
  }

  void setDeveloperModeEnabled(bool enabled) {
    _developerModeEnabled = enabled;
    notifyListeners();
    _saveSettings();
  }

  void setApiEndpoint(String endpoint) {
    _apiEndpoint = endpoint;
    notifyListeners();
    _saveSettings();
  }

  void setLiveTranslationActive(bool active) {
    _liveTranslationActive = active;
    notifyListeners();
  }

  void setTwoWayMode(bool enabled) {
    _twoWayMode = enabled;
    notifyListeners();
    _saveSettings();
  }

  void setLiveStatus(String status) {
    _liveStatus = status;
    notifyListeners();
  }

  void _incrementTranslationCount() {
    _translationCount++;
    _lastTranslation = DateTime.now();
    _saveSettings();
  }

  void resetStats() {
    _translationCount = 0;
    _lastTranslation = null;
    notifyListeners();
    _saveSettings();
  }

  // Persistence
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Languages
      final sourceCode = prefs.getString('source_language') ?? 'auto';
      final targetCode = prefs.getString('target_language') ?? 'en';
      _sourceLanguage = SupportedLanguages.getByCode(sourceCode);
      _targetLanguage = SupportedLanguages.getByCode(targetCode);
      
      // Voice preferences
      final voicePrefsJson = prefs.getString('voice_preferences');
      if (voicePrefsJson != null) {
        _voicePreferences = VoicePreferences.fromJson(
          json.decode(voicePrefsJson) as Map<String, dynamic>,
        );
      }
      
      // Settings
      _overlayEnabled = prefs.getBool('overlay_enabled') ?? false;
      _backgroundServiceEnabled = prefs.getBool('background_service_enabled') ?? false;
      _autoDetectLanguage = prefs.getBool('auto_detect_language') ?? true;
      _continuousListening = prefs.getBool('continuous_listening') ?? false;
      _speechVolume = prefs.getDouble('speech_volume') ?? 0.8;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _developerModeEnabled = prefs.getBool('developer_mode_enabled') ?? false;
      _apiEndpoint = prefs.getString('api_endpoint') ?? 'https://api.translate.google.com';
      _translationCount = prefs.getInt('translation_count') ?? 0;
      _twoWayMode = prefs.getBool('two_way_mode') ?? false;
      
      final lastTranslationMs = prefs.getInt('last_translation');
      if (lastTranslationMs != null) {
        _lastTranslation = DateTime.fromMillisecondsSinceEpoch(lastTranslationMs);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Languages
      await prefs.setString('source_language', _sourceLanguage.code);
      await prefs.setString('target_language', _targetLanguage.code);
      
      // Voice preferences
      await prefs.setString('voice_preferences', json.encode(_voicePreferences.toJson()));
      
      // Settings
      await prefs.setBool('overlay_enabled', _overlayEnabled);
      await prefs.setBool('background_service_enabled', _backgroundServiceEnabled);
      await prefs.setBool('auto_detect_language', _autoDetectLanguage);
      await prefs.setBool('continuous_listening', _continuousListening);
      await prefs.setDouble('speech_volume', _speechVolume);
      await prefs.setBool('vibration_enabled', _vibrationEnabled);
      await prefs.setBool('developer_mode_enabled', _developerModeEnabled);
      await prefs.setString('api_endpoint', _apiEndpoint);
      await prefs.setInt('translation_count', _translationCount);
      await prefs.setBool('two_way_mode', _twoWayMode);
      
      if (_lastTranslation != null) {
        await prefs.setInt('last_translation', _lastTranslation!.millisecondsSinceEpoch);
      }
    } catch (e) {
      print('Error saving settings: $e');
    }
  }
}