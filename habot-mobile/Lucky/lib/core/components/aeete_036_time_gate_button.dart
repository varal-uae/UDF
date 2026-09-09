// AEETE-036 — Dynamic TimeGateButton for overtime hard stops.
// Cross-references inputted hours with daily thresholds, showing inline error tooltips and disabling submission when limits are exceeded without an overtime code.

import 'package:flutter/material.dart';

/// A Material 3 button that enforces daily time logging thresholds.
/// If [inputHours] exceeds [dailyLimitHours] and no [overtimeCode] is provided,
/// the button is disabled and an inline error tooltip is shown.
class TimeGateButton extends StatelessWidget {
  const TimeGateButton({
    super.key,
    required this.inputHours,
    required this.dailyLimitHours,
    this.overtimeCode,
    this.onSubmit,
    this.tooltipMessage = 'Time exceeds allowed limit. Adjust timesheet or provide an Overtime Code.',
  });

  final double inputHours;
  final double dailyLimitHours;
  final String? overtimeCode;
  final VoidCallback? onSubmit;
  final String tooltipMessage;

  bool get _isBlocked => inputHours > dailyLimitHours && (overtimeCode == null || overtimeCode!.isEmpty);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      label: _isBlocked ? 'Submit disabled: ${tooltipMessage}' : 'Submit time entry',
      button: true,
      enabled: !_isBlocked,
      child: Tooltip(
        message: _isBlocked ? tooltipMessage : '',
        child: FilledButton(
          onPressed: _isBlocked ? null : onSubmit,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            disabledBackgroundColor: colorScheme.surfaceContainerHighest,
            disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
            minimumSize: const Size(64, 48),
          ),
          child: const Text('Submit Time'),
        ),
      ),
    );
  }
}
