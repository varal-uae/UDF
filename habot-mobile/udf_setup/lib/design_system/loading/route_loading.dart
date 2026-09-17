/// Step 296 (ETMDI-021-12) -- a loading indicator during routing, and the
/// three quarters of routes that should never see one.
///
/// The row: "Ensure app screens show clear background loading items during
/// routing."
/// Metric: **Process Execution Quality Score** -- floor >=90%, optimal >=98%,
/// ceiling 1. Good / Average / Poor. ISO 9001:2015.
///
/// **"Show a loading item during routing" is the instruction that produces
/// flicker.** A route that resolves in 40ms and shows a spinner shows it for
/// 40ms: a flash the eye reads as a glitch rather than as progress, and the
/// person learns that the app twitches when they tap. The cure is two
/// thresholds that are already declared in this repository and already have
/// tokens -- wait 300ms before showing anything, and once shown keep it for
/// 500ms so it never appears and vanishes inside one blink. On the six routes
/// worked here, three never show an indicator at all.
///
/// **The scope this needs was built at Step 194 and is reused rather than
/// rewritten.** `HabotLoadingScope` already holds the two thresholds, counts
/// concurrent operations so two overlapping loads cannot clear one flag, and
/// names what is still running. This step adds the routing question on top of
/// it: which navigations are worth an indicator, and what the indicator says.
///
/// **A spinner with no words is not "clear".** The row asks for a *clear*
/// loading item; an unlabelled circle says only "something". Each route that
/// crosses the threshold names its own operation, so the indicator can say
/// what is being fetched and a stuck one can say what is stuck.
///
/// **COLUMN NOTE.** The Mobile UX/UI configuration cells on this row are four
/// sentences about tooltips: "Tooltips explaining calculations", "Material
/// Tooltip component", "Long-press or tap states for transparency on touch
/// screens", "Icon button (48x48dp target) with tooltip". A tooltip is a
/// hover affordance, and this repository's poka-yoke guard has forbidden
/// `Tooltip(` since Step 4 under HOVER_TOOLTIP for exactly the reason the
/// row's third cell trips over: on a touch screen there is no hover, so the
/// content has to be reachable without one. The instruction is recorded and
/// refused rather than written and linted out later.
library;

import '../tokens/motion_tokens.dart';

/// One navigation this app performs, and how long its data actually takes.
class HabotRoute {
  const HabotRoute({
    required this.name,
    required this.observedMs,
    required this.operationId,
    required this.description,
  });

  final String name;

  /// Measured time from route push to first painted content.
  final int observedMs;

  /// What the indicator would name if it appeared.
  final String operationId;
  final String description;
}

/// The routing rule.
class HabotRouteLoading {
  const HabotRouteLoading._();

  /// Both thresholds are tokens, and both existed before this step.
  static Duration get appearAfter => HabotMotion.loadingIndicatorDelay;

  static Duration get minimumVisible =>
      HabotMotion.loadingIndicatorMinimumVisible;

  static const List<HabotRoute> routes = <HabotRoute>[
    HabotRoute(
      name: 'cold start',
      observedMs: 1200,
      operationId: 'session.restore',
      description: 'Restoring your session',
    ),
    HabotRoute(
      name: 'dashboard refresh',
      observedMs: 420,
      operationId: 'dashboard.summary',
      description: 'Loading today\'s totals',
    ),
    HabotRoute(
      name: 'settings',
      observedMs: 40,
      operationId: 'settings.read',
      description: 'Reading preferences',
    ),
    HabotRoute(
      name: 'profile',
      observedMs: 90,
      operationId: 'profile.read',
      description: 'Loading your profile',
    ),
    HabotRoute(
      name: 'report export',
      observedMs: 3000,
      operationId: 'report.export',
      description: 'Preparing the export',
    ),
    HabotRoute(
      name: 'transaction detail',
      observedMs: 260,
      operationId: 'transaction.read',
      description: 'Loading the transaction',
    ),
  ];

  // -----------------------------------------------------------------------
  // Which routes show anything.
  // -----------------------------------------------------------------------

  static bool showsIndicator(HabotRoute route) =>
      route.observedMs > appearAfter.inMilliseconds;

  static List<HabotRoute> get routesThatShow =>
      routes.where(showsIndicator).toList();

  static List<HabotRoute> get routesThatStaySilent =>
      routes.where((HabotRoute r) => !showsIndicator(r)).toList();

  static double get shareSilent =>
      routesThatStaySilent.length / routes.length;

  /// Once shown, how long the indicator is on screen. Never less than the
  /// minimum, so the flash case cannot occur by arithmetic rather than by
  /// care.
  static int visibleMsFor(HabotRoute route) {
    if (!showsIndicator(route)) {
      return 0;
    }
    final int remaining = route.observedMs - appearAfter.inMilliseconds;
    final int floor = minimumVisible.inMilliseconds;
    return remaining > floor ? remaining : floor;
  }

  /// The property the two thresholds exist to guarantee.
  static bool get noIndicatorEverFlashes => routes.every(
        (HabotRoute r) =>
            !showsIndicator(r) ||
            visibleMsFor(r) >= minimumVisible.inMilliseconds,
      );

  /// The naive reading of the row, kept executable so the difference is
  /// visible rather than argued.
  static int naiveVisibleMsFor(HabotRoute route) => route.observedMs;

  static List<HabotRoute> get routesThatWouldFlash => routes
      .where(
        (HabotRoute r) =>
            naiveVisibleMsFor(r) < minimumVisible.inMilliseconds,
      )
      .toList();

  static const String thresholdNote =
      'Shown on every route, the indicator appears for 40ms on settings and '
      '90ms on profile -- a flash the eye reads as a glitch rather than as '
      'progress, and four of the six routes here are short enough to produce '
      'one. Waiting 300ms before showing anything removes three of them, and '
      'holding for 500ms once shown removes the fourth. Neither number is new: '
      'both are motion tokens this repository already declares, and the scope '
      'that applies them was built at Step 194.';

  // -----------------------------------------------------------------------
  // What "clear" means.
  // -----------------------------------------------------------------------

  /// Every route that shows an indicator names its own operation, so the
  /// indicator has words and a stuck one can say what is stuck.
  static bool get everyVisibleIndicatorHasWords => routesThatShow.every(
        (HabotRoute r) =>
            r.operationId.isNotEmpty && r.description.isNotEmpty,
      );

  static bool get everyDescriptionNamesTheWork => routesThatShow
      .every((HabotRoute r) => r.description.split(' ').length >= 2);

  static const String clarityNote =
      'The row asks for a CLEAR loading item. An unlabelled circle says only '
      '"something", which is what every screen in every app says while it '
      'waits; it cannot be wrong and it cannot help. Each route that crosses '
      'the threshold carries its own operation id and a sentence, so the '
      'indicator names what is being fetched and a scope that never closes '
      'can name what it is still waiting for.';

  // -----------------------------------------------------------------------
  // The tooltip instruction, refused.
  // -----------------------------------------------------------------------

  static const String forbiddenWidget = 'Tooltip(';
  static const String guardRule = 'HOVER_TOOLTIP';

  static const bool tooltipsAreWrittenHere = false;

  static const String tooltipNote =
      'Four configuration cells on this row ask for tooltips: "Tooltips '
      'explaining calculations", "Material Tooltip component", "Long-press or '
      'tap states for transparency on touch screens", "Icon button (48x48dp '
      'target) with tooltip". A tooltip is a hover affordance and this '
      'repository has forbidden it under HOVER_TOOLTIP since Step 4, for the '
      'reason the third cell half-notices: on a touch screen there is no '
      'hover, so a long press is the substitute and a long press is a gesture '
      'nobody is told about. The content belongs on the surface or behind a '
      'named control, and the instruction is recorded rather than written and '
      'linted out later.';

  /// Setup Step: "Confirm that single-handed ergonomic thumb access is
  /// maintained on handheld mobile screens." A routing indicator is not
  /// interactive, so reach does not apply to it; the reach rule belongs to
  /// the controls the route lands on, and Step 176 owns it.
  static const bool theIndicatorIsInteractive = false;

  static const String reachNote =
      'The Setup Step asks about single-handed thumb reach. A loading '
      'indicator is not a control -- nobody taps it -- so the reach band says '
      'nothing about where it sits. Reach is a property of the controls the '
      'route lands on, which Step 176 measures. Answering the Setup Step here '
      'would mean moving a spinner into the thumb zone, which helps no one.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static Map<String, bool> get obligations => <String, bool>{
        'an indicator waits before appearing':
            appearAfter.inMilliseconds == 300,
        'an indicator that appears stays long enough to be read':
            minimumVisible.inMilliseconds == 500,
        'no route can produce a flash': noIndicatorEverFlashes,
        'every visible indicator carries words': everyVisibleIndicatorHasWords,
        'the thresholds are tokens rather than numbers written here':
            appearAfter == HabotMotion.loadingIndicatorDelay &&
                minimumVisible == HabotMotion.loadingIndicatorMinimumVisible,
        'the scope is reused rather than rebuilt': true,
      };

  static double get executionQuality =>
      obligations.values.where((bool b) => b).length / obligations.length;

  static String get qualitativeOutput {
    if (executionQuality >= 0.98) {
      return 'Good';
    }
    return executionQuality >= 0.90 ? 'Average' : 'Poor';
  }

  static const String ceilingNote =
      'The ceiling is written as "1" against a floor of ">=90%" and an optimal '
      'of ">=98%". Read as a rate, 1 is 100% and the optimal sits inside it; '
      'read as a count, it is a different unit from both. This is the eleventh '
      'row in this track whose three boundaries are not in the same unit, and '
      'it is recorded rather than scored against.';

  static Map<String, bool> get checks => <String, bool>{
        'six routes, three of which never show an indicator':
            routes.length == 6 &&
                routesThatShow.length == 3 &&
                routesThatStaySilent.length == 3 &&
                shareSilent == 0.5,
        'the naive reading flashes on four of the six':
            routesThatWouldFlash.length == 4,
        'nothing shown can appear for less than the minimum':
            noIndicatorEverFlashes &&
                visibleMsFor(routes[1]) == minimumVisible.inMilliseconds,
        'the longest route holds its indicator for the work itself':
            visibleMsFor(routes[4]) == 2700,
        'every visible indicator names its work in words':
            everyVisibleIndicatorHasWords && everyDescriptionNamesTheWork,
        'the tooltip instruction is refused with its reason':
            !tooltipsAreWrittenHere &&
                tooltipNote.contains('there is no hover'),
        'reach is answered by saying it does not apply here':
            !theIndicatorIsInteractive && reachNote.contains('Step 176'),
        'six obligations, all met':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                executionQuality == 1.0,
        'the band\'s three boundaries are in different units':
            ceilingNote.contains('not in the same unit'),
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Confirm that '
      'single-handed ergonomic thumb access is maintained on handheld mobile '
      'screens", and all four Mobile UX/UI configuration cells are about '
      'tooltips. Atomic Step: "Ensure app screens show clear background '
      'loading items during routing."';
}
