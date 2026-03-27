import 'package:flutter/material.dart';

class PulseAnimation extends StatelessWidget {
  final AnimationController controller;
  final bool isActive;
  final Widget child;

  const PulseAnimation({
    Key? key,
    required this.controller,
    required this.isActive,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isActive) return child;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse
            Container(
              width: 80 + (30 * controller.value),
              height: 80 + (30 * controller.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF4444).withOpacity(0.15 * (1 - controller.value)),
              ),
            ),
            // Inner pulse
            Container(
              width: 80 + (15 * controller.value),
              height: 80 + (15 * controller.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF4444).withOpacity(0.1 * (1 - controller.value)),
              ),
            ),
            child,
          ],
        );
      },
    );
  }
}
