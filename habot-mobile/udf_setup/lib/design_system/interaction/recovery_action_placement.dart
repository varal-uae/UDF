/// AISS Step 109 -- GEN-00179
/// "Place the recovery action button in a clear, thumb-accessible mobile
///  screen position."
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// METRIC MISMATCH, RECORDED. The sheet gives this row "General Task
/// Completion Quality" -- floor "Task completed with documented exceptions",
/// optimal "100% completion matching stated implementation-step intent". That
/// is generic project tracking on a step that names a specific, measurable
/// property: a control in the thumb zone. What is gated is the placement,
/// measured on the rendered position of the recovery control against the Step
/// 39 thumb-band geometry. No completion-quality figure is invented.
///
/// WHY THIS IS NARROWER THAN STEP 108 AND SITS AFTER IT. Step 108 maps where
/// taps go wrong across the whole screen. This is the one control whose
/// position matters most, because it is the one a user reaches for when
/// something has ALREADY gone wrong -- offline, a failed submit, a rolled-back
/// write. The reach model and the thumb geometry both already exist; this adds
/// no third definition of "reachable". It adds three rules:
///
///   1. The recovery control sits in the Step 39 thumb band.
///   2. It is sized for the reach band it actually lands in, using
///      `HabotTapAccuracyAudit.sizeRequiredFor` -- so a control pushed to a
///      stretch position grows rather than silently becoming harder to hit.
///   3. It is not adjacent to a destructive control. A user who has just lost
///      work, reaching one-handed, must not have "Discard" within a thumb
///      wobble of "Retry". Step 10's safety margin is the minimum; this
///      doubles it for a destructive neighbour, and that is the one number
///      this file adds.
library;

import 'package:flutter/material.dart';

import '../a11y/semantic_hints.dart';
import '../shell/dashboard_grid.dart';
import '../tokens/spacing_tokens.dart';
import 'tap_accuracy.dart';
import 'touch_target.dart';

/// What a control does if it is tapped by mistake.
enum HabotActionRisk {
  /// Repeats or resumes. A mis-tap costs nothing.
  recovery,

  /// Navigates or reveals. A mis-tap costs a moment.
  neutral,

  /// Loses work or commits something irreversible.
  destructive,
}

/// Why a placement was refused.
enum HabotPlacementDefect {
  outsideThumbBand,
  belowRequiredSize,
  tooCloseToDestructive,
}

/// One placement decision, with its reasons.
@immutable
class HabotPlacementResult {
  const HabotPlacementResult({
    required this.acceptable,
    required this.band,
    required this.requiredSizeDp,
    required this.defects,
    required this.detail,
  });

  final bool acceptable;
  final HabotReachBand band;
  final double requiredSizeDp;
  final List<HabotPlacementDefect> defects;
  final String detail;

  Map<String, Object?> toJson() => <String, Object?>{
    'acceptable': acceptable,
    'reach_band': band.name,
    'required_size_dp': requiredSizeDp,
    'defects': defects.map((HabotPlacementDefect d) => d.name).toList(),
    'detail': detail,
  };
}

/// The placement rules for a recovery control.
class HabotRecoveryPlacement {
  const HabotRecoveryPlacement._();

  /// A destructive neighbour needs twice the ordinary clearance. The ordinary
  /// figure is Step 10's; only the doubling is declared here.
  static double get destructiveClearanceDp =>
      TouchTargetPolicy.safetyMarginDp * 2;

  /// The recovery control's preferred anchor: bottom-centre, which is inside
  /// the thumb arc for both hands. Not bottom-right -- that is comfortable for
  /// a right thumb and a stretch for a left one, and this is the control a
  /// left-handed user reaches for at the worst moment.
  static Alignment get preferredAlignment => Alignment.bottomCenter;

  /// Evaluate a proposed placement.
  static HabotPlacementResult evaluate({
    required Rect control,
    required Size viewport,
    required HabotGrip grip,
    List<Rect> destructiveNeighbours = const <Rect>[],
  }) {
    final List<HabotPlacementDefect> defects = <HabotPlacementDefect>[];
    final List<String> notes = <String>[];

    final bool inBand = HabotDashboardGrid.isWithinThumbZone(
      control.top,
      viewport.height,
    );
    if (!inBand) {
      defects.add(HabotPlacementDefect.outsideThumbBand);
      notes.add(
        'top ${control.top.toStringAsFixed(0)}dp is above the thumb band, '
        'which starts at '
        '${(viewport.height * (1 - HabotDashboardGrid.thumbZoneFraction)).toStringAsFixed(0)}dp',
      );
    }

    final HabotReachBand band = HabotTapAccuracy.bandFor(
      control.center,
      grip,
      viewport,
    );
    final double required = HabotTapAccuracyAudit.sizeRequiredFor(
      band,
      grip: grip,
    );
    final double actual = control.shortestSide;
    if (actual + _tolerance < required) {
      defects.add(HabotPlacementDefect.belowRequiredSize);
      notes.add(
        '${actual.toStringAsFixed(0)}dp is below the '
        '${required.toStringAsFixed(0)}dp needed in the ${band.name} reach '
        'band',
      );
    }

    for (final Rect n in destructiveNeighbours) {
      final double gap = _gapBetween(control, n);
      if (gap + _tolerance < destructiveClearanceDp) {
        defects.add(HabotPlacementDefect.tooCloseToDestructive);
        notes.add(
          'a destructive control is ${gap.toStringAsFixed(0)}dp away; '
          '${destructiveClearanceDp.toStringAsFixed(0)}dp is the minimum for '
          'a destructive neighbour',
        );
        break;
      }
    }

    return HabotPlacementResult(
      acceptable: defects.isEmpty,
      band: band,
      requiredSizeDp: required,
      defects: defects,
      detail: defects.isEmpty
          ? 'In the thumb band, ${actual.toStringAsFixed(0)}dp in the '
                '${band.name} reach band, clear of any destructive control.'
          : notes.join('; '),
    );
  }

  static const double _tolerance = 0.5;

  /// Shortest edge-to-edge distance between two rects; 0 when they overlap.
  static double _gapBetween(Rect a, Rect b) {
    final double dx = b.left > a.right
        ? b.left - a.right
        : (a.left > b.right ? a.left - b.right : 0);
    final double dy = b.top > a.bottom
        ? b.top - a.bottom
        : (a.top > b.bottom ? a.top - b.bottom : 0);
    if (dx == 0 && dy == 0) {
      return 0;
    }
    return dx == 0 ? dy : (dy == 0 ? dx : (dx < dy ? dx : dy));
  }
}

/// The recovery control itself, placed by construction rather than by caller
/// discipline.
///
/// There is no `alignment` parameter. A caller cannot put this in the top-left
/// corner, which is the whole point: the rule is in the widget, not in a
/// review comment.
class HabotRecoveryAction extends StatelessWidget {
  const HabotRecoveryAction({
    required this.label,
    required this.onPressed,
    this.kind = HabotActionKind.retryFailed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  /// Which Step 99 hint is announced. Defaults to retry, which is what a
  /// recovery control almost always is.
  final HabotActionKind kind;

  static const Key actionKey = Key('habot.recovery.action');

  /// The control never renders smaller than the stretch-band requirement, so
  /// it is hittable even when the layout pushes it off-centre.
  static double get minimumSizeDp =>
      HabotTapAccuracyAudit.sizeRequiredFor(HabotReachBand.stretch);

  HabotActionRisk get risk => HabotActionRisk.recovery;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: HabotRecoveryPlacement.preferredAlignment,
      child: Padding(
        padding: const EdgeInsets.only(bottom: HabotSpacing.lg),
        child: HabotHintedAction(
          kind: kind,
          label: label,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: minimumSizeDp,
              minHeight: minimumSizeDp,
            ),
            child: FilledButton(
              key: actionKey,
              onPressed: onPressed,
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
