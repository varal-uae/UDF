// GEN-01765 — Keyboard behavior configuration (pan vs resize) for split-screen rendering.
// Defines keyboard avoidance strategy for the bottom 50% of the screen using Material 3 standards, with mock telemetry and completion tracking.

import 'package:flutter/material.dart';

/// Enum representing the keyboard avoidance behavior strategy.
enum KeyboardAvoidanceBehavior {
  pan,
  resize,
}

/// Mock telemetry event model for BigQuery streaming alignment.
class KeyboardTelemetryEvent {
  final String traceId;
  final DateTime eventDate;
  final KeyboardAvoidanceBehavior behavior;
  final String completionStatus; // Complete/Partial/Not Complete

  const KeyboardTelemetryEvent({
    required this.traceId,
    required this.eventDate,
    required this.behavior,
    required this.completionStatus,
  });

  Map<String, dynamic> toJson() => {
        'trace_id': traceId,
        'event_date': eventDate.toIso8601String(),
        'behavior': behavior.name,
        'completion_status': completionStatus,
      };
}

/// Configuration model for the 50/50 split-screen keyboard behavior.
class SplitScreenKeyboardConfig {
  final KeyboardAvoidanceBehavior behavior;
  final double topPaneFlex;
  final double bottomPaneFlex;
  final bool isMobileLayout;

  const SplitScreenKeyboardConfig({
    this.behavior = KeyboardAvoidanceBehavior.resize,
    this.topPaneFlex = 1.0,
    this.bottomPaneFlex = 1.0,
    this.isMobileLayout = true,
  });

  SplitScreenKeyboardConfig copyWith({
    KeyboardAvoidanceBehavior? behavior,
    double? topPaneFlex,
    double? bottomPaneFlex,
    bool? isMobileLayout,
  }) {
    return SplitScreenKeyboardConfig(
      behavior: behavior ?? this.behavior,
      topPaneFlex: topPaneFlex ?? this.topPaneFlex,
      bottomPaneFlex: bottomPaneFlex ?? this.bottomPaneFlex,
      isMobileLayout: isMobileLayout ?? this.isMobileLayout,
    );
  }
}

/// Widget that applies the defined keyboard behavior (pan or resize)
/// specifically targeting the bottom 50% of a split-screen layout.
class SplitScreenKeyboardAvoidingView extends StatelessWidget {
  final SplitScreenKeyboardConfig config;
  final Widget topPane;
  final Widget bottomPane;

  const SplitScreenKeyboardAvoidingView({
    super.key,
    required this.config,
    required this.topPane,
    required this.bottomPane,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isMobile = mediaQuery.size.width < 600;

    // Determine resizeToAvoidBottomInset based on configured behavior
    final bool resizeToAvoid =
        config.behavior == KeyboardAvoidanceBehavior.resize;

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoid,
      body: SafeArea(
        child: isMobile
            ? _buildMobileSingleColumnLayout()
            : _buildDesktopMultiColumnLayout(),
      ),
    );
  }

  Widget _buildMobileSingleColumnLayout() {
    return Column(
      children: [
        Expanded(
          flex: config.topPaneFlex.toInt(),
          child: topPane,
        ),
        Expanded(
          flex: config.bottomPaneFlex.toInt(),
          child: _wrapBottomPane(bottomPane),
        ),
      ],
    );
  }

  Widget _buildDesktopMultiColumnLayout() {
    return Row(
      children: [
        Expanded(
          flex: config.topPaneFlex.toInt(),
          child: topPane,
        ),
        Expanded(
          flex: config.bottomPaneFlex.toInt(),
          child: _wrapBottomPane(bottomPane),
        ),
      ],
    );
  }

  Widget _wrapBottomPane(Widget child) {
    if (config.behavior == KeyboardAvoidanceBehavior.pan) {
      return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 200),
          child: child,
        ),
      );
    }
    return child;
  }
}

/// M3 Elevated Card displaying the current keyboard behavior configuration.
class KeyboardBehaviorStatusCard extends StatelessWidget {
  final SplitScreenKeyboardConfig config;
  final VoidCallback? onToggleBehavior;

  const KeyboardBehaviorStatusCard({
    super.key,
    required this.config,
    this.onToggleBehavior,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Keyboard Behavior Status',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  avatar: Icon(
                    config.behavior == KeyboardAvoidanceBehavior.resize
                        ? Icons.fit_screen_rounded
                        : Icons.pan_tool_alt_rounded,
                    size: 18,
                  ),
                  label: Text(
                    config.behavior.name.toUpperCase(),
                    style: theme.textTheme.labelLarge,
                  ),
                  backgroundColor: colorScheme.secondaryContainer,
                  labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
                ),
                FilledButton.tonalIcon(
                  onPressed: onToggleBehavior,
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: const Text('Toggle'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(48, 48), // 48x48dp touch targets
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Target: Bottom 50% Pane | Layout: ${config.isMobileLayout ? "Mobile (<600dp)" : "Desktop (>=840dp)"}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mock repository to simulate data collection and step completion metrics.
class MockKeyboardBehaviorRepository {
  static const double floorBoundary = 90.0;
  static const double optimalTarget = 99.0;
  static const double ceilingBoundary = 100.0;

  /// Simulates fetching the Step Completion Rate (%)
  Future<double> fetchStepCompletionRate() async {
    await Future.delayed(const Duration(milliseconds: 80)); // sub-100ms latency
    return 98.5; // Mock value within optimal target
  }

  /// Simulates logging telemetry to BigQuery partitioned by event_date, clustered by trace_id
  Future<void> logTelemetryEvent(KeyboardTelemetryEvent event) async {
    await Future.delayed(const Duration(milliseconds: 50));
    debugPrint('[BigQuery Mock] Logged Event: ${event.toJson()}');
  }

  /// Evaluates qualitative output based on quantitative metric
  String evaluateQualitativeStatus(double completionRate) {
    if (completionRate >= ceilingBoundary) return 'Complete';
    if (completionRate >= floorBoundary) return 'Partial';
    return 'Not Complete';
  }
}
