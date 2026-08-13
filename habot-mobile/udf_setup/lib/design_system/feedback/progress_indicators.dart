/// AISS: GEN-01848-A01 -- "Implement visual progress indicators to show user
/// advancement."
///
/// Two indicators, one rule: a progress indicator must say *something* about
/// how far along the user is. A spinner that spins forever is not progress, it
/// is an apology -- so the determinate form is the default and the
/// indeterminate one has to be asked for by name.
///
/// Reduced motion is handled structurally rather than by shortening the
/// animation: under [HabotMotionPolicy.prefersReducedMotion] an indeterminate
/// indicator degrades to a static track with a text percentage, because a
/// looping animation is precisely what the preference is asking to be spared
/// (the same reasoning BPTR-0422 applied to the failure pulse).
library;

import 'package:flutter/material.dart';

import '../tokens/motion_tokens.dart';
import '../tokens/shape_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/surface_tokens.dart';

/// Shared progress rules, unit-testable without building a widget.
class HabotProgressPolicy {
  const HabotProgressPolicy._();

  /// Clamps any caller-supplied fraction into [0, 1]. A progress bar showing
  /// 140% is a bug the user should never have to see.
  static double clamp(double value) => value.clamp(0.0, 1.0);

  /// The label a screen reader announces. Percentages, not "loading" -- the
  /// number is the information.
  static String semanticsValue(double value) =>
      '${(clamp(value) * 100).round()}%';

  /// Whether an indeterminate indicator may animate here.
  static bool mayAnimate(BuildContext context) =>
      HabotMotionPolicy.allowsLoopingMotion(context);

  /// True when [value] is a real measurement rather than "unknown".
  static bool isDeterminate(double? value) => value != null;
}

/// A linear progress track. The default indicator for anything with a known
/// number of steps: uploads, multi-step forms, batch operations.
class HabotProgressBar extends StatelessWidget {
  const HabotProgressBar({required this.value, this.label, super.key});

  /// Null means indeterminate -- and under reduced motion, that degrades to a
  /// static empty track rather than an animation.
  final double? value;

  final String? label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool animate = HabotProgressPolicy.mayAnimate(context);
    final double? resolved = value ?? (animate ? null : 0);
    return LinearProgressIndicator(
      value: resolved,
      minHeight: HabotFeedback.progressTrackHeight,
      borderRadius: BorderRadius.circular(HabotFeedback.progressCornerRadius),
      backgroundColor: scheme.surfaceContainerHighest,
      color: scheme.primary,
      semanticsLabel: label ?? 'Progress',
      semanticsValue: value == null
          ? null
          : HabotProgressPolicy.semanticsValue(value!),
    );
  }
}

/// A circular indicator, for work whose duration genuinely cannot be known.
class HabotProgressSpinner extends StatelessWidget {
  const HabotProgressSpinner({this.value, this.label, super.key});

  final double? value;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool animate = HabotProgressPolicy.mayAnimate(context);
    return SizedBox(
      width: HabotFeedback.progressSpinnerSize,
      height: HabotFeedback.progressSpinnerSize,
      child: CircularProgressIndicator(
        value: value ?? (animate ? null : 0),
        strokeWidth: HabotFeedback.progressSpinnerStroke,
        backgroundColor: scheme.surfaceContainerHighest,
        color: scheme.primary,
        semanticsLabel: label ?? 'Working',
        semanticsValue: value == null
            ? null
            : HabotProgressPolicy.semanticsValue(value!),
      ),
    );
  }
}

/// Progress through a known sequence of steps, as a labelled bar.
///
/// The wizard in FIEVR-033 already draws dots; this is the same information
/// for surfaces that are not a wizard -- a long upload, a multi-part import.
class HabotStepProgress extends StatelessWidget {
  const HabotStepProgress({
    required this.currentStep,
    required this.totalSteps,
    super.key,
  }) : assert(totalSteps > 0, 'A sequence with no steps has no progress'),
       assert(currentStep >= 0, 'Progress cannot run backwards past zero');

  final int currentStep;
  final int totalSteps;

  double get fraction => HabotProgressPolicy.clamp(currentStep / totalSteps);

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('Step $currentStep of $totalSteps', style: text.labelMedium),
        const SizedBox(height: HabotSpacing.xxs),
        HabotProgressBar(value: fraction, label: 'Step progress'),
      ],
    );
  }
}

/// Radius token re-export, so a caller styling a container around a progress
/// bar does not reach for a raw number.
class HabotProgressShape {
  const HabotProgressShape._();

  static const double cornerRadius = HabotShape.xs;
}
