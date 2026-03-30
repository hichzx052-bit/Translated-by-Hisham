import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _glowController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
    ));

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    _glowOpacity = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(AppConstants.keyOnboardingDone) ?? false;

    if (!mounted) return;

    if (onboardingDone) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppConstants.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Animated background orbs
            ..._buildBackgroundOrbs(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo animation
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) => Transform.scale(
                      scale: _logoScale.value,
                      child: Transform.rotate(
                        angle: _logoRotation.value,
                        child: AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, child) => Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppConstants.primaryIndigo,
                                  AppConstants.primaryPurple,
                                  AppConstants.primaryViolet,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: AppConstants.primaryIndigo
                                      .withOpacity(_glowOpacity.value),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                                BoxShadow(
                                  color: AppConstants.primaryViolet
                                      .withOpacity(_glowOpacity.value * 0.5),
                                  blurRadius: 80,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.translate,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // App name
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) => Opacity(
                      opacity: _textController.value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - _textController.value)),
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppConstants.primaryGradient.createShader(bounds),
                              child: Text(
                                'Translated by',
                                style: GoogleFonts.tajawal(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppConstants.primaryGradient.createShader(bounds),
                              child: Text(
                                'Hisham',
                                style: GoogleFonts.tajawal(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ترجمة هشام',
                              style: GoogleFonts.tajawal(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.white54,
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  // Loading indicator
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) => Opacity(
                      opacity: _textController.value,
                      child: SizedBox(
                        width: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppConstants.primaryViolet.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom tagline
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _textController,
                builder: (context, child) => Opacity(
                  opacity: _textController.value * 0.5,
                  child: Text(
                    'AI-Powered Real-Time Translation',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: Colors.white54,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundOrbs() {
    return [
      AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) => Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppConstants.primaryIndigo
                      .withOpacity(0.15 + _glowOpacity.value * 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) => Positioned(
          bottom: -80,
          right: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppConstants.primaryViolet
                      .withOpacity(0.12 + _glowOpacity.value * 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }
}
