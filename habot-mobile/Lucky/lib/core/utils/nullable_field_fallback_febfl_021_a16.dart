// FEBFL-021-A16 — Nullable Field Mobile Rendering Fallbacks.
// Provides unified null-safety evaluation utilities, conditional display templates, and Material 3 empty-state components
// to guard mobile screens against incomplete database states while tracking fallback metrics for BigQuery compliance audits.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Callback signature for dispatching fallback telemetry events to data pipelines.
typedef FallbackTelemetryCallback = void Function(FallbackMetricRecord metric);

/// Record tracking unpopulated or null fields for BigQuery compliance pipelines.
@immutable
class FallbackMetricRecord {
  final String fieldIdentifier;
  final String entityName;
  final String fallbackType;
  final DateTime timestamp;
  final dynamic rawValue;
  final Map<String, dynamic>? metadata;

  FallbackMetricRecord({
    required this.fieldIdentifier,
    required this.entityName,
    required this.fallbackType,
    required this.timestamp,
    this.rawValue,
    this.metadata,
  });

  Map<String, dynamic> toBigQueryRow() => <String, dynamic>{
        'field_identifier': fieldIdentifier,
        'entity_name': entityName,
        'fallback_type': fallbackType,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'is_null': rawValue == null,
        'raw_value_type': rawValue?.runtimeType.toString() ?? 'null',
        if (metadata != null) ...metadata!,
      };
}

/// Visual style representation for fallback placeholders.
enum FallbackDisplayStyle {
  subtlePlaceholder,
  badge,
  italicText,
  emptyContainer,
  materialCard,
}

/// Core utility offering safe evaluations, standard placeholder string mappings,
/// and Poka-Yoke assertions to avoid runtime exceptions.
class NullHandlerUtils {
  NullHandlerUtils._();

  static const String defaultFallbackString = '—';
  static const String defaultUnspecifiedString = 'Not specified';

  /// Registry for global fallback telemetry listeners (e.g. BigQuery pipeline bridge).
  static final List<FallbackTelemetryCallback> _telemetryListeners = <FallbackTelemetryCallback>[];

  static void registerTelemetryListener(FallbackTelemetryCallback listener) {
    if (!_telemetryListeners.contains(listener)) {
      _telemetryListeners.add(listener);
    }
  }

  static void unregisterTelemetryListener(FallbackTelemetryCallback listener) {
    _telemetryListeners.remove(listener);
  }

  /// Dispatches a telemetry metric to all registered pipelines.
  static void recordFallbackEvent({
    required String fieldIdentifier,
    required String entityName,
    required String fallbackType,
    dynamic rawValue,
    Map<String, dynamic>? metadata,
  }) {
    final metric = FallbackMetricRecord(
      fieldIdentifier: fieldIdentifier,
      entityName: entityName,
      fallbackType: fallbackType,
      timestamp: DateTime.now(),
      rawValue: rawValue,
      metadata: metadata,
    );

    for (final listener in _telemetryListeners) {
      try {
        listener(metric);
      } catch (e, stackTrace) {
        debugPrint('FallbackTelemetry listener error: $e\n$stackTrace');
      }
    }
  }

  /// Checks if [value] is null, an empty string, or whitespace only.
  static bool isNullOrBlank(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is Iterable) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }

  /// Resolves string value with enforced fallback. Poka-Yoke ensures [fallback] cannot be blank.
  static String safeString(
    String? value, {
    String fallback = defaultFallbackString,
    String? fieldIdentifier,
    String? entityName,
  }) {
    assert(
      fallback.trim().isNotEmpty,
      'Poka-Yoke: Fallback string must not be empty or blank.',
    );

    if (value == null || value.trim().isEmpty) {
      if (fieldIdentifier != null) {
        recordFallbackEvent(
          fieldIdentifier: fieldIdentifier,
          entityName: entityName ?? 'GenericEntity',
          fallbackType: 'StringFallback',
          rawValue: value,
        );
      }
      return fallback;
    }
    return value;
  }

  /// Safely resolves a number or returns a fallback format.
  static String safeNumber<T extends num>(
    T? value, {
    String fallback = defaultFallbackString,
    String Function(T val)? formatter,
    String? fieldIdentifier,
    String? entityName,
  }) {
    assert(
      fallback.trim().isNotEmpty,
      'Poka-Yoke: Fallback string must not be empty or blank.',
    );

    if (value == null) {
      if (fieldIdentifier != null) {
        recordFallbackEvent(
          fieldIdentifier: fieldIdentifier,
          entityName: entityName ?? 'GenericEntity',
          fallbackType: 'NumberFallback',
          rawValue: value,
        );
      }
      return fallback;
    }
    return formatter != null ? formatter(value) : value.toString();
  }
}

/// Material 3 Text widget that safely renders text or falls back to a graceful placeholder.
class NullableText extends StatelessWidget {
  final String? text;
  final String fallbackText;
  final TextStyle? style;
  final TextStyle? fallbackStyle;
  final TextOverflow overflow;
  final int? maxLines;
  final TextAlign? textAlign;
  final String? fieldIdentifier;
  final String? entityName;
  final FallbackDisplayStyle displayStyle;

  const NullableText(
    this.text, {
    super.key,
    this.fallbackText = NullHandlerUtils.defaultFallbackString,
    this.style,
    this.fallbackStyle,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.textAlign,
    this.fieldIdentifier,
    this.entityName,
    this.displayStyle = FallbackDisplayStyle.subtlePlaceholder,
  }) : assert(
          fallbackText.length > 0,
          'Poka-Yoke: NullableText requires a non-empty fallbackText',
        );

  @override
  Widget build(BuildContext context) {
    final isMissing = NullHandlerUtils.isNullOrBlank(text);
    final theme = Theme.of(context);

    if (isMissing) {
      if (fieldIdentifier != null) {
        NullHandlerUtils.recordFallbackEvent(
          fieldIdentifier: fieldIdentifier!,
          entityName: entityName ?? 'ScreenUI',
          fallbackType: 'NullableTextFallback',
          rawValue: text,
        );
      }

      final defaultFallbackThemeStyle = theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.60),
        fontStyle: FontStyle.italic,
      );
      final resolvedFallbackStyle = fallbackStyle ?? defaultFallbackThemeStyle;

      if (displayStyle == FallbackDisplayStyle.badge) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Text(
            fallbackText,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }

      return Text(
        fallbackText,
        style: resolvedFallbackStyle,
        overflow: overflow,
        maxLines: maxLines,
        textAlign: textAlign,
      );
    }

    return Text(
      text!,
      style: style ?? theme.textTheme.bodyMedium,
      overflow: overflow,
      maxLines: maxLines,
      textAlign: textAlign,
    );
  }
}

/// Generic conditional renderer that guarantees fallback visualization for nullable objects.
class NullableFieldRenderer<T> extends StatelessWidget {
  final T? value;
  final Widget Function(BuildContext context, T nonNullValue) builder;
  final Widget Function(BuildContext context)? fallbackBuilder;
  final String fallbackLabel;
  final IconData? fallbackIcon;
  final String? fieldIdentifier;
  final String? entityName;

  const NullableFieldRenderer({
    super.key,
    required this.value,
    required this.builder,
    this.fallbackBuilder,
    this.fallbackLabel = 'Information unavailable',
    this.fallbackIcon = Icons.info_outline,
    this.fieldIdentifier,
    this.entityName,
  });

  @override
  Widget build(BuildContext context) {
    final val = value;
    final isMissing = val == null || NullHandlerUtils.isNullOrBlank(val);

    if (isMissing) {
      if (fieldIdentifier != null) {
        NullHandlerUtils.recordFallbackEvent(
          fieldIdentifier: fieldIdentifier!,
          entityName: entityName ?? 'FieldView',
          fallbackType: 'NullableFieldRendererFallback',
          rawValue: val,
        );
      }

      if (fallbackBuilder != null) {
        return fallbackBuilder!(context);
      }

      return MaterialEmptyState(
        title: fallbackLabel,
        icon: fallbackIcon,
        isCompact: true,
      );
    }

    return builder(context, val);
  }
}

/// Material 3 standard Empty State widget for unpopulated screens or sections.
class MaterialEmptyState extends StatelessWidget {
  final String title;
  final String? description;
  final IconData? icon;
  final Widget? actionButton;
  final bool isCompact;

  const MaterialEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.actionButton,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...[
              Icon(
                icon,
                size: 16.0,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6.0),
            ],
            Flexible(
              child: Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 36.0,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16.0),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8.0),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (actionButton != null) ...[
              const SizedBox(height: 16.0),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}
