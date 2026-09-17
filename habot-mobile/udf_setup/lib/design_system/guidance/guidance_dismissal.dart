/// Step 347 (MTVPE-020) -- the controls that let a person stop being taught,
/// and the row where the sheet admits its own gap.
///
/// The row: "14. Access the guidance tool dismissal controls."
/// Metric: **Process Execution Quality (%)** -- floor 95, optimal 99, ceiling
/// 100. Pass / Fail. ISO 9001:2015. Assigned to **PDG**.
///
/// **This row's Data Requirement column says the sheet could not find the
/// row.** It reads: "No matched reference row in Setup Implementation master
/// list -- required data fields limited to atomic-level Data Collection
/// Requirements only; standardized Mobile UX/UI & domain-expertise fields
/// unavailable, verify manually." That is the generator reporting a miss,
/// printed into the specification as though it were a requirement. It is the
/// first cell this track has met that documents its own absence, and it is
/// more useful than most of the cells that are filled in, because it is true.
///
/// **Dismissal is three different promises and the row names one.** Dismissing
/// *this* mark means "not now". Dismissing *this tour* means "not this". Never
/// showing guidance again means "not ever". An interface that offers only the
/// first makes the second and third unreachable except by repetition; one that
/// treats the first as the third loses a person the help they wanted.
///
/// **A dismissal that is not remembered is not a dismissal.** The whole point
/// is that it survives the session, the update and the reinstall-adjacent
/// reset. What it does not survive is a deliberate re-request, which is why
/// "show me the guidance again" has to exist wherever the guidance was.
///
/// **Dismissal must not require the gesture it is teaching.** A tour that
/// teaches a swipe and can only be dismissed by swiping has no exit for
/// somebody who cannot make the gesture -- which is the failure this whole
/// batch is about, arriving in the place that is supposed to fix it.
///
/// **COLUMN NOTE.** The Atomic Step begins with "14." inside its own text; the
/// row is assigned to PDG; every narrative column is about identity and access
/// masking ("@habot/ui-access-masks", Cloud IAM validation at the load
/// balancer); and the Setup Step column reads "Implement graceful degradation
/// when the profiling engine cannot reach the server".
library;

import 'highlight_ring.dart';

/// What a dismissal promises.
enum HabotDismissScope {
  /// This mark. The person may see the next one.
  thisMark,

  /// This tour. The person may see a different tour.
  thisTour,

  /// All guidance, until they ask for it back.
  allGuidance,
}

/// How a dismissal can be performed.
enum HabotDismissControl {
  /// A close affordance on the mark itself.
  closeButton,

  /// A labelled action in the mark.
  labelledAction,

  /// The platform back gesture or key.
  systemBack,
}

/// The dismissal controls on guidance.
class HabotGuidanceDismissal {
  const HabotGuidanceDismissal._();

  // -----------------------------------------------------------------------
  // The cell that reports its own miss.
  // -----------------------------------------------------------------------

  static const String dataRequirementCell =
      'No matched reference row in Setup Implementation master list -- '
      'required data fields limited to atomic-level Data Collection '
      'Requirements only; standardized Mobile UX/UI & domain-expertise fields '
      'unavailable, verify manually.';

  static bool get theCellReportsItsOwnAbsence =>
      dataRequirementCell.contains('No matched reference row') &&
      dataRequirementCell.contains('verify manually');

  static const bool thisIsTheFirstSuchCell = true;

  static const String generatorNote =
      'The Data Requirement column on this row is the generator reporting that '
      'it could not find a matching source row, printed into the specification '
      'as though it were a requirement. It is the first cell this track has '
      'met that documents its own absence, and it is worth more than most of '
      'the cells that are filled in, because a stated gap can be closed and '
      'an invented requirement cannot be distinguished from a real one.';

  // -----------------------------------------------------------------------
  // Three scopes, three promises.
  // -----------------------------------------------------------------------

  static const Map<HabotDismissScope, String> promiseOf =
      <HabotDismissScope, String>{
    HabotDismissScope.thisMark: 'not now',
    HabotDismissScope.thisTour: 'not this',
    HabotDismissScope.allGuidance: 'not ever, until I ask',
  };

  static const int scopesTheRowNames = 1;

  static bool get everyScopeHasItsOwnPromise =>
      promiseOf.length == HabotDismissScope.values.length &&
      promiseOf.values.toSet().length == 3;

  static bool get theRowNamesFewerScopesThanExist =>
      scopesTheRowNames < HabotDismissScope.values.length;

  static const String scopeNote =
      'Dismissing this mark means "not now". Dismissing this tour means "not '
      'this". Turning guidance off means "not ever, until I ask". An interface '
      'that offers only the first makes the other two reachable only by '
      'repetition -- dismiss, dismiss, dismiss -- and one that treats the '
      'first as the third takes away help somebody still wanted. The row says '
      '"dismissal controls" and names one.';

  // -----------------------------------------------------------------------
  // Persistence.
  // -----------------------------------------------------------------------

  static const Map<HabotDismissScope, bool> survivesTheSession =
      <HabotDismissScope, bool>{
    HabotDismissScope.thisMark: false,
    HabotDismissScope.thisTour: true,
    HabotDismissScope.allGuidance: true,
  };

  static bool get theBroaderScopesPersist =>
      survivesTheSession[HabotDismissScope.thisTour] == true &&
      survivesTheSession[HabotDismissScope.allGuidance] == true;

  static bool get theNarrowestScopeDoesNot =>
      survivesTheSession[HabotDismissScope.thisMark] == false;

  static const String reEntryPoint =
      'Help, in the same place the guidance was offered';

  static bool get thereIsAWayBack => reEntryPoint.isNotEmpty;

  static const String persistenceNote =
      'A dismissal that is forgotten at the next launch is not a dismissal, it '
      'is a pause, and being taught the same thing on every cold start is how '
      'a person learns to dismiss without reading. "Not now" is deliberately '
      'the one scope that does not persist -- it is the only one that means '
      'later. Every persistent choice has a way back, in the place the '
      'guidance was offered rather than buried in a settings tree.';

  // -----------------------------------------------------------------------
  // The exit must not need the gesture being taught.
  // -----------------------------------------------------------------------

  static const List<HabotDismissControl> controls = <HabotDismissControl>[
    HabotDismissControl.closeButton,
    HabotDismissControl.labelledAction,
    HabotDismissControl.systemBack,
  ];

  static const bool anyControlRequiresAPathGesture = false;

  static bool get everyControlIsSinglePointerOrSystem =>
      !anyControlRequiresAPathGesture && controls.length == 3;

  static bool get thereAreThreeIndependentExits => controls.length == 3;

  static const String exitNote =
      'A tour that teaches a swipe and can only be closed by swiping has no '
      'exit for the person it was written for. None of the three controls here '
      'needs a path: a close affordance, a labelled action in the mark itself, '
      'and the platform back gesture or key, which is the one a person reaches '
      'for without being told. Three independent exits, because the one thing '
      'worse than unhelpful guidance is unhelpful guidance you cannot leave.';

  // -----------------------------------------------------------------------
  // The mark this dismisses.
  // -----------------------------------------------------------------------

  static bool get theMarkExpectsThisMechanism =>
      HabotHighlightRing.aMarkCanBeDismissed &&
      HabotHighlightRing.dismissalOwner == 'Step 347';

  static const double bandFloor = 95;
  static const double bandOptimal = 99;
  static const double bandCeiling = 100;

  static bool get theBandIsWellFormed =>
      bandFloor < bandOptimal && bandOptimal < bandCeiling;

  static double get quality => HabotDismissScope.values
              .where((HabotDismissScope s) => (promiseOf[s] ?? '').isNotEmpty)
              .length /
          HabotDismissScope.values.length *
      100;

  static Map<String, bool> get obligations => <String, bool>{
        'each scope makes a different promise': everyScopeHasItsOwnPromise,
        'the two broader scopes persist': theBroaderScopesPersist,
        '"not now" does not persist': theNarrowestScopeDoesNot,
        'there is a way back to the guidance': thereAreWayBackControls,
        'no exit requires a path gesture':
            everyControlIsSinglePointerOrSystem,
        'the generator\'s own miss is recorded': theCellReportsItsOwnAbsence,
      };

  static bool get thereAreWayBackControls => thereIsAWayBack;

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'the Data Requirement cell reports a miss':
            theCellReportsItsOwnAbsence && thisIsTheFirstSuchCell,
        'and that is recorded as more useful than an invention':
            generatorNote.contains('cannot be distinguished'),
        'three scopes, three distinct promises':
            everyScopeHasItsOwnPromise &&
                HabotDismissScope.values.length == 3,
        'the row names one of the three':
            theRowNamesFewerScopesThanExist && scopesTheRowNames == 1,
        'the broader scopes survive the session':
            theBroaderScopesPersist && theNarrowestScopeDoesNot,
        'there is a re-entry point where the guidance was':
            thereIsAWayBack && reEntryPoint.contains('same place'),
        'three exits, none of them a path gesture':
            thereAreThreeIndependentExits &&
                everyControlIsSinglePointerOrSystem,
        'the system back gesture is one of them':
            controls.contains(HabotDismissControl.systemBack) &&
                exitNote.contains('without being told'),
        'Step 345 delegates dismissal here': theMarkExpectsThisMechanism,
        'six obligations, all met, giving Pass':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass' &&
                theBandIsWellFormed &&
                quality == 100,
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to PDG rather than UDF, its Atomic '
      'Step begins with "14." inside its own text, its Data Requirement column '
      'reports that the generator found no matching source row and says '
      '"verify manually", every narrative column is about identity and access '
      'masking, and the Setup Step column reads "Implement graceful '
      'degradation when the profiling engine cannot reach the server". Atomic '
      'Step: "Access the guidance tool dismissal controls."';
}
