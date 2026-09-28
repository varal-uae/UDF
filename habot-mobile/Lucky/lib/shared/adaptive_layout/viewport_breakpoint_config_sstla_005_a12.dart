// SSTLA-005-A12 — Viewport Breakpoint Configuration & Adaptive Layout Mapper.
// Establishes explicit structural array configuration mapping mobile devices to strict width ranges for fluid rendering without custom pixel overrides.

import 'package:flutter/material.dart';

/// Defines strict width ranges for mobile device breakpoints to handle fluid layout rendering.
enum DeviceBreakpoint {
  small,
  medium,
  large,
}

/// Data class representing a specific breakpoint configuration.
class BreakpointConfig {
  final DeviceBreakpoint breakpoint;
  final double minWidth;
  final double maxWidth;
  final int gridColumns;
  final EdgeInsets padding;

  const BreakpointConfig({
    required this.breakpoint,
    required this.minWidth,
    required this.maxWidth,
    required this.gridColumns,
    required this.padding,
  });

  Map<String, dynamic> toJson() => {
        'breakpoint': breakpoint.name,
        'minWidth': minWidth,
        'maxWidth': maxWidth,
        'gridColumns': gridColumns,
        'padding': {
          'left': padding.left,
          'top': padding.top,
          'right': padding.right,
          'bottom': padding.bottom,
        },
      };
}

/// Core configuration mapping mobile devices to strict width ranges.
/// Guarantees optimal grid allocation based on touch surface characteristics,
/// eliminating horizontal scrolls on 360px devices.
class ViewportBreakpointMapper {
  ViewportBreakpointMapper._();

  /// Explicit structural array configuration mapping.
  static const List<BreakpointConfig> configurations = [
    BreakpointConfig(
      breakpoint: DeviceBreakpoint.small,
      minWidth: 0.0,
      maxWidth: 360.0,
      gridColumns: 4,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    ),
    BreakpointConfig(
      breakpoint: DeviceBreakpoint.medium,
      minWidth: 361.0,
      maxWidth: 600.0,
      gridColumns: 8,
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    ),
    BreakpointConfig(
      breakpoint: DeviceBreakpoint.large,
      minWidth: 601.0,
      maxWidth: 900.0,
      gridColumns: 12,
      padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
    ),
  ];

  /// Resolves the active breakpoint configuration based on current screen width.
  /// Coordinate calculations complete without injecting custom inline pixel styles.
  static BreakpointConfig resolve(double screenWidth) {
    for (final config in configurations) {
      if (screenWidth >= config.minWidth && screenWidth <= config.maxWidth) {
        return config;
      }
    }
    // Fallback to largest defined configuration if out of bounds
    return configurations.last;
  }

  /// Generates the expected JSON blueprint mapping explicit structural break configurations.
  static String generateJsonBlueprint() {
    final List<Map<String, dynamic>> blueprint =
        configurations.map((c) => c.toJson()).toList();
    return '{"structuralBreakpoints": $blueprint}';
  }
}

/// A wrapper widget that dynamically scales rendering coordinates
/// based on the resolved viewport breakpoint configuration.
class AdaptiveLayoutWrapper extends StatelessWidget {
  final Widget Function(BuildContext context, BreakpointConfig config) builder;

  const AdaptiveLayoutWrapper({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final config = ViewportBreakpointMapper.resolve(constraints.maxWidth);
        return Padding(
          padding: config.padding,
          child: builder(context, config),
        );
      },
    );
  }
}

/// Authorized proof document formats restriction list.
/// Defined as per Setup Step (Action).1 requirement.
class DocumentFormatRestrictions {
  DocumentFormatRestrictions._();

  static const List<String> authorizedExtensions = [
    '.pdf',
    '.jpg',
    '.jpeg',
    '.png',
  ];

  static bool isAuthorized(String fileName) {
    final lower = fileName.toLowerCase();
    return authorizedExtensions.any((ext) => lower.endsWith(ext));
  }
}

/// Mock data simulating raw display configuration properties
/// piped during initial session initialization (GCP / BigQuery Alignment mock).
class MockDisplayTelemetry {
  static const Map<String, dynamic> sessionInitData = {
    'stepExecutionId': 'EXEC-SSTLA-005-A12-001',
    'executionStatus': 'COMPLETED',
    'executionTimestamp': '2026-09-28T10:00:00.000Z',
    'stepOutcome': 'PASS',
    'userId': 'UDF-USER-999',
    'completionStatus': 'Pass',
    'displayProperties': {
      'devicePixelRatio': 2.0,
      'physicalSize': {'width': 1080, 'height': 1920},
      'orientation': 'portrait',
    },
  };
}
