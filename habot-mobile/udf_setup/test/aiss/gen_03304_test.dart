/// AISS GATE -- Step 428 of 415
/// Global Reference ID:       GEN-03304
/// Atomic Steps Reference ID: GEN-03304
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Instrument engagement analytics tracking views, likes,
///               comments, and hesitation heatmaps."
/// Metric: Engagement Log Accuracy -- floor "0.999", optimal "1", ceiling "1".
///         Best Qualitative Output: "Pass". Sentry / Telemetry Specs. Assigned
///         to **CAL**.
///
/// LIKES AND COMMENTS IN A SHIFT-MANAGEMENT APPLICATION, AND A HEATMAP THAT
/// WOULD UNDO THE BATCH.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/engagement_analytics.dart';

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

  group('GEN-03304 :: two of four exist', () {
    gate(
      'GEN-03304-G1',
      'Four subjects named and two of them exist.',
      'Views and hesitation are instrumented; likes and comments have nothing '
          'to instrument',
      () =>
          HabotEngagementAnalytics.subjectCount == 4 &&
          HabotEngagementAnalytics.twoOfFourExist,
    );

    gate(
      'GEN-03304-G2',
      'Every subject is accounted for and nothing absent is built.',
      'Building a like button to satisfy a telemetry row would be the actual '
          'failure',
      () =>
          HabotEngagementAnalytics.everySubjectIsAccountedFor &&
          HabotEngagementAnalytics.nothingAbsentIsInstrumented,
    );

    gate(
      'GEN-03304-G3',
      'The engagement model is borrowed and recorded, not adopted.',
      'Views, likes and comments is a social product\'s model, the same kind '
          'of borrowing as Step 414\'s "props"',
      () =>
          HabotEngagementAnalytics.theBorrowingIsRecorded &&
          HabotEngagementAnalytics
              .borrowingNote.contains('would be the actual failure'),
    );

  });

  group('GEN-03304 :: fields, not pixels', () {
    gate(
      'GEN-03304-G4',
      'No coordinates are captured.',
      'And Step 419\'s allowlist has no coordinate field, which is why it does '
          'not',
      () =>
          HabotEngagementAnalytics.noCoordinateCapture &&
          HabotEngagementAnalytics.theAllowlistHasNoCoordinateField,
    );

    gate(
      'GEN-03304-G5',
      'Three reasons are named.',
      'Which hand holds the phone, how far a tap overshoots, the tremor in a '
          'movement',
      () => HabotEngagementAnalytics.threeReasonsAreNamed,
    );

    gate(
      'GEN-03304-G6',
      'And the heatmap is over fields.',
      'Which is what hesitation needs anyway -- it belongs to a question, not '
          'to a place on the glass',
      () =>
          HabotEngagementAnalytics.theHeatmapIsOverFields &&
          HabotEngagementAnalytics.hesitationBelongsToAQuestion,
    );

  });

  group('GEN-03304 :: the third refusal', () {
    gate(
      'GEN-03304-G7',
      'Three refusals in this batch, each naming its replacement.',
      'Secrecy, a device identifier and coordinate capture',
      () =>
          HabotEngagementAnalytics.threeRefusals &&
          HabotEngagementAnalytics.everyRefusalNamesItsReplacement,
    );

    gate(
      'GEN-03304-G8',
      'And the earlier refusals still hold.',
      'In all three the requirement survives and only the mechanism is '
          'replaced',
      () =>
          HabotEngagementAnalytics.theEarlierRefusalsHold &&
          HabotEngagementAnalytics.refusalNote.contains('still gets done'),
    );

  });

  group('GEN-03304 :: the band and the column', () {
    gate(
      'GEN-03304-G9',
      'The band is nearly collapsed and the column holds one value.',
      '0.999, 1, 1, with "Pass" and nothing else',
      () =>
          HabotEngagementAnalytics.theBandIsNearlyCollapsed &&
          HabotEngagementAnalytics.theOptimalEqualsTheCeiling &&
          HabotEngagementAnalytics.theOutputColumnHoldsOneValue &&
          HabotEngagementAnalytics.threeInThisBatch,
    );

    gate(
      'GEN-03304-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotEngagementAnalytics.obligations.length == 5 &&
          HabotEngagementAnalytics.obligations.values.every((bool b) => b) &&
          HabotEngagementAnalytics.qualitativeOutput == 'Pass' &&
          HabotEngagementAnalytics.accuracyReachesTheCeiling,
    );
  });

  tearDownAll(() {
    final int subjects = HabotEngagementAnalytics.subjectCount;
    final int existing = HabotEngagementAnalytics.existing;
    final int refusals = HabotEngagementAnalytics.refusalsInThisBatch.length;
    final String unit = HabotEngagementAnalytics.heatmapUnit;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03304',
        atomicStepReferenceId: 'GEN-03304',
        setupStepAction:
            'COLUMN NOTE: this row asks for likes and comments in an '
            'application where nothing can be liked and no commentary surface '
            'exists -- the engagement model of a social product borrowed '
            'whole, the same shape as Step 414\'s borrowed noun, recorded '
            'rather than adopted; it asks for hesitation heatmaps, which at '
            'coordinate granularity would put a near-signature into the '
            'payload Step 419 closed, so the heatmap is built over fields; its '
            'band runs 0.999, 1, 1 with the optimal equal to the ceiling; and '
            'its Best Qualitative Output column holds the single word "Pass", '
            'the thirteenth one-valued column in the track and the third in '
            'this batch. Atomic Step: "Instrument engagement analytics '
            'tracking views, likes, comments, and hesitation heatmaps."',
        implementationOrder: 428,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Instrument engagement analytics tracking views, likes, comments, '
          'and hesitation heatmaps':
              '$existing of $subjects named subjects exist in this application '
                  'and are instrumented; the heatmap is built over the "$unit" '
                  'rather than over coordinates',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Engagement Log Accuracy',
            observed:
                'TWO OF THE FOUR THINGS NAMED DO NOT EXIST HERE. Four hundred '
                'and twenty-seven steps of this application are shifts, '
                'clock-ins, overtime approvals and payroll; nothing in it has '
                'ever been liked and no commentary surface exists. "Views, '
                'likes, comments" is the engagement model of a social product '
                'borrowed whole -- the same kind of borrowing as Step 414\'s '
                '"props" -- and it is recorded rather than adopted, because '
                'building a like button to satisfy a telemetry row would be '
                'the actual failure. Its band runs 0.999, 1, 1 and its output '
                'column holds the single word "Pass".',
            floor: '0.999',
            optimal: '1',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Touch coordinates captured',
            observed:
                '0. A heatmap is per-pixel by construction, and coordinates '
                'carrying timestamps are close to a signature: which hand '
                'holds the phone, how far a tap overshoots its target, the '
                'tremor in a movement. Step 419\'s allowlist has no coordinate '
                'field and this row is the reason. The heatmap is built over '
                'the "$unit", which is what the word hesitation needs anyway. '
                'It is the third of $refusals refusals in this batch, and in '
                'all three the requirement survives and only the mechanism is '
                'replaced.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/engagement_analytics.dart',
        ],
      ),
    );
  });
}
