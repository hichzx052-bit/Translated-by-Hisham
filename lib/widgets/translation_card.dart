import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TranslationCard extends StatelessWidget {
  final String title;
  final String text;
  final bool isPlaceholder;
  final IconData icon;
  final String? detectedLanguage;
  final VoidCallback? onPlayAudio;

  const TranslationCard({
    Key? key,
    required this.title,
    required this.text,
    this.isPlaceholder = false,
    required this.icon,
    this.detectedLanguage,
    this.onPlayAudio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF8B5CF6), size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              if (detectedLanguage != null && detectedLanguage!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '🔍 $detectedLanguage',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ),
              ],
              const Spacer(),
              if (!isPlaceholder) ...[
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم النسخ ✅'), duration: Duration(seconds: 1)),
                    );
                  },
                  child: const Icon(Icons.copy, color: Colors.white24, size: 16),
                ),
                if (onPlayAudio != null) ...[
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onPlayAudio,
                    child: const Icon(Icons.volume_up, color: Color(0xFF8B5CF6), size: 18),
                  ),
                ],
              ],
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                text,
                style: TextStyle(
                  color: isPlaceholder ? Colors.white24 : Colors.white,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
