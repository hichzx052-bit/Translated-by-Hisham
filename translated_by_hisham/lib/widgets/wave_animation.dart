import 'dart:math';
import 'package:flutter/material.dart';

class WaveAnimation extends StatefulWidget {
  final bool isActive;
  final Color color;
  final double height;

  const WaveAnimation({
    super.key,
    this.isActive = false,
    this.color = const Color(0xFF8B5CF6),
    this.height = 60,
  });

  @override
  State<WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _WavePainter(
            animationValue: _controller.value,
            isActive: widget.isActive,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;
  final bool isActive;
  final Color color;
  final Random _random = Random(42);

  _WavePainter({
    required this.animationValue,
    required this.isActive,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = 40;
    final barWidth = size.width / barCount - 2;
    final maxHeight = size.height;
    final centerY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + 2);
      double barHeight;

      if (isActive) {
        final wave = sin((animationValue * 2 * pi) + (i * 0.3));
        final noise = _random.nextDouble() * 0.3;
        barHeight = (wave.abs() + noise) * maxHeight * 0.8;
        barHeight = barHeight.clamp(4.0, maxHeight * 0.9);
      } else {
        barHeight = 4.0;
      }

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            color.withOpacity(0.4),
            color,
            color.withOpacity(0.8),
          ],
        ).createShader(Rect.fromLTWH(x, centerY - barHeight / 2, barWidth, barHeight));

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + barWidth / 2, centerY),
          width: barWidth,
          height: barHeight,
        ),
        const Radius.circular(3),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      animationValue != oldDelegate.animationValue ||
      isActive != oldDelegate.isActive;
}
