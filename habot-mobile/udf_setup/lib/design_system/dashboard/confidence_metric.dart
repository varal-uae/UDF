/// AISS: GEN-02929-A01 -- "Format statistical confidence metrics using
/// Material bodySmall typography on mobile."
/// Metric: Task Completion Status -- Floor 0.8, Optimal 1.0.
///
/// METRIC NAME NOTE, RECORDED: "Task Completion Status" is generic project
/// tracking on a typography step. It measures whether the step was done, not
/// whether the typography is right. Gated against the Setup Step -- which
/// names a specific role in the type scale -- and against the Step 46 fitting
/// rules, both of which are checkable.
///
/// A confidence interval is the densest text on a dashboard: a value, a range,
/// a unit and a confidence level in one line, at the second-smallest role in
/// the scale, on the narrowest device supported. That is exactly the case
/// Step 46 exists for, so the formatting here is built to be handed to
/// `HabotTextFit` rather than hoped about.
///
/// The other half of the step is what a confidence interval MEANS, and this
/// file takes a position on it: a range is never rendered without its
/// confidence level. "142-158ms" tells a reader nothing about how much to
/// trust it; "142-158ms (95% CI)" does. There is no constructor that produces
/// the first form.
library;

import 'package:flutter/material.dart';

import '../a11y/text_fit.dart';
import '../tokens/typography_tokens.dart';

/// A measured value with an interval around it.
class HabotConfidenceMetric {
  const HabotConfidenceMetric({
    required this.value,
    required this.lower,
    required this.upper,
    required this.confidence,
    this.unit = '',
  }) : assert(lower <= upper, 'A confidence interval runs low to high');

  final double value;
  final double lower;
  final double upper;

  /// The confidence level, as a fraction. 0.95 renders as "95% CI".
  final double confidence;

  final String unit;

  /// The type role the Setup Step names. Held here so the gate can assert the
  /// role rather than a font size that happens to match it today.
  static const HabotTypeToken token = HabotTypography.bodySmall;

  /// Half-width of the interval as a share of the value -- how wide the error
  /// bars are relative to what is being measured.
  double get relativeWidth =>
      value == 0 ? 0 : ((upper - lower) / 2) / value.abs();

  /// Past this the interval is wider than the reading is useful, and the
  /// metric renders as indicative rather than as a number.
  static const double indicativeThreshold = 0.5;

  bool get isIndicative => relativeWidth > indicativeThreshold;

  static String _n(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  /// The full form: value, range, confidence level.
  String get formatted {
    if (isIndicative) {
      return 'about ${_n(value)}$unit (indicative)';
    }
    return '${_n(value)}$unit '
        '(${_n(lower)}-${_n(upper)}$unit, '
        '${(confidence * 100).round()}% CI)';
  }

  /// The compact form, for a tile too narrow for the full one. Still carries
  /// the confidence level -- that is the part that may not be dropped.
  String get compact =>
      '${_n(value)}$unit +/-${_n((upper - lower) / 2)}$unit '
      '(${(confidence * 100).round()}%)';

  /// Spoken form. "+/-" and "CI" are not words, and a screen reader saying
  /// "plus slash minus" is worse than saying nothing.
  String get semanticsLabel {
    if (isIndicative) {
      return 'about ${_n(value)}$unit, indicative only, the interval is wider '
          'than the value';
    }
    return '${_n(value)}$unit, between ${_n(lower)} and ${_n(upper)}$unit, '
        'at ${(confidence * 100).round()} percent confidence';
  }

  /// How many lines a metric inside a tile is allowed to occupy.
  static const int maxLines = 2;

  /// The form that fits [width], chosen by measuring rather than guessing.
  /// Falls back through full -> compact -> value only.
  ///
  /// Measured against [HabotTextFit.charsPerLine] rather than
  /// [HabotTextFit.audit]. The audit reports body roles as always fitting,
  /// because a paragraph is allowed to grow taller -- correct for a paragraph,
  /// and useless here, where the metric sits in a tile with a fixed number of
  /// lines. The capacity is the thing to measure against, so it is what is
  /// measured.
  String fittedFor(double width) {
    final int perLine = HabotTextFit.charsPerLine(width, token.sizeSp);
    final int capacity = perLine * maxLines;
    if (formatted.length <= capacity) {
      return formatted;
    }
    if (compact.length <= capacity) {
      return compact;
    }
    return '${_n(value)}$unit';
  }
}

/// The rendered metric.
class HabotConfidenceText extends StatelessWidget {
  const HabotConfidenceText({required this.metric, this.width, super.key});

  final HabotConfidenceMetric metric;

  /// The container width, when the caller knows it. Null renders the full
  /// form and lets the fitting text wrap.
  final double? width;

  static const Key textKey = Key('habot.confidence.text');

  @override
  Widget build(BuildContext context) {
    final double? w = width;
    final String text = w == null ? metric.formatted : metric.fittedFor(w);
    return Semantics(
      label: metric.semanticsLabel,
      container: true,
      excludeSemantics: true,
      child: HabotFittingText(
        text,
        key: textKey,
        token: HabotConfidenceMetric.token,
      ),
    );
  }
}
