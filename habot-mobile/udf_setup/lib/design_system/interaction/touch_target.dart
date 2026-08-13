/// AISS: TTMAC-011-A01 -- "Touch-Target Optimization Framework Setup
/// (48x48 dp Minimum Interaction Nodes)."
///
/// 4 Substeps:
///   1. "Define absolute minimum touch-target boundaries (>= 48 x 48 dp) for
///       compact layout elements"
///   2. "Inject transparent target expansion boxes around micro-icons or
///       selector ticks"
///   3. "Configure button element grid bounds to preserve an 8 dp safety
///       spacing margin"
///   4. "Map long-press interaction paths to reveal detailed tooltips instead
///       of dense text boxes."
///
/// Poka-Yoke: "The compile engine throws a validation error if any touch target
/// layout bounds map below 48 dp constraints."
///
/// Dart has no compile-time size check, so the equivalents are: an `assert` in
/// the constructor (fails in debug the moment a smaller size is requested), and
/// `TTMAC-011-G6`, which walks the rendered tree of the running app and
/// measures every interactive element.
library;

import 'package:flutter/material.dart';

import '../surfaces/metadata_disclosure.dart';
import '../tokens/spacing_tokens.dart';

/// Wraps any interactive child in a target of at least 48x48 dp.
///
/// The expansion box is transparent (substep 2): a 20dp icon keeps its 20dp
/// visual size, but the region that responds to a tap is 48dp. This is what
/// stops "fat-finger" misses without making the UI look chunky.
class HabotTouchTarget extends StatelessWidget {
  const HabotTouchTarget({
    required this.child,
    required this.semanticLabel,
    this.onPressed,
    this.onLongPress,
    this.detail,
    this.minSize = HabotDensity.minTouchTarget,
    super.key,
  }) : assert(
         minSize >= HabotDensity.minTouchTarget,
         'TTMAC-011: a touch target may never be smaller than '
         '${HabotDensity.minTouchTarget}dp. Requested a smaller minSize.',
       );

  final Widget child;

  /// Required. An interactive element with no accessible name is a defect, not
  /// a style choice, so there is no way to construct one without it.
  final String semanticLabel;

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  /// Substep 4: long-press reveals detail instead of a dense inline text box.
  /// Defaults to [semanticLabel] when a press handler exists.
  ///
  /// MUFCE-028 replaced the [Tooltip] that used to carry this: a tooltip is a
  /// hover artefact, invisible on a touch device except through the same
  /// long-press, and it truncates anything longer than a phrase. The detail
  /// now opens in a bottom drawer via [HabotMetadataDisclosure], which is the
  /// only surface in the app allowed to present metadata.
  final String? detail;

  final double minSize;

  /// The metadata a long-press will disclose.
  HabotMetadata get metadata =>
      HabotMetadata(title: semanticLabel, description: detail ?? semanticLabel);

  @override
  Widget build(BuildContext context) {
    final Widget target = InkResponse(
      onTap: onPressed,
      onLongPress: onLongPress ?? () => _disclose(context),
      radius: minSize / 2,
      containedInkWell: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
        child: Center(widthFactor: 1, heightFactor: 1, child: child),
      ),
    );

    return Semantics(
      label: semanticLabel,
      hint: detail,
      button: onPressed != null,
      enabled: onPressed != null,
      child: target,
    );
  }

  void _disclose(BuildContext context) {
    HabotMetadataDisclosure.show(context, metadata);
  }
}

/// Lays interactive children out with the 8dp safety margin substep 3 requires.
///
/// Using this instead of a bare `Row` is what makes the margin systematic
/// rather than something each screen remembers.
class HabotTouchRow extends StatelessWidget {
  const HabotTouchRow({
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    super.key,
  });

  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < children.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: HabotDensity.touchSafetyMargin),
          children[i],
        ],
      ],
    );
  }
}

/// Static policy, unit-testable without building anything.
class TouchTargetPolicy {
  const TouchTargetPolicy._();

  static const double minimumDp = HabotDensity.minTouchTarget;
  static const double safetyMarginDp = HabotDensity.touchSafetyMargin;

  static bool isCompliant(Size size) =>
      size.width >= minimumDp - _tolerance &&
      size.height >= minimumDp - _tolerance;

  /// Sub-pixel slack. Layout arithmetic can land a hair under 48.0 on
  /// fractional device pixel ratios; 0.5dp is far below perceptibility and far
  /// above floating-point noise.
  static const double _tolerance = 0.5;

  /// True when two adjacent targets are far enough apart.
  static bool hasSafeSeparation(double gapDp) =>
      gapDp >= safetyMarginDp - _tolerance;
}
