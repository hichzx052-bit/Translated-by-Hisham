import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/language_model.dart';
import '../widgets/glass_container.dart';
import '../widgets/translation_card.dart';
import '../widgets/language_selector.dart';
import '../widgets/pulse_animation.dart';
import '../widgets/wave_animation.dart';
import '../services/overlay_service.dart';
import 'live_mode_screen.dart';
import 'text_translation_screen.dart';
import 'video_translation_screen.dart';
import 'voice_selection_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;
  bool _overlayActive = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    final state = Provider.of<AppState>(context, listen: false);
    if (state.isListening) {
      state.stopListening();
    } else {
      state.startListening();
    }
  }

  void _toggleOverlay() async {
    if (_overlayActive) {
      await OverlayService.closeOverlay();
    } else {
      await OverlayService.showOverlay();
    }
    setState(() => _overlayActive = !_overlayActive);
  }

  void _swapLanguages() {
    final state = Provider.of<AppState>(context, listen: false);
    state.swapLanguages();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0A1A),
          body: Stack(
            children: [
              // Animated background gradient
              AnimatedBuilder(
                animation: _bgController,
                builder: (context, _) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(
                          -0.5 + _bgController.value,
                          -0.8 + _bgController.value * 0.3,
                        ),
                        radius: 1.5,
                        colors: [
                          const Color(0xFF6366F1).withOpacity(0.15),
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
                    _buildAppBar(state),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            // Language selector row
                            _buildLanguageRow(state),
                            const SizedBox(height: 20),
                            // Source card
                            TranslationCard(
                              text: state.sourceText,
                              language: state.sourceLanguage.nativeName,
                              flag: state.sourceLanguage.flag,
                              isSource: true,
                              onSpeak: () => state.speakText(state.sourceText, state.sourceLanguage.code),
                              onCopy: () => Clipboard.setData(ClipboardData(text: state.sourceText)),
                            ),
                            const SizedBox(height: 16),
                            // Target card
                            TranslationCard(
                              text: state.translatedText,
                              language: state.targetLanguage.nativeName,
                              flag: state.targetLanguage.flag,
                              isSource: false,
                              onSpeak: () => state.speakText(state.translatedText, state.targetLanguage.code),
                              onCopy: () => Clipboard.setData(ClipboardData(text: state.translatedText)),
                            ),
                            const SizedBox(height: 20),
                            // Wave animation
                            WaveAnimation(
                              isActive: state.isListening,
                              color: const Color(0xFF8B5CF6),
                              height: 50,
                            ),
                            const SizedBox(height: 20),
                            // Quick actions
                            _buildQuickActions(),
                            const SizedBox(height: 20),
                            // Floating overlay button
                            _buildOverlayButton(),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                    // Bottom mic button
                    _buildMicButton(state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(AppState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF818CF8), Color(0xFFA855F7)],
            ).createShader(bounds),
            child: const Text(
              'Translated by Hisham',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          _iconButton(Icons.record_voice_over, () {
            Navigator.push(context, _pageRoute(const VoiceSelectionScreen()));
          }),
          const SizedBox(width: 8),
          _iconButton(Icons.settings, () {
            Navigator.push(context, _pageRoute(const SettingsScreen()));
          }),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Icon(icon, color: Colors.white60, size: 20),
      ),
    );
  }

  Widget _buildLanguageRow(AppState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: LanguageSelector(
            selectedLanguage: state.sourceLanguage,
            languages: LanguageModel.supportedLanguages,
            onChanged: (lang) => state.setSourceLanguage(lang),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector(
            onTap: _swapLanguages,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.swap_horiz, color: Colors.white, size: 22),
            ),
          ),
        ),
        Expanded(
          child: LanguageSelector(
            selectedLanguage: state.targetLanguage,
            languages: LanguageModel.supportedLanguages,
            onChanged: (lang) => state.setTargetLanguage(lang),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(child: _quickAction(Icons.live_tv, 'لايف', const Color(0xFFEF4444), () {
          Navigator.push(context, _pageRoute(const LiveModeScreen()));
        })),
        const SizedBox(width: 12),
        Expanded(child: _quickAction(Icons.text_fields, 'نص', const Color(0xFF3B82F6), () {
          Navigator.push(context, _pageRoute(const TextTranslationScreen()));
        })),
        const SizedBox(width: 12),
        Expanded(child: _quickAction(Icons.videocam, 'فيديو', const Color(0xFF10B981), () {
          Navigator.push(context, _pageRoute(const VideoTranslationScreen()));
        })),
      ],
    );
  }

  Widget _quickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.15),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayButton() {
    return GestureDetector(
      onTap: _toggleOverlay,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        gradient: LinearGradient(
          colors: _overlayActive
              ? [const Color(0xFF10B981).withOpacity(0.2), const Color(0xFF059669).withOpacity(0.1)]
              : [const Color(0xFF6366F1).withOpacity(0.15), const Color(0xFF8B5CF6).withOpacity(0.05)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _overlayActive ? Icons.stop_circle : Icons.bubble_chart,
              color: _overlayActive ? const Color(0xFF34D399) : const Color(0xFF818CF8),
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              _overlayActive ? 'إيقاف الزر العائم' : 'تشغيل الزر العائم',
              style: TextStyle(
                color: _overlayActive ? const Color(0xFF34D399) : const Color(0xFF818CF8),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicButton(AppState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: PulseAnimation(
        isActive: state.isListening,
        color: state.isListening ? const Color(0xFFEF4444) : const Color(0xFF8B5CF6),
        child: GestureDetector(
          onTap: _toggleListening,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: state.isListening
                    ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                    : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (state.isListening ? const Color(0xFFEF4444) : const Color(0xFF8B5CF6))
                      .withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              state.isListening ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }

  PageRoute _pageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, c) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: c,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
