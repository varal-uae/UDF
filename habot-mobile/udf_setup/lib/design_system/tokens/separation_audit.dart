/// AISS Step 185 -- GEN-01683
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Apply 8dp margin tokens between all adjacent components."
/// Metric: Touch Target Separation Compliance (%) -- Floor 98, Optimal 100,
///         Ceiling 100. Pass / Fail.
///
/// **SEPARATION IS A PROPERTY OF A PAIR, AND EVERY EXISTING CHECK IN THIS
/// REPOSITORY IS A PROPERTY OF ONE COMPONENT.** Step 108 audits each control
/// against the 48dp target; Step 184 adds the ceiling. Both can pass on every
/// control in a screen while every gap between them is 2dp. `hasClearance` has
/// existed since Step 3 and takes two scalars on one axis, which means the
/// caller has to already know which two things are adjacent and on which axis
/// -- so in practice nothing calls it with a real layout.
///
/// **THE DENOMINATOR IS THE WHOLE PROBLEM, AND GETTING IT WRONG PRODUCES A
/// FLATTERING NUMBER.** Twenty controls make 190 pairs, of which perhaps
/// nineteen are actually adjacent. Computing compliance over all 190 puts a
/// layout with *every real gap broken* at about 90% — and the row's floor is
/// 98, so the check would look like it was nearly passing while the screen was
/// unusable. Compliance is therefore computed over **adjacent pairs only**,
/// and [HabotSeparationAudit.naiveComplianceOverAllPairs] is kept so the
/// difference is demonstrable rather than asserted.
///
/// **WHAT ADJACENCY MEANS HERE.** Two controls are adjacent when a tap aimed
/// between them could plausibly resolve to either: their extents overlap on
/// one axis, and the gap on the other axis is smaller than a finger. Controls
/// at opposite ends of a screen are not adjacent and a missing margin between
/// them is not a defect.
///
/// **AN OVERLAP IS NOT A SMALL GAP, IT IS A DIFFERENT FAILURE.** Two
/// intersecting hit boxes mean one control is unreachable in the overlap
/// region, and which one wins depends on tree order. It is reported
/// separately.
library;

import 'package:flutter/widgets.dart';

import '../interaction/touch_standards.dart';
import 'spacing_tokens.dart';

/// A laid-out control.
class HabotControlRect {
  const HabotControlRect(this.label, this.rect);

  final String label;

  /// The TOUCH rect, not the painted one. Step 3 allows the hit box to exceed
  /// the visible outline, which is precisely why separation cannot be eyeballed
  /// from a design: two controls that look 12dp apart can have hit boxes that
  /// touch.
  final Rect rect;
}

/// Why a pair failed.
enum HabotSeparationFailure {
  /// Closer than the clearance token, but not touching.
  tooClose,

  /// The hit boxes intersect. One control is unreachable in the overlap and
  /// which one wins depends on tree order.
  overlapping,
}

/// One failing pair.
class HabotSeparationFinding {
  const HabotSeparationFinding({
    required this.a,
    required this.b,
    required this.gapDp,
    required this.failure,
  });

  final String a;
  final String b;
  final double gapDp;
  final HabotSeparationFailure failure;

  @override
  String toString() => failure == HabotSeparationFailure.overlapping
      ? '$a and $b overlap. One of them is unreachable where they intersect, '
          'and which one wins depends on tree order.'
      : '$a and $b are ${gapDp.toStringAsFixed(1)}dp apart, under the '
          '${HabotSeparationAudit.clearanceDp.toStringAsFixed(0)}dp clearance. '
          'A tap on the seam resolves to whichever is nearer, which is not '
          'what the user aimed at.';
}

/// Separation, measured over the pairs that can actually be confused.
class HabotSeparationAudit {
  const HabotSeparationAudit._();

  /// The token the row names. Read from Step 3 rather than restated.
  static double get clearanceDp => TouchStandards.clearance;

  /// Beyond this, a tap aimed between two controls lands on neither, so they
  /// are not competing for it. A finger's contact patch is about the size of
  /// the minimum target, which is where this comes from.
  static double get proximityDp => HabotDensity.minTouchTarget;

  /// The separating distance between two rects, on whichever axis separates
  /// them. Zero when they intersect.
  static double gapBetween(Rect a, Rect b) {
    final double dx = a.right <= b.left
        ? b.left - a.right
        : (b.right <= a.left ? a.left - b.right : 0);
    final double dy = a.bottom <= b.top
        ? b.top - a.bottom
        : (b.bottom <= a.top ? a.top - b.bottom : 0);
    if (dx == 0 && dy == 0) {
      return 0;
    }
    // Separated on one axis only: that axis is the gap. Separated on both
    // (diagonal neighbours): the larger separation is what keeps them apart.
    if (dx == 0) {
      return dy;
    }
    if (dy == 0) {
      return dx;
    }
    return dx > dy ? dx : dy;
  }

  static bool overlaps(Rect a, Rect b) => a.overlaps(b);

  /// Two controls a tap between could resolve to either -- see the header.
  ///
  /// Intersecting rects are adjacent by definition. Otherwise the separating
  /// distance decides: for neighbours in a row or a column that is the gap on
  /// the separating axis, and for diagonal neighbours [gapBetween] takes the
  /// larger of the two separations, which is the conservative reading -- a
  /// control up and to the left is further from a stray tap than either
  /// component of the offset suggests.
  static bool areAdjacent(Rect a, Rect b) =>
      overlaps(a, b) || gapBetween(a, b) < proximityDp;

  /// The pairs the metric is computed over.
  static List<List<HabotControlRect>> adjacentPairs(
    List<HabotControlRect> controls,
  ) {
    final List<List<HabotControlRect>> out = <List<HabotControlRect>>[];
    for (int i = 0; i < controls.length; i++) {
      for (int j = i + 1; j < controls.length; j++) {
        if (areAdjacent(controls[i].rect, controls[j].rect)) {
          out.add(<HabotControlRect>[controls[i], controls[j]]);
        }
      }
    }
    return out;
  }

  static int totalPairs(int n) => n < 2 ? 0 : (n * (n - 1)) ~/ 2;

  static List<HabotSeparationFinding> violations(
    List<HabotControlRect> controls,
  ) {
    final List<HabotSeparationFinding> out = <HabotSeparationFinding>[];
    for (final List<HabotControlRect> pair in adjacentPairs(controls)) {
      final HabotControlRect a = pair[0];
      final HabotControlRect b = pair[1];
      if (overlaps(a.rect, b.rect)) {
        out.add(
          HabotSeparationFinding(
            a: a.label,
            b: b.label,
            gapDp: 0,
            failure: HabotSeparationFailure.overlapping,
          ),
        );
        continue;
      }
      final double gap = gapBetween(a.rect, b.rect);
      if (!TouchStandards.hasClearance(0, gap)) {
        out.add(
          HabotSeparationFinding(
            a: a.label,
            b: b.label,
            gapDp: gap,
            failure: HabotSeparationFailure.tooClose,
          ),
        );
      }
    }
    return out;
  }

  static List<HabotSeparationFinding> overlapping(
    List<HabotControlRect> controls,
  ) =>
      violations(controls)
          .where((HabotSeparationFinding f) =>
              f.failure == HabotSeparationFailure.overlapping)
          .toList();

  // ---- the row's metric ---------------------------------------------------

  /// Touch Target Separation Compliance, over ADJACENT pairs.
  ///
  /// Returns 100 when nothing is adjacent: a screen with one control, or with
  /// controls nowhere near each other, has no separation defect. Reporting 0
  /// there would make the metric unreadable on exactly the screens that are
  /// fine.
  static double compliancePercent(List<HabotControlRect> controls) {
    final int pairs = adjacentPairs(controls).length;
    if (pairs == 0) {
      return 100;
    }
    return ((pairs - violations(controls).length) / pairs) * 100;
  }

  /// **The same figure computed the flattering way**, over every pair rather
  /// than every adjacent pair. Kept so the difference is demonstrable.
  static double naiveComplianceOverAllPairs(List<HabotControlRect> controls) {
    final int pairs = totalPairs(controls.length);
    if (pairs == 0) {
      return 100;
    }
    return ((pairs - violations(controls).length) / pairs) * 100;
  }

  static const double floor = 98;
  static const double optimal = 100;
  static const double ceiling = 100;

  static bool meetsFloor(List<HabotControlRect> controls) =>
      compliancePercent(controls) >= floor;

  static String qualitativeOutput(List<HabotControlRect> controls) =>
      meetsFloor(controls) ? 'Pass' : 'Fail';

  static const String pairNotComponentNote =
      'Separation is a property of a pair and every existing check here is a '
      'property of one component. Step 108 audits each control against the '
      '48dp target and Step 184 adds the ceiling; both can pass on every '
      'control in a screen while every gap between them is 2dp.';

  static const String denominatorNote =
      'Twenty controls make 190 pairs, of which perhaps nineteen are '
      'adjacent. Computing compliance over all 190 puts a layout with every '
      'real gap broken at about 90% -- and the floor is 98, so the check would '
      'look nearly passing while the screen was unusable. The denominator is '
      'adjacent pairs, and the flattering version is kept alongside so the '
      'difference can be shown rather than claimed.';

  static const String touchRectNote =
      'The audit measures TOUCH rects, not painted ones. Step 3 allows a hit '
      'box to exceed the visible outline, which is exactly why separation '
      'cannot be eyeballed from a design: two controls that look 12dp apart '
      'can have hit boxes that touch.';

  static const String overlapNote =
      'An overlap is not a small gap, it is a different failure. Two '
      'intersecting hit boxes mean one control is unreachable in the overlap '
      'region and which one wins depends on tree order -- so it is reported '
      'separately rather than as a gap of zero.';

  static const String columnNote =
      'Setup Step (Action) is EMPTY on this row. The Atomic Step is the unit '
      'of work.';
}
