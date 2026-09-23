/// AISS GATE -- Step 472 of 1,314
/// Global Reference ID:       GEN-05155
/// Atomic Steps Reference ID: GEN-05155
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Review the step objective: build a touch-optimized interface
///               allowing LSAs and therapists to set daily working hours,
///               locations, and service capabilities with zero desktop
///               dependency"
/// Metric: Requirement/Objective Comprehension Completeness -- floor "Partial
///         understanding; unresolved ambiguities", optimal "Objective fully
///         documented & stakeholder-confirmed", ceiling "1". Best Qualitative
///         Output: "Complete/Partial/Not Complete". BABOK v3 - Requirements
///         Elicitation & Analysis. Assigned to **UDF**.
///
/// A ROTA PEOPLE SET THEMSELVES, AND A REFUSAL TO READ "LOCATIONS" AS A
/// POSITION FEED.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/roster/availability_objective.dart';

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

  group('GEN-05155 :: a band from the previous batch', () {
    gate(
      'GEN-05155-G1',
      'The band is Step 453\'s, character for character.',
      'Floor, optimal and a bare ceiling of 1 under two prose cells',
      () =>
          HabotAvailabilityObjective.bandFirstSeenAtStep == 453 &&
          HabotAvailabilityObjective.theFloorDescribesTheFailure,
    );

    gate(
      'GEN-05155-G2',
      'One of two rows in this batch carrying a Batch Q band.',
      'The other is Step 473',
      () => HabotAvailabilityObjective.twoSuchRows,
    );

  });

  group('GEN-05155 :: four ambiguities', () {
    gate(
      'GEN-05155-G3',
      'Four ambiguities, each with a proposal and a named confirmer.',
      'LSA, service capabilities, locations, zero desktop dependency',
      () =>
          HabotAvailabilityObjective.fourAmbiguities &&
          HabotAvailabilityObjective.everyAmbiguityHasAProposalAndAConfirmer,
    );

    gate(
      'GEN-05155-G4',
      'LSA is the third unexpanded abbreviation in two batches.',
      'After ZII at Step 453 and before DCYN at Step 474',
      () => HabotAvailabilityObjective.theThirdUnexpandedAbbreviation,
    );

  });

  group('GEN-05155 :: a place, not a position', () {
    gate(
      'GEN-05155-G5',
      'Location is a named service area from a list of four.',
      'A worker types where they can work, not where they are',
      () => HabotAvailabilityObjective.locationIsANamedArea,
    );

    gate(
      'GEN-05155-G6',
      'And Step 428\'s refusal of coordinate capture holds.',
      'Availability is not a tracking feed',
      () =>
          HabotAvailabilityObjective.theRowThatRefusedCoordinatesFirst == 428 &&
          HabotAvailabilityObjective
              .locationNote.contains('not a tracking feed'),
    );

  });

  group('GEN-05155 :: offered, never declined', () {
    gate(
      'GEN-05155-G7',
      'Two offered windows, and no unavailable-reason field.',
      'A rota that records gaps becomes a record of who refused work',
      () =>
          HabotAvailabilityObjective.offered.length == 2 &&
          HabotAvailabilityObjective.theShapeIsPositive,
    );

    gate(
      'GEN-05155-G8',
      'And no manager sees an availability percentage.',
      'Nobody is scored on how much of themselves they offered',
      () =>
          HabotAvailabilityObjective.nobodyIsScoredOnAvailability &&
          HabotAvailabilityObjective
              .availabilityNote.contains('who refused work'),
    );

    gate(
      'GEN-05155-G9',
      'Documented, unconfirmed, and no sign-off claimed.',
      'The third of the four rows in this batch waiting on a signature',
      () =>
          HabotAvailabilityObjective.theObjectiveIsDocumented &&
          !HabotAvailabilityObjective.aStakeholderHasConfirmed &&
          HabotAvailabilityObjective.itIsTheThirdRowAwaitingSignature,
    );

    gate(
      'GEN-05155-G10',
      'Five obligations met, and the row reports Partial.',
      'Which is what its own band says a documented but unconfirmed objective '
          'is',
      () =>
          HabotAvailabilityObjective.obligations.length == 5 &&
          HabotAvailabilityObjective.obligations.values.every((bool b) => b) &&
          HabotAvailabilityObjective.qualitativeOutput == 'Partial',
    );
  });

  tearDownAll(() {
    final int ambiguities = HabotAvailabilityObjective.ambiguities.length;
    final int areas = HabotAvailabilityObjective.serviceAreas.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05155',
        atomicStepReferenceId: 'GEN-05155',
        setupStepAction:
            'COLUMN NOTE: this row carries Step 453\'s band character for '
            'character, one of two rows in this batch whose band was first '
            'seen in the previous one; it leaves four phrases open -- LSA, '
            'service capabilities, locations and zero desktop dependency -- '
            'each recorded with a proposal and a named confirmer; "locations" '
            'is read as a named service area rather than a position, holding '
            'Batch P\'s refusal at Step 428; availability is stored as offered '
            'windows with no unavailable-reason field; and because its optimal '
            'requires a stakeholder it reports Partial. Atomic Step: "Review '
            'the step objective: build a touch-optimized interface allowing '
            'LSAs and therapists to set daily working hours, locations, and '
            'service capabilities with zero desktop dependency"',
        implementationOrder: 472,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Review the step objective: build a touch-optimized interface '
          'allowing LSAs':
              '$ambiguities ambiguities documented with proposals and named '
                  'confirmers, location read as one of $areas named service '
                  'areas rather than a position, and availability stored as '
                  'offered windows',
          'Completion Status': 'Partial',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Requirement/Objective Comprehension Completeness',
            observed:
                'PARTIAL, UNDER STEP 453\'S BAND. The optimal is "objective '
                'fully documented and stakeholder-confirmed"; the documenting '
                'is done here across $ambiguities recorded ambiguities and the '
                'confirming cannot be, because no stakeholder exists in this '
                'session. Reporting Complete would claim a sign-off that did '
                'not happen. Two rows in this batch carry bands first seen in '
                'the previous one, and this is the first of them.',
            floor: 'Partial understanding; unresolved ambiguities',
            optimal: 'Objective fully documented & stakeholder-confirmed',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Coordinates captured to record where somebody works',
            observed:
                '0. A worker chooses one of $areas named service areas, held '
                'only for the day it applies to, which holds the refusal Batch '
                'P made at Step 428: availability is not a tracking feed and '
                'nothing in this objective needs to know where anybody is. '
                'Availability is stored as offered windows with no '
                'unavailable-reason field, because a rota that records gaps '
                'becomes a record of who refused work.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/roster/availability_objective.dart',
        ],
      ),
    );
  });
}
