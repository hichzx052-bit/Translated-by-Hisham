import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

/// OverlayService — manages the real Android SYSTEM_ALERT_WINDOW floating bubble.
/// Works exactly like Auto Clicker's overlay: appears on top of ALL apps,
/// draggable, expandable, and communicates with the main app via message passing.
class OverlayService {
  static final OverlayService _instance = OverlayService._internal();
  factory OverlayService() => _instance;
  OverlayService._internal();

  bool _isShowing = false;
  StreamSubscription? _dataSubscription;

  Function(Map<String, dynamic>)? onOverlayAction;

  bool get isShowing => _isShowing;

  // Static convenience methods for screens
  static Future<void> showOverlay() async {
    await OverlayService().showBubble();
  }

  static Future<void> closeOverlay() async {
    await OverlayService().hideBubble();
  }

  static Future<bool> isOverlayActive() async {
    return OverlayService().isShowing;
  }

  Future<bool> hasPermission() async {
    return await FlutterOverlayWindow.isPermissionGranted();
  }

  Future<bool> requestPermission() async {
    if (await FlutterOverlayWindow.isPermissionGranted()) return true;
    await FlutterOverlayWindow.requestPermission();
    // Give user time to grant permission in settings
    await Future.delayed(const Duration(seconds: 1));
    return await FlutterOverlayWindow.isPermissionGranted();
  }

  Future<bool> showBubble() async {
    if (_isShowing) return true;

    final granted = await requestPermission();
    if (!granted) return false;

    await FlutterOverlayWindow.showOverlay(
      height: WindowSize.matchParent, // full parent height so we can position freely
      width: WindowSize.matchParent,
      startPosition: const OverlayPosition(0, -200),
      alignment: OverlayAlignment.center,
      enableDrag: true,
      flag: OverlayFlag.defaultFlag,
      overlayTitle: 'Translated by Hisham',
      overlayContent: 'Translation active',
      positionGravity: PositionGravity.auto,
    );

    _isShowing = true;
    _listenToOverlay();
    return true;
  }

  Future<void> hideBubble() async {
    if (!_isShowing) return;
    await FlutterOverlayWindow.closeOverlay();
    _isShowing = false;
    _dataSubscription?.cancel();
    _dataSubscription = null;
  }

  void _listenToOverlay() {
    _dataSubscription?.cancel();
    _dataSubscription = FlutterOverlayWindow.overlayListener.listen((data) {
      if (data is Map) {
        onOverlayAction?.call(Map<String, dynamic>.from(data));
      }
    });
  }

  /// Send data from main app → overlay
  Future<void> sendToOverlay(Map<String, dynamic> data) async {
    if (!_isShowing) return;
    await FlutterOverlayWindow.shareData(data);
  }

  Future<void> updateTranslation({
    required String original,
    required String translated,
    required bool isListening,
    String sourceLang = '',
    String targetLang = '',
  }) async {
    await sendToOverlay({
      'type': 'translation_update',
      'original': original,
      'translated': translated,
      'isListening': isListening,
      'sourceLang': sourceLang,
      'targetLang': targetLang,
    });
  }

  void dispose() {
    _dataSubscription?.cancel();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// OVERLAY ENTRY POINT — runs in a separate isolate as the floating window UI
// Must be annotated @pragma('vm:entry-point') and registered in AndroidManifest
// ═══════════════════════════════════════════════════════════════════════════════

@pragma('vm:entry-point')
void overlayMain() {
  runApp(const OverlayBubbleApp());
}

class OverlayBubbleApp extends StatelessWidget {
  const OverlayBubbleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayBubbleScreen(),
    );
  }
}

class OverlayBubbleScreen extends StatefulWidget {
  const OverlayBubbleScreen({super.key});

  @override
  State<OverlayBubbleScreen> createState() => _OverlayBubbleScreenState();
}

class _OverlayBubbleScreenState extends State<OverlayBubbleScreen>
    with TickerProviderStateMixin {
  bool _expanded = false;
  bool _isListening = false;
  String _translatedText = '';
  String _originalText = '';
  String _sourceLang = '';
  String _targetLang = 'AR';

  late AnimationController _pulseController;
  late AnimationController _expandController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnim;
  late Animation<double> _expandAnim;
  late Animation<double> _rippleAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _expandAnim = CurvedAnimation(parent: _expandController, curve: Curves.easeOutBack);
    _rippleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    // Listen to messages from the main app
    FlutterOverlayWindow.overlayListener.listen(_handleMessage);
  }

  void _handleMessage(dynamic data) {
    if (data == null || data is! Map) return;
    setState(() {
      final type = data['type'] as String? ?? '';
      if (type == 'translation_update') {
        _translatedText = data['translated'] as String? ?? '';
        _originalText = data['original'] as String? ?? '';
        _isListening = data['isListening'] as bool? ?? false;
        _sourceLang = (data['sourceLang'] as String? ?? '').toUpperCase();
        _targetLang = (data['targetLang'] as String? ?? 'AR').toUpperCase();

        if (_isListening) {
          _pulseController.repeat(reverse: true);
          _rippleController.repeat();
        } else {
          _pulseController.stop();
          _pulseController.reset();
          _rippleController.stop();
          _rippleController.reset();
        }
      }
    });
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  void _toggleListen() {
    FlutterOverlayWindow.shareData({'action': 'toggle_listen'});
  }

  void _closeOverlay() {
    FlutterOverlayWindow.shareData({'action': 'close'});
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _expandController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.topCenter,
        child: AnimatedBuilder(
          animation: _expandAnim,
          builder: (context, child) {
            return _expanded ? _buildExpanded() : _buildCollapsed();
          },
        ),
      ),
    );
  }

  Widget _buildCollapsed() {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Ripple rings when listening
              if (_isListening) ...[
                AnimatedBuilder(
                  animation: _rippleAnim,
                  builder: (context, _) {
                    return Container(
                      width: 72 + (_rippleAnim.value * 40),
                      height: 72 + (_rippleAnim.value * 40),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF4F46E5)
                              .withOpacity(1.0 - _rippleAnim.value),
                          width: 2,
                        ),
                      ),
                    );
                  },
                ),
              ],
              // Main bubble
              Transform.scale(
                scale: _isListening ? _pulseAnim.value : 1.0,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isListening
                        ? const Icon(Icons.mic, color: Colors.white, size: 28)
                        : CustomPaint(
                            size: const Size(32, 32),
                            painter: _LogoPainter(),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExpanded() {
    return ScaleTransition(
      scale: _expandAnim,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xEE1A1A35), Color(0xEE0D0D2B)],
          ),
          border: Border.all(
            color: const Color(0xFF4F46E5).withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: Row(
                children: [
                  const Text('🌐', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Translated by Hisham',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleExpanded,
                    child: const Icon(Icons.keyboard_arrow_up,
                        color: Colors.white70, size: 20),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _closeOverlay,
                    child: const Icon(Icons.close, color: Colors.white54, size: 18),
                  ),
                ],
              ),
            ),

            // ── Language bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  _LangChip(label: _sourceLang.isNotEmpty ? _sourceLang : 'AUTO'),
                  const Expanded(
                    child: Icon(Icons.arrow_forward, color: Color(0xFF8B5CF6), size: 18),
                  ),
                  _LangChip(label: _targetLang),
                ],
              ),
            ),

            // ── Translation text ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_originalText.isNotEmpty)
                    Text(
                      _originalText,
                      style: const TextStyle(color: Color(0xFF8B5CF6), fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (_originalText.isNotEmpty) const SizedBox(height: 4),
                  Text(
                    _translatedText.isNotEmpty ? _translatedText : 'Tap mic to start...',
                    style: TextStyle(
                      color: _translatedText.isNotEmpty ? Colors.white : Colors.white38,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── Controls ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mic button
                  GestureDetector(
                    onTap: _toggleListen,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _isListening
                              ? [const Color(0xFFEC4899), const Color(0xFFBE185D)]
                              : [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening
                                    ? const Color(0xFFEC4899)
                                    : const Color(0xFF4F46E5))
                                .withOpacity(0.5),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  const _LangChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5).withOpacity(0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF8B5CF6),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw a stylized "T" + wave
    final path = Path();
    // Horizontal bar
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.22),
      const Radius.circular(3),
    ));
    // Vertical bar
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.38, 0, size.width * 0.24, size.height * 0.7),
      const Radius.circular(3),
    ));

    canvas.drawPath(path, paint);

    // Wave under
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final wavePath = Path();
    wavePath.moveTo(0, size.height * 0.85);
    wavePath.cubicTo(
      size.width * 0.25, size.height * 0.72,
      size.width * 0.5, size.height * 0.98,
      size.width * 0.75, size.height * 0.85,
    );
    wavePath.cubicTo(
      size.width * 0.88, size.height * 0.78,
      size.width * 0.95, size.height * 0.82,
      size.width, size.height * 0.85,
    );
    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
