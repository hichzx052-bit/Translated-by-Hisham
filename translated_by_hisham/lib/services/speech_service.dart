import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  // Callbacks
  Function(String text, bool isFinal)? onResult;
  Function(double level)? onSoundLevel;
  Function(String error)? onError;
  Function()? onListeningComplete;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    _isInitialized = await _speech.initialize(
      onError: _onError,
      onStatus: _onStatus,
      debugLogging: false,
    );

    return _isInitialized;
  }

  Future<bool> startListening({
    String? localeId,
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    if (!_isInitialized) {
      final init = await initialize();
      if (!init) return false;
    }

    if (_isListening) {
      await stopListening();
    }

    _isListening = true;

    await _speech.listen(
      onResult: _onSpeechResult,
      localeId: localeId,
      listenFor: listenFor ?? const Duration(seconds: 30),
      pauseFor: pauseFor ?? const Duration(seconds: 3),
      onSoundLevelChange: (level) {
        onSoundLevel?.call(level);
      },
      cancelOnError: false,
      partialResults: true,
    );

    return true;
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    _isListening = false;
    await _speech.stop();
    onListeningComplete?.call();
  }

  Future<void> cancelListening() async {
    _isListening = false;
    await _speech.cancel();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    onResult?.call(result.recognizedWords, result.finalResult);
    if (result.finalResult) {
      _isListening = false;
      onListeningComplete?.call();
    }
  }

  void _onError(SpeechRecognitionError error) {
    _isListening = false;
    onError?.call(error.errorMsg);
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
    }
  }

  Future<List<LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) await initialize();
    return await _speech.locales();
  }

  void dispose() {
    _speech.cancel();
  }
}
