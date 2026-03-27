import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../app_theme.dart';
import '../models/app_state.dart';
import '../models/language_model.dart';
import '../widgets/language_selector.dart';
import '../widgets/translation_card.dart';
import '../widgets/pulse_animation.dart';
import '../services/overlay_service.dart';
import '../services/background_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isOverlayActive = false;
  bool _isBackgroundActive = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _checkServiceStatus();
  }

  Future<void> _checkServiceStatus() async {
    final running = await BackgroundServiceManager.isRunning();
    setState(() => _isBackgroundActive = running);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F0F23),
                  Color(0xFF1A1A3E),
                  Color(0xFF0F0F23),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(appState),
                  const SizedBox(height: 10),
                  _buildLanguageRow(appState),
                  const SizedBox(height: 20),
                  Expanded(child: _buildTranslationArea(appState)),
                  _buildMicButton(appState),
                  const SizedBox(height: 10),
                  _buildBottomActions(appState),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppState appState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Text('🪶', style: TextStyle(fontSize: 28)),
              SizedBox(width: 8),
              Text(
                'Translated',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildIconButton(Icons.text_fields, () {
                Navigator.pushNamed(context, '/text-translation');
              }),
              _buildIconButton(Icons.live_tv, () {
                Navigator.pushNamed(context, '/live-mode');
              }),
              _buildIconButton(Icons.settings, () {
                Navigator.pushNamed(context, '/settings');
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white70, size: 22),
      ),
    );
  }

  Widget _buildLanguageRow(AppState appState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: LanguageSelector(
              selectedLanguage: appState.sourceLanguage,
              label: 'من',
              onChanged: (lang) => appState.setSourceLanguage(lang),
              showAutoDetect: true,
            ),
          ),
          GestureDetector(
            onTap: () => appState.swapLanguages(),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.swap_horiz, color: Colors.white, size: 22),
            ),
          ),
          Expanded(
            child: LanguageSelector(
              selectedLanguage: appState.targetLanguage,
              label: 'إلى',
              onChanged: (lang) => appState.setTargetLanguage(lang),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationArea(AppState appState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Expanded(
            child: TranslationCard(
              title: 'النص الأصلي',
              text: appState.recognizedText.isEmpty
                  ? 'اضغط على الميكروفون وابدأ التحدث...'
                  : appState.recognizedText,
              isPlaceholder: appState.recognizedText.isEmpty,
              detectedLanguage: appState.detectedLanguageName,
              icon: Icons.mic,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TranslationCard(
              title: 'الترجمة',
              text: appState.translatedText.isEmpty
                  ? 'الترجمة ستظهر هنا...'
                  : appState.translatedText,
              isPlaceholder: appState.translatedText.isEmpty,
              icon: Icons.translate,
              onPlayAudio: appState.translatedText.isNotEmpty
                  ? () => appState.speakTranslation()
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicButton(AppState appState) {
    final isListening = appState.isListening;
    
    return GestureDetector(
      onTap: () {
        if (isListening) {
          appState.stopListening();
          _pulseController.stop();
        } else {
          appState.startListening();
          _pulseController.repeat();
        }
      },
      child: PulseAnimation(
        controller: _pulseController,
        isActive: isListening,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isListening
                  ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                  : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
            ),
            boxShadow: [
              BoxShadow(
                color: (isListening ? const Color(0xFFEF4444) : const Color(0xFF6366F1))
                    .withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            isListening ? Icons.stop : Icons.mic,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(AppState appState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionChip(
            icon: Icons.layers,
            label: 'زر عائم',
            isActive: _isOverlayActive,
            onTap: () async {
              if (_isOverlayActive) {
                await OverlayService.closeOverlay();
              } else {
                await OverlayService.showOverlay();
              }
              setState(() => _isOverlayActive = !_isOverlayActive);
            },
          ),
          _buildActionChip(
            icon: Icons.play_circle_outline,
            label: 'الخلفية',
            isActive: _isBackgroundActive,
            onTap: () async {
              if (_isBackgroundActive) {
                await BackgroundServiceManager.stopService();
              } else {
                await BackgroundServiceManager.startService();
              }
              setState(() => _isBackgroundActive = !_isBackgroundActive);
            },
          ),
          _buildActionChip(
            icon: Icons.record_voice_over,
            label: 'الأصوات',
            isActive: false,
            onTap: () => Navigator.pushNamed(context, '/voice-selection'),
          ),
          _buildActionChip(
            icon: Icons.sync_alt,
            label: 'ثنائي',
            isActive: appState.isDualMode,
            onTap: () => appState.toggleDualMode(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF6366F1).withOpacity(0.3)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? const Color(0xFF6366F1) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? const Color(0xFF8B5CF6) : Colors.white60, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white60,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
