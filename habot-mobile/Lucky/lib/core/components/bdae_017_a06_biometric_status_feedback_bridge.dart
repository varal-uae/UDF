// BDAE-017-A06 — Biometric Verification Status Feedback Bridge.
// Renders a circular processing wheel only during active biometric evaluation; otherwise shows the provided child.
import 'package:flutter/material.dart';

/// A Material 3 overlay widget that displays a biometric verification
/// processing wheel only when [isEvaluating] is true.
///
/// The wheel is centered in the available layout lane and uses the theme's
/// primary color, with a scrim that respects system elevation.
class BiometricStatusFeedbackBridge extends StatelessWidget {
  const BiometricStatusFeedbackBridge({
    super.key,
    required this.isEvaluating,
    required this.child,
    this.semanticLabel = 'Verifying identity',
  });

  final bool isEvaluating;
  final Widget child;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        child,
        if (isEvaluating)
          Positioned.fill(
            child: ColoredBox(
              color: colorScheme.scrim.withValues(alpha: 0.3),
              child: Center(
                child: Semantics(
                  label: semanticLabel,
                  liveRegion: true,
                  child: SizedBox.square(
                    dimension: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: colorScheme.primary,
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
