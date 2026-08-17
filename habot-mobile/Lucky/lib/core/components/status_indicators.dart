import 'package:flutter/material.dart';

// CTTEE-031-09 — MD3 Status Chips & Badges (A−B=0 visual feedback).
// Spec: "Render immediate visual feedback using Material Design Chips or Badges."
//       "Pin critical status blocks to top layout layers."
//       "Shift tracking element colors as limits approach."
//       "Use subtle accent motion tracks to preserve focus."
//       "Use distinct layout templates for circular metric displays."

// ── Status chip ───────────────────────────────────────────────────────────────

enum StatusLevel { success, warning, critical, info, neutral }

extension StatusLevelX on StatusLevel {
  Color bgColor(ColorScheme cs) {
    switch (this) {
      case StatusLevel.success:  return cs.secondaryContainer;
      case StatusLevel.warning:  return cs.tertiaryContainer;
      case StatusLevel.critical: return cs.errorContainer;
      case StatusLevel.info:     return cs.primaryContainer;
      case StatusLevel.neutral:  return cs.surfaceContainerHighest;
    }
  }

  Color fgColor(ColorScheme cs) {
    switch (this) {
      case StatusLevel.success:  return cs.onSecondaryContainer;
      case StatusLevel.warning:  return cs.onTertiaryContainer;
      case StatusLevel.critical: return cs.onErrorContainer;
      case StatusLevel.info:     return cs.onPrimaryContainer;
      case StatusLevel.neutral:  return cs.onSurfaceVariant;
    }
  }

  IconData get icon {
    switch (this) {
      case StatusLevel.success:  return Icons.check_circle_rounded;
      case StatusLevel.warning:  return Icons.warning_amber_rounded;
      case StatusLevel.critical: return Icons.error_rounded;
      case StatusLevel.info:     return Icons.info_rounded;
      case StatusLevel.neutral:  return Icons.circle_outlined;
    }
  }
}

/// MD3 status chip — immediate visual feedback on any status change.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.level,
    this.showIcon = true,
    this.onTap,
  });

  final String label;
  final StatusLevel level;
  final bool showIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve:    Curves.easeOut,
        padding:  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color:        level.bgColor(cs),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(level.icon, size: 14, color: level.fgColor(cs)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize:   12,
                fontWeight: FontWeight.w600,
                color:      level.fgColor(cs),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Numeric badge ─────────────────────────────────────────────────────────────

/// Badge showing a count — shifts color as value approaches limit.
/// Spec: "Shift tracking element colors as limits approach."
class ThresholdBadge extends StatelessWidget {
  const ThresholdBadge({
    super.key,
    required this.value,
    required this.limit,
    this.warningThreshold = 0.8,
    this.size = 24.0,
  });

  final int value;
  final int limit;

  /// Fraction of limit at which color shifts to warning. Default 80%.
  final double warningThreshold;
  final double size;

  StatusLevel get _level {
    if (limit <= 0) return StatusLevel.neutral;
    final ratio = value / limit;
    if (ratio >= 1.0) return StatusLevel.critical;
    if (ratio >= warningThreshold) return StatusLevel.warning;
    return StatusLevel.success;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration:    const Duration(milliseconds: 300),
      curve:       Curves.easeOut,
      width:       size,
      height:      size,
      decoration:  BoxDecoration(
        color: _level.bgColor(cs),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          value > 99 ? '99+' : '$value',
          style: TextStyle(
            fontSize:   size * 0.42,
            fontWeight: FontWeight.w700,
            color:      _level.fgColor(cs),
          ),
        ),
      ),
    );
  }
}

// ── Circular metric display ───────────────────────────────────────────────────

/// Circular progress metric — distinct template for circular displays.
/// Spec: "Use distinct layout templates for circular metric displays."
class CircularMetric extends StatelessWidget {
  const CircularMetric({
    super.key,
    required this.value,
    required this.total,
    required this.label,
    this.size = 80.0,
    this.strokeWidth = 6.0,
  });

  final double value;
  final double total;
  final String label;
  final double size;
  final double strokeWidth;

  double get _progress => total > 0 ? (value / total).clamp(0.0, 1.0) : 0;

  StatusLevel get _level {
    if (_progress >= 1.0)         return StatusLevel.success;
    if (_progress >= 0.8)         return StatusLevel.warning;
    if (_progress < 0.2 && total > 0) return StatusLevel.critical;
    return StatusLevel.info;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return SizedBox(
      width:  size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          SizedBox(
            width:  size,
            height: size,
            child: CircularProgressIndicator(
              value:       1.0,
              strokeWidth: strokeWidth,
              color:       cs.surfaceContainerHighest,
            ),
          ),
          // Animated progress arc
          SizedBox(
            width:  size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween:    Tween(begin: 0, end: _progress),
              duration: const Duration(milliseconds: 600),
              curve:    Curves.easeOut,
              builder:  (_, v, __) => CircularProgressIndicator(
                value:       v,
                strokeWidth: strokeWidth,
                color:       _level.bgColor(cs),
                strokeCap:   StrokeCap.round,
              ),
            ),
          ),
          // Center label
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(_progress * 100).round()}%',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Subtraction formula display (A-B=0) ──────────────────────────────────────

/// Visual display for A−B=0 formula tracking.
/// Shows A, B, and the delta — shifts color when delta ≠ 0.
class SubtractionFormulaChip extends StatelessWidget {
  const SubtractionFormulaChip({
    super.key,
    required this.valueA,
    required this.valueB,
    this.labelA = 'A',
    this.labelB = 'B',
  });

  final double valueA;
  final double valueB;
  final String labelA;
  final String labelB;

  double get _delta => valueA - valueB;
  bool get _isZero  => _delta.abs() < 0.001;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;
    final level = _isZero ? StatusLevel.success : StatusLevel.critical;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding:  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:        level.bgColor(cs),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$labelA: ${valueA.toStringAsFixed(2)}',
              style: theme.textTheme.labelMedium?.copyWith(
                  color: level.fgColor(cs), fontWeight: FontWeight.w600)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('−',
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: level.fgColor(cs))),
          ),
          Text('$labelB: ${valueB.toStringAsFixed(2)}',
              style: theme.textTheme.labelMedium?.copyWith(
                  color: level.fgColor(cs), fontWeight: FontWeight.w600)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('=',
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: level.fgColor(cs))),
          ),
          Text(
            _isZero ? '0 ✓' : _delta.toStringAsFixed(2),
            style: theme.textTheme.labelLarge?.copyWith(
              color:      level.fgColor(cs),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
