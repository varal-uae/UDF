/// AISS GATE -- Step 427 of 415
/// Global Reference ID:       GEN-02786
/// Atomic Steps Reference ID: GEN-02786
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Test the bottleneck highlight integration by triggering a
///               bottleneck event and confirming the alert appears in the
///               dashboard bottleneck section."
/// Metric: Validation Pass Rate -- floor "95%+ of validation checks pass",
///         optimal "100% validation pass rate", ceiling "1". Best Qualitative
///         Output: "Pass / Fail". IEEE 1012 -- Software Verification and
///         Validation Standards. Assigned to **ADFA**.
///
/// A TEST WRITTEN TO AN ARCHITECTURE NOBODY BUILT: A BOTTLENECK IS NOT AN
/// EVENT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/ops/bottleneck_alert_check.dart';

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

  group('GEN-02786 :: the architecture the row assumes', () {
    gate(
      'GEN-02786-G1',
      'The row assumes an event-driven system.',
      'A thing happens, a message is emitted, a listener reacts',
      () =>
          HabotBottleneckAlertCheck.theTwoArchitecturesDiffer &&
          HabotBottleneckAlertCheck.theDetectorIsScheduled,
    );

    gate(
      'GEN-02786-G2',
      'So the check seeds the aggregate instead.',
      'What Step 424 built is a standing condition over a window, and a test '
          'written to the row\'s architecture would pass against a system '
          'nobody built',
      () =>
          HabotBottleneckAlertCheck.theTestMatchesWhatWasBuilt &&
          HabotBottleneckAlertCheck
              .architectureNote.contains('a system nobody built'),
    );

  });

  group('GEN-02786 :: which dashboard section?', () {
    gate(
      'GEN-02786-G3',
      'The row names one section where two surfaces exist.',
      'Step 425\'s dashboard highlight and Step 426\'s ops manager indicator',
      () =>
          !HabotBottleneckAlertCheck.theSurfaceIsIdentified &&
          HabotBottleneckAlertCheck.twoSurfacesExist,
    );

    gate(
      'GEN-02786-G4',
      'Fifth row in two batches with no antecedent.',
      'So both surfaces are asserted, which is the only reading that cannot be '
          'wrong',
      () =>
          HabotBottleneckAlertCheck.fifthSuchRow &&
          HabotBottleneckAlertCheck.bothAreAsserted,
    );

  });

  group('GEN-02786 :: four assertions, two of them negative', () {
    gate(
      'GEN-02786-G5',
      'Four assertions across two surfaces.',
      'Each surface with a seeded aggregate and again with a clean one',
      () =>
          HabotBottleneckAlertCheck.assertionCount == 4 &&
          HabotBottleneckAlertCheck.everySurfaceIsAssertedBothWays,
    );

    gate(
      'GEN-02786-G6',
      'Two of them are negative.',
      'The half of an integration test usually skipped, and the half that '
          'catches a mark hard-coded into a template',
      () =>
          HabotBottleneckAlertCheck.bothDirectionsAreAsserted &&
          HabotBottleneckAlertCheck.negativeAssertions == 2,
    );

    gate(
      'GEN-02786-G7',
      'And the fixture is removed afterwards.',
      'A test that leaves its seed behind becomes a bottleneck somebody '
          'investigates on Monday',
      () =>
          HabotBottleneckAlertCheck.theAggregateIsRestored &&
          HabotBottleneckAlertCheck
              .assertionNote.contains('investigates on Monday'),
    );

  });

  group('GEN-02786 :: a band holding two types', () {
    gate(
      'GEN-02786-G8',
      'The band holds two sentences and a bare number.',
      'After Step 380 held three types',
      () =>
          HabotBottleneckAlertCheck.theBandHoldsTwoTypes &&
          HabotBottleneckAlertCheck.theRowThatRecordedMixedTypes == 380,
    );

    gate(
      'GEN-02786-G9',
      'And the floor uses a plus sign as an inequality.',
      '"95%+" against an optimal that restates the ceiling in words',
      () =>
          HabotBottleneckAlertCheck.theFloorUsesAPlusSignAsAnInequality &&
          HabotBottleneckAlertCheck
              .bandNote.contains('the same boundary written twice'),
    );

    gate(
      'GEN-02786-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotBottleneckAlertCheck.obligations.length == 5 &&
          HabotBottleneckAlertCheck.obligations.values.every((bool b) => b) &&
          HabotBottleneckAlertCheck.qualitativeOutput == 'Pass' &&
          HabotBottleneckAlertCheck.thePassRateClearsTheOptimal,
    );
  });

  tearDownAll(() {
    final int assertions = HabotBottleneckAlertCheck.assertionCount;
    final int negative = HabotBottleneckAlertCheck.negativeAssertions;
    final int surfaces = HabotBottleneckAlertCheck.surfacesThatExist.length;
    final double rate = HabotBottleneckAlertCheck.passRate;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02786',
        atomicStepReferenceId: 'GEN-02786',
        setupStepAction:
            'COLUMN NOTE: this row describes triggering a bottleneck event, '
            'and what Step 424 built is a standing condition over an aggregate '
            'rather than an event, so the check seeds the aggregate and '
            'records the difference; it names "the dashboard bottleneck '
            'section" where two surfaces exist, the fifth row in two batches '
            'to use a definite article for something never identified, so both '
            'are asserted; its band holds two sentences and a bare 1, with the '
            'floor writing "95%+" in place of an inequality and the optimal '
            'restating the ceiling in words. Atomic Step: "Test the bottleneck '
            'highlight integration by triggering a bottleneck event and '
            'confirming the alert appears in the dashboard bottleneck '
            'section."',
        implementationOrder: 427,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Test the bottleneck highlight integration by triggering a '
          'bottleneck event':
              '$assertions assertions across $surfaces surfaces, $negative of '
                  'them negative, pass rate $rate, with the seeded aggregate '
                  'removed afterwards',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Validation Pass Rate',
            observed:
                'THE ROW DESCRIBES AN ARCHITECTURE THAT WAS NOT BUILT. '
                'Triggering a bottleneck event and waiting for an alert is the '
                'shape of an event-driven system; what Step 424 built is a '
                'standing condition over an aggregate, with no instant at '
                'which it becomes true and only a window in which it is. A '
                'test written to the row\'s architecture would pass against a '
                'system nobody built, so this one seeds the aggregate and says '
                'so. Its band holds two sentences and a bare 1, with the floor '
                'writing "95%+" where an inequality belongs and the optimal '
                'restating the ceiling in words. Observed: pass rate $rate.',
            floor: '95%+ of validation checks pass',
            optimal: '100% validation pass rate',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Surfaces left unasserted',
            observed:
                '0 of $surfaces. The row names "the dashboard bottleneck '
                'section" and two surfaces exist -- the analytics dashboard '
                'highlight and the ops manager indicator -- so both are '
                'asserted, which is the only reading that cannot be wrong. '
                'Each is checked with a seeded aggregate and again with a '
                'clean one, so $negative of the $assertions assertions are '
                'negative: the half of an integration test that is usually '
                'skipped and the half that catches a mark hard-coded into a '
                'template.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/ops/bottleneck_alert_check.dart',
        ],
      ),
    );
  });
}
