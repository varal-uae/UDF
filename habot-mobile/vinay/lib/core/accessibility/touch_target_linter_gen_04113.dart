// GEN-04113 — Touch Target Linter Scan for Accessibility Compliance.
// Provides a widget analyzer utility that flags interactive controls configured smaller than 48x48dp minimum touch targets per M3 accessibility standards.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Result of a touch target linter scan on a single widget node.
class TouchTargetLintResult {
  final String widgetType;
  final Size measuredSize;
  final bool passed;
  final String? failureReason;

  const TouchTargetLintResult({
    required this.widgetType,
    required this.measuredSize,
    required this.passed,
    this.failureReason,
  });

  @override
  String toString() =>
      '[$widgetType] ${passed ? "PASS" : "FAIL"} (${measuredSize.width.toStringAsFixed(1)}x${measuredSize.height.toStringAsFixed(1)})${failureReason != null ? " - $failureReason" : ""}';
}

/// Configuration for the DevSecOps Accessibility Gate thresholds.
class TouchTargetLinterConfig {
  /// Minimum allowed width in logical pixels (48dp).
  final double minWidthDp;

  /// Minimum allowed height in logical pixels (48dp).
  final double minHeightDp;

  /// Floor boundary threshold for metric evaluation.
  final double floorThreshold;

  const TouchTargetLinterConfig({
    this.minWidthDp = 48.0,
    this.minHeightDp = 48.0,
    this.floorThreshold = 1.0,
  });
}

/// Static utility class to perform touch target linter checks on the widget tree.
/// Flags any interactive control configured smaller than 48x48dp.
class TouchTargetLinter {
  TouchTargetLinter._();

  static const TouchTargetLinterConfig _defaultConfig = TouchTargetLinterConfig();

  /// Interactive render object types that must meet the 48x48dp minimum.
  static const Set<Type> _interactiveTypes = {
    GestureDetector,
    InkWell,
    TextButton,
    ElevatedButton,
    OutlinedButton,
    IconButton,
    FloatingActionButton,
    Checkbox,
    Radio,
    Switch,
    Slider,
    DropdownButton,
    PopupMenuButton,
  };

  /// Scans the given [Element] tree and returns a list of lint results
  /// for any interactive widgets violating the 48x48dp touch target rule.
  static List<TouchTargetLintResult> scan(
    Element rootElement, {
    TouchTargetLinterConfig config = _defaultConfig,
  }) {
    final List<TouchTargetLintResult> results = [];

    void visitor(Element element) {
      final Widget widget = element.widget;
      final Type widgetType = widget.runtimeType;

      // Check if the widget is an interactive type
      final bool isInteractive = _interactiveTypes.any(
        (type) => widgetType == type || widgetType.toString().startsWith(type.toString()),
      );

      if (isInteractive) {
        final RenderObject? renderObject = element.renderObject;
        if (renderObject != null && renderObject is RenderBox) {
          final Size size = renderObject.size;
          final bool widthPass = size.width >= config.minWidthDp;
          final bool heightPass = size.height >= config.minHeightDp;
          final bool passed = widthPass && heightPass;

          String? failureReason;
          if (!passed) {
            final List<String> reasons = [];
            if (!widthPass) reasons.add('width ${size.width.toStringAsFixed(1)} < ${config.minWidthDp}');
            if (!heightPass) reasons.add('height ${size.height.toStringAsFixed(1)} < ${config.minHeightDp}');
            failureReason = reasons.join(', ');
          }

          results.add(TouchTargetLintResult(
            widgetType: widgetType.toString(),
            measuredSize: size,
            passed: passed,
            failureReason: failureReason,
          ));
        }
      }

      element.visitChildren(visitor);
    }

    rootElement.visitChildren(visitor);
    return results;
  }

  /// Evaluates overall pass/fail status for CI/CD gate integration.
  /// Returns true only if all scanned interactive elements meet the 48x48dp requirement.
  static bool evaluateGate(List<TouchTargetLintResult> results) {
    return results.every((r) => r.passed);
  }

  /// Generates a DevSecOps Accessibility Gate report string.
  static String generateReport(List<TouchTargetLintResult> results) {
    final bool gatePassed = evaluateGate(results);
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('=== Touch Target Linter Scan Report ===');
    buffer.writeln('Standard: DevSecOps Accessibility Gate');
    buffer.writeln('Metric: Touch Target Linter Scan');
    buffer.writeln('Floor Threshold: ${_defaultConfig.floorThreshold}');
    buffer.writeln('Total Interactive Controls Scanned: ${results.length}');
    buffer.writeln('Overall Status: ${gatePassed ? "PASS" : "FAIL"}');
    buffer.writeln('---------------------------------------');
    for (final result in results) {
      buffer.writeln(result.toString());
    }
    buffer.writeln('=======================================');
    return buffer.toString();
  }
}

/// A wrapper widget that can be used in debug/test mode to automatically
/// run the touch target linter scan after the frame is rendered.
class TouchTargetLinterOverlay extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final VoidCallback? onScanComplete;

  const TouchTargetLinterOverlay({
    super.key,
    required this.child,
    this.enabled = true,
    this.onScanComplete,
  });

  @override
  State<TouchTargetLinterOverlay> createState() => _TouchTargetLinterOverlayState();
}

class _TouchTargetLinterOverlayState extends State<TouchTargetLinterOverlay> {
  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _runScan());
    }
  }

  void _runScan() {
    if (!mounted) return;
    final results = TouchTargetLinter.scan(context as Element);
    final report = TouchTargetLinter.generateReport(results);
    debugPrint(report);
    widget.onScanComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Mock data provider simulating backend telemetry events for BigQuery alignment.
/// All step execution events stream to BigQuery partitioned by event_date, clustered by trace_id.
class MockLinterTelemetryRepository {
  static const List<Map<String, dynamic>> mockExecutionEvents = [
    {
      'trace_id': 'trace-gen-04113-001',
      'event_date': '2026-09-28',
      'step_id': 'GEN-04113',
      'metric_name': 'Touch Target Linter Scan',
      'result': 'Pass',
      'timestamp': '2026-09-28T10:00:00Z',
      'session_id': 'sess-mock-001',
    },
    {
      'trace_id': 'trace-gen-04113-002',
      'event_date': '2026-09-28',
      'step_id': 'GEN-04113',
      'metric_name': 'Touch Target Linter Scan',
      'result': 'Fail',
      'timestamp': '2026-09-28T10:05:00Z',
      'session_id': 'sess-mock-002',
      'failure_reason': 'IconButton width 40.0 < 48.0',
    },
  ];

  static Future<List<Map<String, dynamic>>> fetchEvents() async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 100));
    return mockExecutionEvents;
  }
}
