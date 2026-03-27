import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({Key? key}) : super(key: key);

  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isAuthenticated = false;
  bool _isError = false;
  
  static const String _devCode = 'Hichamdzz';

  void _authenticate() {
    if (_codeController.text == _devCode) {
      setState(() {
        _isAuthenticated = true;
        _isError = false;
      });
    } else {
      setState(() => _isError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        title: const Text('لوحة المطور 🔧'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isAuthenticated ? _buildDeveloperPanel() : _buildLoginPanel(),
    );
  }

  Widget _buildLoginPanel() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 60, color: Color(0xFF8B5CF6)),
            const SizedBox(height: 20),
            const Text(
              'أدخل كود المطور',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _codeController,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                hintText: 'الكود السري',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _isError ? Colors.red : Colors.transparent,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _isError ? Colors.red : Colors.white.withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                ),
              ),
              onSubmitted: (_) => _authenticate(),
            ),
            if (_isError)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('❌ كود خاطئ', style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _authenticate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('دخول', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperPanel() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard('معلومات التطبيق', [
          _infoRow('الاسم', 'Translated by Hisham'),
          _infoRow('الإصدار', '1.0.0'),
          _infoRow('البناء', '1'),
          _infoRow('الحزمة', 'com.hisham.translator'),
          _infoRow('المطور', 'Hicham ☬'),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('الإحصائيات', [
          _infoRow('عدد الترجمات', '0'),
          _infoRow('اللغات المستخدمة', '0'),
          _infoRow('وقت الاستخدام', '0 دقيقة'),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('API & التكامل', [
          _infoRow('GitHub Repo', 'Translated-by-Hisham'),
          _infoRow('نظام التحديث', 'GitHub Releases'),
          _infoRow('حالة الخدمة', '✅ نشط'),
        ]),
        const SizedBox(height: 16),
        _buildFeatureToggles(),
        const SizedBox(height: 16),
        _buildDangerZone(),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6))),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildFeatureToggles() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('التحكم بالميزات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6))),
          const SizedBox(height: 12),
          _featureToggle('الزر العائم', true),
          _featureToggle('الخدمة الخلفية', true),
          _featureToggle('التعرف التلقائي', true),
          _featureToggle('الوضع الثنائي', true),
          _featureToggle('وضع البث المباشر', true),
        ],
      ),
    );
  }

  Widget _featureToggle(String name, bool defaultValue) {
    return StatefulBuilder(
      builder: (context, setInnerState) {
        bool isOn = defaultValue;
        return SwitchListTile(
          title: Text(name, style: const TextStyle(color: Colors.white)),
          value: isOn,
          activeColor: const Color(0xFF8B5CF6),
          onChanged: (val) => setInnerState(() => isOn = val),
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('منطقة خطر ⚠️', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم مسح جميع البيانات')),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('مسح جميع البيانات', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }
}
