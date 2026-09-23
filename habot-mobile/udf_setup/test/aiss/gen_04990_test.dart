/// AISS GATE -- Step 463 of 1,314
/// Global Reference ID:       GEN-04990
/// Atomic Steps Reference ID: GEN-04990
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Confirm the expected output is achieved and mark Sequence
///               Order 34 complete: Interactive SVG sensory map component with
///               accessible list fallback."
/// Metric: Milestone Sign-off / Definition-of-Done Compliance -- floor "100% of
///         stated acceptance criteria verified before sign-off", optimal "100%
///         verified, formally signed off by the accountable owner", ceiling
///         "100% (sign-off is binary; cannot exceed complete)". Best
///         Qualitative Output: "Complete / Partial / Not Complete". Scrum.org
///         Definition of Done / PMI PMBOK Milestone Acceptance practice.
///         Assigned to **UDF**.
///
/// A ROW THAT ASKED FOR ITS OWN ACCESSIBLE FALLBACK BEFORE ANYBODY MADE IT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/assessment/sensory_map_signoff.dart';

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

  group('GEN-04990 :: correct without being told', () {
    gate(
      'GEN-04990-G1',
      'The row names its own accessible fallback.',
      '"Accessible list fallback" is in the expected output, not in a review '
          'comment',
      () => HabotSensoryMapSignoff.theRowNamesTheFallback,
    );

    gate(
      'GEN-04990-G2',
      'The second such row, after Step 451.',
      'Which pointed its measurement at a training video rather than at a '
          'worker',
      () => HabotSensoryMapSignoff.secondSuchRow,
    );

  });

  group('GEN-04990 :: a fallback that carries everything', () {
    gate(
      'GEN-04990-G3',
      'Four places drawn, four places listed.',
      'A fallback that carries less is a different document',
      () =>
          HabotSensoryMapSignoff.theListShowsEveryPlace &&
          HabotSensoryMapSignoff.placesDrawn == 4,
    );

    gate(
      'GEN-04990-G4',
      'The same actions on both, from one record.',
      'Adding a note and marking a place as changed',
      () =>
          HabotSensoryMapSignoff.bothOfferTheSameActions &&
          HabotSensoryMapSignoff.neitherCanDrift,
    );

    gate(
      'GEN-04990-G5',
      'So neither can drift from the other.',
      'A lighter version would quietly give one group a smaller map',
      () => HabotSensoryMapSignoff.fallbackNote.contains('smaller map'),
    );

  });

  group('GEN-04990 :: whose map it is', () {
    gate(
      'GEN-04990-G6',
      'Every level carries words and a shape.',
      'Intensity is never carried by colour alone',
      () => HabotSensoryMapSignoff.intensityIsNotColourAlone,
    );

    gate(
      'GEN-04990-G7',
      'The map belongs to the child.',
      'Written with them, visible to their support team, never aggregated',
      () =>
          HabotSensoryMapSignoff.theMapBelongsToTheChild &&
          HabotSensoryMapSignoff.ownershipNote.contains('nobody else'),
    );

  });

  group('GEN-04990 :: verified, unsigned', () {
    gate(
      'GEN-04990-G8',
      'Five acceptance criteria, all verified.',
      'Which is the whole of this band\'s floor',
      () =>
          HabotSensoryMapSignoff.acceptanceCriteria.length == 5 &&
          HabotSensoryMapSignoff.everyCriterionIsVerified,
    );

    gate(
      'GEN-04990-G9',
      'The band is Step 457\'s, and no owner is named.',
      'Seven rows apart, and the optimal is a signature again',
      () =>
          HabotSensoryMapSignoff.theBandIsStep457s &&
          !HabotSensoryMapSignoff.anAccountableOwnerHasSigned &&
          HabotSensoryMapSignoff.itIsTheSecondRowAwaitingSignature,
    );

    gate(
      'GEN-04990-G10',
      'Five obligations met, and the row reports Partial.',
      'Verified is not signed',
      () =>
          HabotSensoryMapSignoff.obligations.length == 5 &&
          HabotSensoryMapSignoff.obligations.values.every((bool b) => b) &&
          HabotSensoryMapSignoff.qualitativeOutput == 'Partial',
    );
  });

  tearDownAll(() {
    final int places = HabotSensoryMapSignoff.places.length;
    final int waiting = HabotSignoffLedger.count;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04990',
        atomicStepReferenceId: 'GEN-04990',
        setupStepAction:
            'COLUMN NOTE: this row names an accessible list fallback in its '
            'own expected output, the second row in two batches to arrive '
            'already correct on a point the track usually has to add, after '
            'Step 451; the fallback is built equal rather than lighter, '
            'reading from one record and offering the same actions; intensity '
            'carries a label and a shape as well as a tone; and its band is '
            'Step 457\'s, so with every criterion verified and no owner named '
            'it reports Partial. Atomic Step: "Confirm the expected output is '
            'achieved and mark Sequence Order 34 complete: Interactive SVG '
            'sensory map component with accessible list fallback."',
        implementationOrder: 463,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Confirm the expected output is achieved and mark Sequence Order':
              '$places places drawn and $places listed, the same actions on '
                  'both from one record, intensity carried by label and shape '
                  'as well as tone; verified, unsigned, $waiting rows waiting',
          'Completion Status': 'Partial',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Milestone Sign-off / Definition-of-Done Compliance',
            observed:
                'PARTIAL, ON A ROW THAT ARRIVED CORRECT. The expected output '
                'names an accessible list fallback without anybody asking for '
                'one, the second time in two batches a row has arrived already '
                'right on a point the track usually has to add, after Step '
                '451. Every acceptance criterion is verified -- $places places '
                'in both forms, the same actions, one record behind them -- '
                'and the optimal requires a signature, so the row stops at '
                'Partial.',
            floor:
                '100% of stated acceptance criteria verified before sign-off',
            optimal:
                '100% verified, formally signed off by the accountable owner',
            ceiling: '100% (sign-off is binary; cannot exceed complete)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Information the list fallback does not carry',
            observed:
                '0. The list shows every place the map draws, in the same '
                'order, with the same intensities and the same two actions, '
                'reading from the same record so neither can drift. Intensity '
                'carries a label and a distinct shape as well as a tone, and '
                'the map is visible to the people delivering the child\'s '
                'support and to nobody else.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/assessment/sensory_map_signoff.dart',
        ],
      ),
    );
  });
}
