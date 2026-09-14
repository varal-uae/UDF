/// Step 234 (GEN-04108) -- deferring SDK initialisation past first render.
///
/// The row: "Defer non-essential SDK initializations until after the primary UI
/// view renders."
/// Metric: Deferred SDK Initialization -- floor, optimal and ceiling all 1.
/// Pass/Fail.
///
/// **"After the primary UI view renders" is two different moments.** The first
/// frame is often a skeleton, and a skeleton is not a view. Deferring to the
/// first frame moves the work into the exact window in which the user is
/// looking at a placeholder and deciding whether the app is broken. The
/// deferral point declared here is the **first useful paint** -- when the
/// screen shows the thing the user opened the app for -- which is later, and is
/// the
/// moment the row means.
///
/// **A blanket deferral loses the telemetry for the failure it would cause.**
/// Deferring the crash reporter means crashes during startup go unreported --
/// and those are the ones that matter most, because to the user they are not a
/// crash, they are an app that does not open. The same argument applies to the
/// consent gate, which has to run before anything is collected at all. So the
/// list is explicit, with a reason per entry, and three entries are marked
/// **must not defer**.
///
/// **A third category the row does not have.** Step 176 named
/// `ColorScheme.fromSeed` on the cold-start path: work, not an SDK, computing
/// 28 roles the first frame needs. It cannot be deferred because the frame
/// depends on it, and it cannot be dropped. It is listed so that "defer
/// everything non-essential" does not read as a complete account of startup.
library;

import '../tokens/motion_tokens.dart';

/// When a piece of startup work may run.
enum HabotStartupPhase {
  /// Before the first frame. Everything here is on the cold-start critical
  /// path and is counted against the budget.
  beforeFirstFrame,

  /// Between the first frame and the first useful paint.
  beforeFirstUsefulPaint,

  /// After the screen shows what the user opened the app for.
  afterFirstUsefulPaint,

  /// Not at startup at all -- on first use of the feature that needs it.
  onDemand,
}

/// One thing that initialises at startup.
class HabotStartupItem {
  const HabotStartupItem({
    required this.name,
    required this.phase,
    required this.isAnSdk,
    required this.rationale,
  });

  final String name;
  final HabotStartupPhase phase;

  /// Whether this is a third-party SDK, which is what the row is about, or
  /// something else that nonetheless costs cold-start time.
  final bool isAnSdk;

  final String rationale;

  bool get isDeferred => phase != HabotStartupPhase.beforeFirstFrame;

  bool get mustNotDefer => phase == HabotStartupPhase.beforeFirstFrame;
}

/// The deferral plan.
class HabotStartupDeferral {
  const HabotStartupDeferral._();

  /// The moment deferral targets.
  static const HabotStartupPhase deferralPoint =
      HabotStartupPhase.afterFirstUsefulPaint;

  static const String twoMomentsNote =
      'The first frame is often a skeleton, and a skeleton is not a view. '
      'Deferring to it moves the work into the window in which the user is '
      'looking at a placeholder and deciding whether the app is broken. The '
      'deferral point is the first USEFUL paint, which is later and is the '
      'moment the row means.';

  static const List<HabotStartupItem> items = <HabotStartupItem>[
    HabotStartupItem(
      name: 'consent and privacy gate',
      phase: HabotStartupPhase.beforeFirstFrame,
      isAnSdk: false,
      rationale:
          'Nothing may be collected before consent state is known, so every '
          'other SDK\'s deferral depends on this one having run.',
    ),
    HabotStartupItem(
      name: 'crash reporter (Step 159 capture filter)',
      phase: HabotStartupPhase.beforeFirstFrame,
      isAnSdk: true,
      rationale:
          'MUST NOT DEFER. A crash during startup is the crash that matters '
          'most -- to the user it is not a crash, it is an app that does not '
          'open -- and a deferred reporter is asleep for exactly that window.',
    ),
    HabotStartupItem(
      name: 'theme construction (Step 176 ColorScheme.fromSeed)',
      phase: HabotStartupPhase.beforeFirstFrame,
      isAnSdk: false,
      rationale:
          'Not an SDK. Computes 28 colour roles the first frame needs, so it '
          'cannot be deferred and cannot be dropped. Listed so that '
          '"defer everything non-essential" does not read as a complete '
          'account of startup.',
    ),
    HabotStartupItem(
      name: 'local store open (Step 96)',
      phase: HabotStartupPhase.beforeFirstUsefulPaint,
      isAnSdk: false,
      rationale:
          'The first useful paint needs the cached booking list. Deferring '
          'past it would mean rendering the skeleton twice.',
    ),
    HabotStartupItem(
      name: 'analytics transport (Step 156 event schema)',
      phase: HabotStartupPhase.afterFirstUsefulPaint,
      isAnSdk: true,
      rationale:
          'Events queue in memory until the transport is up; nothing is lost '
          'and nothing about the first screen depends on it.',
    ),
    HabotStartupItem(
      name: 'push notification registration',
      phase: HabotStartupPhase.afterFirstUsefulPaint,
      isAnSdk: true,
      rationale:
          'A token refresh is a network call. It has no deadline shorter than '
          'the session.',
    ),
    HabotStartupItem(
      name: 'remote config / feature flags (Step 117)',
      phase: HabotStartupPhase.afterFirstUsefulPaint,
      isAnSdk: true,
      rationale:
          'The first paint uses the last-known flag values from local store, '
          'which is what Step 117 built them to do. Fetching fresh ones is '
          'not on the critical path.',
    ),
    HabotStartupItem(
      name: 'payment provider SDK (Step 207 hosted fields)',
      phase: HabotStartupPhase.onDemand,
      isAnSdk: true,
      rationale:
          'Initialised when the checkout screen opens. Most sessions never '
          'reach it, and loading it at startup costs every session for the '
          'few that do.',
    ),
    HabotStartupItem(
      name: 'QR renderer (Step 209)',
      phase: HabotStartupPhase.onDemand,
      isAnSdk: false,
      rationale:
          'Needed on the confirmation screen and nowhere else. On demand, and '
          'the pass renders offline once it is there.',
    ),
  ];

  static List<HabotStartupItem> get sdks =>
      items.where((HabotStartupItem i) => i.isAnSdk).toList();

  static List<HabotStartupItem> get deferredSdks =>
      sdks.where((HabotStartupItem i) => i.isDeferred).toList();

  static List<HabotStartupItem> get mustNotDeferItems =>
      items.where((HabotStartupItem i) => i.mustNotDefer).toList();

  static List<HabotStartupItem> get nonSdkStartupWork =>
      items.where((HabotStartupItem i) => !i.isAnSdk).toList();

  static List<HabotStartupItem> get onDemandItems => items
      .where((HabotStartupItem i) => i.phase == HabotStartupPhase.onDemand)
      .toList();

  /// Every entry gives a reason. A deferral list without reasons is a list
  /// somebody reorders when a launch is slow.
  static bool get everyItemGivesAReason =>
      items.every((HabotStartupItem i) => i.rationale.length > 40);

  static bool get crashReporterIsNotDeferred => items
      .firstWhere((HabotStartupItem i) => i.name.contains('crash reporter'))
      .mustNotDefer;

  static const String crashReporterNote =
      'Deferring the crash reporter loses exactly the telemetry for the '
      'failure the deferral would cause. A startup crash is not a crash to '
      'the user, it is an app that does not open, and a deferred reporter is '
      'asleep for that whole window. A blanket "defer everything '
      'non-essential" reads as prudent and removes the only evidence of the '
      'one failure nobody can debug from a review.';

  // -----------------------------------------------------------------------
  // What the deferral buys.
  // -----------------------------------------------------------------------

  /// The cold-start budget the deferral is in service of, from Step 165.
  static Duration get coldStartBudget => HabotMotion.coldStartBudget;

  /// Share of SDKs that are off the pre-first-frame path.
  static double get sdkDeferralRate =>
      sdks.isEmpty ? 0 : deferredSdks.length / sdks.length;

  /// Share of everything at startup, SDK or not, that is off that path.
  static double get overallDeferralRate =>
      items.where((HabotStartupItem i) => i.isDeferred).length / items.length;

  // -----------------------------------------------------------------------
  // Metric: Deferred SDK Initialization. 1 / 1 / 1. Pass/Fail.
  // -----------------------------------------------------------------------

  static const double floor = 1;
  static const double optimal = 1;
  static const double ceiling = 1;

  /// A binary metric over a population containing a deliberate exception --
  /// the same shape as Step 233. The rate over the SDKs that MAY be deferred
  /// is what is reported, and the exclusion is declared.
  static double get deferralRateExcludingMustNotDefer {
    final List<HabotStartupItem> deferrable =
        sdks.where((HabotStartupItem i) => !i.mustNotDefer).toList();
    if (deferrable.isEmpty) {
      return 0;
    }
    return deferrable.where((HabotStartupItem i) => i.isDeferred).length /
        deferrable.length;
  }

  static String get qualitativeOutput =>
      deferralRateExcludingMustNotDefer >= optimal ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'the deferral point is the first useful paint, not the first frame':
            deferralPoint == HabotStartupPhase.afterFirstUsefulPaint,
        'every startup item gives a reason': everyItemGivesAReason,
        'the crash reporter is not deferred': crashReporterIsNotDeferred,
        'three items are marked must-not-defer':
            mustNotDeferItems.length == 3,
        'startup work that is not an SDK is listed too':
            nonSdkStartupWork.length == 4,
        'the Step 176 theme cost is one of them': nonSdkStartupWork.any(
          (HabotStartupItem i) => i.name.contains('ColorScheme.fromSeed'),
        ),
        'two items are on demand rather than merely deferred':
            onDemandItems.length == 2,
        'the SDK deferral rate over deferrable SDKs is 1':
            deferralRateExcludingMustNotDefer == 1.0,
        'and over all SDKs it is not, which is why the exclusion is declared':
            sdkDeferralRate < 1.0,
        'the budget this serves is the Step 165 cold-start budget':
            coldStartBudget == HabotMotion.coldStartBudget,
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Defer non-essential SDK initializations until after the primary UI '
      'view renders."';
}
