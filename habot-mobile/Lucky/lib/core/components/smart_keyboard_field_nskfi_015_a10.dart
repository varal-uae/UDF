// NSKFI-015-A10 — SmartKeyboardField Form Atom with Virtual Keyboard Layout Interceptors.
// Provides mobile-first numeric/text input fields that auto-switch keyboard types, enforce real-time input masks, and highlight borders on validation breaches per Material 3 standards.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enum representing the execution outcome of the field interaction.
enum StepOutcome { complete, partial, notComplete }

/// Data class to capture atomic-level telemetry for this step.
class FieldExecutionData {
  final String stepExecutionId;
  final String userId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final StepOutcome stepOutcome;

  const FieldExecutionData({
    required this.stepExecutionId,
    required this.userId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
  });

  Map<String, dynamic> toJson() => {
        'stepExecutionId': stepExecutionId,
        'userId': userId,
        'executionStatus': executionStatus,
        'executionTimestamp': executionTimestamp.toIso8601String(),
        'stepOutcome': stepOutcome.name,
      };
}

/// A reusable form atom that intercepts virtual keyboard layouts,
/// applies real-time formatting, and highlights borders when validation fails.
class SmartKeyboardField extends StatefulWidget {
  final String label;
  final String? helperText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool isNumericOnly;

  const SmartKeyboardField({
    super.key,
    required this.label,
    this.helperText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.controller,
    this.isNumericOnly = false,
  });

  @override
  State<SmartKeyboardField> createState() => _SmartKeyboardFieldState();
}

class _SmartKeyboardFieldState extends State<SmartKeyboardField> {
  late final TextEditingController _controller;
  bool _hasInteracted = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (!_hasInteracted) {
      setState(() => _hasInteracted = true);
    }

    // Real-time validation gate
    if (widget.validator != null) {
      final error = widget.validator!(_controller.text);
      if (error != _errorText) {
        setState(() => _errorText = error);
      }
    }

    widget.onChanged?.call(_controller.text);
  }

  /// Determines the precise keyboard type to eliminate manual typos (Poka-Yoke).
  TextInputType get _resolvedKeyboardType {
    if (widget.isNumericOnly) {
      return TextInputType.number;
    }
    return widget.keyboardType;
  }

  /// Builds input formatters including blocking letters from numeric entries.
  List<TextInputFormatter> get _resolvedFormatters {
    final formatters = <TextInputFormatter>[];
    if (widget.isNumericOnly) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }
    if (widget.inputFormatters != null) {
      formatters.addAll(widget.inputFormatters!);
    }
    return formatters;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isError = _hasInteracted && _errorText != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controller,
        keyboardType: _resolvedKeyboardType,
        inputFormatters: _resolvedFormatters,
        // Comfortable tap zone sizing metrics for handheld ergonomics
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          helperText: widget.helperText,
          errorText: isError ? _errorText : null,
          filled: true,
          fillColor: isError
              ? colorScheme.errorContainer.withOpacity(0.3)
              : colorScheme.surfaceContainerHighest.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: isError ? colorScheme.error : colorScheme.outline,
              width: isError ? 2.0 : 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: isError ? colorScheme.error : colorScheme.primary,
              width: 2.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: colorScheme.error, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 16.0,
          ),
        ),
      ),
    );
  }
}

/// Mock repository providing realistic local data for testing without backend.
class MockTelemetryRepository {
  static const String mockUserId = 'usr_udf_mobile_001';
  static const String mockSessionId = 'sess_nskfi_015_a10_999';

  static FieldExecutionData generateMockExecutionData({
    required StepOutcome outcome,
  }) {
    return FieldExecutionData(
      stepExecutionId: 'exec_${DateTime.now().millisecondsSinceEpoch}',
      userId: mockUserId,
      executionStatus: outcome == StepOutcome.complete ? 'PASS' : 'FAIL',
      executionTimestamp: DateTime.now(),
      stepOutcome: outcome,
    );
  }

  static List<FieldExecutionData> getMockHistory() {
    return [
      generateMockExecutionData(outcome: StepOutcome.complete),
      generateMockExecutionData(outcome: StepOutcome.partial),
      generateMockExecutionData(outcome: StepOutcome.notComplete),
    ];
  }
}

/// Example usage / Integration Blueprint demonstrating the SmartKeyboardField.
class InputKeyboardIntegrationBlueprint extends StatelessWidget {
  const InputKeyboardIntegrationBlueprint({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NSKFI-015-A10 Blueprint'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mobile Virtual Keyboard Layout Interceptors',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            SmartKeyboardField(
              label: 'Phone Number',
              helperText: 'Enter 10-digit mobile number',
              isNumericOnly: true,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required';
                }
                if (value.length < 10) {
                  return 'Must be exactly 10 digits';
                }
                return null;
              },
              onChanged: (val) {
                // Trigger telemetry or state updates
                debugPrint('Numeric input changed: $val');
              },
            ),
            const SizedBox(height: 16),
            SmartKeyboardField(
              label: 'Full Name',
              helperText: 'Alphabetic characters only',
              keyboardType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // Simulate QA Pass Rate check
                final data = MockTelemetryRepository.generateMockExecutionData(
                  outcome: StepOutcome.complete,
                );
                debugPrint('Execution Data: ${data.toJson()}');
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Validate & Record Execution'),
            ),
          ],
        ),
      ),
    );
  }
}