// REF-016-A07 — Character-level text formatting mask handler for data entry input fields.
// Provides Poka-Yoke input filtering that drops invalid characters before they register in form state, with MD3-compliant 56px minimum height and full-width responsive layout support.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A Poka-Yoke compliant text formatting mask handler that filters invalid
/// characters from the keyboard buffer before they can register in form state.
///
/// Supports common structured formats such as phone numbers, credit cards,
/// and generic numeric masks. Eliminates manual punctuation entry on mobile devices.
class MaskFormatter extends TextInputFormatter {
  final String mask;
  final Map<String, RegExp> _maskMap;

  /// Creates a [MaskFormatter] with the given [mask] pattern.
  ///
  /// Default mask map:
  /// - '#' matches digits (0-9)
  /// - 'A' matches uppercase letters (A-Z)
  /// - 'a' matches lowercase letters (a-z)
  /// - '*' matches alphanumeric characters
  ///
  /// Any character not defined in [maskMap] is treated as a literal separator.
  MaskFormatter({
    required this.mask,
    Map<String, RegExp>? maskMap,
  }) : _maskMap = maskMap ??
            {
              '#': RegExp(r'[0-9]'),
              'A': RegExp(r'[A-Z]'),
              'a': RegExp(r'[a-z]'),
              '*': RegExp(r'[a-zA-Z0-9]'),
            };

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String newText = newValue.text;
    final StringBuffer maskedText = StringBuffer();
    int maskIndex = 0;
    int textIndex = 0;

    while (maskIndex < mask.length && textIndex < newText.length) {
      final String maskChar = mask[maskIndex];
      final String textChar = newText[textIndex];

      if (_maskMap.containsKey(maskChar)) {
        final RegExp regExp = _maskMap[maskChar]!;
        if (regExp.hasMatch(textChar)) {
          maskedText.write(textChar);
          maskIndex++;
          textIndex++;
        } else {
          // Poka-Yoke: Drop invalid character from the keyboard buffer
          textIndex++;
        }
      } else {
        // Literal separator character in the mask
        maskedText.write(maskChar);
        maskIndex++;
        // If the user typed the separator, consume it; otherwise insert it automatically
        if (textChar == maskChar) {
          textIndex++;
        }
      }
    }

    // Append any remaining literal separators at the end of the mask
    while (maskIndex < mask.length) {
      final String maskChar = mask[maskIndex];
      if (!_maskMap.containsKey(maskChar)) {
        maskedText.write(maskChar);
        maskIndex++;
      } else {
        break;
      }
    }

    final String result = maskedText.toString();
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

/// Predefined common masks for structured data entry.
class CommonMasks {
  CommonMasks._();

  /// US Phone Number: (###) ###-####
  static const String usPhone = '(###) ###-####';

  /// UAE Phone Number: +### ## ### ####
  static const String uaePhone = '+### ## ### ####';

  /// Credit Card: #### #### #### ####
  static const String creditCard = '#### #### #### ####';

  /// Date: ##/##/####
  static const String date = '##/##/####';

  /// Emirates ID: ###-####-#######-#
  static const String emiratesId = '###-####-#######-#';
}

/// An MD3-compliant masked input field that enforces strict formatting,
/// minimum 56px touch target height, and full-width responsive layout.
///
/// Implements mistake-proofing (Poka-Yoke) by dropping invalid characters
/// before they register in the form state memory.
class MaskedInputField extends StatelessWidget {
  final String label;
  final String hint;
  final String mask;
  final Map<String, RegExp>? customMaskMap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final TextInputType keyboardType;
  final bool enabled;

  const MaskedInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.mask,
    this.customMaskMap,
    this.controller,
    this.onChanged,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Mobile-First & Responsive UI: Stretch across full grid column sets
        // on narrow mobile interfaces using flexible flexbox logic.
        return ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 56.0, // MD3 minimum 56px standard for touch access
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            onChanged: onChanged,
            inputFormatters: <TextInputFormatter>[
              MaskFormatter(mask: mask, maskMap: customMaskMap),
            ],
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              errorText: errorText,
              // MD3 error messaging layout rules: short validation error notes
              // to fit within narrow form widths without clipping.
              errorMaxLines: 2,
              filled: true,
              fillColor: enabled
                  ? colorScheme.surfaceContainerHighest.withOpacity(0.3)
                  : colorScheme.onSurface.withOpacity(0.04),
              // Distinctive visual color variables for focus and idle states
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0), // MD3 shape token
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 2.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: colorScheme.outline,
                  width: 1.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 2.0,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                  color: colorScheme.onSurface.withOpacity(0.12),
                  width: 1.0,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0, // Clear padding limits to keep layouts clean
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Mock telemetry data structure for atomic-level data collection requirements.
/// Used locally to satisfy data requirements without backend dependency.
class MaskHandlerTelemetry {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final bool completionStatus;
  final DateTime actionTimestamp;
  final String sessionId;

  const MaskHandlerTelemetry({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.completionStatus,
    required this.actionTimestamp,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'step_execution_id': stepExecutionId,
        'execution_status': executionStatus,
        'execution_timestamp': executionTimestamp.toIso8601String(),
        'step_outcome': stepOutcome,
        'user_id': userId,
        'completion_status': completionStatus ? 'Complete' : 'Not Complete',
        'action_timestamp': actionTimestamp.toIso8601String(),
        'session_id': sessionId,
      };
}

/// Local mock repository providing realistic telemetry data for testing
/// the mask handler system active across the atomic component package registry layer.
class MockMaskTelemetryRepository {
  static List<MaskHandlerTelemetry> getMockData() {
    final DateTime now = DateTime.now();
    return <MaskHandlerTelemetry>[
      MaskHandlerTelemetry(
        stepExecutionId: 'EXEC-REF-016-A07-001',
        executionStatus: 'SUCCESS',
        executionTimestamp: now.subtract(const Duration(minutes: 5)),
        stepOutcome: 'Listener Attachment Rate: 100%',
        userId: 'USER-MOBILE-001',
        completionStatus: true,
        actionTimestamp: now.subtract(const Duration(minutes: 5)),
        sessionId: 'SESS-99281',
      ),
      MaskHandlerTelemetry(
        stepExecutionId: 'EXEC-REF-016-A07-002',
        executionStatus: 'SUCCESS',
        executionTimestamp: now.subtract(const Duration(minutes: 2)),
        stepOutcome: 'Invalid characters dropped successfully',
        userId: 'USER-MOBILE-002',
        completionStatus: true,
        actionTimestamp: now.subtract(const Duration(minutes: 2)),
        sessionId: 'SESS-99282',
      ),
    ];
  }
}
