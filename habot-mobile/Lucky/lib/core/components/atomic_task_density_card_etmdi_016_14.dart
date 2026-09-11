// ETMDI-016-14 — Atomic task density card with Rule of AND enforcement.
// Provides a Material 3 ElevatedCard for single-focus mobile tasks, centered alignment, generous padding, and input-field density validation against a cognitive overload threshold.
import 'package:flutter/material.dart';

class AtomicTaskDensityCardEtmdi01614 extends StatelessWidget {
  const AtomicTaskDensityCardEtmdi01614({
    super.key,
    required this.title,
    required this.description,
    required this.inputFieldCount,
    this.maxInputFields = 5,
    this.child,
    this.onPressed,
    this.actionLabel,
  });

  final String title;
  final String description;
  final int inputFieldCount;
  final int maxInputFields;
  final Widget? child;
  final VoidCallback? onPressed;
  final String? actionLabel;

  bool get isDensityValid => inputFieldCount <= maxInputFields;
  double get densityRatio => maxInputFields == 0 ? 0 : (inputFieldCount / maxInputFields).clamp(0, 1).toDouble();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Card(
          elevation: 3,
          shape: shape,
          color: colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  isDensityValid ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                  size: 40,
                  color: isDensityValid ? colorScheme.primary : colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _DensityMeter(
                  ratio: densityRatio,
                  valid: isDensityValid,
                  inputFieldCount: inputFieldCount,
                  maxInputFields: maxInputFields,
                ),
                if (child != null) ...[
                  const SizedBox(height: 24),
                  child!,
                ],
                if (onPressed != null && actionLabel != null) ...[
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: isDensityValid ? onPressed : null,
                    child: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DensityMeter extends StatelessWidget {
  const _DensityMeter({
    required this.ratio,
    required this.valid,
    required this.inputFieldCount,
    required this.maxInputFields,
  });

  final double ratio;
  final bool valid;
  final int inputFieldCount;
  final int maxInputFields;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeColor = valid ? colorScheme.primary : colorScheme.error;

    return Semantics(
      label: 'Input field density: $inputFieldCount of $maxInputFields. ${valid ? 'Within threshold' : 'Over threshold'}.',
      value: '$inputFieldCount/$maxInputFields',
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              color: activeColor,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Input fields: $inputFieldCount / $maxInputFields',
            style: theme.textTheme.labelLarge?.copyWith(color: activeColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AtomicTaskAxisScaler {
  const AtomicTaskAxisScaler._();

  static double scale({
    required double value,
    required double dataMin,
    required double dataMax,
    required double outputMin,
    required double outputMax,
  }) {
    if (dataMax <= dataMin) return outputMin;
    final clamped = value.clamp(dataMin, dataMax).toDouble();
    final ratio = (clamped - dataMin) / (dataMax - dataMin);
    return outputMin + ratio * (outputMax - outputMin);
  }
}
