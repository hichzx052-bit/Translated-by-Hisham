import 'package:flutter/material.dart';

class FloatingControls extends StatefulWidget {
  const FloatingControls({Key? key}) : super(key: key);

  @override
  State<FloatingControls> createState() => _FloatingControlsState();
}

class _FloatingControlsState extends State<FloatingControls> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isListening = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isExpanded)
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A3E).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🪶 هشوم',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildControlButton(
                      icon: _isListening ? Icons.stop : Icons.mic,
                      label: _isListening ? 'إيقاف' : 'استماع',
                      color: _isListening ? Colors.red : const Color(0xFF6366F1),
                      onTap: () {
                        setState(() => _isListening = !_isListening);
                      },
                    ),
                    _buildControlButton(
                      icon: Icons.language,
                      label: 'تغيير اللغة',
                      color: const Color(0xFF8B5CF6),
                      onTap: () {},
                    ),
                    _buildControlButton(
                      icon: Icons.record_voice_over,
                      label: 'تغيير الصوت',
                      color: const Color(0xFFA855F7),
                      onTap: () {},
                    ),
                    _buildControlButton(
                      icon: Icons.minimize,
                      label: 'تصغير',
                      color: Colors.grey,
                      onTap: _toggleExpand,
                    ),
                  ],
                ),
              ),
            ),
          // Main floating button
          GestureDetector(
            onTap: _toggleExpand,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🪶', style: TextStyle(fontSize: 26)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
