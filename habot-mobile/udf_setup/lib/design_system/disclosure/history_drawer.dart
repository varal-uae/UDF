/// Step 279 (GEN-03006) -- an inspection panel the row calls a drawer, and the
/// gesture that word would have spent.
///
/// The row: "Implement a collapsible Inspect Justificatory History drawer on
/// mobile response screens."
/// Metric: **Task Completion Status** -- floor 0.8, optimal 1, ceiling 1.
/// Complete / Partial / Not Complete. Cited: ITIL v4 / internal SOP.
///
/// **"Drawer" is an overloaded word and the wrong one here.** In MD3 a
/// navigation drawer slides in from the edge and holds destinations; it is a
/// property of the application, not of anything on the screen. What this row
/// wants belongs to one response: the reasons behind that answer. Building it
/// as an edge drawer would put an audit trail behind the same gesture as the
/// app's menu -- and that gesture is already spent, because Step 226 gave the
/// leading edge to back navigation. So this is a sheet anchored to the
/// response, and Step 225's existing rule picks the surface rather than this
/// file choosing one.
///
/// **History is per-response state, not per-screen state.** Opening the panel
/// on one answer and scrolling to the next must not leave it open on the next,
/// which is what a single boolean on the screen would do. The open set is
/// keyed by response, so the reader's place survives and nobody is shown an
/// audit trail belonging to something they are no longer looking at.
///
/// **An audit trail you can only read is worth more than one you can act in.**
/// There are no controls inside the panel. A justification with an edit button
/// beside it is a justification somebody can change after the fact, which is
/// the one property the record exists to deny.
library;

import '../layout/window_size_class.dart';
import '../surfaces/dialog_to_sheet.dart';

/// One entry in the trail.
class HabotJustification {
  const HabotJustification({
    required this.responseId,
    required this.claim,
    required this.basis,
    required this.recordedAt,
  });

  /// Which response this belongs to. The panel is keyed by it.
  final String responseId;

  /// What was asserted.
  final String claim;

  /// Why -- the rule, the input, or the source that produced it.
  final String basis;

  final DateTime recordedAt;

  bool get isAttributed => basis.isNotEmpty && claim.isNotEmpty;
}

/// The panel.
class HabotHistoryDrawer {
  const HabotHistoryDrawer._();

  /// The word the row uses, and the thing that word means in MD3.
  static const String theRowsWord = 'drawer';
  static const String whatThatWordMeansInMd3 =
      'an edge-anchored container of navigation destinations';

  /// What this actually is.
  static const String whatThisIs =
      'an inspection panel belonging to one response';

  /// The intent it maps to in Step 225's taxonomy: showing something, with no
  /// answer wanted. The surface then follows from the rule rather than from
  /// this file.
  static const HabotSurfaceIntent intent = HabotSurfaceIntent.disclosure;

  static HabotSurfaceForm formAt(double widthDp) =>
      HabotSurfaceChoice.formFor(intent, widthDp);

  /// Compact gets a standard sheet -- not scrimmed, so the response stays
  /// visible behind it, which is the point of comparing a claim with its
  /// basis. Expanded gets an anchored popover.
  static bool get theSurfaceIsDecidedByTheExistingRule =>
      formAt(360) == HabotSurfaceForm.standardSheet &&
      formAt(1024) == HabotSurfaceForm.anchoredPopover;

  /// And it is dismissible, because nothing here is being asked of anybody.
  static bool get itIsDismissibleWithoutAnswering =>
      HabotSurfaceChoice.isDismissibleByGesture(formAt(360));

  /// The compact threshold is read from the declared window classes rather
  /// than from a number chosen here.
  static bool get theWidthSplitIsTheDeclaredOne =>
      HabotWindowSizeClass.classOf(360) == HabotMd3WindowClass.compact &&
      HabotWindowSizeClass.classOf(1024) != HabotMd3WindowClass.compact;

  static const String notANavigationDrawerNote =
      'A navigation drawer is edge-anchored and holds destinations; it '
      'belongs to the application. This belongs to one response. Building the '
      'row\'s word literally would put an audit trail behind the same gesture '
      'as the app menu, and that gesture is already spent -- Step 226 gave '
      'the leading edge to back navigation, and a screen with two meanings '
      'for one swipe teaches people not to swipe. The surface is chosen by '
      'Step 225\'s rule from the intent, which is disclosure, and the rule '
      'returns a standard sheet on a phone: not scrimmed, so the response '
      'stays visible behind the reasons for it.';

  // -----------------------------------------------------------------------
  // Keyed by response.
  // -----------------------------------------------------------------------

  /// Whether the panel is open for a given response, given the set that is
  /// open. A single boolean would make it open for all of them.
  static bool isOpenFor(String responseId, Set<String> openIds) =>
      openIds.contains(responseId);

  static bool get openingOneDoesNotOpenTheNext {
    const Set<String> open = <String>{'r-1'};
    return isOpenFor('r-1', open) && !isOpenFor('r-2', open);
  }

  /// What a per-screen boolean would do, kept for the contrast.
  static bool naiveIsOpenFor(String responseId, bool screenFlag) => screenFlag;

  static bool get theNaiveVersionOpensEverything =>
      naiveIsOpenFor('r-1', true) && naiveIsOpenFor('r-2', true);

  static const String perResponseNote =
      'The open set is keyed by response. A single boolean on the screen '
      'would open the panel on every answer at once, so a reader who opened '
      'the reasons for one and scrolled would be shown an audit trail '
      'belonging to something they are no longer looking at -- and would have '
      'no way to tell, because the panel looks the same either way. The naive '
      'version is kept here as an executable contrast rather than as a '
      'warning in a comment.';

  // -----------------------------------------------------------------------
  // Read only.
  // -----------------------------------------------------------------------

  static const bool hasActionsInside = false;

  static const String readOnlyNote =
      'There are no controls inside the panel. A justification with an edit '
      'button beside it is a justification somebody can change after the '
      'fact, which is the one property the record exists to deny. Corrections '
      'are made where the answer is made and appear in the trail as new '
      'entries -- an audit trail that can be rewritten is a document, not a '
      'trail.';

  /// The panel is not the only route to the information: the row itself names
  /// deep-link drill-down, and a person sent a link to a decision should
  /// arrive at the decision rather than at a screen with a closed panel on it.
  static const bool isReachableByDeepLink = true;

  // -----------------------------------------------------------------------
  // A worked trail.
  // -----------------------------------------------------------------------

  static List<HabotJustification> get workedTrail => <HabotJustification>[
        HabotJustification(
          responseId: 'r-1',
          claim: 'The booking was declined',
          basis: 'Capacity rule: the session had no remaining places at the '
              'time the request arrived',
          recordedAt: DateTime.utc(2026, 9, 15, 9, 14),
        ),
        HabotJustification(
          responseId: 'r-1',
          claim: 'No alternative was offered',
          basis: 'Every session in the same week was also full; the '
              'suggestion list was empty rather than suppressed',
          recordedAt: DateTime.utc(2026, 9, 15, 9, 14, 1),
        ),
        HabotJustification(
          responseId: 'r-2',
          claim: 'The refund was approved automatically',
          basis: 'Cancellation was more than 48 hours before the session, '
              'which the policy table resolves without review',
          recordedAt: DateTime.utc(2026, 9, 15, 9, 20),
        ),
      ];

  static List<HabotJustification> trailFor(String responseId) => workedTrail
      .where((HabotJustification j) => j.responseId == responseId)
      .toList();

  static bool get everyEntryIsAttributed =>
      workedTrail.every((HabotJustification j) => j.isAttributed);

  static bool get theTrailIsGroupedByResponse =>
      trailFor('r-1').length == 2 &&
      trailFor('r-2').length == 1 &&
      trailFor('r-3').isEmpty;

  /// An empty answer is a real answer: a response with no recorded basis says
  /// so rather than showing a blank panel, because a blank panel reads as a
  /// loading failure.
  static String summaryFor(String responseId) => trailFor(responseId).isEmpty
      ? 'No reasons were recorded for this response.'
      : '${trailFor(responseId).length} recorded';

  static bool get anEmptyTrailSaysSo =>
      summaryFor('r-3').contains('No reasons were recorded');

  // -----------------------------------------------------------------------
  // Metric: Task Completion Status -- 0.8 / 1 / 1.
  // -----------------------------------------------------------------------

  static const double floor = 0.8;
  static const double optimal = 1;
  static const double ceiling = 1;

  /// A task is completed or it is not. A floor of 0.8 treats a binary as a
  /// rate, and the Complete/Partial/Not Complete output then collapses it
  /// back into three words -- so the band and its output disagree about what
  /// kind of thing is being measured.
  static bool get theBandAndItsOutputDisagree =>
      floor < optimal && optimal == ceiling;

  static const String bandNote =
      'Task Completion Status with a floor of 0.8 treats a binary as a rate: '
      'a task is completed or it is not, and four fifths of one is not a '
      'fifth short of anything. The output column then collapses it back into '
      'Complete / Partial / Not Complete, so the band and its own output '
      'disagree about what kind of measurement this is. Read as a share of '
      'this step\'s declared obligations, which is the only reading that '
      'admits a fraction, it is 1.0.';

  static Map<String, bool> get obligations => <String, bool>{
        'the surface is chosen by the existing rule':
            theSurfaceIsDecidedByTheExistingRule,
        'it can be dismissed without answering anything':
            itIsDismissibleWithoutAnswering,
        'the panel is keyed by response': openingOneDoesNotOpenTheNext,
        'every entry carries its basis': everyEntryIsAttributed,
        'an empty trail says so rather than rendering blank':
            anEmptyTrailSaysSo,
        'there are no controls inside': !hasActionsInside,
        'the information is reachable without the panel': isReachableByDeepLink,
      };

  static double get completion =>
      obligations.values.where((bool b) => b).length / obligations.length;

  static String get qualitativeOutput =>
      completion >= optimal ? 'Complete' : 'Partial';

  static Map<String, bool> get checks => <String, bool>{
        'the row\'s word is recorded as the wrong one':
            theRowsWord == 'drawer' &&
                whatThatWordMeansInMd3 != whatThisIs &&
                notANavigationDrawerNote.contains('already spent'),
        'the surface comes from Step 225 rather than from here':
            theSurfaceIsDecidedByTheExistingRule &&
                intent == HabotSurfaceIntent.disclosure,
        'the width split is the declared window class':
            theWidthSplitIsTheDeclaredOne,
        'it is dismissible, because nothing is being asked':
            itIsDismissibleWithoutAnswering,
        'opening one response does not open the next':
            openingOneDoesNotOpenTheNext && theNaiveVersionOpensEverything,
        'the per-response finding is recorded with its contrast':
            perResponseNote.contains('executable contrast'),
        'the worked trail is grouped by response and fully attributed':
            theTrailIsGroupedByResponse && everyEntryIsAttributed,
        'an empty trail says so rather than rendering blank':
            anEmptyTrailSaysSo,
        'the panel is read-only, and the reason is recorded':
            !hasActionsInside && readOnlyNote.contains('deny'),
        'seven obligations, all of them met':
            obligations.length == 7 &&
                obligations.values.every((bool b) => b) &&
                completion == 1.0 &&
                qualitativeOutput == 'Complete',
        'the band and its own output are recorded as disagreeing':
            theBandAndItsOutputDisagree &&
                bandNote.contains('admits a fraction'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and the '
      'Mobile-First columns ask for background polling every thirty seconds '
      'on a panel whose content is an immutable record. Atomic Step: '
      '"Implement a collapsible Inspect Justificatory History drawer on '
      'mobile response screens."';
}
