import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

class FeatureManagerScreen extends StatefulWidget {
  const FeatureManagerScreen({super.key});

  @override
  State<FeatureManagerScreen> createState() => _FeatureManagerScreenState();
}

class _FeatureManagerScreenState extends State<FeatureManagerScreen> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final List<_Feature> _features = [
    _Feature('voice_translation', 'ترجمة صوتية', true, '1.0.0'),
    _Feature('text_translation', 'ترجمة نصية', true, '1.0.0'),
    _Feature('live_mode', 'وضع البث المباشر', true, '1.0.0'),
    _Feature('video_translation', 'ترجمة فيديو', false, '1.1.0'),
    _Feature('floating_bubble', 'الزر العائم', true, '1.0.0'),
  ];
  bool _pushing = false;

  void _addFeature() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF12121F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text('إضافة ميزة جديدة',
                style: TextStyle(color: Color(0xFF06B6D4), fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _inputField(_nameController, 'اسم الميزة', Icons.label),
              const SizedBox(height: 12),
              _inputField(_codeController, 'كود البرمجة', Icons.code, maxLines: 5),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  if (_nameController.text.isNotEmpty) {
                    setState(() {
                      _features.add(_Feature(
                        _nameController.text.toLowerCase().replaceAll(' ', '_'),
                        _nameController.text,
                        false,
                        'جديد',
                      ));
                    });
                    _nameController.clear();
                    _codeController.clear();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ تم إضافة الميزة'), backgroundColor: Color(0xFF10B981)),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: AdminTheme.neonGradient,
                  ),
                  child: const Center(
                    child: Text('إضافة', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _pushFeatures() async {
    setState(() => _pushing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _pushing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم دفع الميزات للتطبيق الرئيسي'), backgroundColor: Color(0xFF10B981)),
      );
    }
  }

  Widget _inputField(TextEditingController ctrl, String hint, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
        prefixIcon: maxLines == 1 ? Icon(icon, color: const Color(0xFF06B6D4).withOpacity(0.5)) : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: const Color(0xFF06B6D4).withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: const Color(0xFF06B6D4).withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF06B6D4)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFeature,
        backgroundColor: const Color(0xFF06B6D4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
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
                  const Text('إدارة الميزات',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  GestureDetector(
                    onTap: _pushing ? null : _pushFeatures,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: AdminTheme.neonGradient,
                      ),
                      child: _pushing
                          ? const SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('دفع', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _features.length,
                itemBuilder: (context, index) {
                  final f = _features[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AdminTheme.neonCard(
                        color: f.enabled ? const Color(0xFF10B981) : const Color(0xFF6B7280),
                        opacity: 0.04,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: (f.enabled ? const Color(0xFF10B981) : const Color(0xFF6B7280)).withOpacity(0.1),
                            ),
                            child: Icon(Icons.extension,
                              color: f.enabled ? const Color(0xFF10B981) : const Color(0xFF6B7280), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                                Text('v${f.version}', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: f.enabled,
                            onChanged: (v) => setState(() => f.enabled = v),
                            activeColor: const Color(0xFF10B981),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}

class _Feature {
  final String id;
  final String name;
  bool enabled;
  final String version;
  _Feature(this.id, this.name, this.enabled, this.version);
}
