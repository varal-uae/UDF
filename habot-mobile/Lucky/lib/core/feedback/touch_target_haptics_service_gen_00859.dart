// GEN-00859 — Service & Wrapper Widget standardizing 48x48dp Touch Targets & MD3 Haptics

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../accessibility/touch_target_model_gen_00859.dart';

/// Helper service providing standard MD3 sensory feedback
class TouchTargetHapticsServiceGen00859 {
  TouchTargetHapticsServiceGen00859._();

  /// Trigger haptic feedback corresponding to MD3 interaction level
  static Future<void> trigger(HapticFeedbackProfile profile) async {
    switch (profile) {
      case HapticFeedbackProfile.selection:
        await HapticFeedback.selectionClick();
        break;
      case HapticFeedbackProfile.lightImpact:
        await HapticFeedback.lightImpact();
        break;
      case HapticFeedbackProfile.mediumImpact:
        await HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackProfile.heavyImpact:
        await HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackProfile.success:
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 60));
        await HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackProfile.error:
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.heavyImpact();
        break;
    }
  }
}

/// Reusable component enforcing min 48x48dp target bounding box with haptic trigger
class AccessibleTouchTargetGen00859 extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final HapticFeedbackProfile hapticProfile;
  final double minTouchTargetSize;

  const AccessibleTouchTargetGen00859({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.hapticProfile = HapticFeedbackProfile.selection,
    this.minTouchTargetSize = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minTouchTargetSize,
          minHeight: minTouchTargetSize,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap == null
              ? null
              : () {
                  TouchTargetHapticsServiceGen00859.trigger(hapticProfile);
                  onTap!();
                },
          onLongPress: onLongPress == null
              ? null
              : () {
                  TouchTargetHapticsServiceGen00859.trigger(HapticFeedbackProfile.mediumImpact);
                  onLongPress!();
                },
          child: Center(
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: child,
          ),
        ),
      ),
    );
  }
}
