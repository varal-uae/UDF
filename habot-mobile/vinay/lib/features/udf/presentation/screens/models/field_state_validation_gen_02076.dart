// GEN-02076 — Detach field state data explicitly from submission validation logic.
// Implements a decoupled architecture where FieldStateData is strictly separated from SubmissionValidationResult, ensuring independent evaluation and M3 UI readiness.

import 'package:flutter/material.dart';

/// Represents the raw state of a form field, completely detached from validation.
class FieldStateData {
  final String fieldId;
  final dynamic value;
  final bool isTouched;
  final bool isDirty;
  final DateTime lastModified;

  const FieldStateData({
    required this.fieldId,
    this.value,
    this.isTouched = false,
    this.isDirty = false,
    required this.lastModified,
  });

  FieldStateData copyWith({
    String? fieldId,
    dynamic value,
    bool? isTouched,
    bool? isDirty,
    DateTime? lastModified,
  }) {
    return FieldStateData(
      fieldId: fieldId ?? this.fieldId,
      value: value ?? this.value,
      isTouched: isTouched ?? this.isTouched,
      isDirty: isDirty ?? this.isDirty,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}

/// Represents the outcome of submission validation, independent of field state storage.
class SubmissionValidationResult {
  final bool isValid;
  final Map<String, String> errors;
  final double completionRate;

  const SubmissionValidationResult({
    required this.isValid,
    required this.errors,
    required this.completionRate,
  });
}

/// Engine responsible for evaluating validation rules against detached field states.
class DetachedValidationEngine {
  /// Validates a map of detached field states without mutating them.
  SubmissionValidationResult validate(Map<String, FieldStateData> fields) {
    final Map<String, String> errors = {};
    int completedCount = 0;

    for (final entry in fields.entries) {
      final fieldId = entry.key;
      final state = entry.value;

      // Mock validation logic: value must not be null or empty string
      if (state.value == null || (state.value is String && (state.value as String).trim().isEmpty)) {
        errors[fieldId] = 'Field $fieldId is required.';
      } else {
        completedCount++;
      }
    }

    final double completionRate = fields.isEmpty
        ? 100.0
        : (completedCount / fields.length) * 100.0;

    return SubmissionValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      completionRate: completionRate,
    );
  }
}

/// Mock repository providing initial detached field states.
class MockFieldStateRepository {
  static Map<String, FieldStateData> getInitialStates() {
    final now = DateTime.now();
    return {
      'username': FieldStateData(
        fieldId: 'username',
        value: 'john_doe',
        isTouched: true,
        isDirty: false,
        lastModified: now,
      ),
      'email': FieldStateData(
        fieldId: 'email',
        value: '',
        isTouched: true,
        isDirty: true,
        lastModified: now,
      ),
      'role': FieldStateData(
        fieldId: 'role',
        value: 'engineer',
        isTouched: false,
        isDirty: false,
        lastModified: now,
      ),
    };
  }
}

/// M3 Status Chip widget for displaying step health indicators.
class ValidationStatusChip extends StatelessWidget {
  final bool isValid;
  final double completionRate;

  const ValidationStatusChip({
    super.key,
    required this.isValid,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isValid ? colorScheme.primaryContainer : colorScheme.errorContainer;
    final foregroundColor = isValid ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer;

    return Chip(
      avatar: Icon(
        isValid ? Icons.check_circle_outline : Icons.error_outline,
        color: foregroundColor,
        size: 18,
      ),
      label: Text(
        '${completionRate.toStringAsFixed(1)}% Complete',
        style: TextStyle(color: foregroundColor),
      ),
      backgroundColor: backgroundColor,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

/// M3 Elevated Card Level 2 (3dp) displaying detached field state and validation status.
class FieldStateCard extends StatelessWidget {
  final FieldStateData state;
  final String? errorMessage;

  const FieldStateCard({
    super.key,
    required this.state,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.fieldId.toUpperCase(),
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Value: ${state.value ?? "null"}',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildSemanticIndicator('Touched', state.isTouched, context),
                const SizedBox(width: 16),
                _buildSemanticIndicator('Dirty', state.isDirty, context),
              ],
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSemanticIndicator(String label, bool isActive, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isActive ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          size: 16,
          color: isActive ? colorScheme.secondary : colorScheme.outline,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isActive ? colorScheme.onSurface : colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
