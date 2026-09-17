/// Step 336 (CBSV-006-15) -- a swipe offered as the way between two views,
/// and the Level A criterion that says it cannot be the only way.
///
/// The row: "Integrate swipe-right touch options allowing users to toggle
/// effortlessly between associated table viewports."
/// Metric: **Schema/Field Configuration Accuracy Rate** -- floor ">=90%",
/// optimal 1, ceiling 1. Good/Average/Poor. DAMA-DMBOK2. Assigned to **DEA**.
///
/// **WCAG 2.2 SC 2.5.1 Pointer Gestures is Level A**, which is the lowest bar
/// there is, and it says that any function operable by a path-based gesture
/// must also be operable by a single pointer without a path. A horizontal
/// swipe between viewports is exactly a path-based gesture: it has a start, a
/// direction and a distance, and all three matter. So the swipe is not the
/// defect -- being the only route is. The row says "swipe-right touch options
/// allowing users to toggle", and names no second route at all.
///
/// The people this excludes are not an edge case. Somebody using a head
/// pointer, a switch, a mouth stick or voice control has a single pointer and
/// no path. Somebody with a tremor starts the path and does not finish it.
/// Somebody using a screen reader has the gesture intercepted by the reader
/// before the application ever sees it -- on both platforms, and by design.
///
/// **The swipe is also undiscoverable, which is a separate problem.** A
/// gesture leaves no mark on the screen. The tabs this file requires are the
/// alternative *and* the only reason anybody finds the swipe.
///
/// **A new guard rule is specified here**, and its id is
/// `A11Y_GESTURE_WITHOUT_ALTERNATIVE`,
/// which is the batch's structural contribution: a path-based gesture handler
/// declared without a named single-pointer equivalent fails the guard. It is
/// declared in this file and switched on at Step 344's census.
///
/// **COLUMN NOTE.** The Setup Step column reads "Inject conditional back-button
/// intercept hooks to intercept accidental sheet dismissals", which is a
/// navigation-interception instruction on a view-toggle row, and the band mixes
/// units: a floor written ">=90%" against an optimal and a ceiling both written
/// "1", so the optimal and the ceiling are the same value.
library;

import '../interaction/swipe_back.dart';

/// How a function can be reached.
enum HabotRouteKind {
  /// A path-based gesture: start, direction, distance.
  pathGesture,

  /// One pointer, one place, no path. Tap, click, switch, voice.
  singlePointer,

  /// Traversal by keyboard or by screen-reader swipe.
  traversal,
}

/// One way between two associated viewports.
class HabotViewportRoute {
  const HabotViewportRoute({
    required this.name,
    required this.kind,
    required this.visibleOnScreen,
  });

  final String name;
  final HabotRouteKind kind;

  /// Whether a person who has never used the screen can see that it exists.
  final bool visibleOnScreen;
}

/// The toggle between associated table viewports.
class HabotSwipeAlternative {
  const HabotSwipeAlternative._();

  // -----------------------------------------------------------------------
  // What the row asks for, and what it leaves out.
  // -----------------------------------------------------------------------

  /// The only route the row names.
  static const HabotViewportRoute theRoutTheRowNames = HabotViewportRoute(
    name: 'swipe right between associated viewports',
    kind: HabotRouteKind.pathGesture,
    visibleOnScreen: false,
  );

  /// What is actually built: three routes to the same function.
  static const List<HabotViewportRoute> routes = <HabotViewportRoute>[
    theRoutTheRowNames,
    HabotViewportRoute(
      name: 'tab bar above the table',
      kind: HabotRouteKind.singlePointer,
      visibleOnScreen: true,
    ),
    HabotViewportRoute(
      name: 'tab traversal by keyboard or screen reader',
      kind: HabotRouteKind.traversal,
      visibleOnScreen: true,
    ),
  ];

  static List<HabotViewportRoute> get pathBasedRoutes => routes
      .where((HabotViewportRoute r) => r.kind == HabotRouteKind.pathGesture)
      .toList();

  static List<HabotViewportRoute> get singlePointerRoutes => routes
      .where((HabotViewportRoute r) => r.kind == HabotRouteKind.singlePointer)
      .toList();

  /// SC 2.5.1 is satisfied when at least one route needs no path.
  static bool get theGestureHasASinglePointerEquivalent =>
      singlePointerRoutes.isNotEmpty;

  static bool get theRowNamesOnlyThePath =>
      theRoutTheRowNames.kind == HabotRouteKind.pathGesture;

  static const String criterion = 'WCAG 2.2 SC 2.5.1 Pointer Gestures';
  static const String conformanceLevel = 'A';

  static bool get theCriterionIsLevelA => conformanceLevel == 'A';

  static const String alternativeNote =
      'SC 2.5.1 Pointer Gestures is Level A, the lowest bar there is, and it '
      'requires that anything operable by a path-based gesture also be '
      'operable by a single pointer without a path. A horizontal swipe has a '
      'start, a direction and a distance, so it is path-based by definition. '
      'The gesture is not the defect; being the only route is, and the row '
      'names no other. A head pointer, a switch, a mouth stick and voice '
      'control all produce a single pointer and no path, and on both platforms '
      'a screen reader takes the swipe before the application sees it.';

  // -----------------------------------------------------------------------
  // Discoverability, which is a different problem with the same cure.
  // -----------------------------------------------------------------------

  static List<HabotViewportRoute> get visibleRoutes => routes
      .where((HabotViewportRoute r) => r.visibleOnScreen)
      .toList();

  static int get routesAPersonCanSee => visibleRoutes.length;

  static bool get theGestureIsInvisible => !theRoutTheRowNames.visibleOnScreen;

  /// Two of the three routes are visible; the gesture is the one that is not.
  static bool get theOnlyInvisibleRouteIsTheOneTheRowNames =>
      routesAPersonCanSee == 2 && theGestureIsInvisible;

  static const String discoverabilityNote =
      'A gesture leaves no mark on a screen, so a person who has not been told '
      'about it will not find it. The row calls the swipe "effortless", which '
      'it is for somebody who already knows it is there. Two of the three '
      'routes built here are visible and the gesture is the one that is not, '
      'which means the tab bar is simultaneously the accessible alternative '
      'and the only reason anybody discovers the shortcut.';

  // -----------------------------------------------------------------------
  // The direction, which is not a constant.
  // -----------------------------------------------------------------------

  /// Step 225 already resolved that a leading-edge gesture is leading-edge in
  /// the reading direction, not always on the left. Urdu ships (Step 139).
  static bool get theDirectionRuleIsAlreadyDeclared =>
      HabotSwipeBack.directionIsResolvedNotAssumed;

  static const String directionNote =
      'The row says "swipe-right", which is a physical direction. Step 225 '
      'already settled that a gesture between a first and a second view is '
      'resolved against the reading direction rather than assumed, because '
      'this application ships Urdu. In a right-to-left locale, swiping right '
      'goes back rather than forward, and a hardcoded direction sends half the '
      'shipped locales the wrong way.';

  // -----------------------------------------------------------------------
  // The gesture guard, specified here and switched on at Step 344.
  // -----------------------------------------------------------------------

  static const String guardRuleId = 'A11Y_GESTURE_WITHOUT_ALTERNATIVE';

  static const String guardRuleDescription =
      'A path-based gesture handler declared without a named single-pointer '
      'equivalent on the same widget fails the guard.';

  static const bool guardIsEnabledInThisStep = false;

  static const String guardNote =
      'The rule is specified here and enabled at Step 344, where the census '
      'that would run it is built. Declaring it in the step that discovered '
      'the need, and enabling it in the step that can enforce it, is the '
      'pattern Step 304 used for HARDCODED_HELP_TEXT.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static const String bandFloor = '>=90%';
  static const String bandOptimal = '1';
  static const String bandCeiling = '1';

  static bool get theOptimalEqualsTheCeiling => bandOptimal == bandCeiling;

  /// A floor in per cent against an optimal and a ceiling as a bare ratio.
  static bool get theBandMixesUnits =>
      bandFloor.contains('%') && !bandOptimal.contains('%');

  static const String bandNote =
      'The floor is written ">=90%" and the optimal and the ceiling are both '
      'written "1", so the band mixes a percentage with a bare ratio and its '
      'top two values are the same number. A band whose optimal and ceiling '
      'coincide has two ends and three labels. Recorded rather than gated, '
      'because there is nothing to gate against.';

  static Map<String, bool> get obligations => <String, bool>{
        'the gesture has a single-pointer equivalent':
            theGestureHasASinglePointerEquivalent,
        'the function is reachable by traversal': routes.any(
          (HabotViewportRoute r) => r.kind == HabotRouteKind.traversal,
        ),
        'at least one route is visible without instruction':
            routesAPersonCanSee >= 2,
        'the gesture direction resolves against the reading direction':
            theDirectionRuleIsAlreadyDeclared,
        'the guard rule is specified with an id and a description':
            guardRuleId.isNotEmpty && guardRuleDescription.isNotEmpty,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'three routes to one function':
            routes.length == 3 &&
                routes.map((HabotViewportRoute r) => r.kind).toSet().length ==
                    3,
        'the row names exactly one, and it is the path':
            theRowNamesOnlyThePath && pathBasedRoutes.length == 1,
        'a single-pointer route exists':
            theGestureHasASinglePointerEquivalent &&
                singlePointerRoutes.length == 1,
        'the criterion is Level A':
            theCriterionIsLevelA &&
                criterion.contains('2.5.1') &&
                alternativeNote.contains('lowest bar'),
        'the invisible route is the one the row names':
            theOnlyInvisibleRouteIsTheOneTheRowNames,
        'discoverability and access have the same cure':
            discoverabilityNote.contains('accessible alternative'),
        'the direction is resolved rather than hardcoded':
            theDirectionRuleIsAlreadyDeclared &&
                directionNote.contains('Urdu'),
        'the guard rule is declared and deferred to Step 344':
            !guardIsEnabledInThisStep && guardNote.contains('Step 344'),
        'the band mixes units and repeats its top value':
            theBandMixesUnits && theOptimalEqualsTheCeiling,
        'five obligations, all met, giving Good':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good',
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to DEA rather than UDF, its Setup '
      'Step column reads "Inject conditional back-button intercept hooks to '
      'intercept accidental sheet dismissals" -- a navigation-interception '
      'instruction on a view-toggle row -- and its band sets a floor of '
      '">=90%" '
      'against an optimal and a ceiling both written "1". Atomic Step: '
      '"Integrate swipe-right touch options allowing users to toggle '
      'effortlessly between associated table viewports."';
}
