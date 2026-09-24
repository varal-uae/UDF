// REF-287-A11 — Fail-Closed Default Fallback UI Layout Guard.
// Provides a pluggable 12-column grid layout wrapper that locks transactional workflows
// behind a secure fallback overlay when network or validation failures occur.

import 'package:flutter/material.dart';

/// Mock telemetry data collected during fallback execution.
class _FallbackTelemetryMock {
  static const String stepExecutionId = 'EXEC-REF-287-A11-001';
  static const String executionStatus = 'LOCKED';
  static final DateTime executionTimestamp = DateTime.now();
  static const String stepOutcome = 'FALLBACK_TRIGGERED';
  static const String userId = 'MOCK_USER_001';
  static const String completionStatus = 'Not Complete';
}

/// A layout guard widget that enforces a fail-closed operational baseline.
/// Wraps transactional children and blocks interaction if [isLocked] is true,
/// displaying a secure recovery path using Material 3 design tokens.
class FailClosedFallbackLayout extends StatelessWidget {
  const FailClosedFallbackLayout({
    super.key,
    required this.child,
    required this.isLocked,
    this.onReturnHome,
    this.onReauthenticate,
    this.lockReason = 'Connection instability detected. Form controls are locked to prevent corrupted submissions.',
  });

  /// The transactional workflow content to protect.
  final Widget child;

  /// Determines whether the fallback overlay should be active.
  final bool isLocked;

  /// Callback for the "Return to Home" action.
  final VoidCallback? onReturnHome;

  /// Callback for the "Re-authenticate" action.
  final VoidCallback? onReauthenticate;

  /// The message displayed to the user when the layout is locked.
  final String lockReason;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Enforce 12-column grid structure within the MasterLayout template
            _buildTwelveColumnGrid(context, child),

            // Native verification prompts overlay screen layers smoothly
            if (isLocked)
              Positioned.fill(
                child: _buildFailClosedOverlay(
                  context: context,
                  theme: theme,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Implements a strict 12-column grid structure as per requirement Setup Step (Action).1
  Widget _buildTwelveColumnGrid(BuildContext context, Widget content) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List<Widget>.generate(12, (int index) {
            return Expanded(
              flex: 1,
              child: index == 0
                  ? SizedBox(
                      width: double.infinity,
                      child: content,
                    )
                  : const SizedBox.shrink(),
            );
          }),
        );
      },
    );
  }

  /// Builds the fail-closed overlay blocking partial or corrupted payload shipments.
  Widget _buildFailClosedOverlay({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    // Log mock telemetry data internally
    debugPrint('Fallback Telemetry: '
        'StepID=${_FallbackTelemetryMock.stepExecutionId}, '
        'Status=${_FallbackTelemetryMock.executionStatus}, '
        'Outcome=${_FallbackTelemetryMock.stepOutcome}');

    return Container(
      color: colorScheme.scrim.withOpacity(0.85),
      alignment: Alignment.center,
      child: Card(
        elevation: 8.0,
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.security_rounded,
                size: 64.0,
                color: colorScheme.error,
              ),
              const SizedBox(height: 24.0),
              Text(
                'Secure Fallback Active',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              Text(
                lockReason,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32.0),
              // Provide recovery path actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FilledButton.tonalIcon(
                    onPressed: onReturnHome ?? () => Navigator.of(context).popUntil((route) => route.isFirst),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Return to Home'),
                  ),
                  const SizedBox(width: 16.0),
                  FilledButton.icon(
                    onPressed: onReauthenticate ?? () {},
                    icon: const Icon(Icons.lock_reset_rounded),
                    label: const Text('Re-authenticate'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
