import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'app_theme.dart';
import 'models/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/voice_selection_screen.dart';
import 'screens/developer_screen.dart';
import 'screens/live_mode_screen.dart';
import 'screens/text_translation_screen.dart';
import 'services/background_service.dart';
import 'services/overlay_service.dart';
import 'services/update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize background service
  await initializeService();
  
  // Initialize overlay service
  await OverlayService.initialize();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        title: 'Translated by Hisham',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const AppWrapper(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/voice-selection': (context) => const VoiceSelectionScreen(),
          '/developer': (context) => const DeveloperScreen(),
          '/live-mode': (context) => const LiveModeScreen(),
          '/text-translation': (context) => const TextTranslationScreen(),
        },
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isFirstTime = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    _checkForUpdates();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    
    setState(() {
      _isFirstTime = !hasSeenOnboarding;
      _isLoading = false;
    });
  }

  Future<void> _checkForUpdates() async {
    try {
      final updateService = UpdateService();
      final hasUpdate = await updateService.checkForUpdates();
      
      if (hasUpdate && mounted) {
        _showUpdateDialog();
      }
    } catch (e) {
      print('Error checking for updates: $e');
    }
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'تحديث متوفر',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'يتوفر إصدار جديد من التطبيق. يرجى التحديث للحصول على أحدث الميزات.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final updateService = UpdateService();
              await updateService.downloadAndInstallUpdate();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('تحديث الآن'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }
    
    return _isFirstTime ? const OnboardingScreen() : const HomeScreen();
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
              Color(0xFFA855F7),
            ],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.text_snippet,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'Translated by Hisham',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '🪶 Professional Translation',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}