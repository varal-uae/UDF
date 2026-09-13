// FEBFL-021-A17 — Nullable Field Mobile Rendering Fallbacks.
// Provides a unified Material Empty State and text fallback handler for nullable fields to prevent UI crashes and ensure continuous data scanning.

import 'package:flutter/material.dart';

/// Shared configuration for empty state layouts, spacing, and transitions.
/// Replaces ad hoc, component-specific transition values.
class FallbackLayoutConfig {
  static const double defaultSpacing = 12.0;
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double iconSize = 20.0;
  static const Duration defaultTransitionDuration = Duration(milliseconds: 300);
  static const Curve defaultTransitionCurve = Curves.easeInOut;
}

/// Unified string evaluation utility for null handling (Frontend Utils).
class NullHandler {
  /// Evaluates a string and returns a fallback if it is null or empty.
  static String evaluateString(String? input, {String fallback = 'N/A'}) {
    if (input == null || input.trim().isEmpty) {
      return fallback;
    }
    return input;
  }

  /// Generic check to determine if a value is considered "empty" in the UI context.
  static bool isEmpty<T>(T? value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is Iterable) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }
}

/// A widget that conditionally renders a value or a Material Empty State fallback.
/// 
/// Mistake-Proofing (Poka-Yoke): By requiring a strongly typed [value] and [builder],
/// compilation fails if a developer attempts to map an empty value without using
/// this fallback definition wrapper.
class NullableFieldFallback<T> extends StatelessWidget {
  final T? value;
  final Widget Function(BuildContext context, T value) builder;
  final Widget? fallbackWidget;
  final String fallbackText;
  final IconData fallbackIcon;
  final bool animated;

  const NullableFieldFallback({
    Key? key,
    required this.value,
    required this.builder,
    this.fallbackWidget,
    this.fallbackText = 'No data available',
    this.fallbackIcon = Icons.info_outline,
    this.animated = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isValueEmpty = NullHandler.isEmpty(value);
    
    final Widget content = isValueEmpty
        ? (fallbackWidget ?? _buildMaterialEmptyState(context))
        : builder(context, value as T);

    if (!animated) return content;

    return AnimatedSwitcher(
      duration: FallbackLayoutConfig.defaultTransitionDuration,
      switchInCurve: FallbackLayoutConfig.defaultTransitionCurve,
      switchOutCurve: FallbackLayoutConfig.defaultTransitionCurve,
      child: KeyedSubtree(
        key: ValueKey<bool>(isValueEmpty),
        child: content,
      ),
    );
  }

  /// Constructs a clean, Material 3 compliant empty state visualization.
  Widget _buildMaterialEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FallbackLayoutConfig.defaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(FallbackLayoutConfig.defaultBorderRadius),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            fallbackIcon,
            size: FallbackLayoutConfig.iconSize,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: FallbackLayoutConfig.defaultSpacing),
          Flexible(
            child: Text(
              fallbackText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
