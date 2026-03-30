import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

class UpdatePushScreen extends StatefulWidget {
  const UpdatePushScreen({super.key});

  @override
  State<UpdatePushScreen> createState() => _UpdatePushScreenState();
}

class _UpdatePushScreenState extends State<UpdatePushScreen> {
  final _versionController = TextEditingController(text: '1.1.0');
  final _notesController = TextEditingController();
  bool _forceUpdate = false;
  bool _pushing = false;
  double _progress = 0;

  final List<_UpdateLog> _history = [
    _UpdateLog('1.0.0', '2026-03-15', 'الإصدار الأول — ترجمة صوتية + نصية', true),
    _UpdateLog('1.0.1', '2026-03-20', 'إصلاح أخطاء + تحسين الأداء', true),
  ];

  void _pushUpdate() async {
    if (_versionController.text.isEmpty) return;
    setState(() { _pushing = true; _progress = 0; });

    for (int i = 0; i <= 100; i += 2) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) setState(() => _progress = i / 100);
    }

    setState(() {
      _pushing = false;
      _history.insert(0, _UpdateLog(
        _versionController.text,
        '2026-03-29',
        _notesController.text.isEmpty ? 'تحديث جديد' : _notesController.text,
        true,
      ));
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم إرسال التحديث بنجاح!'), backgroundColor: Color(0xFF10B981)),
      );
      _notesController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
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
                  const Text('إرسال تحديث',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Version input
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AdminTheme.neonCard(color: const Color(0xFF06B6D4)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('تحديث جديد', style: TextStyle(color: Color(0xFF06B6D4), fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        // Version
                        const Text('رقم الإصدار', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _versionController,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.04),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: const Color(0xFF06B6D4).withOpacity(0.15)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: const Color(0xFF06B6D4).withOpacity(0.1)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Notes
                        const Text('ملاحظات التحديث', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'وصف التغييرات...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.04),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Force update toggle
                        Row(
                          children: [
                            Icon(Icons.warning_amber, color: const Color(0xFFF59E0B).withOpacity(0.7), size: 18),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text('تحديث إجباري',
                                style: TextStyle(color: Colors.white70, fontSize: 13)),
                            ),
                            Switch.adaptive(
                              value: _forceUpdate,
                              onChanged: (v) => setState(() => _forceUpdate = v),
                              activeColor: const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Progress
                  if (_pushing) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AdminTheme.neonCard(color: const Color(0xFF8B5CF6)),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 16, height: 16,
                                child: CircularProgressIndicator(color: Color(0xFF8B5CF6), strokeWidth: 2)),
                              const SizedBox(width: 10),
                              const Text('جاري الإرسال...', style: TextStyle(color: Colors.white, fontSize: 14)),
                              const Spacer(),
                              Text('${(_progress * 100).toInt()}%',
                                style: const TextStyle(color: Color(0xFF8B5CF6), fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _progress,
                              backgroundColor: Colors.white.withOpacity(0.06),
                              valueColor: const AlwaysStoppedAnimation(Color(0xFF8B5CF6)),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Push button
                  GestureDetector(
                    onTap: _pushing ? null : _pushUpdate,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: _pushing ? null : AdminTheme.neonGradient,
                        color: _pushing ? Colors.white.withOpacity(0.06) : null,
                        boxShadow: _pushing ? null : [
                          BoxShadow(
                            color: const Color(0xFF06B6D4).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _pushing ? 'جاري الإرسال...' : 'إرسال التحديث',
                          style: TextStyle(
                            color: _pushing ? Colors.white38 : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // History
                  const Text('سجل التحديثات',
                    style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  ...List.generate(_history.length, (i) {
                    final h = _history[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: AdminTheme.neonCard(
                          color: i == 0 ? const Color(0xFF10B981) : const Color(0xFF6B7280),
                          opacity: 0.03,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: const Color(0xFF06B6D4).withOpacity(0.1),
                              ),
                              child: Text('v${h.version}',
                                style: const TextStyle(color: Color(0xFF06B6D4), fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(h.notes, style: const TextStyle(color: Colors.white, fontSize: 13)),
                                  Text(h.date, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
                                ],
                              ),
                            ),
                            Icon(
                              h.success ? Icons.check_circle : Icons.error,
                              color: h.success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _versionController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class _UpdateLog {
  final String version;
  final String date;
  final String notes;
  final bool success;
  _UpdateLog(this.version, this.date, this.notes, this.success);
}
