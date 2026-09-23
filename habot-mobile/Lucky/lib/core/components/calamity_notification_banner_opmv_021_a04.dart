// OPMV-021-A04 — Global Calamity Notification Banner Component.
// A production-grade, non-dismissible priority incident banner that docks rigidly to the top viewport edge, remaining un-obscured by scrolling or keyboards. Enforces Material Design 3 window size classes and sharp contrast typography.

import 'package:flutter/material.dart';

/// Enum representing the severity of the calamity notification.
enum CalamitySeverity { warning, error, critical }

/// Data model for the calamity notification.
class CalamityNotificationData {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String problemOriginSourceId;
  final String message;
  final CalamitySeverity severity;

  const CalamityNotificationData({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.problemOriginSourceId,
    required this.message,
    required this.severity,
  });
}

/// Mock data provider simulating backend transaction constraint exception signals.
class MockCalamityDataProvider {
  static List<CalamityNotificationData> getMockIncidents() {
    return [
      CalamityNotificationData(
        stepExecutionId: 'EXEC-99281',
        executionStatus: 'FAILED',
        executionTimestamp: DateTime.now(),
        stepOutcome: 'TransactionConstraintException',
        userId: 'USR-001',
        problemOriginSourceId: 'SVC-PAYMENT-GATEWAY-04',
        message: 'Critical payment processing failure detected.',
        severity: CalamitySeverity.critical,
      ),
      CalamityNotificationData(
        stepExecutionId: 'EXEC-99282',
        executionStatus: 'WARNING',
        executionTimestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        stepOutcome: 'LatencyThresholdExceeded',
        userId: 'USR-002',
        problemOriginSourceId: 'SVC-AUTH-PROVIDER-01',
        message: 'Authentication service experiencing high latency.',
        severity: CalamitySeverity.warning,
      ),
    ];
  }
}

/// The core global messaging banner layout component.
/// Docks rigidly to the top viewport edge. Cannot be manually closed by workers.
class CalamityNotificationBanner extends StatelessWidget {
  final CalamityNotificationData data;

  const CalamityNotificationBanner({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Map secure states to standard typography role weights & clear contrasting icons
    Color backgroundColor;
    Color foregroundColor;
    IconData statusIcon;

    switch (data.severity) {
      case CalamitySeverity.critical:
        backgroundColor = colorScheme.errorContainer;
        foregroundColor = colorScheme.onErrorContainer;
        statusIcon = Icons.error_outline_rounded;
        break;
      case CalamitySeverity.error:
        backgroundColor = colorScheme.error;
        foregroundColor = colorScheme.onError;
        statusIcon = Icons.cancel_outlined;
        break;
      case CalamitySeverity.warning:
        backgroundColor = colorScheme.tertiaryContainer;
        foregroundColor = colorScheme.onTertiaryContainer;
        statusIcon = Icons.warning_amber_rounded;
        break;
    }

    return Material(
      color: backgroundColor,
      elevation: 4.0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                statusIcon,
                color: foregroundColor,
                size: 24.0,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Calamity text lines must state the precise problem origin source identifier clearly
                    Text(
                      'Origin: ${data.problemOriginSourceId}',
                      style: textTheme.labelLarge?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      data.message,
                      style: textTheme.bodyMedium?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Step ID: ${data.stepExecutionId} | Status: ${data.executionStatus}',
                      style: textTheme.bodySmall?.copyWith(
                        color: foregroundColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // NO CLOSE BUTTON: Frontend layer drops any mechanisms that let workers manually close priority alerts.
            ],
          ),
        ),
      ),
    );
  }
}

/// Wrapper widget that implements fallback alerts within the primary viewing pane container.
/// Adapts predictably across devices using Material Design 3 canonical window-size classes.
class GlobalCalamityBannerOverlay extends StatelessWidget {
  final Widget child;
  final List<CalamityNotificationData> activeIncidents;

  const GlobalCalamityBannerOverlay({
    super.key,
    required this.child,
    required this.activeIncidents,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    // Responsive Breakpoint Accuracy (Material Design 3 Window Size Classes)
    // 0-599dp = Compact, 600-839dp = Medium, >=840dp = Expanded
    int maxVisibleBanners;
    if (screenWidth < 600) {
      maxVisibleBanners = 1; // Compact
    } else if (screenWidth < 840) {
      maxVisibleBanners = 2; // Medium
    } else {
      maxVisibleBanners = 3; // Expanded
    }

    final visibleIncidents = activeIncidents.take(maxVisibleBanners).toList();

    return Stack(
      children: [
        // Primary viewing pane container
        Positioned.fill(child: child),
        // Dock banners rigidly to the top viewport edge
        if (visibleIncidents.isNotEmpty)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: visibleIncidents
                  .map((incident) => CalamityNotificationBanner(data: incident))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

/// Example usage demonstrating how to integrate the banner into the core application layout.
class CoreApplicationLayoutExample extends StatelessWidget {
  const CoreApplicationLayoutExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulated real-time error streams / mock data
    final incidents = MockCalamityDataProvider.getMockIncidents();

    return Scaffold(
      appBar: AppBar(
        title: const Text('UDF Operations Dashboard'),
      ),
      body: GlobalCalamityBannerOverlay(
        activeIncidents: incidents,
        child: const Center(
          child: Text('Primary Application Content Area'),
        ),
      ),
    );
  }
}
