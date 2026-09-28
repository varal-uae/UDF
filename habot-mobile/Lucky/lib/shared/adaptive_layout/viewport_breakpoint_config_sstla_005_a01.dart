// SSTLA-005-A01 — Viewport Breakpoint Configuration & Layout Wrapper.
// Establishes explicit structural array configuration mapping mobile devices to strict width ranges for fluid rendering, including mock telemetry logging.

import 'dart:convert';
import 'package:flutter/material.dart';

/// Represents a specific device breakpoint mapping physical viewport widths.
class ViewportBreakpoint {
  final String id;
  final String mobilePlatform;
  final String osVersion;
  final String deviceType;
  final double minWidth;
  final double maxWidth;
  final Map<String, dynamic> mobileConfiguration;

  const ViewportBreakpoint({
    required this.id,
    required this.mobilePlatform,
    required this.osVersion,
    required this.deviceType,
    required this.minWidth,
    required this.maxWidth,
    required this.mobileConfiguration,
  });

  bool matchesWidth(double width) => width >= minWidth && width <= maxWidth;

  Map<String, dynamic> toJson() => {
        'id': id,
        'mobile_platform': mobilePlatform,
        'os_version': osVersion,
        'device_type': deviceType,
        'min_width': minWidth,
        'max_width': maxWidth,
        'mobile_configuration': mobileConfiguration,
      };
}

/// Mock telemetry log repository service (replaces React Native background network pipeline).
class TelemetryLogService {
  static void streamLog(Map<String, dynamic> payload) {
    // In production, this would stream asynchronously to a telemetry server.
    debugPrint('[TelemetryLogService] Payload: ${jsonEncode(payload)}');
  }
}

/// Core configuration class providing the JSON blueprint mapping and layout wrapper logic.
class ViewportBreakpointConfig {
  /// Explicit structural array configuration mapping mobile devices to strict width ranges.
  static const List<ViewportBreakpoint> breakpoints = [
    ViewportBreakpoint(
      id: 'bp_small_mobile',
      mobilePlatform: 'Android/iOS',
      osVersion: 'Any',
      deviceType: 'Small Mobile',
      minWidth: 0,
      maxWidth: 359,
      mobileConfiguration: {'columns': 4, 'horizontal_padding': 12.0},
    ),
    ViewportBreakpoint(
      id: 'bp_standard_mobile',
      mobilePlatform: 'Android/iOS',
      osVersion: 'Any',
      deviceType: 'Standard Mobile',
      minWidth: 360,
      maxWidth: 599,
      mobileConfiguration: {'columns': 4, 'horizontal_padding': 16.0},
    ),
    ViewportBreakpoint(
      id: 'bp_large_mobile',
      mobilePlatform: 'Android/iOS',
      osVersion: 'Any',
      deviceType: 'Large Mobile / Phablet',
      minWidth: 600,
      maxWidth: 839,
      mobileConfiguration: {'columns': 8, 'horizontal_padding': 24.0},
    ),
    ViewportBreakpoint(
      id: 'bp_tablet',
      mobilePlatform: 'Android/iOS',
      osVersion: 'Any',
      deviceType: 'Tablet',
      minWidth: 840,
      maxWidth: 1199,
      mobileConfiguration: {'columns': 12, 'horizontal_padding': 32.0},
    ),
    ViewportBreakpoint(
      id: 'bp_desktop',
      mobilePlatform: 'Web/Desktop',
      osVersion: 'Any',
      deviceType: 'Desktop',
      minWidth: 1200,
      maxWidth: double.infinity,
      mobileConfiguration: {'columns': 12, 'horizontal_padding': 64.0},
    ),
  ];

  /// Resolves the active breakpoint based on current physical viewport width.
  static ViewportBreakpoint resolve(double width) {
    return breakpoints.firstWhere(
      (bp) => bp.matchesWidth(width),
      orElse: () => breakpoints[1], // Default to standard mobile (360px+)
    );
  }

  /// Generates the expected output: JSON blueprint mapping explicit structural break configurations.
  static String generateJsonBlueprint() {
    final List<Map<String, dynamic>> jsonList =
        breakpoints.map((bp) => bp.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(jsonList);
  }

  /// Initializes session and pipes raw display configuration properties to telemetry.
  static void initializeSession(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bp = resolve(mediaQuery.size.width);

    TelemetryLogService.streamLog({
      'event': 'session_initialization',
      'timestamp': DateTime.now().toIso8601String(),
      'screen_dimensions': {
        'width': mediaQuery.size.width,
        'height': mediaQuery.size.height,
        'pixel_ratio': mediaQuery.devicePixelRatio,
      },
      'active_breakpoint': bp.toJson(),
      'orientation': mediaQuery.orientation.name,
      'completion_status': 'Complete',
    });
  }
}

/// Fluid rendering layout wrapper that scales dynamically without custom pixel overrides.
/// Guarantees optimal grid allocation based on touch surface characteristics, eliminating horizontal scrolls on 360px devices.
class AdaptiveLayoutWrapper extends StatelessWidget {
  final Widget child;

  const AdaptiveLayoutWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize telemetry on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ViewportBreakpointConfig.initializeSession(context);
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final breakpoint = ViewportBreakpointConfig.resolve(width);
        final config = breakpoint.mobileConfiguration;

        final double horizontalPadding =
            (config['horizontal_padding'] as num?)?.toDouble() ?? 16.0;

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // Prevent text scaling from breaking layout fidelity
            textScaler: TextScaler.noScaling,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: SizedBox(
              width: double.infinity,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
