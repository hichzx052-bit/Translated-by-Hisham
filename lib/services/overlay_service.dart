import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/floating_controls.dart';

class OverlayService {
  static final OverlayService _instance = OverlayService._internal();
  factory OverlayService() => _instance;
  OverlayService._internal();

  bool _isOverlayActive = false;
  bool _isMinimized = true;
  bool _hasPermission = false;
  
  // Callbacks
  Function()? onOverlayShow;
  Function()? onOverlayHide;
  Function(bool)? onMinimizeChanged;
  Function()? onStartListening;
  Function()? onStopListening;
  Function(String, String)? onLanguageChanged;
  Function(String)? onVoiceChanged;
  
  bool get isOverlayActive => _isOverlayActive;
  bool get isMinimized => _isMinimized;
  bool get hasPermission => _hasPermission;
  
  static Future<void> initialize() async {
    await OverlayService()._checkPermission();
  }
  
  Future<void> _checkPermission() async {
    try {
      _hasPermission = await Permission.systemAlertWindow.isGranted;
    } catch (e) {
      print('Error checking overlay permission: $e');
      _hasPermission = false;
    }
  }
  
  Future<bool> requestPermission() async {
    try {
      if (_hasPermission) return true;
      
      final status = await Permission.systemAlertWindow.request();
      _hasPermission = status == PermissionStatus.granted;
      
      if (!_hasPermission) {
        // Try alternative method for Android
        _hasPermission = await FlutterOverlayWindow.requestPermission();
      }
      
      return _hasPermission;
    } catch (e) {
      print('Error requesting overlay permission: $e');
      return false;
    }
  }
  
  Future<bool> showOverlay() async {
    try {
      if (!_hasPermission) {
        final granted = await requestPermission();
        if (!granted) return false;
      }
      
      if (_isOverlayActive) {
        return true;
      }
      
      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: "Translated by Hisham",
        overlayContent: 'Translation Overlay',
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.auto,
        width: _isMinimized ? 80 : 300,
        height: _isMinimized ? 80 : 400,
      );
      
      _isOverlayActive = true;
      onOverlayShow?.call();
      
      // Listen for overlay events
      FlutterOverlayWindow.overlayListener.listen((data) {
        _handleOverlayData(data);
      });
      
      return true;
    } catch (e) {
      print('Error showing overlay: $e');
      return false;
    }
  }
  
  Future<bool> hideOverlay() async {
    try {
      if (!_isOverlayActive) return true;
      
      await FlutterOverlayWindow.closeOverlay();
      _isOverlayActive = false;
      _isMinimized = true;
      
      onOverlayHide?.call();
      return true;
    } catch (e) {
      print('Error hiding overlay: $e');
      return false;
    }
  }
  
  Future<void> updateOverlayContent() async {
    if (!_isOverlayActive) return;
    
    try {
      // Update the overlay widget content
      await FlutterOverlayWindow.updateFlag(OverlayFlag.defaultFlag);
    } catch (e) {
      print('Error updating overlay content: $e');
    }
  }
  
  Future<void> minimizeOverlay() async {
    if (!_isOverlayActive) return;
    
    try {
      _isMinimized = true;
      
      await FlutterOverlayWindow.resizeOverlay(80, 80);
      
      onMinimizeChanged?.call(true);
    } catch (e) {
      print('Error minimizing overlay: $e');
    }
  }
  
  Future<void> expandOverlay() async {
    if (!_isOverlayActive) return;
    
    try {
      _isMinimized = false;
      
      await FlutterOverlayWindow.resizeOverlay(300, 400);
      
      onMinimizeChanged?.call(false);
    } catch (e) {
      print('Error expanding overlay: $e');
    }
  }
  
  Future<void> moveOverlay(double x, double y) async {
    if (!_isOverlayActive) return;
    
    try {
      await FlutterOverlayWindow.moveOverlay(x.toInt(), y.toInt());
    } catch (e) {
      print('Error moving overlay: $e');
    }
  }
  
  void _handleOverlayData(dynamic data) {
    if (data is Map<String, dynamic>) {
      final action = data['action'] as String?;
      
      switch (action) {
        case 'minimize':
          minimizeOverlay();
          break;
        case 'expand':
          expandOverlay();
          break;
        case 'start_listening':
          onStartListening?.call();
          break;
        case 'stop_listening':
          onStopListening?.call();
          break;
        case 'change_source_language':
          final sourceLanguage = data['source_language'] as String?;
          final targetLanguage = data['target_language'] as String?;
          if (sourceLanguage != null && targetLanguage != null) {
            onLanguageChanged?.call(sourceLanguage, targetLanguage);
          }
          break;
        case 'change_voice':
          final voiceName = data['voice_name'] as String?;
          if (voiceName != null) {
            onVoiceChanged?.call(voiceName);
          }
          break;
        case 'toggle_minimize':
          if (_isMinimized) {
            expandOverlay();
          } else {
            minimizeOverlay();
          }
          break;
        case 'close':
          hideOverlay();
          break;
      }
    }
  }
  
  Future<void> sendDataToOverlay(Map<String, dynamic> data) async {
    if (!_isOverlayActive) return;
    
    try {
      await FlutterOverlayWindow.shareData(data);
    } catch (e) {
      print('Error sending data to overlay: $e');
    }
  }
  
  Future<void> updateTranslationStatus({
    required bool isListening,
    required bool isSpeaking,
    required String sourceLanguage,
    required String targetLanguage,
    String? currentText,
    String? translatedText,
  }) async {
    await sendDataToOverlay({
      'type': 'status_update',
      'is_listening': isListening,
      'is_speaking': isSpeaking,
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
      'current_text': currentText,
      'translated_text': translatedText,
    });
  }
  
  Future<void> updateLanguages({
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    await sendDataToOverlay({
      'type': 'language_update',
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
    });
  }
  
  Future<void> showError(String message) async {
    await sendDataToOverlay({
      'type': 'error',
      'message': message,
    });
  }
  
  Future<bool> isOverlayPermissionGranted() async {
    try {
      return await Permission.systemAlertWindow.isGranted;
    } catch (e) {
      return false;
    }
  }
  
  void dispose() {
    hideOverlay();
    onOverlayShow = null;
    onOverlayHide = null;
    onMinimizeChanged = null;
    onStartListening = null;
    onStopListening = null;
    onLanguageChanged = null;
    onVoiceChanged = null;
  }
}

// Widget for the overlay content
class OverlayWidget extends StatefulWidget {
  const OverlayWidget({Key? key}) : super(key: key);

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  bool _isMinimized = true;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _sourceLanguage = 'auto';
  String _targetLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _listenForData();
  }

  void _listenForData() {
    FlutterOverlayWindow.overlayListener.listen((data) {
      if (data is Map<String, dynamic>) {
        final type = data['type'] as String?;
        
        if (type == 'status_update') {
          setState(() {
            _isListening = data['is_listening'] ?? false;
            _isSpeaking = data['is_speaking'] ?? false;
            _sourceLanguage = data['source_language'] ?? 'auto';
            _targetLanguage = data['target_language'] ?? 'en';
          });
        } else if (type == 'language_update') {
          setState(() {
            _sourceLanguage = data['source_language'] ?? 'auto';
            _targetLanguage = data['target_language'] ?? 'en';
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: _isMinimized ? _buildMinimizedView() : _buildExpandedView(),
    );
  }
  
  Widget _buildMinimizedView() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isMinimized = false;
        });
        FlutterOverlayWindow.shareData({'action': 'expand'});
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.text_snippet,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
  
  Widget _buildExpandedView() {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingControls(
        isListening: _isListening,
        isSpeaking: _isSpeaking,
        sourceLanguage: _sourceLanguage,
        targetLanguage: _targetLanguage,
        onMinimize: () {
          setState(() {
            _isMinimized = true;
          });
          FlutterOverlayWindow.shareData({'action': 'minimize'});
        },
        onClose: () {
          FlutterOverlayWindow.shareData({'action': 'close'});
        },
        onStartListening: () {
          FlutterOverlayWindow.shareData({'action': 'start_listening'});
        },
        onStopListening: () {
          FlutterOverlayWindow.shareData({'action': 'stop_listening'});
        },
        onLanguageChanged: (source, target) {
          FlutterOverlayWindow.shareData({
            'action': 'change_source_language',
            'source_language': source,
            'target_language': target,
          });
        },
        onVoiceChanged: (voiceName) {
          FlutterOverlayWindow.shareData({
            'action': 'change_voice',
            'voice_name': voiceName,
          });
        },
      ),
    );
  }
}