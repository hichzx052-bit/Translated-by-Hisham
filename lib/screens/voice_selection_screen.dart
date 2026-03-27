import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/voice_model.dart';
import '../widgets/voice_card.dart';

class VoiceSelectionScreen extends StatelessWidget {
  const VoiceSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F0F23),
          appBar: AppBar(
            title: const Text('اختيار الصوت 🎙️'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: appState.availableVoices.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                      SizedBox(height: 16),
                      Text('جاري تحميل الأصوات...', style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appState.availableVoices.length,
                  itemBuilder: (context, index) {
                    final voice = appState.availableVoices[index];
                    final isSelected = appState.selectedVoice?.name == voice.name;
                    return VoiceCard(
                      voice: voice,
                      isSelected: isSelected,
                      onSelect: () => appState.selectVoice(voice),
                      onPreview: () => appState.previewVoice(voice),
                    );
                  },
                ),
        );
      },
    );
  }
}
