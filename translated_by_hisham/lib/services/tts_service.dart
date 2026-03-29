import 'package:flutter_tts/flutter_tts.dart';
import '../models/voice_model.dart';

enum TtsState { playing, stopped, paused, continued }

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  TtsState _state = TtsState.stopped;
  bool _isInitialized = false;

  Function()? onStart;
  Function()? onComplete;
  Function()? onPause;
  Function(String error)? onError;

  TtsState get state => _state;
  bool get isSpeaking => _state == TtsState.playing;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ],
      IosTextToSpeechAudioMode.defaultMode,
    );

    _flutterTts.setStartHandler(() {
      _state = TtsState.playing;
      onStart?.call();
    });

    _flutterTts.setCompletionHandler(() {
      _state = TtsState.stopped;
      onComplete?.call();
    });

    _flutterTts.setPauseHandler(() {
      _state = TtsState.paused;
      onPause?.call();
    });

    _flutterTts.setCancelHandler(() {
      _state = TtsState.stopped;
    });

    _flutterTts.setErrorHandler((msg) {
      _state = TtsState.stopped;
      onError?.call(msg);
    });

    _isInitialized = true;
  }

  Future<void> speak(
    String text, {
    String? language,
    double? speechRate,
    double? pitch,
    double? volume,
    VoiceModel? voice,
  }) async {
    if (!_isInitialized) await initialize();
    if (text.trim().isEmpty) return;

    await stop();

    if (language != null) {
      await _flutterTts.setLanguage(language);
    }

    if (speechRate != null) {
      await _flutterTts.setSpeechRate(speechRate.clamp(0.1, 1.0));
    }

    if (pitch != null) {
      await _flutterTts.setPitch(pitch.clamp(0.5, 2.0));
    }

    if (volume != null) {
      await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
    }

    if (voice != null) {
      await _applyVoiceSettings(voice);
    }

    await _flutterTts.speak(text);
  }

  Future<void> _applyVoiceSettings(VoiceModel voice) async {
    final availableVoices = await _flutterTts.getVoices;
    if (availableVoices == null) return;

    // Try to find a matching voice by gender and locale
    final voices = availableVoices as List;
    for (final v in voices) {
      final vMap = v as Map;
      final locale = vMap['locale']?.toString() ?? '';
      final name = vMap['name']?.toString().toLowerCase() ?? '';

      if (locale.startsWith(voice.locale.split('-').first)) {
        if (voice.gender == 'female' && (name.contains('female') || name.contains('woman') || name.contains('f'))) {
          await _flutterTts.setVoice({'name': vMap['name'], 'locale': vMap['locale']});
          return;
        } else if (voice.gender == 'male' && !name.contains('female')) {
          await _flutterTts.setVoice({'name': vMap['name'], 'locale': vMap['locale']});
          return;
        }
      }
    }
  }

  Future<void> stop() async {
    if (_state == TtsState.playing || _state == TtsState.paused) {
      await _flutterTts.stop();
      _state = TtsState.stopped;
    }
  }

  Future<void> pause() async {
    if (_state == TtsState.playing) {
      await _flutterTts.pause();
    }
  }

  Future<List<String>> getAvailableLanguages() async {
    if (!_isInitialized) await initialize();
    final langs = await _flutterTts.getLanguages;
    return (langs as List).cast<String>();
  }

  Future<List<dynamic>> getAvailableVoices() async {
    if (!_isInitialized) await initialize();
    final voices = await _flutterTts.getVoices;
    return (voices as List?) ?? [];
  }

  void dispose() {
    _flutterTts.stop();
  }
}
