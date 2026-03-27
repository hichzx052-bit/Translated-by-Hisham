import 'package:flutter/material.dart';
import '../models/voice_model.dart';

class VoiceCard extends StatelessWidget {
  final VoiceModel voice;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onPreview;

  const VoiceCard({
    Key? key,
    required this.voice,
    required this.isSelected,
    required this.onSelect,
    required this.onPreview,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF6366F1).withOpacity(0.15)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.08),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSelected
                  ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                  : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            voice.gender == 'male' ? Icons.person : Icons.person_outline,
            color: isSelected ? Colors.white : Colors.white54,
          ),
        ),
        title: Text(
          voice.displayName,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          '${voice.languageName} • ${voice.gender == "male" ? "ذكر" : "أنثى"}',
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_circle_outline, color: Color(0xFF8B5CF6)),
              onPressed: onPreview,
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF8B5CF6))
            else
              GestureDetector(
                onTap: onSelect,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF6366F1)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('اختر', style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
