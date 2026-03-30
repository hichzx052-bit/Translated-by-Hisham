import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/glass_container.dart';
import '../widgets/wave_animation.dart';
import '../widgets/language_selector.dart';
import '../models/language_model.dart';

class LiveModeScreen extends StatefulWidget {
  const LiveModeScreen({super.key});

  @override
  State<LiveModeScreen> createState() => _LiveModeScreenState();
}

class _LiveModeScreenState extends State<LiveModeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  bool _isLive = false;
  final List<_LiveMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _toggleLive() {
    final state = Provider.of<AppState>(context, listen: false);
    setState(() {
      _isLive = !_isLive;
      if (_isLive) {
        state.startListening();
      } else {
        state.stopListening();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        // Add new messages when translation comes
        if (state.translatedText.isNotEmpty && _isLive) {
          final lastMsg = _messages.isEmpty ? '' : _messages.last.translated;
          if (state.translatedText != lastMsg) {
            _messages.add(_LiveMessage(
              original: state.sourceText,
              translated: state.translatedText,
              time: DateTime.now(),
            ));
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A1A),
          body: Stack(
            children: [
              // Live background glow
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, _) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topCenter,
                        radius: 1.2,
                        colors: [
                          (_isLive ? const Color(0xFFEF4444) : const Color(0xFF6366F1))
                              .withOpacity(0.08 + _glowController.value * 0.07),
                          const Color(0xFF0A0A1A),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(state),
                    const SizedBox(height: 12),
                    // Wave visualization
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: WaveAnimation(
                        isActive: _isLive && state.isListening,
                        color: _isLive ? const Color(0xFFEF4444) : const Color(0xFF8B5CF6),
                        height: 60,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Language row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LanguageSelector(
                            selectedLanguage: state.sourceLanguage,
                            languages: LanguageModel.supportedLanguages,
                            onChanged: (l) => state.setSourceLanguage(l),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(Icons.arrow_forward, color: Colors.white30, size: 20),
                          ),
                          LanguageSelector(
                            selectedLanguage: state.targetLanguage,
                            languages: LanguageModel.supportedLanguages,
                            onChanged: (l) => state.setTargetLanguage(l),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Current translation
                    if (state.translatedText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GlassContainer(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFEF4444).withOpacity(0.15),
                              const Color(0xFFEF4444).withOpacity(0.03),
                            ],
                          ),
                          borderColor: const Color(0xFFEF4444).withOpacity(0.2),
                          child: Column(
                            children: [
                              Text(
                                state.sourceText,
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.translatedText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    // Message history
                    Expanded(
                      child: _messages.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.live_tv,
                                      color: Colors.white.withOpacity(0.1), size: 64),
                                  const SizedBox(height: 12),
                                  Text(
                                    _isLive ? 'جاري الاستماع للبث...' : 'اضغط LIVE للبدء',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.3),
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              reverse: true,
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final msg = _messages[_messages.length - 1 - index];
                                return _buildMessageBubble(msg);
                              },
                            ),
                    ),
                    // Live control button
                    _buildLiveButton(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white70, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'وضع البث المباشر',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isLive ? const Color(0xFFEF4444) : Colors.white24,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isLive ? 'مباشر الآن' : 'متوقف',
                    style: TextStyle(
                      color: _isLive ? const Color(0xFFFCA5A5) : Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          if (_isLive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFEF4444),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_LiveMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.original,
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              msg.translated,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                '${msg.time.hour}:${msg.time.minute.toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: _toggleLive,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: _isLive
                  ? [const Color(0xFF7F1D1D), const Color(0xFFEF4444)]
                  : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withOpacity(_isLive ? 0.5 : 0.3),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isLive ? Icons.stop : Icons.fiber_manual_record,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isLive ? 'إيقاف البث' : 'بدء البث المباشر',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveMessage {
  final String original;
  final String translated;
  final DateTime time;

  _LiveMessage({required this.original, required this.translated, required this.time});
}
