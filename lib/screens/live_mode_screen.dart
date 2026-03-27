import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/overlay_service.dart';
import '../services/background_service.dart';

class LiveModeScreen extends StatefulWidget {
  const LiveModeScreen({Key? key}) : super(key: key);

  @override
  State<LiveModeScreen> createState() => _LiveModeScreenState();
}

class _LiveModeScreenState extends State<LiveModeScreen> {
  bool _isLiveActive = false;
  bool _translateIncoming = true;
  bool _translateOutgoing = true;
  bool _overlayActive = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F0F23),
          appBar: AppBar(
            title: const Text('وضع البث المباشر 📺'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatusCard(),
              const SizedBox(height: 16),
              _buildModeCard(appState),
              const SizedBox(height: 16),
              _buildOptionsCard(),
              const SizedBox(height: 16),
              _buildInstructionsCard(),
              const SizedBox(height: 24),
              _buildStartButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isLiveActive
              ? [const Color(0xFF10B981).withOpacity(0.2), const Color(0xFF059669).withOpacity(0.2)]
              : [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.03)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isLiveActive ? const Color(0xFF10B981) : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isLiveActive ? const Color(0xFF10B981) : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _isLiveActive ? 'البث المباشر نشط' : 'البث المباشر متوقف',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isLiveActive ? const Color(0xFF10B981) : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('أوضاع الترجمة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6))),
          const SizedBox(height: 12),
          _buildOption(
            'ترجمة ما أسمعه',
            'ترجم كلام الطرف الثاني إلى لغتي',
            Icons.hearing,
            _translateIncoming,
            (val) => setState(() => _translateIncoming = val),
          ),
          const Divider(color: Colors.white10),
          _buildOption(
            'ترجمة ما أقوله',
            'ترجم كلامي إلى لغة الطرف الثاني',
            Icons.campaign,
            _translateOutgoing,
            (val) => setState(() => _translateOutgoing = val),
          ),
          const Divider(color: Colors.white10),
          _buildOption(
            'الزر العائم',
            'إظهار أدوات التحكم فوق التطبيقات',
            Icons.layers,
            _overlayActive,
            (val) async {
              if (val) {
                await OverlayService.showOverlay();
              } else {
                await OverlayService.closeOverlay();
              }
              setState(() => _overlayActive = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      secondary: Icon(icon, color: const Color(0xFF8B5CF6)),
      value: value,
      activeColor: const Color(0xFF8B5CF6),
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildOptionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('تعليمات الاستخدام', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6))),
          const SizedBox(height: 12),
          _instructionStep('1', 'فعّل الزر العائم'),
          _instructionStep('2', 'افتح التطبيق المطلوب (تيك توك، لعبة، إلخ)'),
          _instructionStep('3', 'اضغط على الزر العائم 🪶'),
          _instructionStep('4', 'اختر اللغات وابدأ الترجمة'),
          _instructionStep('5', 'الترجمة تعمل تلقائياً في الخلفية'),
        ],
      ),
    );
  }

  Widget _instructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF6366F1),
            ),
            child: Center(
              child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFFF59E0B)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'للحصول على أفضل نتائج، استخدم سماعات وتأكد من وضوح الصوت',
              style: TextStyle(color: Color(0xFFF59E0B), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          if (_isLiveActive) {
            await BackgroundServiceManager.stopService();
            await OverlayService.closeOverlay();
          } else {
            await BackgroundServiceManager.startService();
            if (_overlayActive) {
              await OverlayService.showOverlay();
            }
          }
          setState(() => _isLiveActive = !_isLiveActive);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _isLiveActive ? const Color(0xFFEF4444) : const Color(0xFF6366F1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          _isLiveActive ? 'إيقاف البث 🛑' : 'بدء البث المباشر 🪶',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
