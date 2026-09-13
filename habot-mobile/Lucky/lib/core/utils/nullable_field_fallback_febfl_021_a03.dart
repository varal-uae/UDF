// FEBFL-021-A03 — Nullable Field Mobile Rendering Fallbacks & Empty State Evaluator.
// Unified string evaluation utilities and Material 3 fallback visualizers that prevent unhandled null crashes and track BigQuery telemetry compliance.

import 'package:flutter/material.dart';

/// BigQuery-aligned compliance payload for tracking fallback occurrences.
@immutable
class FallbackComplianceMetric {
  final String definitionId;
  final String definitionName;
  final String definitionType;
  final String validationStatus;
  final Map<String, dynamic> definitionParameters;
  final String completionStatus;
  final DateTime timestamp;
  final String? sessionId;

  const FallbackComplianceMetric({
    required this.definitionId,
    required this.definitionName,
    required this.definitionType,
    required this.validationStatus,
    this.definitionParameters = const <String, dynamic>{},
    this.completionStatus = 'Complete',
    required this.timestamp,
    this.sessionId,
  });

  Map<String, dynamic> toBigQueryMap() {
    return <String, dynamic>{
      'definition_id': definitionId,
      'definition_name': definitionName,
      'definition_type': definitionType,
      'validation_status': validationStatus,
      'definition_parameters': definitionParameters,
      'completion_status': completionStatus,
      'action_timestamp': timestamp.toIso8601String(),
      'session_id': sessionId ?? 'anonymous',
    };
  }
}

/// Telemetry logger callback signature for field fallback tracking.
typedef FallbackTelemetryDispatcher = void Function(
  FallbackComplianceMetric metric,
);

/// Registry and evaluator for null handling and explicit visual fallbacks.
class NullableFieldEvaluator {
  NullableFieldEvaluator._();

  static final List<FallbackComplianceMetric> _trackedFallbacks = [];
  static FallbackTelemetryDispatcher? _globalDispatcher;

  /// Register a global BigQuery pipeline dispatcher
  static void registerDispatcher(FallbackTelemetryDispatcher dispatcher) {
    _globalDispatcher = dispatcher;
  }

  /// Returns immutable copy of recorded fallback events for audit.
  static List<FallbackComplianceMetric> get recordedMetrics =>
      List.unmodifiable(_trackedFallbacks);

  /// Evaluates a nullable string, enforces non-empty fallback, and logs to telemetry if missing.
  static String evaluate({
    required String? value,
    required String fallback,
    required String definitionId,
    required String definitionName,
    String definitionType = 'Text',
    Map<String, dynamic>? parameters,
    String? sessionId,
  }) {
    assert(
      fallback.trim().isNotEmpty,
      'Poka-Yoke: Fallback placeholder string cannot be blank.',
    );

    final bool isMissing = value == null || value.trim().isEmpty;

    if (isMissing) {
      final metric = FallbackComplianceMetric(
        definitionId: definitionId,
        definitionName: definitionName,
        definitionType: definitionType,
        validationStatus: 'FALLBACK_TRIGGERED',
        definitionParameters: parameters ?? <String, dynamic>{},
        completionStatus: 'Complete',
        timestamp: DateTime.now().toUtc(),
        sessionId: sessionId,
      );
      _trackedFallbacks.add(metric);
      _globalDispatcher?.call(metric);
      return fallback;
    }

    return value;
  }
}

/// Material 3 visual presentation modes for empty/null fallback fields.
enum FallbackDisplayMode {
  inlineText,
  subtleBadge,
  materialEmptyState,
}

/// A defensive widget that guarantees safe mobile rendering of nullable fields.
class NullableFieldView extends StatelessWidget {
  final String? value;
  final String fallbackText;
  final String definitionId;
  final String definitionName;
  final String definitionType;
  final FallbackDisplayMode displayMode;
  final TextStyle? style;
  final TextStyle? fallbackStyle;
  final IconData? emptyStateIcon;

  const NullableFieldView({
    super.key,
    required this.value,
    required this.fallbackText,
    required this.definitionId,
    required this.definitionName,
    this.definitionType = 'Text',
    this.displayMode = FallbackDisplayMode.inlineText,
    this.style,
    this.fallbackStyle,
    this.emptyStateIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMissing = value == null || value!.trim().isEmpty;
    final resolvedText = NullableFieldEvaluator.evaluate(
      value: value,
      fallback: fallbackText,
      definitionId: definitionId,
      definitionName: definitionName,
      definitionType: definitionType,
    );

    if (!isMissing) {
      return Text(
        resolvedText,
        style: style ?? theme.textTheme.bodyMedium,
      );
    }

    switch (displayMode) {
      case FallbackDisplayMode.inlineText:
        return Text(
          resolvedText,
          style: fallbackStyle ??
              theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
        );

      case FallbackDisplayMode.subtleBadge:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Text(
            resolvedText,
            style: fallbackStyle ??
                theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
          ),
        );

      case FallbackDisplayMode.materialEmptyState:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                emptyStateIcon ?? Icons.info_outline,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  resolvedText,
                  style: fallbackStyle ??
                      theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
