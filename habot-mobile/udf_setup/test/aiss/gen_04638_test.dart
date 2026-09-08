/// AISS GATE -- Step 134 of 135
/// Global Reference ID:       GEN-04638
/// Atomic Steps Reference ID: GEN-04638
/// Atomic Step: "Build a local feature flag management wrapper service."
/// Metric: Staged Rollout Exposure Percentage -- Floor "1% (initial canary)",
///         Optimal "10-25% (progressive)", Ceiling "50% (pre full-rollout
///         ceiling)".
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// THIS GATE IS THE JOIN BETWEEN STEPS 133 AND 134. Step 133 declared a
/// specification as code; this checks the implementation against EVERY
/// acceptance criterion in it, behaviourally, one gate each. GEN-04638-G7
/// asserts the coverage is total, so an acceptance criterion added to the spec
/// later fails this gate until it is actually checked. That is the whole
/// reason the specification was written as code rather than as a document.
///
/// THE METRIC IS A CEILING, NOT A TARGET. "50% pre-full-rollout ceiling" means
/// exposure must not exceed 50% while an experiment is running. A flag at 100%
/// is not an experiment -- it is a shipped feature, and it should be a released
/// flag with the losing code path deleted.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/preferences/feature_flag_spec.dart';
import 'package:udf_setup/design_system/preferences/feature_flags.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

  /// Which gate discharges which of Step 133's acceptance criteria.
  /// GEN-04638-G7 asserts this covers the spec exactly.
  const Map<String, String> criterionToGate = <String, String>{
    'AC-1': 'GEN-04638-G1',
    'AC-2': 'GEN-04638-G2',
    'AC-3': 'GEN-04638-G3',
    'AC-4': 'GEN-04638-G4',
    'AC-5': 'GEN-04638-G5',
    'AC-6': 'GEN-04638-G6',
  };

  // A unit that buckets INSIDE a 50% rollout of 'nav_v2' (bucket 47.7).
  // Verified numerically against the FNV-1a in HabotFeatureFlags.bucketOf
  // before this gate was written -- a gate whose fixture silently falls
  // outside the experiment would pass while testing nothing.
  const String insideUnit = 'device-2';
  const String flag = 'nav_v2';

  double measuredAt20 = 0;
  double measuredCanary = 0;
  double controlShare = 0;

  HabotRollout half({Map<String, int>? variants}) => HabotRollout(
    flagKey: flag,
    variants: variants ?? const <String, int>{'control': 1, 'treatment': 1},
    exposurePercent: 50,
  );

  void gate(String id, String source, String description, bool Function() run) {
    test('[$id] $description', () {
      bool passed = false;
      try {
        passed = run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        gates.add(
          AissGate(
            id: id,
            requirementSource: source,
            description: description,
            passed: passed,
          ),
        );
      }
    });
  }

  group('GEN-04638 :: Step 133 acceptance criteria, one gate each', () {
    gate(
      'GEN-04638-G1',
      'Step 133 AC-1: "Evaluation is synchronous and touches neither disk nor '
          'network." The touch-UI requirement: a flag consulted during build() '
          'cannot await anything.',
      'A thousand evaluations complete inside ONE synchronous expression with '
          'no event-loop turn available -- something an async implementation '
          'could not do -- and a device that has never reached the server still '
          'answers, and says that it is answering from defaults',
      () {
        final HabotFeatureFlags cold = HabotFeatureFlags(unitId: insideUnit);
        // Never reached the server. Step 133's offline-first edge case.
        final HabotVariantAssignment offline = cold.variantOf('unshipped_flag');

        final HabotFeatureFlags f = HabotFeatureFlags(unitId: insideUnit);
        f.applySnapshot(<HabotRollout>[half()]);
        final List<String> answers = <String>[
          for (int i = 0; i < 1000; i++) f.variantOf(flag).variant,
        ];

        return HabotFlagSpec.evaluationIsSynchronous &&
            cold.isRunningOnDefaults &&
            !f.isRunningOnDefaults &&
            offline.source == HabotVariantSource.defaultValue &&
            offline.variant == 'control' &&
            answers.length == 1000 &&
            answers.toSet().length == 1;
      },
    );

    gate(
      'GEN-04638-G2',
      'Step 133 AC-2: "The same unit and flag always yield the same variant." '
          'A user whose UI changes between two taps has, from their side, '
          'encountered a bug -- and on a touch surface the control they were '
          'reaching for has moved.',
      'The answer is stable across evaluations, across a fresh instance '
          'standing in for an app restart, and when a variant is REMOVED from '
          'the rollout underneath a unit it falls back to control with the '
          'source saying so rather than staying in an arm that no longer exists',
      () {
        final HabotFeatureFlags f = HabotFeatureFlags(unitId: insideUnit);
        // Weight 0 on control: every unit inside the band lands on treatment,
        // so the fixture cannot drift onto the other arm.
        f.applySnapshot(<HabotRollout>[
          half(variants: const <String, int>{'control': 0, 'treatment': 1}),
        ]);
        final String first = f.variantOf(flag).variant;
        final bool stableWithinASession = List<String>.generate(
          50,
          (int _) => f.variantOf(flag).variant,
        ).every((String v) => v == first);

        // A restart: same unit id, no stored state, same answer required.
        final HabotFeatureFlags afterRestart =
            HabotFeatureFlags(unitId: insideUnit);
        afterRestart.applySnapshot(<HabotRollout>[
          half(variants: const <String, int>{'control': 0, 'treatment': 1}),
        ]);

        // A DIFFERENT unit must be able to land elsewhere, or "stable" would
        // just mean "constant" and this gate would pass on a stub.
        final HabotFeatureFlags elsewhere =
            HabotFeatureFlags(unitId: 'device-1');
        elsewhere.applySnapshot(<HabotRollout>[
          half(variants: const <String, int>{'control': 0, 'treatment': 1}),
        ]);

        // The arm is decommissioned while this unit is in it.
        f.applySnapshot(<HabotRollout>[
          half(variants: const <String, int>{'control': 1, 'variant_c': 1}),
        ]);
        final HabotVariantAssignment orphaned = f.variantOf(flag);

        return first == 'treatment' &&
            stableWithinASession &&
            afterRestart.variantOf(flag).variant == 'treatment' &&
            elsewhere.variantOf(flag).variant == 'control' &&
            orphaned.variant == 'control' &&
            orphaned.source == HabotVariantSource.fallbackFromRemovedVariant;
      },
    );

    gate(
      'GEN-04638-G3',
      'Step 133 AC-3: "An unknown flag returns its default rather than '
          'throwing." A flag the server knows and the client does not is the '
          'NORMAL case during a staged rollout; throwing there crashes the app '
          'for the users furthest behind on updates.',
      'An unknown key answers with control and records no exposure, and a flag '
          'paused at 0% is indistinguishable from one that does not exist -- so '
          'a stopped experiment stops polluting its own results',
      () {
        final HabotFeatureFlags f = HabotFeatureFlags(unitId: insideUnit);
        f.applySnapshot(<HabotRollout>[
          const HabotRollout(
            flagKey: 'paused_flag',
            variants: <String, int>{'control': 1, 'treatment': 1},
            exposurePercent: 0,
          ),
        ]);
        final HabotVariantAssignment unknown =
            f.variantOf('never_heard_of_it', forRender: true);
        final HabotVariantAssignment paused =
            f.variantOf('paused_flag', forRender: true);

        return unknown.variant == 'control' &&
            unknown.source == HabotVariantSource.defaultValue &&
            !unknown.isExposure &&
            paused.variant == 'control' &&
            paused.source == HabotVariantSource.defaultValue &&
            !paused.isExposure &&
            f.exposedFlags.isEmpty &&
            !f.isEnabled('never_heard_of_it');
      },
    );

    gate(
      'GEN-04638-G4',
      'Step 133 AC-4: "Bucketing is uniform: over many units, observed variant '
          'shares match the declared weights within tolerance." Deterministic '
          'is not the same as uniform -- a hash that is stable but lumpy gives '
          'an experiment the wrong denominator in every arm.',
      'Over 5,000 units a 20% rollout exposes 20% of them and a 1% canary '
          'exposes about 1%, and inside a 50% rollout with 60/40 weights the '
          'observed control share lands on 0.60 within three points -- measured '
          'through the real service, not modelled',
      () {
        const HabotRollout twenty = HabotRollout(
          flagKey: flag,
          variants: <String, int>{'control': 1, 'treatment': 1},
          exposurePercent: 20,
        );
        const HabotRollout canary = HabotRollout(
          flagKey: 'canary_flag',
          variants: <String, int>{'control': 1, 'treatment': 1},
          exposurePercent: HabotFeatureFlags.canaryPercent,
        );
        final List<String> units = <String>[
          for (int i = 0; i < 5000; i++) 'device-$i',
        ];

        measuredAt20 = HabotFeatureFlags.measuredExposure(twenty, units);
        measuredCanary = HabotFeatureFlags.measuredExposure(canary, units);

        final HabotRollout weighted = half(
          variants: const <String, int>{'control': 60, 'treatment': 40},
        );
        int control = 0;
        int exposedUnits = 0;
        for (final String u in units) {
          final HabotFeatureFlags f = HabotFeatureFlags(unitId: u);
          f.applySnapshot(<HabotRollout>[weighted]);
          final HabotVariantAssignment a = f.variantOf(flag, forRender: true);
          if (a.source != HabotVariantSource.bucketed) {
            continue;
          }
          exposedUnits++;
          if (a.variant == 'control') {
            control++;
          }
        }
        controlShare = exposedUnits == 0 ? 0 : control / exposedUnits;

        return (measuredAt20 - 20).abs() <= 1.0 &&
            (measuredCanary - HabotFeatureFlags.canaryPercent).abs() <= 0.5 &&
            exposedUnits > 2000 &&
            (controlShare - 0.60).abs() <= 0.03;
      },
    );

    gate(
      'GEN-04638-G5',
      'Step 133 AC-5: "Exposure is recorded once per unit per flag, and only '
          'when the variant is actually SERVED FOR RENDERING." Counting an '
          'evaluation as an exposure inflates every experiment denominator, and '
          'a flag checked to decide whether to prefetch has shown the user '
          'nothing.',
      'A flag consulted without rendering records no exposure; rendering it '
          'twenty times records one; and a unit OUTSIDE the experiment is never '
          'counted as exposed even when the render flag is set',
      () {
        final HabotFeatureFlags f = HabotFeatureFlags(unitId: insideUnit);
        f.applySnapshot(<HabotRollout>[half()]);

        f.variantOf(flag);
        final bool quietAfterPlainReads = f.exposedFlags.isEmpty;

        for (int i = 0; i < 20; i++) {
          f.variantOf(flag, forRender: true);
        }
        final int renderedEvaluations =
            f.log.where((HabotVariantAssignment a) => a.isExposure).length;

        // 'device-1' buckets at 71.51 -- outside a 50% band.
        final HabotFeatureFlags outside = HabotFeatureFlags(unitId: 'device-1');
        outside.applySnapshot(<HabotRollout>[half()]);
        final HabotVariantAssignment out =
            outside.variantOf(flag, forRender: true);

        return quietAfterPlainReads &&
            renderedEvaluations == 20 &&
            f.exposedFlags.length == 1 &&
            f.exposedFlags.contains(flag) &&
            !out.isExposure &&
            out.variant == 'control' &&
            out.source == HabotVariantSource.defaultValue &&
            outside.exposedFlags.isEmpty;
      },
    );

    gate(
      'GEN-04638-G6',
      'Step 133 AC-6: "Overrides are honoured and are visible in the '
          'evidence." An override that is honoured but invisible is a '
          'permanent silent behaviour change that nobody can find.',
      'A forced variant wins over the bucket, is reported as overridden rather '
          'than as a result, is listed in the active overrides, and clearing it '
          'returns the unit to its bucketed answer',
      () {
        final HabotFeatureFlags f = HabotFeatureFlags(unitId: 'device-1');
        f.applySnapshot(<HabotRollout>[half()]);
        final HabotVariantAssignment natural = f.variantOf(flag);

        f.override(flag, 'treatment');
        final HabotVariantAssignment forced =
            f.variantOf(flag, forRender: true);
        final bool listed = f.activeOverrides[flag] == 'treatment';

        f.clearOverride(flag);
        final HabotVariantAssignment restored = f.variantOf(flag);

        return natural.variant == 'control' &&
            forced.variant == 'treatment' &&
            forced.source == HabotVariantSource.overridden &&
            forced.isExposure &&
            forced.toJson()['source'] == 'overridden' &&
            listed &&
            f.activeOverrides.isEmpty &&
            restored.variant == natural.variant &&
            restored.source == natural.source;
      },
    );
  });

  group('GEN-04638 :: the metric, and the join to Step 133', () {
    gate(
      'GEN-04638-G7',
      'Metric: Staged Rollout Exposure Percentage -- Floor "1% (initial '
          'canary)", Optimal "10-25% (progressive)", Ceiling "50% (pre '
          'full-rollout ceiling)". A ceiling read as a target is how an '
          'experiment becomes a rollout nobody decided on.',
      'Every band in the row is a named answer from the code, exposure above '
          '50% is reported as a fault rather than as progress, AND every '
          'acceptance criterion Step 133 declares is discharged by a gate here '
          '-- so a criterion added to the spec fails this until it is checked',
      () {
        HabotRollout at(double pct) => HabotRollout(
          flagKey: 'f',
          variants: const <String, int>{'control': 1, 'treatment': 1},
          exposurePercent: pct,
        );

        final HabotFeatureFlags f = HabotFeatureFlags(unitId: insideUnit);
        f.applySnapshot(<HabotRollout>[
          const HabotRollout(
            flagKey: 'over_the_top',
            variants: <String, int>{'control': 1, 'treatment': 1},
            exposurePercent: 75,
          ),
        ]);

        final bool bands =
            HabotFeatureFlags.bandFor(at(0)) == 'off' &&
            HabotFeatureFlags.bandFor(at(HabotFeatureFlags.canaryPercent)) ==
                'canary (floor)' &&
            HabotFeatureFlags.bandFor(at(10)) == 'progressive (optimal)' &&
            HabotFeatureFlags.bandFor(at(25)) == 'progressive (optimal)' &&
            HabotFeatureFlags.bandFor(at(40)) == 'within ceiling' &&
            HabotFeatureFlags.bandFor(
                  at(HabotFeatureFlags.rolloutCeilingPercent),
                ) ==
                'within ceiling' &&
            HabotFeatureFlags.bandFor(at(75)) == 'ABOVE CEILING';

        final bool ceiling =
            HabotFeatureFlags.rolloutCeilingPercent == 50 &&
            HabotFeatureFlags.canaryPercent == 1 &&
            HabotFeatureFlags.progressiveLowPercent == 10 &&
            HabotFeatureFlags.progressiveHighPercent == 25 &&
            !HabotFeatureFlags.exceedsRolloutCeiling(at(50)) &&
            HabotFeatureFlags.exceedsRolloutCeiling(at(50.1)) &&
            f.rolloutsOverCeiling.length == 1 &&
            f.rolloutsOverCeiling.single.contains('over_the_top');

        // The anti-drift check the spec-as-code decision exists for.
        final bool coversTheSpec =
            criterionToGate.keys.toSet().containsAll(
              HabotFeatureFlags.satisfiedCriteria,
            ) &&
            HabotFeatureFlags.satisfiedCriteria.toSet().containsAll(
              criterionToGate.keys,
            ) &&
            HabotFlagSpec.acceptance.length == criterionToGate.length;

        return bands && ceiling && coversTheSpec;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04638',
        atomicStepReferenceId: 'GEN-04638',
        setupStepAction: 'Build a local feature flag management wrapper '
            'service.',
        implementationOrder: 134,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotFeatureFlags / HabotRollout / '
              'HabotVariantAssignment',
          'Component Properties':
              'synchronous in-memory evaluation; FNV-1a bucketing over '
              '"flagKey:unitId"; '
              '${HabotVariantSource.values.length} variant sources; ceiling '
              '${HabotFeatureFlags.rolloutCeilingPercent}%, canary '
              '${HabotFeatureFlags.canaryPercent}%, progressive '
              '${HabotFeatureFlags.progressiveLowPercent}-'
              '${HabotFeatureFlags.progressiveHighPercent}%',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) is EMPTY. This row is the implementation of '
              'Step 133 (GEN-05309); all '
              '${HabotFlagSpec.acceptance.length} acceptance criteria declared '
              'there are discharged by a named gate here, and G7 fails if that '
              'coverage ever stops being total.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Staged Rollout Exposure Percentage',
            observed:
                'A 20% rollout exposed '
                '${measuredAt20.toStringAsFixed(2)}% of 5,000 units and a 1% '
                'canary exposed ${measuredCanary.toStringAsFixed(2)}%, both '
                'measured through the service rather than modelled. Inside a '
                '50% rollout weighted 60/40, the observed control share was '
                '${controlShare.toStringAsFixed(3)}. No rollout in the '
                'snapshot sits above the 50% ceiling; one deliberately placed '
                'at 75% is reported as a fault.',
            floor: '1% (initial canary)',
            optimal: '10-25% (progressive)',
            ceiling: '50% (pre full-rollout ceiling)',
          ),
          AissMeasurement(
            metricName: 'Step 133 acceptance criteria discharged',
            observed:
                '${criterionToGate.length} of '
                '${HabotFlagSpec.acceptance.length}, each by a named gate: '
                'AC-1 synchronous evaluation, AC-2 stable assignment across '
                'restart and across a removed variant, AC-3 unknown and paused '
                'flags, AC-4 uniform bucketing, AC-5 exposure once and only on '
                'render, AC-6 overrides honoured and visible.',
            floor: '6',
            optimal: '6',
            ceiling: '6',
          ),
          const AissMeasurement(
            metricName: 'Drift between the specification and the build',
            observed:
                '0, and it cannot be non-zero silently. GEN-04638-G7 asserts '
                'the gate coverage equals the criteria the spec declares, so '
                'an acceptance criterion added at Step 133 fails Step 134 '
                'until it is genuinely checked. This is what the spec-as-code '
                'decision bought.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/preferences/feature_flags.dart',
        ],
      ),
    );
  });
}
