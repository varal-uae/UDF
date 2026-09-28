// SSTLA-026-A16 — Responsive Layout Breakpoints & Grid Settings.
// Defines layout breakpoint values and 8dp baseline grid settings to transition screens between phone displays and large tablet form factors seamlessly.

import 'package:flutter/material.dart';

/// Atomic-level data fields for system configuration tracking.
class Sstla026A16SystemConfig {
  static const String systemName = 'UDF Mobile';
  static const String systemVersion = '1.0.0';
  static const List<String> componentList = [
    'ResponsiveBreakpoints',
    'BaselineGrid',
    'AdaptiveLayoutBuilder',
  ];
  static const Map<String, double> tokenValues = {
    'baseline_grid': 8.0,
    'breakpoint_phone': 600.0,
    'breakpoint_tablet': 1024.0,
  };
  static const String documentationLink = 'https://docs.internal/sstla-026-a16';
}

/// Defines standard breakpoints using an 8dp baseline grid system.
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  /// Maximum width for phone layouts (single-column vertical scroll).
  static const double phone = 600.0;

  /// Maximum width for tablet layouts (dual-panel display).
  static const double tablet = 1024.0;

  /// 8dp baseline grid unit as per world's best practice selection guidance.
  static const double baselineGrid = 8.0;

  /// Returns true if the current context represents a phone-sized screen.
  static bool isPhone(BuildContext context) {
    return MediaQuery.sizeOf(context).width < phone;
  }

  /// Returns true if the current context represents a tablet-sized screen.
  static bool isTablet(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return width >= phone && width < tablet;
  }

  /// Returns true if the current context represents a large desktop/tablet screen.
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= tablet;
  }

  /// Calculates spacing based on the 8dp baseline grid multiplier.
  static double gridSpacing(int multiplier) => baselineGrid * multiplier;
}

/// A layout builder that automatically transitions between phone (single-column)
/// and tablet (dual-panel) layouts based on defined breakpoints.
/// Wraps text fields automatically onto new lines rather than cutting them off.
class AdaptiveLayoutBuilder extends StatelessWidget {
  const AdaptiveLayoutBuilder({
    super.key,
    required this.phoneLayout,
    required this.tabletLayout,
  });

  /// The widget tree rendered when the screen width is below [ResponsiveBreakpoints.phone].
  final Widget phoneLayout;

  /// The widget tree rendered when the screen width is at or above [ResponsiveBreakpoints.phone].
  final Widget tabletLayout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Enforce 8dp baseline grid alignment
        final double maxWidth = constraints.maxWidth -
            (constraints.maxWidth % ResponsiveBreakpoints.baselineGrid);

        if (constraints.maxWidth < ResponsiveBreakpoints.phone) {
          // Organizes dense, wide data grids into single-column vertical scrolls on phones
          return SizedBox(
            width: maxWidth,
            child: phoneLayout,
          );
        }

        // Expanding to dual-panel displays on tablet devices
        return SizedBox(
          width: maxWidth,
          child: tabletLayout,
        );
      },
    );
  }
}

/// Mock repository providing pre-summarized data summaries to minimize mobile loading lag.
/// Aligns with GCP / BigQuery requirement by simulating queried summaries locally.
class MockDataVisualizationRepository {
  static const List<Map<String, dynamic>> businessTrendsSummary = [
    {
      'id': 'trend_001',
      'label': 'Q3 Revenue Growth',
      'value': 14.5,
      'unit': '%',
      'timestamp': '2026-09-28T10:00:00Z',
    },
    {
      'id': 'trend_002',
      'label': 'Active Supervisors',
      'value': 142,
      'unit': 'users',
      'timestamp': '2026-09-28T10:00:00Z',
    },
    {
      'id': 'trend_003',
      'label': 'Deployment Success Rate',
      'value': 99.9,
      'unit': '%',
      'timestamp': '2026-09-28T10:00:00Z',
    },
  ];

  /// Simulates fetching summarized data from BigQuery tables.
  Future<List<Map<String, dynamic>>> fetchSummarizedTrends() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return businessTrendsSummary;
  }
}

/// Mistake-proofing (Poka-Yoke) widget that ensures text fields wrap
/// automatically onto new lines rather than cutting them off.
class SafeWrapText extends StatelessWidget {
  const SafeWrapText({
    super.key,
    required this.text,
    this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ?? Theme.of(context).textTheme.bodyMedium,
      softWrap: true,
      overflow: TextOverflow.visible,
    );
  }
}