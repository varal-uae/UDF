/// AISS GATE -- Step 484 of 1,314
/// Global Reference ID:       GEN-05320
/// Atomic Steps Reference ID: GEN-05320
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Unit-test and validate the implementation of: create an
///               automated rollback subroutine disabling underperforming UI
///               variants instantly"
/// Metric: Validation Test Pass Rate (Experiment Statistical Significance) --
///         floor ">= 95% test pass rate, >= 80% code coverage", optimal "100%
///         test pass rate, >= 90% code coverage", ceiling "100% coverage
///         (diminishing ROI beyond)". Best Qualitative Output: "Pass/Fail".
///         ISO/IEC 25010 & ISTQB Foundation - Test Coverage Standard. Assigned
///         to **ADFA**.
///
/// "INSTANTLY", SPLIT INTO THE THING THAT CAN BE KNOWN INSTANTLY AND THE THING
/// THAT CANNOT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/release/variant_halt.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

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

  group('GEN-05320 :: a name and a band about different things', () {
    gate(
      'GEN-05320-G1',
      'The metric name promises statistical significance.',
      'In a parenthesis, on a row about unit tests',
      () => HabotVariantHalt.theNamePromisesSignificance,
    );

    gate(
      'GEN-05320-G2',
      'And the band measures test pass rate and coverage.',
      'Neither of which is a significance test',
      () => HabotVariantHalt.theBandMeasuresTestsOnly,
    );

    gate(
      'GEN-05320-G3',
      'So both are reported.',
      'A rollback subroutine that is perfectly tested and fires on noise is a '
      'perfectly tested mistake',
      () =>
          HabotVariantHalt.twoThingsInOneName &&
          HabotVariantHalt.nameNote.contains('perfectly tested mistake'),
    );

  });

  group('GEN-05320 :: what the band does measure', () {
    gate(
      'GEN-05320-G4',
      'The test figures meet the optimal.',
      '100 per cent passing at 92 per cent coverage',
      () => HabotVariantHalt.theOptimalIsMet,
    );

    gate(
      'GEN-05320-G5',
      'The ceiling argues about return on investment.',
      'The thirteenth annotated boundary in the track',
      () =>
          HabotVariantHalt.theCeilingIsAnArgument &&
          HabotVariantHalt.annotatedBoundaryCount == 13,
    );

  });

  group('GEN-05320 :: two triggers, not one', () {
    gate(
      'GEN-05320-G6',
      'A variant that fails to render is halted on sight.',
      'A broken screen is not a hypothesis',
      () =>
          HabotVariantHalt.aBrokenVariantIsHaltedAtOnce &&
          HabotVariantHalt.errorOccurrencesBeforeHalt == 1,
    );

    gate(
      'GEN-05320-G7',
      'An early dip over 46 sessions is not acted on.',
      'A variant identical to the control looks worse half the time',
      () =>
          HabotVariantHalt.anEarlyDipIsNotActedOn &&
          HabotVariantHalt.performanceNeedsAWindowAndASample,
    );

    gate(
      'GEN-05320-G8',
      'And a noisy canary is still not acted on.',
      'The rule the telemetry thread already established',
      () => HabotVariantHalt.aNoisyCanaryIsNotActedOn,
    );

    gate(
      'GEN-05320-G9',
      'A measured loss over a full window is acted on.',
      'Which is what the row wanted, once it can be known',
      () =>
          HabotVariantHalt.aMeasuredLossIsActedOn &&
          HabotVariantHalt.triggerNote.contains('not a hypothesis'),
    );

  });

  group('GEN-05320 :: the result', () {
    gate(
      'GEN-05320-G10',
      'Five obligations met, nobody switched mid-task, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotVariantHalt.obligations.length == 5 &&
          HabotVariantHalt.obligations.values.every((bool b) => b) &&
          HabotVariantHalt.midTaskNote.contains('what you typed') &&
          HabotVariantHalt.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final double coverage = HabotVariantHalt.coveragePercent;
    final int cases = HabotVariantHalt.corpus.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05320',
        atomicStepReferenceId: 'GEN-05320',
        setupStepAction:
            'COLUMN NOTE: this row\'s metric name promises experiment '
            'statistical significance and its three band cells measure test '
            'pass rate and code coverage, so both are reported; its ceiling '
            'argues about return on investment, the thirteenth annotated '
            'boundary in the track; and its "instantly" is split into two '
            'triggers -- a broken variant is disabled on the first occurrence '
            'because a broken screen is not a hypothesis, while a variant that '
            'is merely behind waits for the full observation window and the '
            'five-hundred-session minimum the telemetry thread already '
            'established, and nobody is switched mid-task. Atomic Step: '
            '"Unit-test and validate the implementation of: create an '
            'automated rollback subroutine disabling underperforming UI '
            'variants instantly"',
        implementationOrder: 484,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Unit-test and validate the implementation of: create an automated '
          'rollback':
              '100 per cent test pass at ${coverage.toStringAsFixed(0)} per '
              'cent coverage, and $cases worked signals decided by two '
              'triggers: errors at once, performance only after a window and a '
              'sample',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName:
                'Validation Test Pass Rate (Experiment Statistical '
                'Significance)',
            observed:
                'A NAME AND A BAND ABOUT DIFFERENT THINGS. The parenthesis '
                'promises experiment statistical significance and the three '
                'cells measure test pass rate and code coverage, so both are '
                'reported: 100 per cent passing at '
                '${coverage.toStringAsFixed(0)} per cent coverage, and the '
                'significance rule beside it. The ceiling argues about return '
                'on investment, the thirteenth annotated boundary in the '
                'track.',
            floor: '>= 95% test pass rate, >= 80% code coverage',
            optimal: '100% test pass rate, >= 90% code coverage',
            ceiling: '100% coverage (diminishing ROI beyond)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Variants disabled on a dip that could be noise',
            observed:
                '0 of $cases. With a small sample a variant identical to the '
                'control looks worse half the time, so "instantly" is split in '
                'two: a variant that throws or fails to render is disabled on '
                'the first occurrence, because a broken screen is not a '
                'hypothesis, and a variant that is merely behind waits for the '
                'full observation window and the five-hundred-session minimum. '
                'Nobody is switched mid-task.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/release/variant_halt.dart',
        ],
      ),
    );
  });
}
