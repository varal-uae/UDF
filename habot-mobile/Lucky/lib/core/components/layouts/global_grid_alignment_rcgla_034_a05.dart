// RCGLA-034-A05 — Global Grid Alignment Rules and Design Tokens.
// Defines 8dp baseline grid, 4-column mobile layout, outer side padding parameters, Material 3 warning color tokens, status banners, and UI linting constraints for all presentation models.

import 'package:flutter/material.dart';

/// Atomic-level design tokens and layout rules for the global mobile grid system.
/// Enforces 8dp baseline grid, 4-column mobile template, and consistent padding.
class GlobalGridTokens {
  GlobalGridTokens._();

  /// 8dp baseline grid unit. All spacing and sizing must be multiples of this value.
  static const double baselineGrid = 8.0;

  /// Number of columns in the mobile grid template.
  static const int mobileColumnCount = 4;

  /// Outer side padding for responsive mobile screen borders.
  static const double outerSidePaddingMobile = 16.0; // 2 * baselineGrid

  /// Gutter size between grid columns.
  static const double gutterSize = 16.0; // 2 * baselineGrid

  /// Standard vertical stacking margin for mobile-first layouts.
  static const double verticalStackMargin = 24.0; // 3 * baselineGrid

  /// Material 3 compliant explicit warning color token for compliance status highlights.
  static const Color warningColorToken = Color(0xFFF9A825);

  /// High-visibility green layout status banner color for processing feedback.
  static const Color statusSuccessColor = Color(0xFF2E7D32);

  /// High-visibility red layout status banner color for error feedback.
  static const Color statusErrorColor = Color(0xFFC62828);
}

/// Poka-Yoke (Mistake-Proofing) utility to enforce grid alignment.
/// Physically locks elements to the mobile grid by snapping values to the nearest 8dp multiple.
class GridEnforcer {
  GridEnforcer._();

  /// Snaps a given [value] to the nearest multiple of the 8dp baseline grid.
  static double snapToGrid(double value) {
    return (value / GlobalGridTokens.baselineGrid).round() * GlobalGridTokens.baselineGrid;
  }

  /// Validates if a [value] strictly adheres to the 8dp baseline grid.
  /// Used by UI linting plugins or debug assertions to flag grid violations.
  static bool isAligned(double value) {
    return value % GlobalGridTokens.baselineGrid == 0;
  }

  /// Asserts alignment in debug mode. Forces correction during development.
  static void assertAlignment(double value, String propertyName) {
    assert(
      isAligned(value),
      'UI Lint Violation: $propertyName ($value) does not align to the ${GlobalGridTokens.baselineGrid}px baseline grid.',
    );
  }
}

/// A standardized layout widget that applies the 4-column mobile grid template
/// with enforced outer side padding and vertical stacking for limited screen real estate.
class GlobalGridContainer extends StatelessWidget {
  const GlobalGridContainer({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(
      horizontal: GlobalGridTokens.outerSidePaddingMobile,
    ),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    // Validate padding adherence in debug mode
    if (padding is EdgeInsets) {
      final edgeInsets = padding as EdgeInsets;
      GridEnforcer.assertAlignment(edgeInsets.left, 'Padding.left');
      GridEnforcer.assertAlignment(edgeInsets.right, 'Padding.right');
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const SizedBox(height: GlobalGridTokens.verticalStackMargin),
          ],
        ],
      ),
    );
  }
}

/// High-visibility layout status banner providing immediate processing feedback.
/// Utilizes explicit Material warning color tokens when applicable.
class LayoutStatusBanner extends StatelessWidget {
  const LayoutStatusBanner({
    super.key,
    required this.message,
    required this.status,
  });

  final String message;
  final LayoutStatus status;

  Color get _backgroundColor {
    switch (status) {
      case LayoutStatus.success:
        return GlobalGridTokens.statusSuccessColor;
      case LayoutStatus.error:
        return GlobalGridTokens.statusErrorColor;
      case LayoutStatus.warning:
        return GlobalGridTokens.warningColorToken;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GlobalGridTokens.baselineGrid * 2),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(GlobalGridTokens.baselineGrid),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

enum LayoutStatus { success, error, warning }

/// Formats error detail messages inside prominent outline boxes.
/// Follows Mobile-First & Responsive UI Google Material Design Implementation rules.
class ErrorOutlineBox extends StatelessWidget {
  const ErrorOutlineBox({
    super.key,
    required this.errorMessage,
  });

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GlobalGridTokens.baselineGrid * 2),
      decoration: BoxDecoration(
        border: Border.all(
          color: GlobalGridTokens.statusErrorColor,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(GlobalGridTokens.baselineGrid),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: GlobalGridTokens.statusErrorColor,
            size: 24.0, // 3 * baselineGrid
          ),
          const SizedBox(width: GlobalGridTokens.baselineGrid),
          Expanded(
            child: Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: GlobalGridTokens.statusErrorColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dynamic loading animation widget used during document validation processing.
class ValidationLoadingIndicator extends StatelessWidget {
  const ValidationLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 3.0,
            valueColor: AlwaysStoppedAnimation<Color>(
              GlobalGridTokens.warningColorToken,
            ),
          ),
          const SizedBox(height: GlobalGridTokens.baselineGrid * 2),
          Text(
            'Validating document...',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Mock telemetry data structure for tracking UI/UX Design-System Consistency.
/// Maps to the Data Collected by System requirement.
class UiConsistencyTelemetry {
  const UiConsistencyTelemetry({
    required this.mobilePlatform,
    required this.osVersion,
    required this.deviceType,
    required this.screenDimensions,
    required this.mobileConfiguration,
    required this.completionStatus,
    required this.timestamp,
    required this.sessionId,
  });

  final String mobilePlatform;
  final String osVersion;
  final String deviceType;
  final Size screenDimensions;
  final String mobileConfiguration;
  final String completionStatus; // 'Good', 'Average', 'Poor'
  final DateTime timestamp;
  final String sessionId;

  Map<String, dynamic> toJson() => {
        'mobile_platform': mobilePlatform,
        'os_version': osVersion,
        'device_type': deviceType,
        'screen_dimensions': '${screenDimensions.width}x${screenDimensions.height}',
        'mobile_configuration': mobileConfiguration,
        'completion_status': completionStatus,
        'timestamp': timestamp.toIso8601String(),
        'session_id': sessionId,
      };
}

/// Local mock repository supplying realistic telemetry data for frontend ingestion rendering.
class MockUiConsistencyRepository {
  static List<UiConsistencyTelemetry> fetchMockData() {
    return [
      UiConsistencyTelemetry(
        mobilePlatform: 'Android',
        osVersion: '14',
        deviceType: 'Pixel 8',
        screenDimensions: const Size(1080, 2400),
        mobileConfiguration: '4-column-grid-8dp-baseline',
        completionStatus: 'Good',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        sessionId: 'sess_abc_123',
      ),
      UiConsistencyTelemetry(
        mobilePlatform: 'iOS',
        osVersion: '17.4',
        deviceType: 'iPhone 15 Pro',
        screenDimensions: const Size(1179, 2556),
        mobileConfiguration: '4-column-grid-8dp-baseline',
        completionStatus: 'Good',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        sessionId: 'sess_def_456',
      ),
    ];
  }

  /// Calculates the UI/UX Design-System Consistency (%).
  /// Floor: 90%, Optimal Target: 97%, Ceiling: 100%.
  static double calculateConsistencyPercentage(List<UiConsistencyTelemetry> data) {
    if (data.isEmpty) return 0.0;
    final goodCount = data.where((e) => e.completionStatus == 'Good').length;
    return (goodCount / data.length) * 100.0;
  }
}
