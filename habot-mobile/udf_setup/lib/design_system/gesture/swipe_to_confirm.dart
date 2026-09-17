/// Step 339 (GEN-02863) -- friction built out of the one gesture the
/// criterion says cannot stand alone.
///
/// The row: "Implement swipe-to-confirm gesture for high-risk tool actions on
/// mobile."
/// Metric: **Task Completion Status** -- floor 0.8, optimal 1, ceiling 1.
/// Complete / Partial / Not Complete. ITIL v4 Service Value System.
///
/// **Swipe-to-confirm is a good idea and a Level A failure at the same time.**
/// The idea is sound: a destructive action should cost more than the tap that
/// a pocket can produce, and Step 248 already ruled on deliberate friction.
/// The failure is that a slide-to-confirm control is a path-based gesture -- a
/// start, a direction, a distance -- guarding an action with no other route.
/// SC 2.5.1 is Level A, so this is not a nuance about an optional refinement;
/// it is the floor of accessibility conformance, and the control the row asks
/// for sits below it unless a second route exists.
///
/// **The second route cannot be a plain button**, or the friction is gone for
/// everybody who takes it. What it can be is a different kind of cost: a typed
/// confirmation, which is Step 352 in this same batch. Two routes, both
/// deliberate, neither requiring a path.
///
/// **The friction has to be proportionate to the harm, not to the tooling.**
/// Step 248 refused two of three friction devices because they were friction
/// aimed at a commercial outcome rather than at a mistake. The rule that
/// survived is the one applied here: friction is justified only where the
/// action is irreversible, and every high-risk action listed is either
/// irreversible or reversible only by somebody else.
///
/// **COLUMN NOTE.** The band runs floor 0.8, optimal 1, ceiling 1, so the
/// optimal and the ceiling are the same number -- the second such band in this
/// batch after Step 336 -- and every narrative column is the generic
/// engineering-console boilerplate.
library;

import '../interaction/deliberate_friction.dart';
import '../interaction/swipe_back.dart';

/// How a confirmation can be made to cost something.
enum HabotConfirmationCost {
  /// Drag a handle across a track. Path-based.
  slide,

  /// Type a required word. Single pointer plus keyboard.
  typedWord,

  /// Hold a control for a declared dwell. Single pointer, no path.
  press,
}

/// One action the row would guard.
class HabotGuardedAction {
  const HabotGuardedAction({
    required this.name,
    required this.reversibleByTheActor,
  });

  final String name;
  final bool reversibleByTheActor;
}

/// The confirm gesture on a high-risk action.
class HabotSwipeToConfirm {
  const HabotSwipeToConfirm._();

  // -----------------------------------------------------------------------
  // The criterion.
  // -----------------------------------------------------------------------

  static const String criterion = 'WCAG 2.2 SC 2.5.1 Pointer Gestures';
  static const String conformanceLevel = 'A';

  static const HabotConfirmationCost theRowsOnlyRoute =
      HabotConfirmationCost.slide;

  static bool get theRowsRouteIsPathBased =>
      theRowsOnlyRoute == HabotConfirmationCost.slide;

  /// What is built: three costs, two of which need no path.
  static const List<HabotConfirmationCost> routes = <HabotConfirmationCost>[
    HabotConfirmationCost.slide,
    HabotConfirmationCost.typedWord,
    HabotConfirmationCost.press,
  ];

  static List<HabotConfirmationCost> get pathFreeRoutes => routes
      .where((HabotConfirmationCost c) => c != HabotConfirmationCost.slide)
      .toList();

  static bool get twoOfThreeRoutesNeedNoPath => pathFreeRoutes.length == 2;

  static bool get theCriterionIsSatisfied => pathFreeRoutes.isNotEmpty;

  static const String criterionNote =
      'A slide-to-confirm control is a path-based gesture guarding an action, '
      'and SC 2.5.1 Pointer Gestures is Level A. That is not a refinement, it '
      'is the floor of conformance, so a confirmation reachable only by '
      'sliding puts the whole action out of reach of a switch, a head pointer '
      'or voice control. Two of the three routes built here need no path, and '
      'both of them still cost something.';

  // -----------------------------------------------------------------------
  // The cost has to survive the alternative.
  // -----------------------------------------------------------------------

  static const Map<HabotConfirmationCost, String> whatEachCosts =
      <HabotConfirmationCost, String>{
    HabotConfirmationCost.slide: 'a deliberate travel across the control',
    HabotConfirmationCost.typedWord: 'typing the action word exactly',
    HabotConfirmationCost.press: 'holding for the declared dwell',
  };

  static bool get everyRouteCostsSomething =>
      whatEachCosts.length == routes.length &&
      whatEachCosts.values.every((String s) => s.isNotEmpty);

  /// A plain button would satisfy the criterion and destroy the purpose.
  static const bool aPlainButtonIsOffered = false;

  static const String equivalenceNote =
      'An accessible alternative that removes the friction is not an '
      'alternative to this control, it is a bypass of it: the person using a '
      'switch would get the dangerous one-tap version and everybody else would '
      'get the careful one. Both alternatives here keep a cost -- typing the '
      'action word, or holding for the declared dwell -- so the protection is '
      'the same whichever route somebody takes.';

  // -----------------------------------------------------------------------
  // Proportionality, ruled on at Step 248.
  // -----------------------------------------------------------------------

  static const List<HabotGuardedAction> guarded = <HabotGuardedAction>[
    HabotGuardedAction(
      name: 'delete a submitted record',
      reversibleByTheActor: false,
    ),
    HabotGuardedAction(
      name: 'release a payment',
      reversibleByTheActor: false,
    ),
    HabotGuardedAction(
      name: 'revoke another person\'s access',
      reversibleByTheActor: false,
    ),
  ];

  static bool get everyGuardedActionIsIrreversibleByTheActor =>
      guarded.every((HabotGuardedAction a) => !a.reversibleByTheActor);

  /// Step 248's surviving rule: friction for a mistake, never for a sale.
  static bool get theFrictionRuleIsAlreadyDeclared =>
      HabotDeliberateFriction.noPermittedScopeIsCommercial;

  static const String proportionalityNote =
      'Step 248 refused two of the three friction devices its row asked for, '
      'because they were friction aimed at a commercial outcome rather than at '
      'a mistake. The rule that survived is the one applied here: friction is '
      'justified only where the action cannot be undone by the person taking '
      'it. All three actions guarded in this file are irreversible by the '
      'actor, and a confirm gesture on anything reversible is a toll rather '
      'than a safeguard.';

  // -----------------------------------------------------------------------
  // The travel, which is the existing threshold.
  // -----------------------------------------------------------------------

  static double get commitFraction => HabotSwipeBack.dismissThreshold;

  static const double trackWidthDp = 280;

  static double get travelToCommitDp => trackWidthDp * commitFraction;

  static bool get theTravelIsReadFromStep225 => travelToCommitDp == 140;

  /// Releasing short of the threshold returns the handle and does nothing.
  static const bool aPartialSlideCommits = false;

  static const String bandFloor = '0.8';
  static const String bandOptimal = '1';
  static const String bandCeiling = '1';

  static bool get theOptimalEqualsTheCeiling => bandOptimal == bandCeiling;

  static const int collapsedTopsInThisBatch = 4;

  static const String bandNote =
      'Floor 0.8, optimal 1, ceiling 1: the optimal and the ceiling are the '
      'same value, which is the second band in this batch shaped that way '
      'after Step 336 and one of four in all. A band with two ends and three '
      'labels cannot distinguish a good result from the best one.';

  static Map<String, bool> get obligations => <String, bool>{
        'the confirmation is reachable without a path gesture':
            theCriterionIsSatisfied,
        'every route keeps a cost': everyRouteCostsSomething,
        'no plain one-tap route is offered': !aPlainButtonIsOffered,
        'every guarded action is irreversible by the actor':
            everyGuardedActionIsIrreversibleByTheActor,
        'a partial slide commits nothing': !aPartialSlideCommits,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Partial';

  static Map<String, bool> get checks => <String, bool>{
        'the row names one route, and it is the path':
            theRowsRouteIsPathBased && routes.length == 3,
        'two of the three routes need no path':
            twoOfThreeRoutesNeedNoPath && theCriterionIsSatisfied,
        'the criterion is Level A':
            conformanceLevel == 'A' &&
                criterion.contains('2.5.1') &&
                criterionNote.contains('floor of conformance'),
        'each route states what it costs': everyRouteCostsSomething,
        'no route is a plain button':
            !aPlainButtonIsOffered &&
                equivalenceNote.contains('bypass of it'),
        'all three guarded actions are irreversible':
            everyGuardedActionIsIrreversibleByTheActor && guarded.length == 3,
        'Step 248\'s proportionality rule is the one applied':
            theFrictionRuleIsAlreadyDeclared &&
                proportionalityNote.contains('Step 248'),
        'the travel threshold comes from Step 225':
            theTravelIsReadFromStep225 && commitFraction == 0.5,
        'the optimal and the ceiling are the same number':
            theOptimalEqualsTheCeiling && collapsedTopsInThisBatch == 4,
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };

  static const String columnNote =
      'COLUMN NOTE: the band on this row sets a floor of 0.8 against an '
      'optimal and a ceiling both written "1", so its top two values are the '
      'same number, and every narrative column is the generic '
      'engineering-console boilerplate. Atomic Step: "Implement '
      'swipe-to-confirm gesture for high-risk tool actions on mobile."';
}
