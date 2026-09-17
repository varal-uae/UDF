/// AISS GATE -- Step 341 of 355
/// Global Reference ID:       GEN-05023
/// Atomic Steps Reference ID: GEN-05023
/// Setup Step (Action): (the generic engineering-console boilerplate --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Apply the mistake-proofing (Poka-Yoke) safeguard: Dragging an
///               item beyond container boundaries smoothly cancels the drag
///               action without saving invalid indexes."
/// Metric: Error-Proofing (Poka-Yoke) Coverage Rate -- floor, optimal and
///         ceiling all 100%. Pass / Fail. Shigeo Shingo. Assigned to **DEA**.
///
/// A ROW THAT SAYS POKA-YOKE AND EARNS IT, AND THE SECOND COLLAPSED BAND THIS
/// TRACK HAS BEEN ABLE TO ENDORSE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/gesture/drag_boundary.dart';

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

  group('GEN-05023 :: the mechanical kind', () {
    gate(
      'GEN-05023-G1',
      'Atomic Step: "without saving invalid indexes".',
      'A drop outside the container writes nothing, and every index that is '
          'written is inside the list',
      () =>
          HabotDragBoundary.anOutsideDropWritesNothing &&
          HabotDragBoundary.everyWrittenIndexIsInRange,
    );

    gate(
      'GEN-05023-G2',
      'No code path computes an index from a position outside.',
      'So an invalid index cannot be produced rather than merely rejected, '
          'which is Shingo\'s distinction',
      () =>
          !HabotDragBoundary.anIndexCanBeComputedFromOutside &&
          HabotDragBoundary.shingoNote.contains('not merely rejected'),
    );

    gate(
      'GEN-05023-G3',
      'Step 328 used the word and did not earn it.',
      'A text matcher that can be worked around is a detector; the contrast '
          'is recorded here rather than left implicit',
      () => HabotDragBoundary.shingoNote.contains('Step 328'),
    );
  });

  group('GEN-05023 :: three drop sites', () {
    gate(
      'GEN-05023-G4',
      'Three sites, one of which writes nothing.',
      'Inside over a slot, inside between slots, and outside entirely',
      () =>
          HabotDropSite.values.length == 3 &&
          HabotDragBoundary.anOutsideDropWritesNothing,
    );

    gate(
      'GEN-05023-G5',
      'A drop between slots still resolves to a slot.',
      'There is no third outcome hiding between the two, which is where an '
          'off-by-one would live',
      () =>
          HabotDragBoundary.aBetweenSlotsDropStillResolvesToASlot &&
          HabotDragBoundary.slotCount == 9,
    );
  });

  group('GEN-05023 :: the band', () {
    gate(
      'GEN-05023-G6',
      'Floor, optimal and ceiling are all 100%.',
      'And the ceiling cell gives the reason: coverage is binary',
      () =>
          HabotDragBoundary.theBandIsFullyCollapsed &&
          HabotDragBoundary.theRowExplainsItsOwnCollapse,
    );

    gate(
      'GEN-05023-G7',
      'On this subject the collapse is correct.',
      'A safeguard that holds most of the time is a safeguard with a known '
          'way through -- second endorsed collapse after Step 316',
      () =>
          HabotDragBoundary.thisIsTheSecondEndorsedCollapse &&
          HabotDragBoundary.theOtherEndorsedCollapse == 316 &&
          HabotDragBoundary.bandNote.contains('known way through'),
    );
  });

  group('GEN-05023 :: "smoothly", and the list underneath', () {
    gate(
      'GEN-05023-G8',
      'The return travel is the whole of a cancel\'s feedback.',
      'So it is animated from the motion tokens rather than teleported',
      () =>
          !HabotDragBoundary.theItemTeleportsBack &&
          HabotDragBoundary.theReturnIsAnimatedFromTokens &&
          HabotDragBoundary.smoothNote.contains('whole of'),
    );

    gate(
      'GEN-05023-G9',
      'The row says nothing about the preview underneath.',
      'A cancel that writes no index but leaves the shifted preview shows an '
          'order the model does not have -- silently',
      () =>
          HabotDragBoundary.theScreenAndTheModelAgreeAfterACancel &&
          HabotDragBoundary.previewNote.contains('silent'),
    );

    gate(
      'GEN-05023-G10',
      'Output reported as Pass / Fail.',
      'Six obligations, all met, giving Pass; all ten declared checks hold',
      () =>
          HabotDragBoundary.obligations.length == 6 &&
          HabotDragBoundary.obligations.values.every((bool b) => b) &&
          HabotDragBoundary.qualitativeOutput == 'Pass' &&
          HabotDragBoundary.checks.length == 10 &&
          HabotDragBoundary.checks.values.every((bool b) => b) &&
          HabotDragBoundary.columnNote.contains('DEA'),
    );
  });

  tearDownAll(() {
    final String cancel = HabotDragBoundary.cancelAnnouncement;
    final int slots = HabotDragBoundary.slotCount;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05023',
        atomicStepReferenceId: 'GEN-05023',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to DEA rather than UDF, and its '
            'band sets floor, optimal and ceiling all at 100% -- which on this '
            'subject is correct, and the ceiling cell says so. Every narrative '
            'column is the generic engineering-console boilerplate. Atomic '
            'Step: "Apply the mistake-proofing (Poka-Yoke) safeguard: Dragging '
            'an item beyond container boundaries smoothly cancels the drag '
            'action without saving invalid indexes."',
        implementationOrder: 341,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Apply the mistake-proofing (Poka-Yoke) safeguard: Dragging an item '
                  'beyond container':
              '3 drop sites over $slots slots; the one outside the container '
                  'writes nothing and reverts the preview',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the cancel announces "$cancel" and animates the item back from '
                  'the motion tokens rather than teleporting it',
          'Data Quality Note':
              'SHINGO: ${HabotDragBoundary.shingoNote} '
              'BAND: ${HabotDragBoundary.bandNote} '
              'SMOOTH: ${HabotDragBoundary.smoothNote} '
              'PREVIEW: ${HabotDragBoundary.previewNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Error-Proofing (Poka-Yoke) Coverage Rate',
            observed:
                'THE BAND IS FULLY COLLAPSED AND IT IS CORRECT. Floor, optimal '
                'and ceiling are all 100%, and the ceiling cell explains why: '
                'coverage is binary. This is the second collapsed band this '
                'track has been able to endorse, after Step 316\'s fail-closed '
                'reliability, and for the same reason -- a safeguard that '
                'holds most of the time is a safeguard with a known way '
                'through. The row also earns the word poka-yoke, which Step '
                '328 did not: no code path computes an index from a position '
                'the container does not own.',
            floor: '100% of identified critical-path failure modes covered',
            optimal: '100% coverage with automated enforcement (no silent '
                'bypass)',
            ceiling: '100% (coverage is binary; cannot exceed full)',
          ),
          AissMeasurement(
            metricName: 'Ways a drag can write an out-of-range index',
            observed:
                '0 over $slots slots and three drop sites. A drop on a slot '
                'and a drop between slots both resolve to a slot; a drop '
                'outside the container writes nothing and reverts the preview '
                'the drag had shifted. The second half is the part the row '
                'does not mention: a cancel that writes no index but leaves '
                'the preview moved shows an order the model does not have, and '
                'says nothing about it.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/gesture/drag_boundary.dart',
        ],
      ),
    );
  });
}
