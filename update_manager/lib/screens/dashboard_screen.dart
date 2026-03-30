import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';
import 'feature_manager_screen.dart';
import 'update_push_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _appEnabled = true;
  int _activeUsers = 0;
  String _currentVersion = '1.0.0';
  String _lastUpdate = '2026-03-29';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.dashboard, color: Color(0xFF06B6D4), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('لوحة التحكم',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Update Manager',
                          style: TextStyle(color: Color(0xFF06B6D4), fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  // App toggle
                  Column(
                    children: [
                      Text(
                        _appEnabled ? 'التطبيق شغّال' : 'التطبيق متوقف',
                        style: TextStyle(
                          color: _appEnabled ? const Color(0xFF22D3EE) : const Color(0xFFEF4444),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Switch.adaptive(
                        value: _appEnabled,
                        onChanged: (v) => setState(() => _appEnabled = v),
                        activeColor: const Color(0xFF06B6D4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Status cards
                  Row(
                    children: [
                      Expanded(child: _statusCard('الحالة',
                          _appEnabled ? 'نشط' : 'متوقف',
                          const Color(0xFF06B6D4))),
                      const SizedBox(width: 12),
                      Expanded(child: _statusCard('الإصدار', _currentVersion, const Color(0xFF8B5CF6))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _statusCard('آخر تحديث', _lastUpdate, const Color(0xFF10B981))),
                      const SizedBox(width: 12),
                      Expanded(child: _statusCard('المستخدمين', '$_activeUsers', const Color(0xFFF59E0B))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Connection status
                  _buildConnectionCard(),
                  const SizedBox(height: 16),
                  // Quick actions
                  const Text('الإجراءات',
                      style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _actionCard(
                    icon: Icons.extension,
                    title: 'إدارة الميزات',
                    subtitle: 'أضف أو عدّل ميزات التطبيق',
                    color: const Color(0xFF8B5CF6),
                    onTap: () => Navigator.push(context, _route(const FeatureManagerScreen())),
                  ),
                  const SizedBox(height: 10),
                  _actionCard(
                    icon: Icons.system_update,
                    title: 'إرسال تحديث',
                    subtitle: 'ادفع تحديث جديد للمستخدمين',
                    color: const Color(0xFF06B6D4),
                    onTap: () => Navigator.push(context, _route(const UpdatePushScreen())),
                  ),
                  const SizedBox(height: 10),
                  _actionCard(
                    icon: Icons.power_settings_new,
                    title: _appEnabled ? 'إيقاف التطبيق' : 'تشغيل التطبيق',
                    subtitle: _appEnabled
                        ? 'إيقاف التطبيق عند جميع المستخدمين'
                        : 'إعادة تشغيل التطبيق للمستخدمين',
                    color: _appEnabled ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    onTap: () => setState(() => _appEnabled = !_appEnabled),
                  ),
                  const SizedBox(height: 10),
                  _actionCard(
                    icon: Icons.analytics,
                    title: 'الإحصائيات',
                    subtitle: 'عرض إحصائيات الاستخدام',
                    color: const Color(0xFFF59E0B),
                    onTap: () {},
                  ),
                  const SizedBox(height: 30),
                  // Developer info
                  Center(
                    child: Text(
                      'Developer: Hichamdzz',
                      style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(String label, String value, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color.withOpacity(0.06),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 12)),
              const SizedBox(height: 6),
              Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AdminTheme.neonCard(color: const Color(0xFF06B6D4)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF06B6D4).withOpacity(0.1),
            ),
            child: const Icon(Icons.link, color: Color(0xFF06B6D4), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('الاتصال بالتطبيق الرئيسي',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                Text('متصل عبر API Key',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF10B981).withOpacity(0.15),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Color(0xFF10B981), size: 14),
                SizedBox(width: 4),
                Text('متصل', style: TextStyle(color: Color(0xFF10B981), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AdminTheme.neonCard(color: color, opacity: 0.05),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: color.withOpacity(0.1),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.5), size: 22),
          ],
        ),
      ),
    );
  }

  PageRoute _route(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, c) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
        child: c,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
