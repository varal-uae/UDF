// FEBFL-021-A07 — Nullable Field Mobile Rendering Fallbacks.
// Provides an inline conditional layout wrapping system and Material 3 empty-state fallbacks for nullable UI fields.
// Enforces non-null visual integrity, tracks failover state, and logs BigQuery compliance metrics for incomplete records.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Global application status state variable to track active visual failovers.
final ValueNotifier<bool> isFailoverActive = ValueNotifier<bool>(false);

/// Supported layout container categories for rendering nullable fields.
enum FallbackLayoutType {
  inline,
  block,
  gridItem,
  card,
}

/// Design system adherence and completion status rating.
enum FallbackAdherenceRating {
  good,
  average,
  poor,
}

/// Immutable payload captured for audit trails and BigQuery data pipeline tracking.
class FieldMappingMetricEvent {
  final String fieldIdentifier;
  final FallbackLayoutType layoutType;
  final String layoutGridDimensions;
  final String spacingRules;
  final AlignmentGeometry alignmentSettings;
  final bool layoutValidationStatus;
  final FallbackAdherenceRating completionStatus;
  final DateTime timestamp;
  final String sessionId;

  const FieldMappingMetricEvent({
    required this.fieldIdentifier,
    required this.layoutType,
    required this.layoutGridDimensions,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.layoutValidationStatus,
    required this.completionStatus,
    required this.timestamp,
    required this.sessionId,
  });

  Map<String, dynamic> toBigQueryMap() {
    return <String, dynamic>{
      'field_identifier': fieldIdentifier,
      'layout_type': layoutType.name,
      'layout_grid_dimensions': layoutGridDimensions,
      'spacing_rules': spacingRules,
      'alignment_settings': alignmentSettings.toString(),
      'layout_validation_status': layoutValidationStatus,
      'completion_status': completionStatus.name.toUpperCase(),
      'timestamp': timestamp.toIso8601String(),
      'session_id': sessionId,
    };
  }
}

/// Repository registry tracking text fallback telemetry events for audit and BigQuery sync.
class FallbackTrackingRegistry {
  FallbackTrackingRegistry._();
  static final FallbackTrackingRegistry instance = FallbackTrackingRegistry._();

  final List<FieldMappingMetricEvent> _events = <FieldMappingMetricEvent>[];

  List<FieldMappingMetricEvent> get events => List.unmodifiable(_events);

  void recordEvent(FieldMappingMetricEvent event) {
    _events.add(event);
    if (kDebugMode) {
      debugPrint('[BigQuery Telemetry] Field fallback: ${event.toBigQueryMap()}');
    }
  }

  void clear() => _events.clear();
}

/// Production-grade inline conditional layout wrapper for nullable values.
/// Ensures incomplete backend records display accessible fallback states without throwing exceptions.
class NullableFieldFallback extends StatelessWidget {
  const NullableFieldFallback({
    super.key,
    required this.fieldIdentifier,
    required this.value,
    required this.builder,
    this.fallbackText = '—',
    this.customFallbackBuilder,
    this.layoutType = FallbackLayoutType.inline,
    this.layoutGridDimensions = '1x1',
    this.spacingRules = 'margin: 0; padding: 4px 8px;',
    this.alignment = Alignment.centerLeft,
    this.sessionId = 'anonymous_session',
    this.showPlaceholderIcon = true,
    this.textStyle,
    this.fallbackStyle,
  });

  /// Machine identifier for the field, used in audit and telemetry.
  final String fieldIdentifier;

  /// The potentially null or empty raw field value.
  final String? value;

  /// Builder invoked when a valid, non-empty value exists.
  final Widget Function(BuildContext context, String safeValue) builder;

  /// Default textual fallback placeholder conforming to Material guidelines.
  final String fallbackText;

  /// Optional custom empty-state builder if a custom visual template is supplied.
  final Widget Function(BuildContext context)? customFallbackBuilder;

  /// Target layout categorization for structure tracking.
  final FallbackLayoutType layoutType;

  /// Grid or dimension constraints description (e.g. '1x1', '2x4').
  final String layoutGridDimensions;

  /// CSS-like spacing descriptor recorded for compliance evaluation.
  final String spacingRules;

  /// Visual alignment inside the host frame.
  final AlignmentGeometry alignment;

  /// Active user session token for BigQuery tracking.
  final String sessionId;

  /// Whether to show a subtle Material Empty State placeholder icon when falling back.
  final bool showPlaceholderIcon;

  /// Standard text style applied to regular value if built as plain text.
  final TextStyle? textStyle;

  /// Specialized subdued text style applied to fallback placeholder.
  final TextStyle? fallbackStyle;

  bool get _hasValidValue => value != null && value!.trim().isNotEmpty;

  void _emitTelemetry({required bool isValid}) {
    final FallbackAdherenceRating rating = isValid
        ? FallbackAdherenceRating.good
        : (fallbackText.isNotEmpty ? FallbackAdherenceRating.average : FallbackAdherenceRating.poor);

    final FieldMappingMetricEvent event = FieldMappingMetricEvent(
      fieldIdentifier: fieldIdentifier,
      layoutType: layoutType,
      layoutGridDimensions: layoutGridDimensions,
      spacingRules: spacingRules,
      alignmentSettings: alignment,
      layoutValidationStatus: isValid,
      completionStatus: rating,
      timestamp: DateTime.now().toUtc(),
      sessionId: sessionId,
    );

    FallbackTrackingRegistry.instance.recordEvent(event);

    // Keep global application failover indicator updated
    if (!isValid && !isFailoverActive.value) {
      isFailoverActive.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool valid = _hasValidValue;
    _emitTelemetry(isValid: valid);

    return Align(
      alignment: alignment,
      child: valid ? builder(context, value!.trim()) : _buildFallback(context),
    );
  }

  Widget _buildFallback(BuildContext context) {
    if (customFallbackBuilder != null) {
      return customFallbackBuilder!(context);
    }

    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final TextStyle effectiveFallbackStyle = fallbackStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withOpacity(0.65),
          fontStyle: FontStyle.italic,
        ) ??
        const TextStyle(fontStyle: FontStyle.italic);

    if (layoutType == FallbackLayoutType.inline) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAlignmentToFlex.fromAlignment(alignment),
        children: <Widget>[
          if (showPlaceholderIcon) ...<Widget>[
            Icon(
              Icons.remove_circle_outline,
              size: (effectiveFallbackStyle.fontSize ?? 14.0) + 1.0,
              color: colorScheme.outline,
            ),
            const SizedBox(width: 4.0),
          ],
          Flexible(
            child: Text(
              fallbackText,
              style: effectiveFallbackStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    // Material Card / Block Empty State template
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.6),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.info_outline,
            size: 16.0,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8.0),
          Flexible(
            child: Text(
              fallbackText,
              style: effectiveFallbackStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Convenience helper for deriving CrossAxisAlignment from AlignmentGeometry.
class CrossAlignmentToFlex {
  static CrossAxisAlignment fromAlignment(AlignmentGeometry alignment) {
    if (alignment == Alignment.topLeft ||
        alignment == Alignment.centerLeft ||
        alignment == Alignment.bottomLeft) {
      return CrossAxisAlignment.start;
    } else if (alignment == Alignment.topRight ||
        alignment == Alignment.centerRight ||
        alignment == Alignment.bottomRight) {
      return CrossAxisAlignment.end;
    }
    return CrossAxisAlignment.center;
  }
}
