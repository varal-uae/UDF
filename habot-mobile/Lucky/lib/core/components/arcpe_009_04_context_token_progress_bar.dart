// ARCPE-009-04 — Context Token Progress Bar & Pruning Warning Overlay.
// Renders a visible context token progress bar near document zones with dynamic color shifting, animated width transitions, and accessibility semantics.
import 'package:flutter/material.dart';

/// A Material 3 progress bar that visualizes context token consumption.
///
/// The bar is intended to be placed near document zones so users can see
/// when context pruning is approaching. Color shifts from primary to
/// warning/error as the consumed token ratio crosses thresholds, and the
/// width transition is animated to reflect token count changes.
class ContextTokenProgressBar extends StatelessWidget {
  const ContextTokenProgressBar({
    super.key,
    required this.usedTokens,
    required this.totalTokens,
    this.warningThreshold = 0.7,
    this.criticalThreshold = 0.9,
    this.height = 8,
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
    this.showWarningBadge = true,
    this.semanticLabel = 'Context token usage',
  }) : assert(usedTokens >= 0),
       assert(totalTokens > 0),
       assert(warningThreshold >= 0 && warningThreshold <= 1),
       assert(criticalThreshold >= 0 && criticalThreshold <= 1),
       assert(warningThreshold < criticalThreshold);

  final int usedTokens;
  final int totalTokens;
  final double warningThreshold;
  final double criticalThreshold;
  final double height;
  final BorderRadius borderRadius;
  final bool showWarningBadge;
  final String semanticLabel;

  double get _ratio {
    if (totalTokens <= 0) return 1.0;
    return (usedTokens / totalTokens).clamp(0.0, 1.0);
  }

  bool get _isWarning => _ratio >= warningThreshold;
  bool get _isCritical => _ratio >= criticalThreshold;

  Color _resolveColor(ColorScheme scheme) {
    if (_isCritical) return scheme.error;
    if (_isWarning) return scheme.tertiary;
    return scheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final barColor = _resolveColor(colorScheme);

    return Semantics(
      label: semanticLabel,
      value: '$usedTokens of $totalTokens tokens used (${(_ratio * 100).round()}%)',
      hint: _isCritical
          ? 'Context limit nearly reached. Consider pruning.'
          : _isWarning
              ? 'Context usage is elevated.'
              : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: borderRadius,
            child: SizedBox(
              height: height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: _ratio),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedRatio, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: animatedRatio,
                        child: child,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: borderRadius,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showWarningBadge && _isWarning) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: DecoratedBox(
                  key: ValueKey(_isCritical ? 'critical' : 'warning'),
                  decoration: BoxDecoration(
                    color: barColor.withAlpha(36),
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    child: Text(
                      _isCritical ? 'Context limit critical' : 'Context usage elevated',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: barColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
