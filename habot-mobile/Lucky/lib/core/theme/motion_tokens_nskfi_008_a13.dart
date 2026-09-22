// NSKFI-008-A13 — Centralized Motion Configuration Tokens and Animation Utilities.
// Provides MD3-compliant easing curves, duration tokens, reduced-motion accessibility support, and performance benchmarking for UI transitions in Flutter.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Centralized motion configuration tokens driving application transition paths.
/// All custom interface animations must utilize tokens from this library.
/// Rely strictly on high-performance properties (transform, opacity) to avoid unnecessary layout recalculations.
class MotionTokens {
  const MotionTokens._();

  // --- Duration Tokens ---
  /// Ceiling boundary: Under 100ms, perceived as instantaneous per Nielsen Norman 0.1s rule.
  static const Duration instant = Duration(milliseconds: 50);

  /// Optimal target: Under 200ms, smooth and perceptibly responsive per Material Motion guidance.
  static const Duration short = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 200);

  /// Floor boundary: Under 300ms (upper bound of Google's RAIL 'response' threshold).
  static const Duration long = Duration(milliseconds: 300);

  // --- MD3 Easing Curves ---
  /// Standard MD3 easing rules across layout components.
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve standardAccelerate = Curves.easeInCubic;
  static const Curve standardDecelerate = Curves.easeOutCubic;

  /// For elements entering the screen.
  static const Curve emphasized = Curves.easeOutQuart;
  static const Curve emphasizedAccelerate = Curves.easeInQuart;
  static const Curve emphasizedDecelerate = Curves.easeOutQuart;

  /// Linear fallback for specific continuous animations.
  static const Curve linear = Curves.linear;

  /// Instant shift curve used when prefers-reduced-motion is active.
  static const Curve instantShift = _InstantCurve();
}

/// A custom curve that instantly jumps to 1.0, converting all transitions into instant style shifts.
class _InstantCurve extends Curve {
  const _InstantCurve();

  @override
  double transform(double t) => t > 0.0 ? 1.0 : 0.0;
}

/// Resolves animation parameters based on device accessibility settings.
/// Mistake-Proofing (Poka-Yoke): If a device signals a preference for reduced motion,
/// it instantly converts all transitions into instant style shifts.
class MotionResolver {
  const MotionResolver._();

  /// Returns the appropriate duration respecting [MediaQueryData.accessibleNavigation]
  /// and platform dispatcher settings for reduced motion.
  static Duration resolveDuration(BuildContext context, Duration baseDuration) {
    final bool prefersReducedMotion = _prefersReducedMotion(context);
    return prefersReducedMotion ? Duration.zero : baseDuration;
  }

  /// Returns the appropriate curve respecting reduced motion preferences.
  static Curve resolveCurve(BuildContext context, Curve baseCurve) {
    final bool prefersReducedMotion = _prefersReducedMotion(context);
    return prefersReducedMotion ? MotionTokens.instantShift : baseCurve;
  }

  static bool _prefersReducedMotion(BuildContext context) {
    // Check MediaQuery for accessible navigation / reduced motion flags
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery?.accessibleNavigation == true) {
      return true;
    }
    // Fallback to platform dispatcher
    return SchedulerBinding.instance.platformDispatcher.accessibilityFeatures.reduceMotion;
  }
}

/// Standardized page route transitions maintaining a clean 1:1 match between
/// physical user inputs and on-screen animation paths.
class MotionPageRoute<T> extends PageRouteBuilder<T> {
  MotionPageRoute({
    required super.builder,
    super.settings,
    super.transitionDuration = MotionTokens.medium,
    super.reverseTransitionDuration = MotionTokens.short,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = MotionResolver.resolveCurve(context, MotionTokens.emphasizedDecelerate);
            final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

            // Slide in from right boundary without altering surrounding data card positions
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: curvedAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Automated performance test metrics structure to measure UI frame rates
/// during view transition sequences.
class InteractionLatencyMetric {
  final String testType;
  final String testResult; // 'Good', 'Average', 'Poor'
  final double testCoverage;
  final DateTime testTimestamp;
  final String testLogPath;
  final int latencyMs;
  final String userId;
  final String sessionId;
  final bool completionStatus;

  const InteractionLatencyMetric({
    required this.testType,
    required this.testResult,
    required this.testCoverage,
    required this.testTimestamp,
    required this.testLogPath,
    required this.latencyMs,
    required this.userId,
    required this.sessionId,
    required this.completionStatus,
  });

  Map<String, dynamic> toJson() => {
        'Test Type': testType,
        'Test Result': testResult,
        'Test Coverage': testCoverage,
        'Test Timestamp': testTimestamp.toIso8601String(),
        'Test Log Path': testLogPath,
        'Interaction Latency (ms)': latencyMs,
        'User/Session ID': '$userId/$sessionId',
        'Completion Status': testResult,
        'Action/Event Timestamp': testTimestamp.millisecondsSinceEpoch,
      };
}

/// Mock repository providing local data for telemetry and performance testing.
/// Backend & Mock Data Rule: Supply realistic local mock data directly.
class MockMotionTelemetryRepository {
  const MockMotionTelemetryRepository._();

  static List<InteractionLatencyMetric> fetchMockMetrics() {
    return [
      InteractionLatencyMetric(
        testType: 'View Transition Frame Rate',
        testResult: 'Good',
        testCoverage: 1.0,
        testTimestamp: DateTime(2026, 9, 22, 10, 0),
        testLogPath: '/logs/motion/nskfi_008_a13_run_01.log',
        latencyMs: 145, // Under 200ms optimal target
        userId: 'user_udf_001',
        sessionId: 'sess_abc_123',
        completionStatus: true,
      ),
      InteractionLatencyMetric(
        testType: 'Detail Panel Slide-In',
        testResult: 'Good',
        testCoverage: 0.95,
        testTimestamp: DateTime(2026, 9, 22, 10, 5),
        testLogPath: '/logs/motion/nskfi_008_a13_run_02.log',
        latencyMs: 180, // Under 200ms optimal target
        userId: 'user_udf_002',
        sessionId: 'sess_def_456',
        completionStatus: true,
      ),
      InteractionLatencyMetric(
        testType: 'Snackbar Fade Duration',
        testResult: 'Average',
        testCoverage: 0.88,
        testTimestamp: DateTime(2026, 9, 22, 10, 10),
        testLogPath: '/logs/motion/nskfi_008_a13_run_03.log',
        latencyMs: 240, // Between 200ms and 300ms floor boundary
        userId: 'user_udf_003',
        sessionId: 'sess_ghi_789',
        completionStatus: true,
      ),
    ];
  }

  /// Evaluates metric against RAIL model boundaries.
  static String evaluatePerformance(int latencyMs) {
    if (latencyMs < 100) return 'Good'; // Ceiling: Instantaneous
    if (latencyMs < 200) return 'Good'; // Optimal: Smooth
    if (latencyMs < 300) return 'Average'; // Floor: Acceptable
    return 'Poor'; // Exceeds RAIL response threshold
  }
}

/// Widget wrapper ensuring all expanded items fit cleanly within active responsive boundaries
/// while applying standardized motion tokens.
class AnimatedMotionContainer extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedMotionContainer({
    super.key,
    required this.child,
    this.duration = MotionTokens.medium,
    this.curve = MotionTokens.standard,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedDuration = MotionResolver.resolveDuration(context, duration);
    final resolvedCurve = MotionResolver.resolveCurve(context, curve);

    return AnimatedSwitcher(
      duration: resolvedDuration,
      switchInCurve: resolvedCurve,
      switchOutCurve: resolvedCurve,
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Rely strictly on high-performance attributes (transform, opacity)
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