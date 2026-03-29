import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _error = false;
  bool _loading = false;
  int _attempts = 0;
  late AnimationController _glowController;

  static const _password = 'Hichamdzz';

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() { _loading = true; _error = false; });
    await Future.delayed(const Duration(milliseconds: 800));

    if (_controller.text == _password) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const DashboardScreen(),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    } else {
      _attempts++;
      setState(() { _error = true; _loading = false; });
      if (_attempts >= 3) {
        // Show warning
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ محاولات كثيرة — حاول لاحقاً'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      body: Stack(
        children: [
          // Animated background glow
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.3 + _glowController.value * 0.2),
                    radius: 1.5,
                    colors: [
                      const Color(0xFF06B6D4).withOpacity(0.06 + _glowController.value * 0.04),
                      const Color(0xFF0A0A12),
                    ],
                  ),
                ),
              );
            },
          ),
          // Grid lines background (hacker aesthetic)
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _GridPainter(),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo/icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF06B6D4).withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.admin_panel_settings,
                          color: Color(0xFF06B6D4), size: 48),
                    ),
                    const SizedBox(height: 24),
                    // Title with typing animation
                    DefaultTextStyle(
                      style: const TextStyle(
                        color: Color(0xFF06B6D4),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'Update Manager',
                            speed: const Duration(milliseconds: 80),
                          ),
                        ],
                        isRepeatingAnimation: false,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'لوحة تحكم المطور',
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                    ),
                    const SizedBox(height: 48),
                    // Password field
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white.withOpacity(0.04),
                            border: Border.all(
                              color: _error
                                  ? const Color(0xFFEF4444).withOpacity(0.5)
                                  : const Color(0xFF06B6D4).withOpacity(0.15),
                            ),
                          ),
                          child: TextField(
                            controller: _controller,
                            obscureText: _obscure,
                            style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'كلمة مرور المطور',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), letterSpacing: 0),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              prefixIcon: Icon(Icons.lock_outline,
                                  color: _error ? const Color(0xFFEF4444) : Colors.white24),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.white24,
                                ),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            onSubmitted: (_) => _login(),
                          ),
                        ),
                      ),
                    ),
                    if (_error)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'كلمة المرور خاطئة ❌ (محاولة $_attempts/3)',
                          style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Login button
                    GestureDetector(
                      onTap: _loading ? null : _login,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF06B6D4).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _loading
                              ? const SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'دخول 🔐',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      '🛡️ منطقة محمية — للمطور فقط',
                      style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Grid lines painter for hacker aesthetic
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF06B6D4).withOpacity(0.03)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
