/// AISS Step 108 -- GEN-00090
/// "Test tap accuracy across various mobile screen sizes and thumb zones."
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// THE METRIC RESTATES STEP 10, RECORDED. The row's metric is the TTMAC-011
/// touch standard verbatim -- 44px WCAG floor, 48dp Material optimal, 56dp
/// ceiling. Step 10 already declares those numbers and gates them. Restating
/// them here would give this project two definitions of a touch target, which
/// is one more than it can keep consistent. So this step CONSUMES
/// `HabotDensity.minTouchTarget` and `TouchTargetPolicy` and measures the
/// thing Step 10 did not: ACCURACY.
///
/// SIZE IS NOT ACCURACY. Step 10 asks "is the target big enough?". This asks
/// "does the finger land on it?" -- and those come apart in two ways that
/// matter on a real handset:
///
///   1. A thumb does not touch where the user is looking. The contact patch is
///      an ellipse roughly 9-11mm across, and its centroid sits BELOW and
///      slightly INBOARD of the perceived point, because the thumb approaches
///      at an angle. [HabotTapAccuracy.thumbOffsetDownDp] is that bias.
///   2. The bias grows with reach. A target at the top-left of a 6.7-inch
///      phone held right-handed is at the end of an extended thumb, where the
///      arc flattens and the error grows. [HabotTapAccuracy.reachPenaltyFor]
///      is that growth.
///
/// A 48dp target at the bottom centre is comfortable. The same 48dp target in
/// the top-left corner of a large phone is not, and no size check will say so.
///
/// PROVENANCE, STATED. The offset and penalty figures below are a MODEL, not a
/// measurement from this app's users. They are consistent with the published
/// touch literature the 44/48/56 bands themselves come from, and they are
/// declared as named constants precisely so they can be replaced with real
/// telemetry when Step 123 has a sync loop to carry it. Nothing here claims to
/// be an observed accuracy rate for this product.
library;

import 'dart:math' as math;
import 'dart:ui' show Offset, Rect, Size;

import '../layout/device_profiles.dart';
import '../shell/dashboard_grid.dart';
import '../tokens/spacing_tokens.dart';
import 'touch_target.dart';

/// Which hand, which posture. The reach model depends on it.
enum HabotGrip { rightThumb, leftThumb, twoHanded }

/// How comfortably a point can be reached.
enum HabotReachBand {
  /// Inside the thumb arc without moving the hand.
  natural,

  /// Reachable, but at the end of an extended thumb.
  stretch,

  /// Needs a regrip or the other hand.
  outOfReach,
}

/// The tap-accuracy model.
class HabotTapAccuracy {
  const HabotTapAccuracy._();

  /// The touch standard. Read from Step 10; not redeclared.
  static double get minTargetDp => TouchTargetPolicy.minimumDp;
  static double get safetyMarginDp => TouchTargetPolicy.safetyMarginDp;

  /// The contact patch centroid sits below the perceived point.
  static const double thumbOffsetDownDp = 4.0;

  /// ...and inboard of it, towards the palm.
  static const double thumbOffsetInboardDp = 2.0;

  /// The scatter of the contact patch at natural reach, in dp.
  ///
  /// A thumb pad is roughly 9-11mm across, which on a typical handset is
  /// 34-42dp of contact. The centroid of that patch does not land on the
  /// centroid of the user's intent, and this is how far it wanders. It is the
  /// dominant term: the reach penalties below only add to it.
  static const double baseScatterDp = 9.0;

  /// Extra scatter, in dp, added at full stretch.
  static const double stretchPenaltyDp = 6.0;

  /// Out of the thumb arc entirely: the user is regripping, and a regrip is
  /// where mis-taps actually happen.
  static const double outOfReachPenaltyDp = 12.0;

  /// The thumb arc, as a fraction of the diagonal, measured from the bottom
  /// corner on the gripping side. Reuses the Step 39 thumb band for the
  /// vertical half rather than declaring a second geometry.
  static const double naturalArcFraction = 0.55;
  static const double stretchArcFraction = 0.78;

  /// The origin of the thumb arc for [grip] on a [size] viewport: the bottom
  /// corner on the gripping side, inset by one grid unit for the bezel.
  static Offset pivotFor(HabotGrip grip, Size size) {
    switch (grip) {
      case HabotGrip.rightThumb:
        return Offset(size.width - HabotSpacing.lg, size.height);
      case HabotGrip.leftThumb:
        return Offset(HabotSpacing.lg, size.height);
      case HabotGrip.twoHanded:
        return Offset(size.width / 2, size.height);
    }
  }

  /// How far [point] is from the pivot, as a fraction of the viewport
  /// diagonal.
  static double reachFraction(Offset point, HabotGrip grip, Size size) {
    final Offset pivot = pivotFor(grip, size);
    final double diagonal = math.sqrt(
      size.width * size.width + size.height * size.height,
    );
    if (diagonal == 0) {
      return 0;
    }
    return (point - pivot).distance / diagonal;
  }

  static HabotReachBand bandFor(Offset point, HabotGrip grip, Size size) {
    final double f = reachFraction(point, grip, size);
    if (f <= naturalArcFraction) {
      return HabotReachBand.natural;
    }
    if (f <= stretchArcFraction) {
      return HabotReachBand.stretch;
    }
    return HabotReachBand.outOfReach;
  }

  static double reachPenaltyFor(HabotReachBand band) {
    switch (band) {
      case HabotReachBand.natural:
        return 0;
      case HabotReachBand.stretch:
        return stretchPenaltyDp;
      case HabotReachBand.outOfReach:
        return outOfReachPenaltyDp;
    }
  }

  /// Where a tap aimed at [intended] is modelled to actually land.
  ///
  /// The inboard direction depends on the grip, which is why this is not a
  /// single constant offset.
  static Offset landingFor(Offset intended, HabotGrip grip, Size size) {
    final double inboard = switch (grip) {
      HabotGrip.rightThumb => -thumbOffsetInboardDp,
      HabotGrip.leftThumb => thumbOffsetInboardDp,
      HabotGrip.twoHanded => 0.0,
    };
    return Offset(
      intended.dx + inboard,
      intended.dy + thumbOffsetDownDp,
    );
  }

  /// Total scatter at [band]: the contact patch, plus what reach adds.
  static double scatterFor(HabotReachBand band) =>
      baseScatterDp + reachPenaltyFor(band);

  /// How far the worst-case tap lands from the target centre, per axis.
  ///
  /// The systematic offset and the scatter add: the offset is where the patch
  /// sits on average, the scatter is how far it moves around that. Treating
  /// them as alternatives is how a model concludes that every target is fine.
  static Offset worstCaseDisplacement(HabotGrip grip, HabotReachBand band) {
    final double scatter = scatterFor(band);
    final double inboard =
        grip == HabotGrip.twoHanded ? 0 : thumbOffsetInboardDp;
    return Offset(inboard + scatter, thumbOffsetDownDp + scatter);
  }

  /// Whether a tap aimed at the centre of [target] lands inside it, in the
  /// worst case rather than on average. An average that lands inside a target
  /// half the time is a control users learn to distrust.
  static bool landsInside({
    required Rect target,
    required HabotGrip grip,
    required Size viewport,
  }) {
    final HabotReachBand band = bandFor(target.center, grip, viewport);
    final Offset d = worstCaseDisplacement(grip, band);
    return d.dx <= target.width / 2 + _tolerance &&
        d.dy <= target.height / 2 + _tolerance;
  }

  /// The smallest square target that survives [band], before the Step 10
  /// floor is applied. Below the floor the floor wins -- a model is not
  /// permitted to argue a control smaller than the standard.
  static double sizeRequiredFor(HabotGrip grip, HabotReachBand band) {
    final Offset d = worstCaseDisplacement(grip, band);
    final double needed = 2 * math.max(d.dx, d.dy);
    return needed < minTargetDp ? minTargetDp : needed;
  }

  static const double _tolerance = 0.5;
}

/// One measured target on one device.
class HabotTapAccuracyResult {
  const HabotTapAccuracyResult({
    required this.deviceName,
    required this.grip,
    required this.targetLabel,
    required this.target,
    required this.band,
    required this.hits,
    required this.meetsSizeStandard,
  });

  final String deviceName;
  final HabotGrip grip;
  final String targetLabel;
  final Rect target;
  final HabotReachBand band;

  /// Whether the modelled tap landed inside the target.
  final bool hits;

  /// Whether the target satisfies Step 10 at all. Kept separate so a failure
  /// says WHICH problem it is: too small, or too far.
  final bool meetsSizeStandard;

  bool get isAccurate => hits && meetsSizeStandard;

  @override
  String toString() =>
      '$deviceName ${grip.name} "$targetLabel" ${band.name}: '
      '${hits ? "hit" : "MISS"}'
      '${meetsSizeStandard ? "" : " (also below ${HabotTapAccuracy.minTargetDp}dp)"}';
}

/// Runs the model across devices, grips and screen positions.
class HabotTapAccuracyAudit {
  const HabotTapAccuracyAudit._();

  /// The nine positions any screen has: three bands by three columns.
  static Map<String, Offset> positionsFor(Size size) {
    final Map<String, Offset> out = <String, Offset>{};
    const List<String> rows = <String>['top', 'middle', 'bottom'];
    const List<String> cols = <String>['left', 'centre', 'right'];
    for (int r = 0; r < rows.length; r++) {
      for (int c = 0; c < cols.length; c++) {
        out['${rows[r]}-${cols[c]}'] = Offset(
          size.width * (c + 0.5) / cols.length,
          size.height * (r + 0.5) / rows.length,
        );
      }
    }
    return out;
  }

  /// Audit a target of [targetSize] at every position, on every phone
  /// profile, in both one-handed grips.
  static List<HabotTapAccuracyResult> audit({
    Size targetSize = const Size(
      HabotDensity.minTouchTarget,
      HabotDensity.minTouchTarget,
    ),
  }) {
    final List<HabotTapAccuracyResult> out = <HabotTapAccuracyResult>[];
    for (final HabotDeviceProfile device in HabotDevices.ofType(
      HabotDeviceType.phone,
    )) {
      final Size viewport = device.logicalSize;
      for (final HabotGrip grip in <HabotGrip>[
        HabotGrip.rightThumb,
        HabotGrip.leftThumb,
      ]) {
        for (final MapEntry<String, Offset> p
            in positionsFor(viewport).entries) {
          final Rect target = Rect.fromCenter(
            center: p.value,
            width: targetSize.width,
            height: targetSize.height,
          );
          out.add(
            HabotTapAccuracyResult(
              deviceName: device.name,
              grip: grip,
              targetLabel: p.key,
              target: target,
              band: HabotTapAccuracy.bandFor(p.value, grip, viewport),
              hits: HabotTapAccuracy.landsInside(
                target: target,
                grip: grip,
                viewport: viewport,
              ),
              meetsSizeStandard: TouchTargetPolicy.isCompliant(targetSize),
            ),
          );
        }
      }
    }
    return out;
  }

  /// The positions where a minimum-size target is NOT reliably hit.
  ///
  /// This is the actual output of the step: not a pass/fail, but a map of
  /// where a 48dp control is too small for where it has been put. Step 109
  /// consumes it.
  static List<HabotTapAccuracyResult> misses() =>
      audit().where((HabotTapAccuracyResult r) => !r.hits).toList();

  /// The size a target must be to survive [band]. Step 109 uses this to size
  /// the recovery control rather than guessing.
  ///
  /// FINDING, RECORDED: for the natural and stretch bands this returns exactly
  /// the Step 10 figure of 48dp, because 48dp already covers them. The model
  /// only asks for more in the out-of-reach band. That is a result worth
  /// stating rather than hiding: the touch standard is adequate everywhere a
  /// thumb actually goes, and the far top corner of a large phone is not one
  /// of those places.
  static double sizeRequiredFor(
    HabotReachBand band, {
    HabotGrip grip = HabotGrip.rightThumb,
  }) => HabotTapAccuracy.sizeRequiredFor(grip, band);

  /// True when [rect] on [viewport] sits in the Step 39 thumb band.
  /// Delegates rather than redefining "reachable".
  static bool isInThumbBand(Rect rect, Size viewport) =>
      HabotDashboardGrid.isWithinThumbZone(rect.top, viewport.height);
}
