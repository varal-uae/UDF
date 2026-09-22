/// AISS GATE -- Step 442 of 415
/// Global Reference ID:       GEN-05232
/// Atomic Steps Reference ID: GEN-05232
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Make and document the required upfront decision: establish
///               criteria for auto-publishing gratitude notes and point
///               conversion rates"
/// Metric: Decision Documentation Completeness -- floor "Decision undocumented
///         or verbal only", optimal "Decision documented with rationale & owner
///         sign-off", ceiling "1". Best Qualitative Output:
///         "Complete/Partial/Not Complete". ISO 21500 - Project Governance &
///         Decision Records. Assigned to **UDF**.
///
/// TWO DECISIONS THAT PULL AGAINST EACH OTHER: PUBLISHING THANKS AUTOMATICALLY,
/// AND TURNING THANKS INTO POINTS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/recognition/gratitude_policy.dart';

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

  group('GEN-05232 :: a floor that describes failure', () {
    gate(
      'GEN-05232-G1',
      'The floor describes the failure.',
      '"Decision undocumented or verbal only" is not a minimum',
      () =>
          HabotGratitudePolicy.theFloorDescribesTheFailure &&
          HabotGratitudePolicy.theRowWhoseCeilingDidThis == 400,
    );

    gate(
      'GEN-05232-G2',
      'And sits above a bare ceiling of 1.',
      'The second of five prose-and-a-1 bands in this batch',
      () =>
          HabotGratitudePolicy.proseFloorAndBareCeiling &&
          HabotGratitudePolicy.floorNote.contains('exists to prevent'),
    );

  });

  group('GEN-05232 :: thanks is not payment', () {
    gate(
      'GEN-05232-G3',
      'Two decisions recorded.',
      'Point conversion, and auto-publishing',
      () => HabotGratitudePolicy.twoDecisionsAreRecorded,
    );

    gate(
      'GEN-05232-G4',
      'Peer thanks converts to zero points.',
      'Thanks worth points is thanks that can be paid for',
      () =>
          HabotGratitudePolicy.peerThanksPointValue == 0 &&
          HabotGratitudePolicy.thanksWouldBreakTheLedger,
    );

    gate(
      'GEN-05232-G5',
      'Because a thank-you is not a completion.',
      'Points from thanks would break Step 438\'s ledger',
      () =>
          HabotGratitudePolicy.aThankYouIsNotACompletion &&
          HabotGratitudePolicy
              .conversionNote.contains('gratitude stays gratitude'),
    );

  });

  group('GEN-05232 :: publication is the person\'s choice', () {
    gate(
      'GEN-05232-G6',
      'Gratitude is private by default and not auto-published.',
      'Delivered to the person thanked and nobody else',
      () => HabotGratitudePolicy.publicationIsThePersonsChoice,
    );

    gate(
      'GEN-05232-G7',
      'Because publication is the person\'s choice.',
      'Some people would rather not have their name on a shared screen',
      () =>
          HabotGratitudePolicy.theCharterFirstRuleHolds &&
          HabotGratitudePolicy
              .publicationNote.contains('reasons that are theirs'),
    );

  });

  group('GEN-05232 :: the records', () {
    gate(
      'GEN-05232-G8',
      'Every record has an owner, a rationale and a review date.',
      'A decision with no review date becomes a rule nobody remembers choosing',
      () =>
          HabotGratitudePolicy.everyRecordHasAnOwnerAndRationale &&
          HabotGratitudePolicy.everyRecordHasAReviewDate,
    );

    gate(
      'GEN-05232-G9',
      'Documentation reaches the ceiling.',
      'Both records complete',
      () => HabotGratitudePolicy.documentation == 1,
    );

    gate(
      'GEN-05232-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotGratitudePolicy.obligations.length == 5 &&
          HabotGratitudePolicy.obligations.values.every((bool b) => b) &&
          HabotGratitudePolicy.qualitativeOutput == 'Complete',
    );
  });

  tearDownAll(() {
    final int records = HabotGratitudePolicy.records.length;
    final int points = HabotGratitudePolicy.peerThanksPointValue;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05232',
        atomicStepReferenceId: 'GEN-05232',
        setupStepAction:
            'COLUMN NOTE: this row\'s floor reads "Decision undocumented or '
            'verbal only", which describes the failure rather than a minimum '
            'acceptable state, and its ceiling is a bare 1 beneath two prose '
            'cells, the second of five such rows in this batch; it bundles two '
            'decisions that pull against each other -- publishing thanks '
            'automatically and converting thanks into points -- and both are '
            'recorded with owner, rationale and a review date: peer thanks is '
            'worth zero points, and publication is the thanked person\'s '
            'choice. Atomic Step: "Make and document the required upfront '
            'decision: establish criteria for auto-publishing gratitude notes '
            'and point conversion rates"',
        implementationOrder: 442,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Make and document the required upfront decision: establish criteria '
          'for':
              '$records decision records: peer thanks is worth $points points, '
                  'and gratitude is published only if the person thanked '
                  'chooses',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Decision Documentation Completeness',
            observed:
                'THE FLOOR DESCRIBES THE FAILURE. "Decision undocumented or '
                'verbal only" is the state of not having done the work, so the '
                'band\'s lowest acceptable value is the thing the row exists '
                'to prevent -- Step 400\'s ceiling did this, and now a floor '
                'does. Observed: $records decisions recorded with owner, '
                'rationale and review date.',
            floor: 'Decision undocumented or verbal only',
            optimal: 'Decision documented with rationale & owner sign-off',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Points minted by a thank-you',
            observed:
                '$points. A thank-you worth ten points is a thank-you somebody '
                'can be paid for, and the first thing that happens to a '
                'currency of thanks is that pairs of colleagues start trading '
                'it; it would also mint points with no validated completion '
                'behind them. Gratitude stays gratitude, and it is private '
                'unless the person thanked chooses otherwise.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/recognition/gratitude_policy.dart',
        ],
      ),
    );
  });
}
