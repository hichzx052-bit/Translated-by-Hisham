import 'package:flutter/material.dart';
import '../models/voice_model.dart';

class VoiceCard extends StatelessWidget {
  final VoiceModel voice;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onPreview;

  const VoiceCard({
    super.key,
    required this.voice,
    required this.isSelected,
    required this.onTap,
    this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.06),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.1),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.06),
              ),
              child: Icon(
                voice.gender == 'male' ? Icons.face : Icons.face_3,
                color: isSelected ? Colors.white : Colors.white54,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voice.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    voice.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (onPreview != null)
              GestureDetector(
                onTap: onPreview,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(isSelected ? 0.2 : 0.06),
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: isSelected ? Colors.white : Colors.white54,
                    size: 20,
                  ),
                ),
              ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle, color: Colors.white, size: 22),
              ),
          ],
        ),
      ),
    );
  }
}
