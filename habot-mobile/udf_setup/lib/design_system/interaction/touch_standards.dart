/// AISS: TTMAC-014-A01 -- "Interactive Touch Target Standardization Engine
/// Setup."
///
/// Substep 1: "Wrap all interactive components in protective padding zones
///             matching minimum target dimensions."
/// Substep 2: "Set default dimensions for icon actions to maintain structural
///             usability."
/// Substep 3: "Configure clearance spaces around closely positioned items to
///             avoid accidental double taps."
/// Substep 4: "Test alignment grids against different device screen scale
///             definitions."
///
/// Decision recorded (the step's "Decision to be Made Before Setup Step" asks
/// whether hit boxes may exceed the visible outline for small icons): YES.
/// A 20dp icon keeps its 20dp visual weight and gains a transparent 48dp hit
/// box. The alternative -- inflating every icon to 48dp of ink -- would make
/// dense screens unreadable, and MD3 explicitly sanctions the transparent
/// expansion. Recorded here rather than left implicit; gated by TTMAC-014-G1.
library;

import 'dart:ui' show Size;

import '../tokens/spacing_tokens.dart';

/// Standard icon sizes. The *visual* size of the glyph, never the target.
enum HabotIconSize { dense, standard, large }

class TouchStandards {
  const TouchStandards._();

  /// The decision above, as a testable constant.
  static const bool hitBoxMayExceedVisibleOutline = true;

  /// Reference dense-glyph size. This is the 18dp Material dense icon used for
  /// inline affordances and as the padding-maths worked example (TTMAC-014-G1:
  /// an 18dp glyph needs 15dp a side to reach the 48dp floor). It is a raw
  /// glyph size, deliberately *not* part of the on-grid action scale below --
  /// 18 does not sit on the 4dp sub-baseline, and 48 - 2*15 is only satisfied
  /// by exactly 18.
  static const double iconDense = 18;

  /// Substep 2: default dimensions for icon actions. The [HabotIconSize] scale
  /// must stay on the 4dp sub-baseline so protective padding always resolves it
  /// to the touch floor (TTMAC-014-G3). Its smallest step is therefore 20dp,
  /// not the off-grid 18dp reference above.
  static const double iconActionSmall = 20;
  static const double iconStandard = 24;
  static const double iconLarge = 32;

  static const Map<HabotIconSize, double> iconSizes = <HabotIconSize, double>{
    HabotIconSize.dense: iconActionSmall,
    HabotIconSize.standard: iconStandard,
    HabotIconSize.large: iconLarge,
  };

  static double iconSizeFor(HabotIconSize size) => iconSizes[size]!;

  /// Substep 1: the protective padding an icon of [visualSize] needs on each
  /// side so its target reaches the 48dp minimum.
  ///
  /// Returns 0 when the glyph is already large enough -- padding is only ever
  /// added to reach the floor, never beyond it, so dense layouts stay dense.
  static double protectivePaddingFor(double visualSize) {
    final double deficit = HabotDensity.minTouchTarget - visualSize;
    return deficit <= 0 ? 0 : deficit / 2;
  }

  /// The resulting target for a glyph of [visualSize] once padded.
  static Size targetFor(double visualSize) {
    final double side = visualSize + (protectivePaddingFor(visualSize) * 2);
    return Size(
      side < HabotDensity.minTouchTarget ? HabotDensity.minTouchTarget : side,
      side < HabotDensity.minTouchTarget ? HabotDensity.minTouchTarget : side,
    );
  }

  /// Substep 3: minimum clearance between two adjacent interactive items.
  ///
  /// The step's completion measure is "average frequency of double tap
  /// corrections on closely packed selections (<1%)", which is a telemetry
  /// number this suite cannot produce. What it *can* guarantee is the
  /// geometric precondition: adjacent targets never share a boundary, so a
  /// tap landing on the seam cannot resolve to the wrong control.
  static const double clearance = HabotDensity.touchSafetyMargin;

  /// True when two targets laid out at [aRight] and [bLeft] are far enough
  /// apart. Tolerant of sub-pixel layout arithmetic.
  static bool hasClearance(double aRight, double bLeft) =>
      (bLeft - aRight) >= clearance - _tolerance;

  /// Substep 4: the device pixel ratios the alignment grid must survive.
  /// Real ratios from the approved device matrix, including the fractional
  /// 2.75 that exposes rounding bugs a clean 2.0 or 3.0 hides.
  static const List<double> testedDevicePixelRatios = <double>[
    1.0,
    2.0,
    2.75,
    3.0,
    3.5,
  ];

  /// A target of [logicalSize] still clears the floor after being rasterised
  /// at [devicePixelRatio] and rounded to whole physical pixels.
  static bool survivesScale(double logicalSize, double devicePixelRatio) {
    final double physical = (logicalSize * devicePixelRatio).roundToDouble();
    final double backToLogical = physical / devicePixelRatio;
    return backToLogical >= HabotDensity.minTouchTarget - _tolerance;
  }

  static const double _tolerance = 0.5;
}

/// One measured target that fell below the floor.
class TouchTargetViolation {
  const TouchTargetViolation({
    required this.label,
    required this.size,
    required this.required_,
  });

  final String label;
  final Size size;
  final double required_;

  @override
  String toString() =>
      'TouchTargetViolation($label: ${size.width.toStringAsFixed(1)}x'
      '${size.height.toStringAsFixed(1)}dp, needs ${required_.toStringAsFixed(0)}dp)';
}

/// BPTR-0128 Self-Chasing: "Runtime assertions write explicit warning flags to
/// console environments if computed bounding client rectangles fall beneath
/// target 48px parameters."
///
/// Implemented as a collector the gates walk the rendered tree with, rather
/// than a console print. Same detection, but it fails CI instead of scrolling
/// past in a log nobody reads -- which is what the requirement is actually for.
class TouchTargetAudit {
  TouchTargetAudit._();

  static final List<TouchTargetViolation> _violations =
      <TouchTargetViolation>[];

  static List<TouchTargetViolation> get violations =>
      List<TouchTargetViolation>.unmodifiable(_violations);

  static bool get isClean => _violations.isEmpty;

  static void reset() => _violations.clear();

  /// Records [size] against the floor. Returns true when compliant.
  static bool check(String label, Size size) {
    final bool ok =
        size.width >= HabotDensity.minTouchTarget - TouchStandards._tolerance &&
        size.height >= HabotDensity.minTouchTarget - TouchStandards._tolerance;
    if (!ok) {
      _violations.add(
        TouchTargetViolation(
          label: label,
          size: size,
          required_: HabotDensity.minTouchTarget,
        ),
      );
    }
    return ok;
  }
}
