import 'package:flutter/material.dart';
import 'glass_container.dart';

class TranslationCard extends StatelessWidget {
  final String text;
  final String language;
  final String flag;
  final bool isSource;
  final VoidCallback? onCopy;
  final VoidCallback? onSpeak;

  const TranslationCard({
    super.key,
    required this.text,
    required this.language,
    required this.flag,
    this.isSource = true,
    this.onCopy,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isSource
            ? [
                const Color(0xFF6366F1).withOpacity(0.15),
                const Color(0xFF8B5CF6).withOpacity(0.05),
              ]
            : [
                const Color(0xFF10B981).withOpacity(0.15),
                const Color(0xFF059669).withOpacity(0.05),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                language,
                style: TextStyle(
                  color: isSource ? const Color(0xFF818CF8) : const Color(0xFF34D399),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (onSpeak != null)
                _actionButton(Icons.volume_up, onSpeak!),
              if (onCopy != null) ...[
                const SizedBox(width: 8),
                _actionButton(Icons.copy, onCopy!),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text.isEmpty
                ? (isSource ? 'ابدأ بالتحدث...' : 'الترجمة ستظهر هنا...')
                : text,
            style: TextStyle(
              color: text.isEmpty ? Colors.white38 : Colors.white.withOpacity(0.9),
              fontSize: 17,
              height: 1.6,
            ),
            textDirection: _isArabic(text) ? TextDirection.rtl : TextDirection.ltr,
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.08),
        ),
        child: Icon(icon, color: Colors.white54, size: 16),
      ),
    );
  }

  bool _isArabic(String text) {
    if (text.isEmpty) return true;
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
}
