// BDAE-004 — Haptic Feedback Integration for Triangular Checks.
// A Material 3 haptic wrapper that binds native OS haptic drivers and triggers
// deterministic feedback when a triangular check control is tapped or focused.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps a triangular check control and fires native haptic feedback on tap.
class Bdae004HapticWrapper extends StatelessWidget {
  const Bdae004HapticWrapper({
    super.key,
    required this.child,
    this.hapticType = HapticType.lightImpact,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final HapticType hapticType;
  final VoidCallback? onTap;
  final String? semanticLabel;

  Future<void> _triggerHaptic() async {
    switch (hapticType) {
      case HapticType.lightImpact:
        await HapticFeedback.lightImpact();
        break;
      case HapticType.mediumImpact:
        await HapticFeedback.mediumImpact();
        break;
      case HapticType.heavyImpact:
        await HapticFeedback.heavyImpact();
        break;
      case HapticType.selectionClick:
        await HapticFeedback.selectionClick();
        break;
      case HapticType.vibrate:
        await HapticFeedback.vibrate();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _triggerHaptic();
          onTap?.call();
        },
        child: child,
      ),
    );
  }
}

enum HapticType { lightImpact, mediumImpact, heavyImpact, selectionClick, vibrate }