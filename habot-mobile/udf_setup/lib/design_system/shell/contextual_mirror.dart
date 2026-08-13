/// AISS: SSTLA-012-A01 -- "Defining the structural assembly blueprint for the
/// mobile split-screen (Contextual Mirror) layout to present evidence and
/// action panels together."
///
/// Setup Step Description: "Gather detailed functional requirements for the
/// mobile Contextual Mirror layout experience."
/// Why This Matters: "Clunky split-screen layouts cause constant scrolling,
/// increasing processing errors."
/// User Interaction / Flow Impact: "Double-tapping panel bars snaps views
/// between split ratios instantly."
/// Expected Output: "Unified layout container component files. Measures of
/// Completion: Mobile views adjust cleanly when rotated, maintaining target
/// sizes across panels."
/// Poka-Yoke: "Code linters block views that do not extend the master layout
/// wrapper."
/// Self-Chasing: "Missing layout hooks stop compilation, keeping bad code out
/// of testing builds."
///
/// This file is the blueprint, not the widget. It exists separately because
/// the sheet asks for a *structural assembly specification* -- layout type,
/// grid dimensions, spacing rules, alignment settings and a validation status
/// -- and those are the five fields its Data Collected column names. Step 37
/// builds the containers that implement it; keeping them apart is what lets
/// the gate check the specification without pumping a widget.
///
/// The poka-yoke is enforced twice: `RCGLA-018-G4` already scans every screen
/// class for the master wrapper, and this batch adds a `ROGUE_SCAFFOLD` rule
/// to the poka-yoke guard so no file outside the master scaffold may construct
/// a bare `Scaffold`. That is what "code linters block views that do not
/// extend the master layout wrapper" looks like when it is executable.
library;

import '../tokens/grid_tokens.dart';
import '../tokens/spacing_tokens.dart';

/// Which half of the mirror a pane is.
enum HabotPaneRole {
  /// What the operator is looking at -- the document, the record, the image.
  evidence,

  /// What the operator is doing about it -- the form, the decision, the
  /// controls.
  action,
}

/// How the two panes are arranged. Determined by the window class, never by
/// the caller: the whole point of a blueprint is that the arrangement is a
/// property of the screen, not of whoever wrote this page.
enum HabotMirrorArrangement {
  /// Compact: a vertical stack. SSTLA-010's Mobile-First row is explicit --
  /// "replaces wide side-by-side desktop grids with clean, thumb-friendly
  /// vertical stacks".
  stacked,

  /// Medium and expanded: side by side, evidence leading.
  sideBySide,

  /// Neither pane can be shown at a usable size, so they become two tabs of
  /// one pane instead.
  ///
  /// This is a real device, not a hypothetical: an iPhone SE in landscape is
  /// 568x320dp, which is still compact (so the split runs vertically) and only
  /// 320dp tall. A 50/50 split there gives each pane 160dp -- a title, one row
  /// and nothing else. Showing both panes badly is worse than showing one
  /// properly, so the blueprint says so out loud rather than letting the
  /// layout quietly degrade.
  tabbed,
}

/// The snap ratios a split may rest at, as the evidence pane's share.
///
/// Flow Impact: "Double-tapping panel bars snaps views between split ratios
/// instantly." Three stops, cycling -- a continuous drag would be a fine
/// desktop affordance and a poor one for a thumb on a moving train.
enum HabotSplitRatio {
  /// Evidence minimised: the operator is mostly typing.
  actionHeavy,

  /// Even split. The default, and where a double-tap cycle returns to.
  balanced,

  /// Evidence maximised: the operator is mostly reading.
  evidenceHeavy;

  /// The evidence pane's share of the long axis.
  double get evidenceShare {
    switch (this) {
      case HabotSplitRatio.actionHeavy:
        return 0.35;
      case HabotSplitRatio.balanced:
        return 0.50;
      case HabotSplitRatio.evidenceHeavy:
        return 0.65;
    }
  }

  double get actionShare => 1 - evidenceShare;

  /// The next stop a double-tap moves to. Cycles, so the gesture is always
  /// available and never lands somewhere it cannot leave.
  HabotSplitRatio get next {
    switch (this) {
      case HabotSplitRatio.actionHeavy:
        return HabotSplitRatio.balanced;
      case HabotSplitRatio.balanced:
        return HabotSplitRatio.evidenceHeavy;
      case HabotSplitRatio.evidenceHeavy:
        return HabotSplitRatio.actionHeavy;
    }
  }
}

/// Whether a blueprint reading is usable. The fifth of the five fields the
/// sheet's Data Collected column names.
enum HabotLayoutValidationStatus {
  /// Every rule holds on this viewport.
  valid,

  /// The viewport is narrower than the design system supports at all. The
  /// only genuine failure of the three.
  belowMinimumWidth,

  /// A split would leave a pane too short to hold its content, so the panes
  /// became tabs. Usable, documented, and deliberately not called "valid" --
  /// the operator is not seeing evidence and action together, which is the
  /// whole point of the mirror.
  tabbedFallback,
}

/// One reading of the blueprint against a concrete viewport.
class HabotMirrorLayout {
  const HabotMirrorLayout({
    required this.arrangement,
    required this.ratio,
    required this.evidenceExtent,
    required this.actionExtent,
    required this.status,
  });

  final HabotMirrorArrangement arrangement;
  final HabotSplitRatio ratio;

  /// Logical pixels along the split axis -- height when stacked, width when
  /// side by side.
  final double evidenceExtent;
  final double actionExtent;

  final HabotLayoutValidationStatus status;

  bool get isValid => status == HabotLayoutValidationStatus.valid;

  /// Usable, whether or not it is a mirror. The rotation measure is about
  /// this, not about [isValid].
  bool get isUsable => status != HabotLayoutValidationStatus.belowMinimumWidth;

  bool get isMirror => arrangement != HabotMirrorArrangement.tabbed;

  /// The five atomic fields the step's Data Collected column asks for.
  Map<String, String> toDataRecord() => <String, String>{
    'Layout Type': 'Contextual Mirror (${arrangement.name})',
    'Layout Grid Dimensions':
        'evidence ${evidenceExtent.toStringAsFixed(0)}dp / '
        'action ${actionExtent.toStringAsFixed(0)}dp at '
        '${(ratio.evidenceShare * 100).toStringAsFixed(0)}%',
    'Spacing Rules':
        'divider ${ContextualMirrorSpec.dividerThickness}dp, pane padding '
        '${ContextualMirrorSpec.panePadding}dp, gutter ${HabotGrid.gutter}dp',
    'Alignment Settings':
        'evidence leads on ${arrangement.name}; both panes stretch to the '
        'cross axis',
    'Layout Validation Status': status.name,
  };
}

/// The blueprint itself.
class ContextualMirrorSpec {
  const ContextualMirrorSpec._();

  /// Every pane keeps at least this much of the split axis. Below it the pane
  /// cannot hold a title, one row and one action at the touch minimum, which
  /// is what [HabotLayoutValidationStatus.tabbedFallback] reports.
  static const double minPaneExtent = 160;

  static const double dividerThickness = 1;
  static const double panePadding = HabotSpacing.md;

  /// The bar the operator double-taps to cycle the ratio. Full touch height,
  /// because it is an interactive element and TTMAC-011 has no exceptions.
  static const double panelBarHeight = HabotDensity.minTouchTarget;

  static const HabotSplitRatio defaultRatio = HabotSplitRatio.balanced;

  /// The arrangement a viewport would use if both panes fit. Whether they
  /// actually fit is [resolve]'s job.
  static HabotMirrorArrangement preferredArrangementFor(double width) =>
      HabotGrid.windowClassFor(width) == HabotWindowClass.compact
      ? HabotMirrorArrangement.stacked
      : HabotMirrorArrangement.sideBySide;

  /// The arrangement a viewport actually gets, including the tabbed fallback.
  static HabotMirrorArrangement arrangementFor({
    required double width,
    required double height,
    HabotSplitRatio ratio = defaultRatio,
  }) => resolve(width: width, height: height, ratio: ratio).arrangement;

  /// Reads the blueprint against a viewport.
  ///
  /// [width] and [height] are the whole viewport; the split axis is chosen by
  /// the arrangement, which is why rotating a device changes the answer
  /// without changing the specification -- the completion measure the sheet
  /// names ("mobile views adjust cleanly when rotated").
  static HabotMirrorLayout resolve({
    required double width,
    required double height,
    HabotSplitRatio ratio = defaultRatio,
  }) {
    final HabotMirrorArrangement preferred = preferredArrangementFor(width);
    final double axis = preferred == HabotMirrorArrangement.stacked
        ? height
        : width;
    final double usable = axis - dividerThickness;
    final double evidence = usable * ratio.evidenceShare;
    final double action = usable - evidence;

    if (width < HabotGrid.minSupportedWidth) {
      return HabotMirrorLayout(
        arrangement: preferred,
        ratio: ratio,
        evidenceExtent: evidence,
        actionExtent: action,
        status: HabotLayoutValidationStatus.belowMinimumWidth,
      );
    }

    if (evidence < minPaneExtent || action < minPaneExtent) {
      // The documented fallback: one pane, two tabs, each getting the whole
      // axis. Recorded as tabbedFallback rather than as a failure, because the
      // layout is usable -- it just is not a mirror.
      return HabotMirrorLayout(
        arrangement: HabotMirrorArrangement.tabbed,
        ratio: ratio,
        evidenceExtent: axis,
        actionExtent: axis,
        status: HabotLayoutValidationStatus.tabbedFallback,
      );
    }

    return HabotMirrorLayout(
      arrangement: preferred,
      ratio: ratio,
      evidenceExtent: evidence,
      actionExtent: action,
      status: HabotLayoutValidationStatus.valid,
    );
  }

  /// True when both orientations of a device produce a usable layout at every
  /// ratio the double-tap can reach.
  ///
  /// This is the completion measure the sheet names -- "mobile views adjust
  /// cleanly when rotated, maintaining target sizes across panels" -- and
  /// "cleanly" is the operative word: a pane that shrinks below
  /// [minPaneExtent] has NOT maintained its target size, so the blueprint
  /// switches arrangement rather than pretending.
  static bool survivesRotation({
    required double widthDp,
    required double heightDp,
  }) {
    for (final HabotSplitRatio ratio in HabotSplitRatio.values) {
      for (final List<double> axes in <List<double>>[
        <double>[widthDp, heightDp],
        <double>[heightDp, widthDp],
      ]) {
        final HabotMirrorLayout layout = resolve(
          width: axes[0],
          height: axes[1],
          ratio: ratio,
        );
        if (!layout.isUsable) {
          return false;
        }
        if (layout.isMirror &&
            (layout.evidenceExtent < minPaneExtent ||
                layout.actionExtent < minPaneExtent)) {
          return false;
        }
      }
    }
    return true;
  }

  /// True when a device can show both panes at once in BOTH orientations.
  /// Reported separately so the evidence records which devices get the mirror
  /// and which get the fallback, rather than averaging the two together.
  static bool mirrorsInBothOrientations({
    required double widthDp,
    required double heightDp,
  }) =>
      resolve(width: widthDp, height: heightDp).isMirror &&
      resolve(width: heightDp, height: widthDp).isMirror;
}
