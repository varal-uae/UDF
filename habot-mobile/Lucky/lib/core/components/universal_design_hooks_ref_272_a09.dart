// REF-272-A09 — Universal Design Library Hook Configuration (Buttons, Inputs).
// Provides standardized Flutter hooks and widgets for buttons and inputs ensuring 48px touch targets, inline error display with high-contrast system red, tight helper text positioning, and seamless state resets.

import 'package:flutter/material.dart';

/// Standardized button hook configuration enforcing Material 3 design tokens,
/// 48px minimum touch targets, and seamless active-state resets.
class UdfButtonConfig {
  const UdfButtonConfig({
    this.minHeight = 48.0,
    this.minWidth = 48.0,
  });

  final double minHeight;
  final double minWidth;
}

/// Standardized input hook configuration enforcing inline error presentation,
/// high-contrast system red error colors, and tight vertical spacing for helper text.
class UdfInputConfig {
  const UdfInputConfig({
    this.minTouchTarget = 48.0,
    this.errorColor = Colors.red,
    this.helperTextSpacing = 4.0,
  });

  final double minTouchTarget;
  final Color errorColor;
  final double helperTextSpacing;
}

/// A standardized universal button that scales safely to fit standard 48px
/// touch targets on mobile devices and resets processing states seamlessly.
class UdfUniversalButton extends StatelessWidget {
  const UdfUniversalButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.config = const UdfButtonConfig(),
    this.isProcessing = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final UdfButtonConfig config;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: config.minHeight,
        minWidth: config.minWidth,
      ),
      child: FilledButton(
        onPressed: isProcessing ? null : onPressed,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: theme.textTheme.labelLarge,
        ),
        child: isProcessing
            ? SizedBox(
                height: 20.0,
                width: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : child,
      ),
    );
  }
}

/// A standardized universal text field that positions text lines tightly beneath
/// input boxes to save vertical layout space, and presents clear visual corrections
/// inline using high-contrast system red to highlight input typos instantly.
class UdfUniversalTextField extends StatefulWidget {
  const UdfUniversalTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.helperText,
    this.errorText,
    this.config = const UdfInputConfig(),
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? helperText;
  final String? errorText;
  final UdfInputConfig config;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  State<UdfUniversalTextField> createState() => _UdfUniversalTextFieldState();
}

class _UdfUniversalTextFieldState extends State<UdfUniversalTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    // Reset processing/error states seamlessly to allow immediate typing corrections.
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && widget.errorText != null) {
        // In a real state management scenario, trigger an event to clear the error here.
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = widget.errorText != null;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: widget.config.minTouchTarget,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: widget.labelText,
          // Position text lines tightly beneath input boxes to save vertical layout space.
          helperText: widget.helperText,
          helperMaxLines: 2,
          helperStyle: theme.textTheme.bodySmall?.copyWith(
            height: 1.0,
          ),
          // Present clear visual corrections inline to protect layout flow from jarring modal block disruptions.
          // Color error layout assets with high-contrast system red to highlight input typos instantly.
          errorText: widget.errorText,
          errorStyle: theme.textTheme.bodySmall?.copyWith(
            color: widget.config.errorColor,
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
          errorMaxLines: 2,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: widget.config.errorColor,
              width: 2.0,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: widget.config.errorColor,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}

/// Mock telemetry data structure aligned with GCP / BigQuery audit tables
/// for interface performance logging as specified in the requirement.
class UdfComponentTelemetryMock {
  const UdfComponentTelemetryMock({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });

  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  Map<String, dynamic> toJson() => {
        'step_execution_id': stepExecutionId,
        'execution_status': executionStatus,
        'execution_timestamp': executionTimestamp.toIso8601String(),
        'step_outcome': stepOutcome,
        'user_id': userId,
      };

  static List<UdfComponentTelemetryMock> get mockLogs => [
        UdfComponentTelemetryMock(
          stepExecutionId: 'REF-272-A09-EXEC-001',
          executionStatus: 'Complete',
          executionTimestamp: DateTime.now(),
          stepOutcome: 'Success',
          userId: 'USR-MOCK-001',
        ),
        UdfComponentTelemetryMock(
          stepExecutionId: 'REF-272-A09-EXEC-002',
          executionStatus: 'Complete',
          executionTimestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          stepOutcome: 'Success',
          userId: 'USR-MOCK-002',
        ),
      ];
}