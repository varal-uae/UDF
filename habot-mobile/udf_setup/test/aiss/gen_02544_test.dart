/// AISS GATE -- Step 135 of 135
/// Global Reference ID:       GEN-02544
/// Atomic Steps Reference ID: GEN-02544
/// Atomic Step: "Set up variation mapping within the frontend state
///               management."
/// Metric: WCAG 2.2 AA Compliance Rate (%) -- Floor 0.8, Optimal 1, Ceiling 1.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// A ROW DELIBERATELY NOT TAKEN AT STEPS 96-110, TAKEN NOW. That build order
/// excluded it as "an A/B experiment row wearing an accessibility metric...
/// building it as experiment infrastructure is a different batch". This is that
/// batch: Steps 133 and 134 built the dispatcher, and this is the state
/// management it maps into.
///
/// THE METRIC IS REINTERPRETED, AND THE REINTERPRETATION IS GATED. A WCAG
/// compliance rate is the wrong metric for wiring variants into state -- but it
/// names a real and commonly-missed hazard, so it is used for the thing it
/// accidentally describes: **every variant must be independently accessible.**
/// An experiment that ships an inaccessible treatment arm has not run an
/// experiment; it has degraded the product for a randomly selected share of its
/// users, invisibly, and the result will read as a preference. The rate here is
/// over registered VARIANTS, not screens, and it is NOT a claim about overall
/// conformance -- that figure is Step 96's and is reported there.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/preferences/feature_flags.dart';
import 'package:udf_setup/design_system/preferences/variation_mapping.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

  const String flag = 'result_card_density';

  // 'device-2' buckets at 47.7 -- INSIDE a 50% band. 'device-1' at 71.51 --
  // outside it. Both verified numerically against HabotFeatureFlags.bucketOf
  // before this gate was written; a fixture that silently sat outside the
  // experiment would let this pass while testing nothing.
  const String insideUnit = 'device-2';
  const String outsideUnit = 'device-1';

  double complianceRate = 0;
  double degradedRate = 0;

  const HabotVariantAccessibility auditedControl = HabotVariantAccessibility(
    variant: 'control',
    auditedCriteria: <String>['1.4.3', '1.4.11', '2.5.8', '4.1.2'],
    failingCriteria: <String>[],
  );
  const HabotVariantAccessibility auditedTreatment = HabotVariantAccessibility(
    variant: 'treatment',
    auditedCriteria: <String>['1.4.3', '1.4.11', '2.5.8', '4.1.2'],
    failingCriteria: <String>[],
  );

  HabotFeatureFlags flagsFor(String unit, {int controlWeight = 1}) {
    final HabotFeatureFlags f = HabotFeatureFlags(unitId: unit);
    f.applySnapshot(<HabotRollout>[
      HabotRollout(
        flagKey: flag,
        variants: <String, int>{'control': controlWeight, 'treatment': 1},
        exposurePercent: 50,
      ),
    ]);
    return f;
  }

  HabotVariationMapping<int> mapping(
    HabotFeatureFlags flags, {
    Map<String, HabotVariantAccessibility>? accessibility,
  }) => HabotVariationMapping<int>(
    flagKey: flag,
    flags: flags,
    values: const <String, int>{'control': 1, 'treatment': 2},
    accessibility:
        accessibility ??
        const <String, HabotVariantAccessibility>{
          'control': auditedControl,
          'treatment': auditedTreatment,
        },
    controlVariant: 'control',
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

  group('GEN-02544 :: the state-management half the row actually asks for', () {
    gate(
      'GEN-02544-G1',
      'Atomic Step: "Set up VARIATION MAPPING within the frontend STATE '
          'MANAGEMENT." A variant must select a VALUE, not a code path. '
          '`if (flags.isEnabled(...))` sprinkled across twenty widgets is '
          'untestable and undeletable; a mapping from variant name to value is '
          'neither.',
      'One mapping holds every arm of one decision, resolves to the value for '
          'whichever variant this unit is in, and follows the variant when it '
          'changes -- and the reason this row was not taken at Steps 96-110 is '
          'recorded in the code rather than lost',
      () {
        final HabotFeatureFlags flags = flagsFor(outsideUnit);
        final HabotVariationMapping<int> m = mapping(flags);

        final int naturally = m.resolve();
        flags.override(flag, 'treatment');
        final int forced = m.resolve();
        flags.clearOverride(flag);
        final int back = m.resolve();

        return m.values.length == 2 &&
            naturally == 1 &&
            forced == 2 &&
            back == 1 &&
            m.resolutions == 3 &&
            HabotVariationMapping.notTakenEarlierNote.contains(
              'a different batch',
            ) &&
            HabotVariationMapping.notTakenEarlierNote.contains(
              'Steps 133 and 134',
            );
      },
    );

    gate(
      'GEN-02544-G2',
      'Every unit outside an experiment gets control, which is MOST of them. A '
          'mapping with no value for control has no answer for the majority of '
          'its users.',
      'A mapping missing its control value is refused at construction, and a '
          'variant with no value falls back to the control value rather than '
          'returning null into a build()',
      () {
        bool refusedAtConstruction = false;
        try {
          HabotVariationMapping<int>(
            flagKey: flag,
            flags: flagsFor(outsideUnit),
            values: const <String, int>{'treatment': 2},
            accessibility: const <String, HabotVariantAccessibility>{
              'treatment': auditedTreatment,
            },
            controlVariant: 'control',
          );
        } on HabotUnauditedVariantError {
          refusedAtConstruction = false;
        } on StateError catch (e) {
          refusedAtConstruction = e.message.contains('no value for its control');
        }

        // A variant the dispatcher can name but the mapping has no value for.
        final HabotFeatureFlags flags = flagsFor(outsideUnit);
        final HabotVariationMapping<int> m = mapping(flags);
        flags.override(flag, 'variant_c');

        return refusedAtConstruction && m.resolve() == 1;
      },
    );

    gate(
      'GEN-02544-G3',
      'Steps 133/134 decided that evaluating a flag is not exposure and '
          'RENDERING it is. The mapping is where a variant becomes a value on '
          'the screen, so it is exactly where exposure is owed.',
      'Resolving for render records the exposure on the Step 134 dispatcher, '
          'reading the current variant for diagnostics does not, and a unit '
          'outside the experiment is never counted as exposed',
      () {
        final HabotFeatureFlags flags = flagsFor(insideUnit);
        final HabotVariationMapping<int> m = mapping(flags);

        final String peeked = m.currentVariant;
        final bool quietAfterPeek = flags.exposedFlags.isEmpty;

        m.resolve();
        m.resolve();
        final bool exposedOnce =
            flags.exposedFlags.length == 1 && flags.exposedFlags.contains(flag);

        final HabotFeatureFlags outsideFlags = flagsFor(outsideUnit);
        mapping(outsideFlags).resolve();

        return peeked.isNotEmpty &&
            quietAfterPeek &&
            exposedOnce &&
            outsideFlags.exposedFlags.isEmpty;
      },
    );
  });

  group('GEN-02544 :: the metric, used for the hazard it names', () {
    gate(
      'GEN-02544-G4',
      'THE FAILURE THIS EXISTS TO CATCH: an experiment that ships an '
          'inaccessible arm has not run an experiment. It has degraded the '
          'product for a randomly selected share of users, invisibly, and the '
          'metrics will read as a preference result.',
      'A variant registered with no declared audit is REFUSED at construction '
          'rather than warned about, and the refusal explains the hazard rather '
          'than only naming the rule',
      () {
        HabotUnauditedVariantError? thrown;
        try {
          HabotVariationMapping<int>(
            flagKey: flag,
            flags: flagsFor(outsideUnit),
            values: const <String, int>{'control': 1, 'treatment': 2},
            accessibility: const <String, HabotVariantAccessibility>{
              'control': auditedControl,
            },
            controlVariant: 'control',
          );
        } on HabotUnauditedVariantError catch (e) {
          thrown = e;
        }
        return thrown != null &&
            thrown.message.contains('has not run an experiment') &&
            thrown.message.contains('randomly selected share of users') &&
            thrown.message.contains('even if the answer is that it is '
                'identical to control');
      },
    );

    gate(
      'GEN-02544-G5',
      'Metric: WCAG 2.2 AA Compliance Rate -- Floor 0.8, Optimal 1, Ceiling 1. '
          'A rate that cannot fall is not a measurement.',
      'The rate is the share of REGISTERED VARIANTS that pass their audit: 1.0 '
          'when both arms pass, and it drops below the floor and names the '
          'offending arm and criterion when one does not',
      () {
        complianceRate = mapping(flagsFor(outsideUnit)).variantComplianceRate;

        final HabotVariationMapping<int> degraded = mapping(
          flagsFor(outsideUnit),
          accessibility: const <String, HabotVariantAccessibility>{
            'control': auditedControl,
            'treatment': HabotVariantAccessibility(
              variant: 'treatment',
              auditedCriteria: <String>['1.4.3', '1.4.11', '2.5.8', '4.1.2'],
              failingCriteria: <String>['2.5.8'],
            ),
          },
        );
        degradedRate = degraded.variantComplianceRate;

        return complianceRate == HabotVariationMapping.optimal &&
            complianceRate >= HabotVariationMapping.floor &&
            mapping(flagsFor(outsideUnit)).inaccessibleVariants.isEmpty &&
            degradedRate == 0.5 &&
            degradedRate < HabotVariationMapping.floor &&
            degraded.inaccessibleVariants.length == 1 &&
            degraded.inaccessibleVariants.single.contains('treatment') &&
            degraded.inaccessibleVariants.single.contains('2.5.8');
      },
    );

    gate(
      'GEN-02544-G6',
      'An "audit" that checked one criterion and declared a pass is worse than '
          'no audit, because it is evidence of the wrong thing.',
      'The minimum criteria a UI variation realistically changes are declared '
          'and drawn from the Step 96 catalogue rather than restated as loose '
          'strings, and an audit that misses any of them is reported as '
          'insufficient even though it has no failures',
      () {
        const HabotVariantAccessibility thin = HabotVariantAccessibility(
          variant: 'treatment',
          auditedCriteria: <String>['1.4.3'],
          failingCriteria: <String>[],
        );
        return HabotVariationMapping.minimumCriteria.length == 4 &&
            HabotVariationMapping.minimumCriteria.toSet().containsAll(
              const <String>['1.4.3', '1.4.11', '2.5.8', '4.1.2'],
            ) &&
            thin.passes &&
            !HabotVariationMapping.auditIsSufficient(thin) &&
            HabotVariationMapping.auditIsSufficient(auditedTreatment) &&
            auditedControl.complianceRate == 1.0;
      },
    );

    gate(
      'GEN-02544-G7',
      'A reinterpreted metric that is not declared as one is a metric being '
          'quietly reported as something it is not.',
      'The reinterpretation is recorded in the code: what the row said, why the '
          'mismatch was flagged at Steps 96-110, what the number now measures, '
          'and the explicit statement that it is NOT a claim about overall '
          'conformance',
      () =>
          HabotVariationMapping.metricReinterpretation.contains(
            'wiring variants into state management',
          ) &&
          HabotVariationMapping.metricReinterpretation.contains(
            'deliberately excluded the row',
          ) &&
          HabotVariationMapping.metricReinterpretation.contains(
            'over registered VARIANTS, not screens',
          ) &&
          HabotVariationMapping.metricReinterpretation.contains(
            'not a claim about overall conformance',
          ),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02544',
        atomicStepReferenceId: 'GEN-02544',
        setupStepAction:
            'Set up variation mapping within the frontend state management.',
        implementationOrder: 135,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotVariationMapping / HabotVariantAccessibility',
          'Component Properties':
              'one mapping per decision, variant name to value; resolution is '
              'synchronous through the Step 134 dispatcher; registration '
              'refuses an unaudited variant; minimum audit set of '
              '${HabotVariationMapping.minimumCriteria.length} WCAG criteria '
              'drawn from the Step 96 catalogue',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) is EMPTY. This row was deliberately not '
              'taken at Steps 96-110 as "an A/B experiment row wearing an '
              'accessibility metric"; it is taken here because Steps 133 and '
              '134 built the dispatcher it maps into. The metric is '
              'reinterpreted, and the reinterpretation is recorded in '
              'HabotVariationMapping.metricReinterpretation and gated by '
              'GEN-02544-G7.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName:
                'WCAG 2.2 AA Compliance Rate, over registered variants',
            observed:
                '${complianceRate.toStringAsFixed(2)} -- both arms of the '
                'mapping pass their declared audit against the four criteria a '
                'UI variation realistically changes (1.4.3, 1.4.11, 2.5.8, '
                '4.1.2). The rate is demonstrably able to fall: an arm failing '
                '2.5.8 drives it to ${degradedRate.toStringAsFixed(2)} and is '
                'named with its criterion.',
            floor: '0.8',
            optimal: '1',
            ceiling: '1',
          ),
          const AissMeasurement(
            metricName: 'Unaudited variants able to reach a user',
            observed:
                '0, by construction rather than by review. A variant with no '
                'declared accessibility audit is refused at registration, so '
                'an inaccessible treatment arm cannot ship and be read later '
                'as a preference result. This is the hazard the row metric '
                'accidentally names, and almost nobody checks for it.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
          const AissMeasurement(
            metricName: 'Overall app WCAG 2.2 AA conformance',
            observed:
                'NOT CLAIMED HERE. That figure is owned and reported by Step '
                '96 (GEN-02621) over the audited surfaces of the app. The rate '
                'on this row is over the variants of one experiment, and '
                'conflating the two would overstate conformance on the '
                'strength of a two-arm mapping.',
            floor: 'owned by Step 96',
            optimal: 'owned by Step 96',
            ceiling: 'owned by Step 96',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/preferences/variation_mapping.dart',
        ],
      ),
    );
  });
}
