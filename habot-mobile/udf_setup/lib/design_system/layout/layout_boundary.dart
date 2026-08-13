/// AISS: RCGLA-032-A01 -- the MD3 adaptive 4-column fluid layout token engine.
///
/// Substep 2: "Implement an automated viewport listener that flags any element
///             trying to split into more than 4 vertical segments on mobile."
/// Substep 3: "Wrap all application view components inside a global layout
///             boundary container component."
///
/// Two behaviours, deliberately different by build mode:
///   * debug   -> a violation throws, so it is caught during development
///   * release -> the span is clamped and the violation reported, so a
///                production user never sees a broken layout
library;

import 'package:flutter/widgets.dart';

import '../tokens/grid_tokens.dart';

/// One recorded attempt to exceed the segment limit.
@immutable
class SegmentViolation {
  const SegmentViolation({
    required this.requestedSegments,
    required this.allowedSegments,
    required this.viewportWidth,
    required this.origin,
  });

  final int requestedSegments;
  final int allowedSegments;
  final double viewportWidth;
  final String origin;

  @override
  String toString() =>
      'SegmentViolation($origin: requested $requestedSegments, '
      'allowed $allowedSegments at ${viewportWidth.toStringAsFixed(0)}dp)';
}

/// The viewport listener RCGLA-032 substep 2 asks for.
///
/// Static rather than instance state because it has to be reachable from any
/// widget's build without threading a reference through the tree, and because
/// the gate needs to inspect it after a pump.
class LayoutBoundaryReporter {
  LayoutBoundaryReporter._();

  static final List<SegmentViolation> _violations = <SegmentViolation>[];

  static List<SegmentViolation> get violations =>
      List<SegmentViolation>.unmodifiable(_violations);

  static bool get isClean => _violations.isEmpty;

  @visibleForTesting
  static void reset() => _violations.clear();

  /// Checks [requested] against what [width] permits. Returns the span that
  /// should actually be used.
  static int check(int requested, double width, String origin) {
    final int allowed = HabotGrid.clampSegments(requested, width);
    if (allowed == requested) {
      return allowed;
    }
    final SegmentViolation violation = SegmentViolation(
      requestedSegments: requested,
      allowedSegments: allowed,
      viewportWidth: width,
      origin: origin,
    );
    _violations.add(violation);
    assert(() {
      throw FlutterError(
        'RCGLA-032 layout boundary violated.\n'
        '$violation\n'
        'A compact viewport is restricted to '
        '${HabotGrid.maxCompactSegments} vertical segments. Reduce the span, '
        'or stack the children instead of splitting them.',
      );
    }());
    return allowed;
  }
}

/// The global layout boundary every application view is wrapped in.
///
/// It fixes the outer margin, caps the content width, and publishes the
/// resolved window class and column count to descendants so no child has to
/// recompute them (or invent its own breakpoints).
class HabotLayoutBoundary extends StatelessWidget {
  const HabotLayoutBoundary({required this.child, this.debugOrigin, super.key});

  final Widget child;

  /// Names this boundary in any violation it reports.
  final String? debugOrigin;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        return HabotLayoutScope(
          width: width,
          windowClass: HabotGrid.windowClassFor(width),
          columns: HabotGrid.columnsFor(width),
          origin: debugOrigin ?? 'HabotLayoutBoundary',
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: HabotGrid.maxContentWidthFor(width),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Resolved layout facts, published down the tree.
class HabotLayoutScope extends InheritedWidget {
  const HabotLayoutScope({
    required this.width,
    required this.windowClass,
    required this.columns,
    required this.origin,
    required super.child,
    super.key,
  });

  final double width;
  final HabotWindowClass windowClass;
  final int columns;
  final String origin;

  bool get isCompact => windowClass == HabotWindowClass.compact;

  /// Validates a requested span and returns the span to use.
  int resolveSpan(int requested) =>
      LayoutBoundaryReporter.check(requested, width, origin);

  static HabotLayoutScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HabotLayoutScope>();

  static HabotLayoutScope of(BuildContext context) {
    final HabotLayoutScope? scope = maybeOf(context);
    if (scope == null) {
      throw FlutterError(
        'HabotLayoutScope.of() found no HabotLayoutBoundary above this widget.\n'
        'RCGLA-032 requires every application view to be wrapped in a global '
        'layout boundary container. Use HabotMasterScaffold, which wraps one '
        'for you.',
      );
    }
    return scope;
  }

  @override
  bool updateShouldNotify(HabotLayoutScope oldWidget) =>
      oldWidget.width != width ||
      oldWidget.windowClass != windowClass ||
      oldWidget.columns != columns;
}
