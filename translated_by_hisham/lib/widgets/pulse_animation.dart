import 'package:flutter/material.dart';

class PulseAnimation extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Color color;
  final double maxScale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.isActive = false,
    this.color = const Color(0xFF8B5CF6),
    this.maxScale = 1.5,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isActive) _controller.repeat();
  }

  @override
  void didUpdateWidget(PulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
      _controller.reset();
    }
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
        return Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isActive) ...[
              // Outer pulse ring
              Transform.scale(
                scale: 1.0 + (_controller.value * (widget.maxScale - 1.0)),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withOpacity(1.0 - _controller.value),
                      width: 2,
                    ),
                  ),
                ),
              ),
              // Middle pulse ring
              Transform.scale(
                scale: 1.0 + (_controller.value * (widget.maxScale - 1.0) * 0.7),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity((1.0 - _controller.value) * 0.15),
                  ),
                ),
              ),
            ],
            widget.child,
          ],
        );
      },
    );
  }
}
