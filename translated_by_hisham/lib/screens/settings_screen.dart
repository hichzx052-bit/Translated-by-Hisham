import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/glass_container.dart';
import 'developer_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0A1A),
          body: SafeArea(
            child: Column(
              children: [
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
                        'الإعدادات',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Translation section
                      _sectionTitle('الترجمة'),
                      GlassContainer(
                        child: Column(
                          children: [
                            _toggleTile(
                              icon: Icons.auto_awesome,
                              title: 'كشف اللغة تلقائياً',
                              subtitle: 'يكشف لغة المتحدث بدون ما تختارها',
                              value: state.autoDetectLanguage,
                              onChanged: (v) => state.setAutoDetect(v),
                            ),
                            _divider(),
                            _toggleTile(
                              icon: Icons.volume_up,
                              title: 'نطق الترجمة تلقائياً',
                              subtitle: 'ينطق الترجمة فور ما تجهز',
                              value: state.autoSpeak,
                              onChanged: (v) => state.setAutoSpeak(v),
                            ),
                            _divider(),
                            _toggleTile(
                              icon: Icons.speed,
                              title: 'ترجمة سريعة',
                              subtitle: 'أولوية للسرعة على الدقة',
                              value: state.fastMode,
                              onChanged: (v) => state.setFastMode(v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Overlay section
                      _sectionTitle('الزر العائم'),
                      GlassContainer(
                        child: Column(
                          children: [
                            _toggleTile(
                              icon: Icons.bubble_chart,
                              title: 'تشغيل تلقائي',
                              subtitle: 'يشغل الزر العائم عند فتح التطبيق',
                              value: state.autoStartOverlay,
                              onChanged: (v) => state.setAutoStartOverlay(v),
                            ),
                            _divider(),
                            _toggleTile(
                              icon: Icons.vibration,
                              title: 'اهتزاز',
                              subtitle: 'اهتزاز خفيف عند بدء/إيقاف الترجمة',
                              value: state.hapticFeedback,
                              onChanged: (v) => state.setHapticFeedback(v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Background section
                      _sectionTitle('الخلفية'),
                      GlassContainer(
                        child: Column(
                          children: [
                            _toggleTile(
                              icon: Icons.notifications,
                              title: 'إشعار الخلفية',
                              subtitle: 'عرض إشعار أثناء العمل بالخلفية',
                              value: state.showNotification,
                              onChanged: (v) => state.setShowNotification(v),
                            ),
                            _divider(),
                            _toggleTile(
                              icon: Icons.battery_saver,
                              title: 'توفير البطارية',
                              subtitle: 'تقليل استهلاك البطارية بالخلفية',
                              value: state.batterySaver,
                              onChanged: (v) => state.setBatterySaver(v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // About section
                      _sectionTitle('حول التطبيق'),
                      GlassContainer(
                        child: Column(
                          children: [
                            _infoTile(Icons.info_outline, 'الإصدار', '1.0.0'),
                            _divider(),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => const DeveloperScreen(),
                                  transitionsBuilder: (_, a, __, c) => SlideTransition(
                                    position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                                        .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                                    child: c,
                                  ),
                                  transitionDuration: const Duration(milliseconds: 350),
                                ),
                              ),
                              child: _infoTile(Icons.code, 'المطور', 'Hichamdzz'),
                            ),
                            _divider(),
                            _infoTile(Icons.update, 'آخر تحديث', '2026-03-30'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Update check
                      GestureDetector(
                        onTap: () => state.checkForUpdates(),
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF6366F1).withOpacity(0.15),
                              const Color(0xFF8B5CF6).withOpacity(0.05),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.system_update, color: Color(0xFF818CF8), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'التحقق من التحديثات',
                                style: TextStyle(color: Color(0xFF818CF8), fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
            ),
            child: Icon(icon, color: const Color(0xFF818CF8), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF8B5CF6),
            inactiveTrackColor: Colors.white.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
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
