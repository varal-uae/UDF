// GEN-00483 — ScrimOverlay Form Submission Gate.
// Connects a scrim overlay to form submission: activates on submit, releases on response.

import 'package:flutter/material.dart';

class ScrimOverlayFormGate extends StatefulWidget {
  const ScrimOverlayFormGate({
    super.key,
    required this.onSubmit,
    required this.builder,
    this.scrimOpacity = 0.5,
  });

  final Future<void> Function() onSubmit;
  final Widget Function(VoidCallback onSubmit) builder;
  final double scrimOpacity;

  @override
  State<ScrimOverlayFormGate> createState() => _ScrimOverlayFormGateState();
}

class _ScrimOverlayFormGateState extends State<ScrimOverlayFormGate> {
  bool _isSubmitting = false;

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        widget.builder(_handleSubmit),
        if (_isSubmitting)
          Positioned.fill(
            child: AbsorbPointer(
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  color: colorScheme.scrim.withOpacity(widget.scrimOpacity),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
