// REF-212-A12 — 4-Column Mobile Grid Setup & Spacing Matrix Implementation.
// Provides a strict responsive grid module driving all content placements on mobile layouts using 4dp spacing multiples.

import 'package:flutter/material.dart';

/// Enforces spacing and sizing in multiples of 4dp as per design system standards.
class SpacingMatrix {
  const SpacingMatrix._();

  static const double base = 4.0;
  static const double xxs = base; // 4.0
  static const double xs = base * 2; // 8.0
  static const double sm = base * 3; // 12.0
  static const double md = base * 4; // 16.0
  static const double lg = base * 6; // 24.0
  static const double xl = base * 8; // 32.0
  static const double xxl = base * 12; // 48.0

  /// Poka-Yoke: Validates that a given value is a multiple of 4dp.
  /// Throws an [AssertionError] if the constraint is violated.
  static bool validateMultipleOfFour(double value) {
    assert(
      value % base == 0,
      'Spacing or sizing value $value is not a multiple of ${base}dp. '
      'All layout parameters must adhere to the 4dp grid matrix.',
    );
    return true;
  }
}

/// A global style layout asset providing a strict 4-column responsive grid.
/// Functions as the core grid engine for complex business data interfaces.
class FourColumnGridMatrix extends StatelessWidget {
  const FourColumnGridMatrix({
    super.key,
    required this.children,
    this.columnSpacing = SpacingMatrix.md,
    this.rowSpacing = SpacingMatrix.md,
    this.padding = const EdgeInsets.all(SpacingMatrix.md),
    this.crossAxisAlignment = CrossAxisAlignment.start,
  })  : assert(children.length > 0, 'Grid must have at least one child.'),
        assert(columnSpacing % 4 == 0, 'columnSpacing must be a multiple of 4dp.'),
        assert(rowSpacing % 4 == 0, 'rowSpacing must be a multiple of 4dp.');

  final List<Widget> children;
  final double columnSpacing;
  final double rowSpacing;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    // Validate spacings (Poka-Yoke)
    SpacingMatrix.validateMultipleOfFour(columnSpacing);
    SpacingMatrix.validateMultipleOfFour(rowSpacing);

    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Determine number of columns based on available width
          // Mobile-first: defaults to 4 columns, but adapts gracefully
          int crossAxisCount = 4;
          if (constraints.maxWidth < 300) {
            crossAxisCount = 2;
          } else if (constraints.maxWidth < 600) {
            crossAxisCount = 4;
          } else {
            crossAxisCount = 4; // Maintains 4-column structure on larger screens too
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: rowSpacing,
              crossAxisSpacing: columnSpacing,
              childAspectRatio: 1.0,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) {
              return children[index];
            },
          );
        },
      ),
    );
  }
}

/// Wrapper widget that enforces grid alignment boundaries on its child.
/// Restricts element boundaries to structured steps, creating a clean rhythm.
class GridAlignedBox extends StatelessWidget {
  const GridAlignedBox({
    super.key,
    required this.child,
    this.columnsSpan = 1,
    this.heightMultiple = 1,
  })  : assert(columnsSpan >= 1 && columnsSpan <= 4, 'columnsSpan must be between 1 and 4.'),
        assert(heightMultiple >= 1, 'heightMultiple must be at least 1.');

  final Widget child;
  final int columnsSpan;
  final int heightMultiple;

  @override
  Widget build(BuildContext context) {
    // Height strictly follows 4dp multiples
    final double enforcedHeight = SpacingMatrix.base * 16 * heightMultiple;
    SpacingMatrix.validateMultipleOfFour(enforcedHeight);

    return SizedBox(
      height: enforcedHeight,
      child: child,
    );
  }
}

/// Mock telemetry logger for device sizing stats at session launch.
/// Aligns with GCP / BigQuery requirement for device profiling indices.
class GridTelemetryLogger {
  GridTelemetryLogger._();

  static void logDeviceSizingStats(Size screenSize) {
    // Mock implementation for local testing without backend
    final Map<String, dynamic> mockPayload = {
      'step_execution_id': 'EXEC-${DateTime.now().millisecondsSinceEpoch}',
      'execution_status': 'SUCCESS',
      'execution_timestamp': DateTime.now().toIso8601String(),
      'step_outcome': 'DEVICE_PROFILED',
      'user_id': 'MOCK_USER_001',
      'screen_width': screenSize.width,
      'screen_height': screenSize.height,
      'device_pixel_ratio': WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio,
    };
    
    debugPrint('[GridTelemetryLogger] Device Sizing Stats: $mockPayload');
  }
}
