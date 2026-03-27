import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.translate,
      title: 'ترجمة فورية',
      description: 'ترجم أي لغة بالصوت أو الكتابة فوراً مع التعرف التلقائي على اللغة',
      gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    ),
    OnboardingPage(
      icon: Icons.mic,
      title: 'ترجمة صوتية',
      description: 'تكلم بلغتك والتطبيق يترجم كلامك للغة الطرف الثاني بأصوات متعددة',
      gradient: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
    ),
    OnboardingPage(
      icon: Icons.layers,
      title: 'زر عائم',
      description: 'زر عائم يشتغل فوق كل التطبيقات — تيك توك، ألعاب، مكالمات فيديو',
      gradient: [Color(0xFFA855F7), Color(0xFFEC4899)],
    ),
    OnboardingPage(
      icon: Icons.sync_alt,
      title: 'وضع ثنائي',
      description: 'أنت تتكلم عربي والطرف الثاني يسمع إنجليزي — والعكس! محادثة بلا حدود',
      gradient: [Color(0xFFEC4899), Color(0xFFEF4444)],
    ),
    OnboardingPage(
      icon: Icons.play_circle_filled,
      title: 'جاهز!',
      description: 'التطبيق جاهز للاستخدام. ابدأ الترجمة الآن! 🪶',
      gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    ),
  ];

  void _onDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: page.gradient,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(page.icon, size: 60, color: Colors.white),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        page.title,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const Spacer(flex: 3),
                    ],
                  ),
                ),
              );
            },
          ),
          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: TextButton(
              onPressed: _onDone,
              child: const Text(
                'تخطي',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Bottom navigation
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 30),
                // Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _onDone();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'ابدأ الآن 🪶' : 'التالي',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}
