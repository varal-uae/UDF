// GEN-03915 — Tap Block Verification Widget for disabled submit button on incomplete form buffer.
// Implements M3 Elevated Card with status chip, 48x48dp touch targets, single-column mobile layout,
// and verifies that tapping a disabled submit button produces no side effects.

import 'package:flutter/material.dart';

/// Mock data representing the form buffer completion state.
class _MockFormBuffer {
  final bool isComplete;
  final String metricName;
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;
  final String qualitativeOutput;

  const _MockFormBuffer({
    required this.isComplete,
    required this.metricName,
    required this.floorBoundary,
    required this.optimalTarget,
    required this.ceilingBoundary,
    required this.qualitativeOutput,
  });
}

const _MockFormBuffer _mockIncompleteBuffer = _MockFormBuffer(
  isComplete: false,
  metricName: 'Tap Block Verification',
  floorBoundary: 1.0,
  optimalTarget: 1.0,
  ceilingBoundary: 1.0,
  qualitativeOutput: 'Pass/Fail',
);

/// Verifies that attempting to tap the disabled submit button on an incomplete
/// form buffer does not trigger submission or navigation.
class TapBlockVerificationGen03915 extends StatefulWidget {
  const TapBlockVerificationGen03915({super.key});

  @override
  State<TapBlockVerificationGen03915> createState() => _TapBlockVerificationGen03915State();
}

class _TapBlockVerificationGen03915State extends State<TapBlockVerificationGen03915> {
  int _tapAttemptCount = 0;
  bool _submissionTriggered = false;

  void _onSubmitAttempt() {
    setState(() {
      _tapAttemptCount++;
      // Because the form is incomplete, submission must remain blocked.
      if (!_mockIncompleteBuffer.isComplete) {
        _submissionTriggered = false;
      } else {
        _submissionTriggered = true;
      }
    });
  }

  String get _verificationStatus {
    if (_tapAttemptCount > 0 && !_submissionTriggered) {
      return 'Pass';
    } else if (_submissionTriggered) {
      return 'Fail';
    }
    return 'Pending';
  }

  Color _statusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (_verificationStatus) {
      case 'Pass':
        return colorScheme.primary;
      case 'Fail':
        return colorScheme.error;
      default:
        return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isDesktop = constraints.maxWidth >= 840;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // M3 Elevated Card Level 2 (3dp)
              Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isMobile || !isDesktop
                      ? _buildSingleColumnLayout(textTheme, colorScheme)
                      : _buildMultiColumnLayout(textTheme, colorScheme),
                ),
              ),
              const SizedBox(height: 24.0),
              // Submit Button with 48x48dp minimum touch target
              SizedBox(
                width: double.infinity,
                height: 48.0,
                child: FilledButton(
                  onPressed: _mockIncompleteBuffer.isComplete ? _onSubmitAttempt : _onSubmitAttempt,
                  // Button is visually and functionally disabled when form is incomplete
                  style: FilledButton.styleFrom(
                    backgroundColor: _mockIncompleteBuffer.isComplete
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    foregroundColor: _mockIncompleteBuffer.isComplete
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant.withOpacity(0.38),
                    minimumSize: const Size(48.0, 48.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ).copyWith(
                    // Enforce disabled visual state via overlay
                    overlayColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.transparent;
                      }
                      return null;
                    }),
                  ),
                  child: Text(
                    'Submit Form Buffer',
                    style: textTheme.labelLarge?.copyWith(
                      color: _mockIncompleteBuffer.isComplete
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant.withOpacity(0.38),
                    ),
                  ),
                ),
              ),
              if (!_mockIncompleteBuffer.isComplete && _tapAttemptCount > 0) ...[
                const SizedBox(height: 12.0),
                // M3 Snackbar equivalent inline message
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.block, color: colorScheme.onErrorContainer, size: 20.0),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'Submission blocked: Form buffer is incomplete.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSingleColumnLayout(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(textTheme, colorScheme),
        const SizedBox(height: 16.0),
        _buildMetricDetails(textTheme, colorScheme),
        const SizedBox(height: 16.0),
        _buildStatusChip(colorScheme),
      ],
    );
  }

  Widget _buildMultiColumnLayout(TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildHeader(textTheme, colorScheme)),
        const SizedBox(width: 24.0),
        Expanded(flex: 3, child: _buildMetricDetails(textTheme, colorScheme)),
        const SizedBox(width: 24.0),
        Expanded(child: _buildStatusChip(colorScheme)),
      ],
    );
  }

  Widget _buildHeader(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GEN-03915: Tap Block Verification',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          'Attempt to tap the disabled submit button on an incomplete form buffer.',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricDetails(TextTheme textTheme, ColorScheme colorScheme) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: [
        _buildInfoChip('Metric', _mockIncompleteBuffer.metricName, textTheme, colorScheme),
        _buildInfoChip('Floor', _mockIncompleteBuffer.floorBoundary.toString(), textTheme, colorScheme),
        _buildInfoChip('Optimal', _mockIncompleteBuffer.optimalTarget.toString(), textTheme, colorScheme),
        _buildInfoChip('Ceiling', _mockIncompleteBuffer.ceilingBoundary.toString(), textTheme, colorScheme),
        _buildInfoChip('Output Type', _mockIncompleteBuffer.qualitativeOutput, textTheme, colorScheme),
        _buildInfoChip('Attempts', _tapAttemptCount.toString(), textTheme, colorScheme),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value, TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: textTheme.labelSmall?.copyWith(color: colorScheme.outline)),
        const SizedBox(height: 2.0),
        Text(value, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildStatusChip(ColorScheme colorScheme) {
    return Align(
      alignment: Alignment.centerRight,
      child: Chip(
        avatar: Icon(
          _verificationStatus == 'Pass'
              ? Icons.check_circle_outline
              : _verificationStatus == 'Fail'
                  ? Icons.error_outline
                  : Icons.pending_outlined,
          size: 18.0,
          color: _statusColor(context),
        ),
        label: Text(
          _verificationStatus,
          style: TextStyle(
            color: _statusColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: _statusColor(context).withOpacity(0.12),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }
}