import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F0F23),
          appBar: AppBar(
            title: const Text('الإعدادات'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection('عام', [
                _buildSwitchTile(
                  'الوضع الثنائي',
                  'ترجمة ثنائية الاتجاه',
                  Icons.sync_alt,
                  appState.isDualMode,
                  (val) => appState.toggleDualMode(),
                ),
                _buildSwitchTile(
                  'التعرف التلقائي',
                  'اكتشاف اللغة تلقائياً',
                  Icons.auto_awesome,
                  appState.autoDetectLanguage,
                  (val) => appState.toggleAutoDetect(),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSection('الصوت', [
                _buildNavTile(
                  'اختيار الصوت',
                  'اختر صوت الترجمة المفضل',
                  Icons.record_voice_over,
                  () => Navigator.pushNamed(context, '/voice-selection'),
                ),
                _buildSliderTile(
                  'سرعة الكلام',
                  Icons.speed,
                  appState.speechRate,
                  0.1,
                  2.0,
                  (val) => appState.setSpeechRate(val),
                ),
                _buildSliderTile(
                  'حدة الصوت',
                  Icons.tune,
                  appState.pitch,
                  0.5,
                  2.0,
                  (val) => appState.setPitch(val),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSection('متقدم', [
                _buildNavTile(
                  'وضع البث المباشر',
                  'إعدادات الترجمة في اللايفات',
                  Icons.live_tv,
                  () => Navigator.pushNamed(context, '/live-mode'),
                ),
                _buildNavTile(
                  'لوحة المطور',
                  'إعدادات المطور',
                  Icons.developer_mode,
                  () => Navigator.pushNamed(context, '/developer'),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSection('حول', [
                _buildInfoTile('الإصدار', '1.0.0', Icons.info_outline),
                _buildInfoTile('المطور', 'Hisham 🪶', Icons.person),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, right: 4),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B5CF6),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8B5CF6)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF8B5CF6),
      ),
    );
  }

  Widget _buildNavTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8B5CF6)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white30),
      onTap: onTap,
    );
  }

  Widget _buildSliderTile(String title, IconData icon, double value, double min, double max, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.white)),
              const Spacer(),
              Text(value.toStringAsFixed(1), style: const TextStyle(color: Colors.white54)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: const Color(0xFF8B5CF6),
            inactiveColor: Colors.white12,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8B5CF6)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Text(value, style: const TextStyle(color: Colors.white54)),
    );
  }
}
