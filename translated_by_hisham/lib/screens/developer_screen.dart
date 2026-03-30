import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';

class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({super.key});

  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

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
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Stack(
        children: [
          // Background glow
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.5,
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.08 + _glowController.value * 0.04),
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
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      const Text(
                        'حول المطور',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        // Developer avatar
                        AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, _) {
                            return Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF8B5CF6).withOpacity(0.3 + _glowController.value * 0.2),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.code, color: Colors.white, size: 52),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        // Developer name
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF818CF8), Color(0xFFA855F7)],
                          ).createShader(bounds),
                          child: Text(
                            'Hichamdzz',
                            style: GoogleFonts.tajawal(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Full-Stack Developer',
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                        ),
                        const SizedBox(height: 32),
                        // Info cards
                        GlassContainer(
                          child: Column(
                            children: [
                              _infoRow(Icons.apps, 'التطبيق', 'Translated by Hisham'),
                              _divider(),
                              _infoRow(Icons.update, 'الإصدار', '1.0.0'),
                              _divider(),
                              _infoRow(Icons.build_circle_outlined, 'البناء', '2026.03.30'),
                              _divider(),
                              _infoRow(Icons.language, 'المنصة', 'Android (Flutter)'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        GlassContainer(
                          child: Column(
                            children: [
                              _infoRow(Icons.auto_awesome, 'محرك الترجمة', 'Google Translate API'),
                              _divider(),
                              _infoRow(Icons.mic, 'التعرف الصوتي', 'Speech-to-Text'),
                              _divider(),
                              _infoRow(Icons.record_voice_over, 'النطق', 'Flutter TTS'),
                              _divider(),
                              _infoRow(Icons.layers, 'الزر العائم', 'System Overlay'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // GitHub link
                        GlassContainer(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF6366F1).withOpacity(0.12),
                              const Color(0xFF8B5CF6).withOpacity(0.04),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white.withOpacity(0.08),
                                ),
                                child: const Icon(Icons.terminal, color: Color(0xFF818CF8), size: 22),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('GitHub',
                                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                                    Text('hichzx052-bit',
                                        style: TextStyle(color: Color(0xFF818CF8), fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.open_in_new, color: Colors.white24, size: 18),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Footer
                        Text(
                          'صُنع بكل حب من الجزائر',
                          style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF818CF8), size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(color: Colors.white.withOpacity(0.06), height: 1),
    );
  }
}
