import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';
import 'services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize background service
  await BackgroundServiceManager().initialize();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0A1A),
  ));
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const TranslatedByHisham());
}

// Overlay entry point for floating bubble
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FloatingOverlayWidget(),
  ));
}

class FloatingOverlayWidget extends StatefulWidget {
  const FloatingOverlayWidget({super.key});

  @override
  State<FloatingOverlayWidget> createState() => _FloatingOverlayWidgetState();
}

class _FloatingOverlayWidgetState extends State<FloatingOverlayWidget>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _isListening = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: _expanded ? _buildExpanded() : _buildCollapsed(),
    );
  }

  Widget _buildCollapsed() {
    return GestureDetector(
      onTap: () => setState(() => _expanded = true),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 + (_isListening ? _pulseController.value * 0.15 : 0);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.translate, color: Colors.white, size: 28),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpanded() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.95),
            const Color(0xFF16213E).withOpacity(0.95),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.translate, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'ترجمة فورية',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _expanded = false),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: const Icon(Icons.close, color: Colors.white70, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mic button
          GestureDetector(
            onTap: () => setState(() => _isListening = !_isListening),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isListening
                      ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                      : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? const Color(0xFFEF4444) : const Color(0xFF8B5CF6))
                        .withOpacity(0.5),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isListening ? 'جاري الاستماع...' : 'اضغط للترجمة',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
          ),
          const SizedBox(height: 12),
          // Language selector row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _langChip('العربية', '🇸🇦'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.swap_horiz, color: Colors.white54, size: 20),
              ),
              _langChip('English', '🇬🇧'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _langChip(String name, String flag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        '$flag $name',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

class TranslatedByHisham extends StatelessWidget {
  const TranslatedByHisham({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Translated by Hisham',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
        },
      ),
    );
  }
}
