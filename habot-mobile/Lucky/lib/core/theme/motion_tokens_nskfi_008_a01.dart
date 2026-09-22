// NSKFI-008-A01 — Centralized Motion & Animation Timing Tokens.
// Provides MD3-compliant animation curves, durations, and reduced-motion accessibility support for Flutter transitions.

import 'package:flutter/material.dart';

/// Centralized motion configuration tokens driving application transition paths.
/// Implements Material Design 3 easing rules and respects `prefers-reduced-motion`.
class UdfMotionTokens {
  UdfMotionTokens._();

  // --- MD3 Standard Durations ---
  static const Duration short1 = Duration(milliseconds: 50);
  static const Duration short2 = Duration(milliseconds: 100);
  static const Duration short3 = Duration(milliseconds: 150);
  static const Duration short4 = Duration(milliseconds: 200);
  static const Duration medium1 = Duration(milliseconds: 250);
  static const Duration medium2 = Duration(milliseconds: 300);
  static const Duration medium3 = Duration(milliseconds: 350);
  static const Duration medium4 = Duration(milliseconds: 400);
  static const Duration long1 = Duration(milliseconds: 450);
  static const Duration long2 = Duration(milliseconds: 500);
  static const Duration long3 = Duration(milliseconds: 550);
  static const Duration long4 = Duration(milliseconds: 600);

  // --- MD3 Standard Easing Curves ---
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve standardAccelerate = Curves.easeInCubic;
  static const Curve standardDecelerate = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  static const Curve emphasizedAccelerate = Curves.easeInCubicEmphasized;
  static const Curve emphasizedDecelerate = Curves.easeOutCubicEmphasized;

  // --- Layout Transition Constraints ---
  /// Maximum allowed duration for layout transitions to ensure <200ms completion target.
  static const Duration maxLayoutTransition = short4; // 200ms

  /// Minimum touch perimeter as per MD3 guidelines.
  static const double minTouchPerimeter = 44.0;

  /// Returns the appropriate curve based on accessibility settings.
  /// If reduced motion is preferred, returns a linear instant-like step curve.
  static Curve getCurve(BuildContext context, Curve defaultCurve) {
    final bool isReducedMotion = MediaQuery.of(context).accessibleNavigation ||
        MediaQuery.of(context).disableAnimations;
    return isReducedMotion ? Curves.linear : defaultCurve;
  }

  /// Returns the appropriate duration based on accessibility settings.
  /// If reduced motion is preferred, instantly resolves to zero duration.
  static Duration getDuration(BuildContext context, Duration defaultDuration) {
    final bool isReducedMotion = MediaQuery.of(context).accessibleNavigation ||
        MediaQuery.of(context).disableAnimations;
    return isReducedMotion ? Duration.zero : defaultDuration;
  }

  /// Standard page route transition builder using high-performance attributes (opacity/transform).
  static PageRouteBuilder<T> createPageRoute<T>({
    required Widget page,
    required BuildContext context,
  }) {
    final duration = getDuration(context, medium1);
    final curve = getCurve(context, standardDecelerate);

    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Rely strictly on high-performance attributes (transform, opacity)
        final tween = Tween<Offset>(
          begin: const Offset(0.0, 0.05),
          end: Offset.zero,
        ).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: curve),
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }
}

/// A wrapper widget that applies standardized motion tokens to its child.
/// Ensures all expanded items fit cleanly within active responsive boundaries.
class MotionContainer extends StatelessWidget {
  const MotionContainer({
    super.key,
    required this.child,
    this.duration,
    this.curve,
  });

  final Widget child;
  final Duration? duration;
  final Curve? curve;

  @override
  Widget build(BuildContext context) {
    final effectiveDuration = duration != null
        ? UdfMotionTokens.getDuration(context, duration!)
        : UdfMotionTokens.getDuration(context, UdfMotionTokens.short4);
    final effectiveCurve = curve != null
        ? UdfMotionTokens.getCurve(context, curve!)
        : UdfMotionTokens.getCurve(context, UdfMotionTokens.standard);

    return AnimatedSwitcher(
      duration: effectiveDuration,
      switchInCurve: effectiveCurve,
      switchOutCurve: effectiveCurve,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Enforces a minimum 44px touch perimeter around data adjustment toggle elements.
class TouchTargetWrapper extends StatelessWidget {
  const TouchTargetWrapper({
    super.key,
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: UdfMotionTokens.minTouchPerimeter,
          minHeight: UdfMotionTokens.minTouchPerimeter,
        ),
        child: Center(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: child,
        ),
      ),
    );
  }
}