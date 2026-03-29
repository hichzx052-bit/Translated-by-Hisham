import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/voice_model.dart';
import '../widgets/voice_card.dart';
import '../widgets/glass_container.dart';

class VoiceSelectionScreen extends StatelessWidget {
  const VoiceSelectionScreen({super.key});

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
                        'اختيار الصوت',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Current voice preview
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassContainer(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.15),
                        const Color(0xFF8B5CF6).withOpacity(0.05),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                          ),
                          child: Icon(
                            state.selectedVoice.gender == 'male' ? Icons.face : Icons.face_3,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('الصوت الحالي',
                                  style: TextStyle(color: Colors.white54, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(
                                state.selectedVoice.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => state.speakText('مرحباً، هذا صوت الترجمة', 'ar'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                            child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Voices list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'الأصوات المتاحة',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: VoiceModel.availableVoices.length,
                    itemBuilder: (context, index) {
                      final voice = VoiceModel.availableVoices[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: VoiceCard(
                          voice: voice,
                          isSelected: voice.id == state.selectedVoice.id,
                          onTap: () => state.setVoice(voice),
                          onPreview: () => state.speakText(
                            'مرحباً، هذا صوت ${voice.name}',
                            'ar',
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
      },
    );
  }
}
