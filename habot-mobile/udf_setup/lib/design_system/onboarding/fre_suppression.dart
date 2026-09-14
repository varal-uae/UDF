/// Step 197 (GEN-01419) -- deciding whether the first-run carousel is shown.
///
/// The row: "Configure suppression logic to automatically bypass the FRE
/// carousel for returning authenticated users."
///
/// Two things make this more than an `if`.
///
/// **The device flag is the wrong key.** Step 196's flag is per install. A
/// returning authenticated user on a new phone, or after a reinstall, has no
/// flag -- which is exactly the person the row names, and exactly the person
/// the flag cannot recognise. Authentication state can, so the suppression is
/// keyed on the account and the flag is only the fast path for someone who is
/// not signed in.
///
/// **The decision has to be total.** A chain of `if` statements with no final
/// `else` shows the carousel to whoever falls off the end, and on a first-run
/// screen "whoever falls off the end" is every unanticipated state -- a session
/// that is restoring, a token that has expired, a cold start with no network.
/// Every input combination resolves to a named [HabotFreDecision] here, and the
/// reason is carried with it so a support conversation can start from "why did
/// it show" rather than from a boolean.
library;

import 'fre_completion_flag.dart';

/// Where the app is in establishing who the user is.
enum HabotAuthPosture {
  /// No credential on the device. A genuine first run, or a signed-out user.
  anonymous,

  /// A credential exists and is being validated. Transient, and the one state
  /// a naive check gets wrong, because it is neither signed in nor signed out.
  restoring,

  /// Signed in, and the account is known to have used the app before.
  returning,

  /// Signed in, and this is the account's first session anywhere.
  newAccount,
}

/// What the app should do with the first-run carousel.
enum HabotFreDecision {
  /// Show it.
  show,

  /// Do not show it, because this account has already been onboarded.
  suppressedByAccount,

  /// Do not show it, because this install has already settled it.
  suppressedByDevice,

  /// Do not show it YET -- the answer is not knowable, so nothing is shown and
  /// the decision is retaken when the posture resolves.
  deferred,
}

/// One decision plus why it was reached.
class HabotFreVerdict {
  const HabotFreVerdict(this.decision, this.reason);

  final HabotFreDecision decision;

  /// Plain-language reason, for logs and for support.
  final String reason;

  bool get showsCarousel => decision == HabotFreDecision.show;
}

/// The suppression rule.
class HabotFreSuppression {
  const HabotFreSuppression({required this.flag});

  final HabotFreFlag flag;

  /// The decision, for every combination of posture and local state.
  ///
  /// Order matters and is deliberate:
  ///   1. an unresolved posture defers, because guessing here is visible;
  ///   2. the account answers if there is one, because it outlives the device;
  ///   3. the device flag answers only when there is no account to ask;
  ///   4. anything left shows the carousel, which is the safe default -- seeing
  ///      it twice is an annoyance, never seeing it is a user who never learned
  ///      what the app does.
  HabotFreVerdict decide({
    required HabotAuthPosture posture,
    required HabotFreState? localState,
    bool accountHasCompletedOnboarding = false,
  }) {
    if (posture == HabotAuthPosture.restoring) {
      return const HabotFreVerdict(
        HabotFreDecision.deferred,
        'Session is still restoring; the answer is not knowable yet and '
        'showing the carousel to a signed-in user is the worse mistake.',
      );
    }
    if (posture == HabotAuthPosture.returning &&
        accountHasCompletedOnboarding) {
      return const HabotFreVerdict(
        HabotFreDecision.suppressedByAccount,
        'The account has completed onboarding, on this device or another one.',
      );
    }
    if (posture == HabotAuthPosture.returning) {
      return const HabotFreVerdict(
        HabotFreDecision.show,
        'The account is returning but has never completed onboarding -- a '
        'sign-up that stopped before the carousel finished.',
      );
    }
    if (!flag.shouldShowCarousel(localState)) {
      return const HabotFreVerdict(
        HabotFreDecision.suppressedByDevice,
        'This install has already settled the current carousel version.',
      );
    }
    if (posture == HabotAuthPosture.newAccount) {
      return const HabotFreVerdict(
        HabotFreDecision.show,
        'First session for this account.',
      );
    }
    return const HabotFreVerdict(
      HabotFreDecision.show,
      'Anonymous with no settled local state: a first run.',
    );
  }

  /// Every input combination this rule can be given.
  ///
  /// Enumerated rather than sampled, so "total" is a property that can be
  /// checked rather than a claim in a comment.
  List<(HabotAuthPosture, bool, HabotFreState?)> get allInputs {
    final List<HabotFreState?> states = <HabotFreState?>[
      null,
      _state(HabotFreOutcome.completed, flag.carouselVersion),
      _state(HabotFreOutcome.skipped, flag.carouselVersion),
      _state(HabotFreOutcome.abandoned, flag.carouselVersion),
      _state(HabotFreOutcome.completed, flag.carouselVersion + 1),
    ];
    return <(HabotAuthPosture, bool, HabotFreState?)>[
      for (final HabotAuthPosture p in HabotAuthPosture.values)
        for (final bool onboarded in <bool>[false, true])
          for (final HabotFreState? s in states) (p, onboarded, s),
    ];
  }

  static HabotFreState _state(HabotFreOutcome outcome, int version) =>
      HabotFreState(
        outcome: outcome,
        furthestSlide: 2,
        slideCount: 4,
        carouselVersion: version,
        recordedAt: DateTime.utc(2026, 1, 1),
      );

  /// True when every enumerated input produces a decision with a reason.
  bool get isTotal {
    for (final (HabotAuthPosture p, bool onboarded, HabotFreState? s)
        in allInputs) {
      final HabotFreVerdict v = decide(
        posture: p,
        localState: s,
        accountHasCompletedOnboarding: onboarded,
      );
      if (v.reason.isEmpty) {
        return false;
      }
    }
    return true;
  }

  /// The decision for a returning user whose device has never seen the app.
  ///
  /// This is the case the row is about and the case a device-flag-only
  /// implementation gets wrong.
  HabotFreVerdict get returningOnFreshInstall => decide(
        posture: HabotAuthPosture.returning,
        localState: null,
        accountHasCompletedOnboarding: true,
      );

  /// What a device-flag-only implementation would do with that same user.
  bool get deviceOnlyWouldShowForReturningUser =>
      flag.shouldShowCarousel(null);

  /// Share of enumerated inputs that resolve without showing the carousel.
  double get suppressionRate {
    final List<(HabotAuthPosture, bool, HabotFreState?)> inputs = allInputs;
    final int suppressed = inputs.where((
      (HabotAuthPosture, bool, HabotFreState?) i,
    ) {
      return !decide(
        posture: i.$1,
        localState: i.$3,
        accountHasCompletedOnboarding: i.$2,
      ).showsCarousel;
    }).length;
    return suppressed / inputs.length;
  }

  static const double floor = 0.7;
  static const double optimal = 0.9;
  static const double ceiling = 1;

  static const String accountNotDeviceNote =
      'A returning authenticated user on a fresh install has no device flag. '
      'That is the person the row names and the person the flag cannot see, so '
      'the suppression is keyed on the account and the device flag answers '
      'only when there is no account to ask.';

  static const String totalityNote =
      'A chain of ifs with no final else shows the carousel to whoever falls '
      'off the end, and on this screen that means every unanticipated state. '
      'Every combination of posture and local state resolves to a named '
      'decision here, and the enumeration is a property that can be checked.';

  static const String restoringNote =
      'The restoring posture is neither signed in nor signed out, and it is '
      'the state a cold start spends its first frames in. Treated as '
      'anonymous, a returning user sees the carousel flash before the session '
      'resolves. Nothing is shown until the posture settles.';

  static const String defaultIsToShowNote =
      'When the rule genuinely cannot decide, the carousel is shown. Seeing it '
      'a second time is an annoyance; never seeing it is a user who never '
      'learned what the app does, and that failure is invisible in the '
      'completion rate because the install never entered the denominator.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Configure suppression logic to automatically bypass the FRE carousel '
      'for returning authenticated users."';
}
