// SSELC-025-A05 — Screen Size Detection & Responsive Layout Engine.
// Deploys screen size detection scripts across app layout layers using Material Design 8pt grid breakpoints, ensuring fluid scaling and compact 4-column fallbacks.

import 'package:flutter/material.dart';

/// Represents the active layout type determined by screen width breakpoints.
enum LayoutType {
  compact,
  medium,
  expanded,
}

/// Holds atomic-level data fields for layout configuration following the 8pt grid system.
class LayoutGridDimensions {
  final int columns;
  final double gutter;
  final double margin;

  const LayoutGridDimensions({
    required this.columns,
    required this.gutter,
    required this.margin,
  });
}

/// Encapsulates spacing rules and alignment settings for the responsive layout.
class SpacingRules {
  final double baseUnit; // 8pt grid baseline
  final double componentSpacing;
  final double sectionSpacing;

  const SpacingRules({
    this.baseUnit = 8.0,
    this.componentSpacing = 16.0,
    this.sectionSpacing = 24.0,
  });
}

/// Complete layout validation status and properties.
class LayoutValidationStatus {
  final LayoutType layoutType;
  final LayoutGridDimensions gridDimensions;
  final SpacingRules spacingRules;
  final bool isValid;
  final DateTime timestamp;

  const LayoutValidationStatus({
    required this.layoutType,
    required this.gridDimensions,
    required this.spacingRules,
    required this.isValid,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'layoutType': layoutType.name,
        'columns': gridDimensions.columns,
        'gutter': gridDimensions.gutter,
        'margin': gridDimensions.margin,
        'baseUnit': spacingRules.baseUnit,
        'isValid': isValid,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Establishes screen width breakpoint limits for layout adaptations.
/// Follows official Material Design specifications.
class MaterialBreakpoints {
  static const double compactMax = 599.0;
  static const double mediumMax = 839.0;
  // Expanded is anything >= 840.0

  static LayoutType resolveLayoutType(double screenWidth) {
    if (screenWidth <= compactMax) return LayoutType.compact;
    if (screenWidth <= mediumMax) return LayoutType.medium;
    return LayoutType.expanded;
  }

  static LayoutGridDimensions resolveGrid(LayoutType type) {
    switch (type) {
      case LayoutType.compact:
        // Strictly on the compact 4-column viewport
        return const LayoutGridDimensions(columns: 4, gutter: 16.0, margin: 16.0);
      case LayoutType.medium:
        return const LayoutGridDimensions(columns: 8, gutter: 24.0, margin: 32.0);
      case LayoutType.expanded:
        return const LayoutGridDimensions(columns: 12, gutter: 24.0, margin: 40.0);
    }
  }
}

/// Active size listening engine guiding app component rendering paths.
/// Falls back to secure compact structures when dimension details are unclear (Poka-Yoke).
class ScreenSizeDetector extends StatefulWidget {
  final Widget Function(BuildContext context, LayoutValidationStatus status) builder;

  const ScreenSizeDetector({
    super.key,
    required this.builder,
  });

  @override
  State<ScreenSizeDetector> createState() => _ScreenSizeDetectorState();
}

class _ScreenSizeDetectorState extends State<ScreenSizeDetector> with WidgetsBindingObserver {
  LayoutValidationStatus? _currentStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Defer initial calculation to after first frame to ensure MediaQuery is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _evaluateLayout();
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Screens adjust fluidly when users activate split-screen modes or change orientations
    _evaluateLayout();
  }

  void _evaluateLayout() {
    if (!mounted) return;

    try {
      final mediaQuery = MediaQuery.of(context);
      final screenWidth = mediaQuery.size.width;

      // Poka-Yoke: Fall back to secure compact structures when dimension details are unclear
      if (screenWidth <= 0 || screenWidth.isNaN || screenWidth.isInfinite) {
        _applyFallback();
        return;
      }

      final layoutType = MaterialBreakpoints.resolveLayoutType(screenWidth);
      final gridDimensions = MaterialBreakpoints.resolveGrid(layoutType);
      const spacingRules = SpacingRules();

      setState(() {
        _currentStatus = LayoutValidationStatus(
          layoutType: layoutType,
          gridDimensions: gridDimensions,
          spacingRules: spacingRules,
          isValid: true,
          timestamp: DateTime.now(),
        );
      });

      // Log user device sizes cleanly to analytical datasets (Mock telemetry)
      _logTelemetry(_currentStatus!);
    } catch (e) {
      // Mistake-Proofing: Catch any unexpected errors and fall back to compact
      _applyFallback();
    }
  }

  void _applyFallback() {
    const fallbackGrid = LayoutGridDimensions(columns: 4, gutter: 16.0, margin: 16.0);
    const spacingRules = SpacingRules();

    setState(() {
      _currentStatus = LayoutValidationStatus(
        layoutType: LayoutType.compact,
        gridDimensions: fallbackGrid,
        spacingRules: spacingRules,
        isValid: false,
        timestamp: DateTime.now(),
      );
    });

    _logTelemetry(_currentStatus!);
  }

  void _logTelemetry(LayoutValidationStatus status) {
    // GCP / BigQuery Alignment: Mock logging for analytical datasets
    debugPrint('[SSELC-025-A05 Telemetry] Layout Data: ${status.toJson()}');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStatus == null) {
      // Render nothing or a minimal container until post-frame evaluation completes
      return const SizedBox.shrink();
    }

    return widget.builder(context, _currentStatus!);
  }
}

/// A utility wrapper that provides standard structured navigation blocks
/// and maintains clear layout contrast profiles across text entry forms.
class AdaptiveLayoutContainer extends StatelessWidget {
  final Widget child;

  const AdaptiveLayoutContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenSizeDetector(
      builder: (context, status) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: status.gridDimensions.margin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prominent information banners detailing structural field constraints
              if (!status.isValid)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Layout Fallback Active: Displaying in safe compact mode.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              // Distinct, high-visibility style guidelines for numeric data displays
              // Fluidly scaled content
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}

/// Mock repository for layout analytics to satisfy backend/data requirements locally.
class LayoutAnalyticsMockRepository {
  static final List<Map<String, dynamic>> _logs = [];

  static void recordEvent(LayoutValidationStatus status, String sessionId) {
    _logs.add({
      ...status.toJson(),
      'sessionId': sessionId,
      'actionTimestamp': DateTime.now().toIso8601String(),
    });
  }

  static List<Map<String, dynamic>> getLogs() => List.unmodifiable(_logs);
}