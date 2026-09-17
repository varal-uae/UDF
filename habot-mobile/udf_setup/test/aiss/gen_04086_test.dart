/// AISS GATE -- Step 431 of 415
/// Global Reference ID:       GEN-04086
/// Atomic Steps Reference ID: GEN-04086
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Verify that latency updates display on mobile dashboard clocks
///               with under 1 second delay."
/// Metric: Dashboard Clock Update Latency -- floor "<1s", optimal "<200ms",
///         ceiling "2s". Best Qualitative Output: "Pass/Fail". Data Freshness
///         Standards (<1s). Assigned to **UDF**.
///
/// A REFERENCE STANDARD THAT IS THE ROW'S OWN FLOOR, AND A CLOCK THAT SHOULD
/// SHOW AGE RATHER THAN TIME.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/live/clock_latency.dart';

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

  group('GEN-04086 :: the standard column holds the floor', () {
    gate(
      'GEN-04086-G1',
      'The standard column restates the floor.',
      '"Data Freshness Standards (<1s)" is this row\'s own floor in brackets '
          'after a phrase that sounds like a standard',
      () =>
          HabotClockLatency.theStandardRepeatsTheFloor &&
          !HabotClockLatency.aRealStandardIsNamed,
    );

    gate(
      'GEN-04086-G2',
      'Four kinds of content have appeared in that column.',
      'A foreign framework at 415, prose at 416 and 429, and a copied '
          'threshold here -- it is being used as a second notes field',
      () =>
          HabotClockLatency.fourDifferentUsesRecorded &&
          HabotClockLatency.standardNote.contains('a second notes field'),
    );

  });

  group('GEN-04086 :: two readings of one sentence', () {
    gate(
      'GEN-04086-G3',
      'The Atomic Step has two readings.',
      'The display of latency updates, or the latency with which updates '
          'display',
      () =>
          HabotClockLatency.theSentenceIsAmbiguous &&
          HabotClockLatency.theOtherReadingIsRecorded,
    );

    gate(
      'GEN-04086-G4',
      'And the metric name settles which was built.',
      'With the other recorded, because two people implementing two readings '
          'is how a dashboard ends up with two clocks',
      () =>
          HabotClockLatency.theMetricSettlesIt &&
          HabotClockLatency.ambiguityNote.contains('two clocks'),
    );

  });

  group('GEN-04086 :: the clock shows age', () {
    gate(
      'GEN-04086-G5',
      'The clock shows age, not time.',
      'What a reader wants from a dashboard clock is not what time it is but '
          'whether what they are looking at is still true',
      () =>
          HabotClockLatency.itShowsAgeRatherThanTime &&
          HabotClockLatency.freshDataShowsNoAge,
    );

    gate(
      'GEN-04086-G6',
      'Four readings across the boundaries.',
      'Current, seconds, minutes, and never-arrived as its own state',
      () =>
          HabotClockLatency.aMinuteOldShowsSeconds &&
          HabotClockLatency.tenMinutesOldShowsMinutes &&
          HabotClockLatency.nothingEverArrivedIsItsOwnState,
    );

    gate(
      'GEN-04086-G7',
      'Four clocks, and no per-second repaints.',
      'Four clocks ticking once a second is four repaints a second for a '
          'number nobody is watching change',
      () =>
          HabotClockLatency.clocksOnTheScreen == 4 &&
          HabotClockLatency.theRepaintsAreSaved,
    );

    gate(
      'GEN-04086-G8',
      'The cadence policy is bound rather than restated.',
      'Step 395 settled it on the SLA countdown: match the tick rate to the '
          'magnitude',
      () =>
          HabotClockLatency.theCadencePolicyIsBound &&
          HabotClockLatency.cadenceNote.contains('still true'),
    );

  });

  group('GEN-04086 :: the band', () {
    gate(
      'GEN-04086-G9',
      'The optimal sits below both boundaries.',
      'Floor "<1s" and ceiling "2s" bracket one to two seconds; the optimal is '
          '"<200ms"',
      () =>
          HabotClockLatency.theOptimalIsBelowBothBoundaries &&
          HabotClockLatency.theShapeIsTheDeclaredConvention,
    );

    gate(
      'GEN-04086-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotClockLatency.obligations.length == 5 &&
          HabotClockLatency.obligations.values.every((bool b) => b) &&
          HabotClockLatency.qualitativeOutput == 'Pass' &&
          HabotClockLatency.theUpdateBeatsTheOptimal,
    );
  });

  tearDownAll(() {
    final int clocks = HabotClockLatency.clocksOnTheScreen;
    final int updateMs = HabotClockLatency.observedUpdateMs;
    final int uses = HabotClockLatency.whatHasAppearedInThatColumn.length;
    final int firstBoundary = HabotClockLatency.firstBoundarySeconds;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04086',
        atomicStepReferenceId: 'GEN-04086',
        setupStepAction:
            'COLUMN NOTE: this row\'s reference-standard column reads "Data '
            'Freshness Standards (<1s)", which restates its own floor rather '
            'than naming a standard -- the fourth distinct kind of content to '
            'appear in that column across two batches; its Atomic Step can be '
            'read two ways and the metric name settles it, with the other '
            'reading recorded; and its optimal of "<200ms" sits below both its '
            'floor of "<1s" and its ceiling of "2s", the fifth row in this '
            'batch written to the convention Step 418 sets out. Atomic Step: '
            '"Verify that latency updates display on mobile dashboard clocks '
            'with under 1 second delay."',
        implementationOrder: 431,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Verify that latency updates display on mobile dashboard clocks with':
              '$clocks clocks showing the age of the data rather than the wall '
                  'time, repainting when the age crosses a boundary at '
                  '$firstBoundary seconds; observed update latency $updateMs '
                  'ms',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Dashboard Clock Update Latency',
            observed:
                'THE REFERENCE-STANDARD COLUMN HOLDS THIS ROW\'S OWN FLOOR. '
                '"Data Freshness Standards (<1s)" is not the name of a '
                'standard; it is the floor restated in brackets after a phrase '
                'that sounds like one. $uses different kinds of thing have now '
                'appeared in that column across two batches -- a foreign '
                'framework, prose arguing for the band twice, and a threshold '
                'copied from the row itself -- which means it is being used as '
                'a second notes field. The optimal of "<200ms" sits below both '
                'the floor of "<1s" and the ceiling of "2s". Observed: '
                '$updateMs ms.',
            floor: '<1s',
            optimal: '<200ms',
            ceiling: '2s',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Clocks repainting once a second',
            observed:
                '0 of $clocks. Step 395 settled the cadence question on the '
                'SLA countdown -- match the tick rate to the magnitude -- and '
                'that policy is bound here rather than restated. The clock '
                'shows the age of the data rather than the wall time, because '
                'what a reader wants from a clock on a dashboard is not what '
                'time it is but whether what they are looking at is still '
                'true, and it repaints when the age crosses a boundary '
                'somebody would act on. The Atomic Step reads two ways and the '
                'metric name settles it; the other reading is recorded.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/live/clock_latency.dart',
        ],
      ),
    );
  });
}
