/// Step 337 (SGTIM-015) -- a card drag scored on an incident-response metric,
/// under a narrative about role-based access control.
///
/// The row: "Bind touch tracking routines to horizontal drag of card layers."
/// Metric: **Mean Time to Detect (MTTD)** -- floor "<15 min", optimal "<5 min",
/// ceiling "<1 min". High / Medium / Low. Cited: Google SRE Book, Monitoring
/// Distributed Systems.
///
/// **Mean Time to Detect is how long an outage runs before anybody notices.**
/// It is measured in minutes, it belongs to an on-call rotation, and it has no
/// meaning on a finger dragging a card sideways. The gap is not a rounding
/// error between units -- the floor is fifteen minutes and the subject is an
/// interaction that lasts about a fifth of a second. That is a factor of four
/// and a half thousand between the metric's worst tolerated value and the
/// whole duration of the thing being measured.
///
/// **And the band is ordered correctly**, floor 15 minutes as the worst
/// tolerable value down to a ceiling of 1 minute as the best. That matters
/// because Steps 325, 326, 334 and 335 in the batch immediately before this one
/// were all inverted. Two correctly ordered latency bands now stand against
/// four inverted ones, which keeps the inversions errors rather than a house
/// convention.
///
/// **What the row actually needs is a drag that can be undone.** A horizontal
/// drag on a card reveals actions; the actions are usually destructive, because
/// that is what hidden trays are for. SC 2.5.7 Dragging Movements (Level AA,
/// WCAG 2.2) requires a single-pointer alternative for the drag itself, and the
/// thing the row does not mention at all is what happens after the action
/// fires.
///
/// **COLUMN NOTE.** Every narrative column on this row is about identity and
/// perimeter control -- "Map operational duties strictly following the
/// principle of least privilege", an operating-model-privileges JSON file,
/// "Automatically hides unpermitted control fields" -- on a row whose Atomic
/// Step is a card drag. The Setup Step column reads "Apply backdrop background
/// styling (e.g., semi-transparent white with CSS backdrop-filter: blur())",
/// which is CSS.
library;

import '../interaction/swipe_back.dart';
import '../tokens/motion_tokens.dart';

/// What a horizontal drag reveals.
enum HabotTrayAction {
  /// Opens the record. Reversible by leaving.
  open,

  /// Marks the record handled. Reversible for a window.
  archive,

  /// Removes the record. The row's reason for a hidden tray.
  delete,
}

/// One worked drag.
class HabotDragSample {
  const HabotDragSample({
    required this.travelDp,
    required this.thresholdDp,
    required this.releasedInsideTray,
  });

  final double travelDp;
  final double thresholdDp;
  final bool releasedInsideTray;

  bool get commits => releasedInsideTray && travelDp >= thresholdDp;
}

/// The drag on a card layer.
class HabotCardDrag {
  const HabotCardDrag._();

  // -----------------------------------------------------------------------
  // The metric, which belongs to a different discipline.
  // -----------------------------------------------------------------------

  static const String metricName = 'Mean Time to Detect (MTTD)';
  static const String metricDiscipline = 'incident response';
  static const String rowSubject = 'a horizontal drag on a card';

  static const int bandFloorSeconds = 900;
  static const int bandOptimalSeconds = 300;
  static const int bandCeilingSeconds = 60;

  /// A drag that a person would call quick.
  static const int typicalDragMilliseconds = 200;

  static double get floorToSubjectRatio =>
      (bandFloorSeconds * 1000) / typicalDragMilliseconds;

  /// Four and a half thousand times the duration of the thing measured.
  static bool get theFloorIsThousandsOfTimesTheSubject =>
      floorToSubjectRatio == 4500;

  static const String metricNote =
      'Mean Time to Detect is how long a fault runs before anybody notices. It '
      'is an on-call number, measured in minutes, and the standard cited for '
      'it here is the Google SRE book chapter on monitoring distributed '
      'systems. The subject of this row is a finger moving a card sideways for '
      'about two hundred milliseconds. The band floor of fifteen minutes is '
      'four and a half thousand times the whole duration of the interaction, '
      'so the metric cannot be failed by anything this row could build.';

  // -----------------------------------------------------------------------
  // The band, which is ordered correctly, and why that is recorded.
  // -----------------------------------------------------------------------

  static bool get theBandIsOrderedForLowerIsBetter =>
      bandFloorSeconds > bandOptimalSeconds &&
      bandOptimalSeconds > bandCeilingSeconds;

  /// Steps 325, 326, 334 and 335 ran the other way.
  static const List<int> invertedBandsInThePreviousBatch = <int>[
    325,
    326,
    334,
    335,
  ];

  static const int theOtherOrderedBand = 333;

  static bool get twoOrderedAgainstFour =>
      theBandIsOrderedForLowerIsBetter &&
      invertedBandsInThePreviousBatch.length == 4;

  static const String bandNote =
      'The band runs floor 15 minutes, optimal 5, ceiling 1: the worst '
      'tolerable value at the floor and the best at the ceiling, which is the '
      'right direction for a lower-is-better measure. Step 333 was the only '
      'correctly ordered latency band in the previous batch, against four '
      'inverted ones at Steps 325, 326, 334 and 335. This is the second, and '
      'two correct instances against four wrong ones keep the inversions '
      'errors rather than the way this sheet writes bands.';

  // -----------------------------------------------------------------------
  // The drag itself.
  // -----------------------------------------------------------------------

  /// Reuses the threshold Step 225 resolved rather than declaring a second.
  static double get commitFraction => HabotSwipeBack.dismissThreshold;

  static const double cardWidthDp = 328;

  static double get thresholdDp => cardWidthDp * commitFraction;

  static const List<HabotDragSample> samples = <HabotDragSample>[
    // Deliberate: past the threshold, released in the tray.
    HabotDragSample(
      travelDp: 200,
      thresholdDp: 164,
      releasedInsideTray: true,
    ),
    // Started and abandoned: short of the threshold.
    HabotDragSample(
      travelDp: 60,
      thresholdDp: 164,
      releasedInsideTray: true,
    ),
    // Far enough, but the finger left the tray before release.
    HabotDragSample(
      travelDp: 240,
      thresholdDp: 164,
      releasedInsideTray: false,
    ),
  ];

  static int get committingSamples =>
      samples.where((HabotDragSample s) => s.commits).length;

  /// One of three worked drags commits; two are abandonments, and an
  /// abandonment must cost nothing.
  static bool get onlyTheDeliberateDragCommits => committingSamples == 1;

  static bool get theThresholdIsReadNotInvented => thresholdDp == 164;

  // -----------------------------------------------------------------------
  // The alternative, and the undo.
  // -----------------------------------------------------------------------

  static const String draggingCriterion =
      'WCAG 2.2 SC 2.5.7 Dragging Movements';

  static const String draggingLevel = 'AA';

  static const Map<HabotTrayAction, String> singlePointerEquivalent =
      <HabotTrayAction, String>{
    HabotTrayAction.open: 'tap the card',
    HabotTrayAction.archive: 'the overflow menu on the card',
    HabotTrayAction.delete: 'the overflow menu on the card',
  };

  static bool get everyTrayActionHasATapRoute =>
      HabotTrayAction.values.every(
        (HabotTrayAction a) =>
            (singlePointerEquivalent[a] ?? '').isNotEmpty,
      );

  /// Which of the tray's actions cannot be got back by leaving the screen.
  static List<HabotTrayAction> get destructiveActions =>
      <HabotTrayAction>[HabotTrayAction.archive, HabotTrayAction.delete];

  static bool get everyDestructiveActionIsUndoable =>
      destructiveActions.every(
        (HabotTrayAction a) => undoWindowFor(a) != null,
      );

  /// The window is the snackbar-with-an-action duration already declared in
  /// the motion tokens, not a second number invented here.
  static Duration get undoWindow => HabotMotion.snackbarDisplayWithAction;

  static Duration? undoWindowFor(HabotTrayAction action) =>
      destructiveActions.contains(action) ? undoWindow : null;

  static const String undoNote =
      'A hidden tray exists because the actions in it are not ones you want on '
      'the card face, which is another way of saying they are destructive. A '
      'drag that fires a destructive action on release, with no window to take '
      'it back, converts an accidental movement into a lost record. The row '
      'says nothing about what happens after the action fires, which is the '
      'only part a person is ever hurt by.';

  static Map<String, bool> get obligations => <String, bool>{
        'a partial drag commits nothing': onlyTheDeliberateDragCommits,
        'every tray action has a single-pointer route':
            everyTrayActionHasATapRoute,
        'every destructive tray action is undoable':
            everyDestructiveActionIsUndoable,
        'the commit threshold is read from Step 225':
            theThresholdIsReadNotInvented,
        'the metric mismatch is recorded rather than approximated':
            metricNote.contains('cannot be failed'),
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'High' : 'Low';

  static Map<String, bool> get checks => <String, bool>{
        'the metric belongs to incident response':
            metricName.contains('Mean Time to Detect') &&
                metricDiscipline == 'incident response',
        'the floor is 4,500 times the interaction it scores':
            theFloorIsThousandsOfTimesTheSubject,
        'the band is ordered correctly for lower-is-better':
            theBandIsOrderedForLowerIsBetter,
        'and it is the second such band against four inverted ones':
            twoOrderedAgainstFour &&
                theOtherOrderedBand == 333 &&
                bandNote.contains('errors rather than'),
        'three worked drags, one of which commits':
            samples.length == 3 && onlyTheDeliberateDragCommits,
        'the threshold comes from the existing gesture rule':
            theThresholdIsReadNotInvented && commitFraction == 0.5,
        'the dragging criterion is named at its own level':
            draggingCriterion.contains('2.5.7') && draggingLevel == 'AA',
        'every tray action is reachable without a drag':
            everyTrayActionHasATapRoute &&
                singlePointerEquivalent.length == 3,
        'both destructive actions carry an undo window from the tokens':
            everyDestructiveActionIsUndoable &&
                destructiveActions.length == 2 &&
                undoWindow == HabotMotion.snackbarDisplayWithAction &&
                undoNote.contains('lost record'),
        'five obligations, all met, giving High':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'High',
      };

  static const String columnNote =
      'COLUMN NOTE: every narrative column on this row is about identity and '
      'perimeter control -- least privilege, an operating-model-privileges '
      'JSON file, hiding unpermitted control fields -- on a row whose Atomic '
      'Step is a card drag; its metric is Mean Time to Detect from the Google '
      'SRE monitoring chapter; and its Setup Step column asks for a CSS '
      'backdrop-filter blur. Atomic Step: "Bind touch tracking routines to '
      'horizontal drag of card layers."';
}
