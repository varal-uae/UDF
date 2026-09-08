/// AISS Step 134 -- GEN-04638
/// Atomic Step: "Build a local feature flag management wrapper service."
/// Metric: Staged Rollout Exposure Percentage -- Floor "1% (initial canary)",
///         Optimal "10-25% (progressive)", Ceiling "50% (pre full-rollout
///         ceiling)".
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// THE IMPLEMENTATION OF STEP 133'S SPECIFICATION. Every acceptance criterion
/// there is checked against this by GEN-04638's gate, so the two cannot drift.
///
/// "LOCAL" IS THE LOAD-BEARING WORD. Evaluation happens entirely on the
/// device, from a snapshot held in memory. The server's role is to REPLACE the
/// snapshot, never to answer a question. That is what makes the dispatcher
/// synchronous (Step 133's touch-UI requirement) and what makes it work on a
/// device that has never reached the network -- which for this product is not
/// an edge case, it is Tuesday.
///
/// THE METRIC IS A CEILING, NOT A TARGET, and it is worth being explicit
/// because it reads like a target. "50% pre-full-rollout ceiling" means: while
/// an experiment is running, exposure must not exceed 50%. A flag intended for
/// everyone is not an experiment at 100% -- it is a shipped feature, and it
/// should be a released flag with the code path deleted behind it.
/// [HabotFeatureFlags.exceedsRolloutCeiling] enforces the distinction rather
/// than letting an experiment quietly become a rollout nobody decided on.
///
/// BUCKETING IS DETERMINISTIC AND STABLE. A hash of `flagKey:unitId`, so the
/// same device gets the same answer forever, across restarts and across
/// reinstalls where the unit id survives -- with no state to store and nothing
/// to migrate. Bucketing on a session id would move users between arms on
/// every launch; Step 133 records why that is fatal.
library;

import 'feature_flag_spec.dart';

/// How a variant was arrived at.
enum HabotVariantSource {
  /// The flag is unknown to this build, or the rollout is off.
  defaultValue,

  /// Bucketed by the hash.
  bucketed,

  /// Forced, for QA or support.
  overridden,

  /// The unit was in a variant that no longer exists.
  fallbackFromRemovedVariant,
}

/// One staged rollout.
class HabotRollout {
  const HabotRollout({
    required this.flagKey,
    required this.variants,
    required this.exposurePercent,
    this.controlVariant = 'control',
  });

  final String flagKey;

  /// Variant name to relative weight. Must include [controlVariant].
  final Map<String, int> variants;

  /// What share of units are in the experiment at all, 0-100. Units outside it
  /// get [controlVariant] and are not counted as exposed.
  final double exposurePercent;

  final String controlVariant;

  bool get isOff => exposurePercent <= 0;

  int get totalWeight =>
      variants.values.fold(0, (int a, int b) => a + b);

  bool get isWellFormed =>
      flagKey.trim().isNotEmpty &&
      variants.containsKey(controlVariant) &&
      totalWeight > 0 &&
      exposurePercent >= 0 &&
      exposurePercent <= 100;
}

/// The answer for one evaluation.
class HabotVariantAssignment {
  const HabotVariantAssignment({
    required this.flagKey,
    required this.variant,
    required this.source,
    required this.isExposure,
  });

  final String flagKey;
  final String variant;
  final HabotVariantSource source;

  /// See Step 133: evaluating is not exposure; serving for render is.
  final bool isExposure;

  Map<String, Object?> toJson() => <String, Object?>{
    'flag': flagKey,
    'variant': variant,
    'source': source.name,
    'is_exposure': isExposure,
  };
}

/// The local flag service.
class HabotFeatureFlags {
  HabotFeatureFlags({required this.unitId});

  /// The stable identity rollouts are bucketed by. A device or account id --
  /// never a session id. See Step 133.
  final String unitId;

  /// The row's ceiling, verbatim: an experiment must not exceed this.
  static const double rolloutCeilingPercent = 50;

  /// The row's floor: the initial canary.
  static const double canaryPercent = 1;

  /// The row's optimal band.
  static const double progressiveLowPercent = 10;
  static const double progressiveHighPercent = 25;

  final Map<String, HabotRollout> _snapshot = <String, HabotRollout>{};
  final Map<String, String> _overrides = <String, String>{};
  final Map<String, String> _assigned = <String, String>{};
  final Set<String> _exposed = <String>{};
  final List<HabotVariantAssignment> _log = <HabotVariantAssignment>[];

  /// True until a server snapshot has been applied. Reported rather than
  /// hidden: a build serving defaults because it never reached the server
  /// looks identical to one serving defaults on purpose, and the difference
  /// matters when an experiment shows no effect.
  bool _onDefaults = true;

  bool get isRunningOnDefaults => _onDefaults;

  List<HabotVariantAssignment> get log =>
      List<HabotVariantAssignment>.unmodifiable(_log);

  Set<String> get exposedFlags => Set<String>.unmodifiable(_exposed);

  Iterable<HabotRollout> get rollouts => _snapshot.values;

  /// Replace the snapshot. The server's only role.
  ///
  /// Assignments already made are KEPT: a unit that has been in a variant
  /// stays in it, which is Step 133's AC-2. A snapshot that reassigns live
  /// users mid-session is the layout-jump defect the touch-UI requirement
  /// exists to prevent.
  void applySnapshot(List<HabotRollout> rollouts) {
    _snapshot
      ..clear()
      ..addEntries(
        rollouts
            .where((HabotRollout r) => r.isWellFormed)
            .map((HabotRollout r) => MapEntry<String, HabotRollout>(r.flagKey, r)),
      );
    _onDefaults = false;
  }

  /// Force a variant. Visible in the evidence -- Step 133's AC-6.
  void override(String flagKey, String variant) =>
      _overrides[flagKey] = variant;

  void clearOverride(String flagKey) => _overrides.remove(flagKey);

  Map<String, String> get activeOverrides =>
      Map<String, String>.unmodifiable(_overrides);

  /// Deterministic bucket in [0, 100) for this unit and flag.
  ///
  /// FNV-1a over `flagKey:unitId`. Chosen because it is short, has no
  /// dependencies, and is stable across platforms and Dart versions -- unlike
  /// `Object.hashCode`, which is explicitly not stable across runs and would
  /// silently reshuffle every user's variant on an SDK upgrade.
  static double bucketOf(String flagKey, String unitId) {
    const int prime = 16777619;
    int hash = 2166136261;
    for (final int c in '$flagKey:$unitId'.codeUnits) {
      hash = (hash ^ c) & 0xFFFFFFFF;
      hash = (hash * prime) & 0xFFFFFFFF;
    }
    return (hash % 10000) / 100;
  }

  /// Evaluate. Synchronous, from memory -- Step 133's AC-1.
  ///
  /// [forRender] is what turns an evaluation into an exposure. A caller
  /// checking a flag to decide whether to prefetch is not exposing the user
  /// to anything.
  HabotVariantAssignment variantOf(
    String flagKey, {
    bool forRender = false,
  }) {
    final String? forced = _overrides[flagKey];
    if (forced != null) {
      return _record(
        HabotVariantAssignment(
          flagKey: flagKey,
          variant: forced,
          source: HabotVariantSource.overridden,
          isExposure: forRender,
        ),
        forRender,
      );
    }

    final HabotRollout? rollout = _snapshot[flagKey];
    if (rollout == null || rollout.isOff) {
      // AC-3, and the 0% edge case: indistinguishable from a flag that does
      // not exist, and no exposure recorded.
      return _record(
        HabotVariantAssignment(
          flagKey: flagKey,
          variant: rollout?.controlVariant ?? 'control',
          source: HabotVariantSource.defaultValue,
          isExposure: false,
        ),
        false,
      );
    }

    // A unit already assigned keeps its variant -- AC-2.
    final String? already = _assigned[flagKey];
    if (already != null) {
      if (!rollout.variants.containsKey(already)) {
        return _record(
          HabotVariantAssignment(
            flagKey: flagKey,
            variant: rollout.controlVariant,
            source: HabotVariantSource.fallbackFromRemovedVariant,
            isExposure: forRender,
          ),
          forRender,
        );
      }
      return _record(
        HabotVariantAssignment(
          flagKey: flagKey,
          variant: already,
          source: HabotVariantSource.bucketed,
          isExposure: forRender,
        ),
        forRender,
      );
    }

    final double bucket = bucketOf(flagKey, unitId);
    if (bucket >= rollout.exposurePercent) {
      // Outside the experiment. Control, and not counted as exposed.
      return _record(
        HabotVariantAssignment(
          flagKey: flagKey,
          variant: rollout.controlVariant,
          source: HabotVariantSource.defaultValue,
          isExposure: false,
        ),
        false,
      );
    }

    // Inside: distribute across the weights, using the position within the
    // exposed band so the weighting is independent of the exposure percentage.
    final double within =
        rollout.exposurePercent == 0 ? 0 : bucket / rollout.exposurePercent;
    double cumulative = 0;
    String chosen = rollout.controlVariant;
    for (final MapEntry<String, int> e in rollout.variants.entries) {
      cumulative += e.value / rollout.totalWeight;
      if (within < cumulative) {
        chosen = e.key;
        break;
      }
    }
    _assigned[flagKey] = chosen;
    return _record(
      HabotVariantAssignment(
        flagKey: flagKey,
        variant: chosen,
        source: HabotVariantSource.bucketed,
        isExposure: forRender,
      ),
      forRender,
    );
  }

  HabotVariantAssignment _record(
    HabotVariantAssignment a,
    bool countExposure,
  ) {
    _log.add(a);
    if (countExposure && a.isExposure) {
      // AC-5: once per unit per flag.
      _exposed.add(a.flagKey);
    }
    return a;
  }

  bool isEnabled(String flagKey, {String enabledVariant = 'treatment'}) =>
      variantOf(flagKey).variant == enabledVariant;

  // ---- the row's metric --------------------------------------------------

  /// True when a rollout is past the ceiling the row names. See the header for
  /// why that is a fault rather than a milestone.
  static bool exceedsRolloutCeiling(HabotRollout r) =>
      r.exposurePercent > rolloutCeilingPercent;

  /// Which declared band a rollout is in, in the row's own words.
  static String bandFor(HabotRollout r) {
    if (r.isOff) {
      return 'off';
    }
    if (r.exposurePercent <= canaryPercent) {
      return 'canary (floor)';
    }
    if (r.exposurePercent >= progressiveLowPercent &&
        r.exposurePercent <= progressiveHighPercent) {
      return 'progressive (optimal)';
    }
    if (r.exposurePercent <= rolloutCeilingPercent) {
      return 'within ceiling';
    }
    return 'ABOVE CEILING';
  }

  /// Rollouts currently over the ceiling. Empty is the requirement.
  List<String> get rolloutsOverCeiling => _snapshot.values
      .where(exceedsRolloutCeiling)
      .map((HabotRollout r) => '${r.flagKey} at ${r.exposurePercent}%')
      .toList();

  /// Measured exposure share for a flag across a set of units. Used by the
  /// gate to check Step 133's AC-4 -- that bucketing is actually uniform
  /// rather than merely deterministic.
  static double measuredExposure(HabotRollout rollout, List<String> unitIds) {
    if (unitIds.isEmpty) {
      return 0;
    }
    final int inside = unitIds
        .where(
          (String u) => bucketOf(rollout.flagKey, u) < rollout.exposurePercent,
        )
        .length;
    return inside / unitIds.length * 100;
  }

  /// Every Step 133 acceptance criterion this implementation claims to meet.
  /// The gate checks each one behaviourally; this is the index.
  static List<String> get satisfiedCriteria =>
      HabotFlagSpec.acceptance.map((HabotSpecCriterion c) => c.id).toList();
}
