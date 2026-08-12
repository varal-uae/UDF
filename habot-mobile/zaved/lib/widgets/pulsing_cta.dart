import 'package:flutter/material.dart';

/// Custom CTA button that gently pulses continuously to draw user focus.
class PulsingCTA extends StatefulWidget {
  const PulsingCTA({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  State<PulsingCTA> createState() => _PulsingCTAState();
}

class _PulsingCTAState extends State<PulsingCTA>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Subtle scaling pulse between 1.0 and 1.06
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Continuous reverse looping pulse
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FilledButton.icon(
        onPressed: widget.onPressed,
        icon: widget.icon != null ? Icon(widget.icon) : null,
        label: Text(
          widget.label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        ),
      ),
    );
  }
}
