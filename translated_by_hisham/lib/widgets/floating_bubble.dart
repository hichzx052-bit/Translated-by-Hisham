import 'package:flutter/material.dart';
import '../services/overlay_service.dart';

class FloatingBubble extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isActive;

  const FloatingBubble({
    super.key,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => OverlayService.showOverlay(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: isActive
                ? [const Color(0xFF10B981), const Color(0xFF059669)]
                : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
          ),
          boxShadow: [
            BoxShadow(
              color: (isActive ? const Color(0xFF10B981) : const Color(0xFF8B5CF6))
                  .withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.stop_circle : Icons.play_circle_fill,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              isActive ? 'إيقاف الزر العائم' : 'تشغيل الزر العائم',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
