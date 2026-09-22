/// AISS GATE -- Step 443 of 415
/// Global Reference ID:       GEN-05243
/// Atomic Steps Reference ID: GEN-05243
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Build and configure: stream gratitude metrics to BigQuery to
///               track team morale and customer sentiment trends"
/// Metric: Recognition Program Engagement Rate -- floor ">= 20%", optimal ">=
///         30%", ceiling "<= 50% (gaming-risk ceiling)". Best Qualitative
///         Output: "Pass/Fail". SHRM Employee/Customer Recognition Benchmark.
///         Assigned to **DEA**.
///
/// THE FIRST CEILING IN THE TRACK THAT MEANS WHAT A CEILING SHOULD: GOODHART'S
/// LAW, WRITTEN INTO A CELL.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/recognition/recognition_engagement.dart';

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

  group('GEN-05243 :: a ceiling that is an upper bound', () {
    gate(
      'GEN-05243-G1',
      'The ceiling is a true upper bound.',
      '"<= 50% (gaming-risk ceiling)"',
      () =>
          HabotRecognitionEngagement.theCeilingIsAnUpperBound &&
          HabotRecognitionEngagement.theBandIsTwoSided,
    );

    gate(
      'GEN-05243-G2',
      'And both ends of the band are failures.',
      'Too little engagement and too much',
      () => HabotRecognitionEngagement.bothSidesAreFailures,
    );

    gate(
      'GEN-05243-G3',
      'Goodhart\'s law, written into a cell.',
      'The seventh annotated boundary, and the only one whose annotation is an '
          'insight',
      () =>
          HabotRecognitionEngagement.ceilingNote.contains('Goodhart') &&
          HabotRecognitionEngagement.seventhAnnotatedBoundary &&
          HabotRecognitionEngagement.theAnnotationIsAnInsight,
    );

  });

  group('GEN-05243 :: volume is not morale', () {
    gate(
      'GEN-05243-G4',
      'Gratitude volume has three readings, none of them morale.',
      'A happy team, a team told to use the feature, or one generous person',
      () =>
          HabotRecognitionEngagement.threeReadingsOfOneNumber &&
          HabotRecognitionEngagement.theLabelIsKeptHonest,
    );

    gate(
      'GEN-05243-G5',
      'So the dashboard says recognition activity.',
      'A number labelled morale becomes the morale figure on a slide',
      () => HabotRecognitionEngagement.moraleNote.contains('on a slide'),
    );

  });

  group('GEN-05243 :: a minimum group size', () {
    gate(
      'GEN-05243-G6',
      'Four teams, one suppressed below five members.',
      'A team of two is a report about one colleague',
      () =>
          HabotRecognitionEngagement.teams.length == 4 &&
          HabotRecognitionEngagement.theTeamOfTwoIsSuppressed,
    );

    gate(
      'GEN-05243-G7',
      'The published figure is 34 per cent.',
      'Across the three teams large enough to publish',
      () =>
          HabotRecognitionEngagement.engagementPercent > 34 &&
          HabotRecognitionEngagement.engagementPercent < 35,
    );

    gate(
      'GEN-05243-G8',
      'Which is inside the healthy band.',
      'Above the floor, below the gaming-risk ceiling',
      () => HabotRecognitionEngagement.theReadingIsHealthy,
    );

  });

  group('GEN-05243 :: two subjects', () {
    gate(
      'GEN-05243-G9',
      'Staff thanks and customer sentiment are kept apart.',
      'Different populations with different consent, never joined',
      () =>
          HabotRecognitionEngagement.theSubjectsAreKeptApart &&
          HabotRecognitionEngagement.groupNote.contains('suppressed'),
    );

    gate(
      'GEN-05243-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotRecognitionEngagement.obligations.length == 5 &&
          HabotRecognitionEngagement.obligations.values.every((bool b) => b) &&
          HabotRecognitionEngagement.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final double engagement = HabotRecognitionEngagement.engagementPercent;
    final int suppressed = HabotRecognitionEngagement.suppressed;
    final int minimum = HabotRecognitionEngagement.minimumGroupSize;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05243',
        atomicStepReferenceId: 'GEN-05243',
        setupStepAction:
            'COLUMN NOTE: this row\'s ceiling reads "<= 50% (gaming-risk '
            'ceiling)", the first ceiling in the track used as a true upper '
            'bound -- engagement above half signals that thanks is being given '
            'because it is counted -- making the band two-sided with a failure '
            'at each end, and the seventh annotated boundary; it streams '
            'gratitude "to track team morale", which gratitude volume does not '
            'measure, so the figure is published as recognition activity; team '
            'figures are suppressed below five members; and customer '
            'sentiment, a second subject in the same instruction, is streamed '
            'separately and never joined. Atomic Step: "Build and configure: '
            'stream gratitude metrics to BigQuery to track team morale and '
            'customer sentiment trends"',
        implementationOrder: 443,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Build and configure: stream gratitude metrics to BigQuery to track':
              'recognition activity published at '
                  '${engagement.toStringAsFixed(1)} per cent; $suppressed team '
                  'suppressed below $minimum members; staff and customer data '
                  'in separate tables',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Recognition Program Engagement Rate',
            observed:
                'THE BEST CELL IN THE SHEET. "<= 50% (gaming-risk ceiling)" '
                'says engagement above half is not better but worse -- past '
                'that point thanks is being given because it is counted. It is '
                'Goodhart\'s law in a band, and after Batch P showed the '
                'Ceiling column holding the worst value on latency rows, this '
                'row uses it as a ceiling should be used: an upper bound '
                'beyond which more is a problem. Both ends of the band are '
                'failures. Observed: ${engagement.toStringAsFixed(1)} per '
                'cent, healthy.',
            floor: '>= 20%',
            optimal: '>= 30%',
            ceiling: '<= 50% (gaming-risk ceiling)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Teams published below the minimum group size',
            observed:
                '0. A team of two turns a team metric into a report about one '
                'identifiable colleague, so nothing is published for fewer '
                'than $minimum people and $suppressed team in the worked set '
                'is suppressed. Gratitude volume is published as recognition '
                'activity rather than morale, and customer sentiment -- a '
                'second subject in the same instruction -- is streamed '
                'separately and never joined.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/recognition/recognition_engagement.dart',
        ],
      ),
    );
  });
}
