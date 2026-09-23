/// AISS GATE -- Step 495 of 1,314
/// Global Reference ID:       GEN-05419
/// Atomic Steps Reference ID: GEN-05419
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Document the completed configuration, mark the step as done in
///               the project tracker, and obtain sign-off to proceed to the
///               next step"
/// Metric: Documentation & Sign-off Completeness -- floor "Undocumented / no
///         sign-off obtained", optimal "Fully documented in tracker with
///         stakeholder sign-off", ceiling "1". Best Qualitative Output:
///         "Complete/Partial/Not Complete". PMBOK 7th Ed. - Project Closing
///         Process Group. Assigned to **PDG**.
///
/// STEP 475 AGAIN, TWENTY ROWS AND ONE BATCH LATER, AND A LEDGER THAT REOPENS
/// AT FIVE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/release/release_signoff.dart';

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

  group('GEN-05419 :: the same row, across a batch boundary', () {
    gate(
      'GEN-05419-G1',
      'Eight cells are identical to Step 475\'s.',
      'Instruction, team, metric, three band values, output column and '
      'standard',
      () =>
          HabotReleaseSignoff.eightCellsAreIdentical &&
          HabotReleaseSignoff.theRowThisRepeats == 475,
    );

    gate(
      'GEN-05419-G2',
      'Twenty rows apart, across a batch boundary.',
      'Steps 458 and 465 were seven rows apart inside one batch',
      () =>
          HabotReleaseSignoff.rowsBetween == 20 &&
          HabotReleaseSignoff.theFirstAcrossBatches,
    );

    gate(
      'GEN-05419-G3',
      'So the duplicate register has to span batches.',
      'Which is a different kind of register from the one that was opened',
      () =>
          HabotReleaseSignoff.theSecondInstructionPair &&
          HabotReleaseSignoff.registerNote
              .contains('different kind ' 'of register'),
    );

  });

  group('GEN-05419 :: three asked, two measured, still', () {
    gate(
      'GEN-05419-G4',
      'Three actions asked for and two measured.',
      'Document, mark done, obtain sign-off',
      () =>
          HabotReleaseSignoff.threeActionsAreAskedFor &&
          HabotReleaseSignoff.onlyTwoAreMeasured,
    );

    gate(
      'GEN-05419-G5',
      'And the unmeasured one is still the one people read.',
      'A step marked done is read downstream as a step that works',
      () => HabotReleaseSignoff.theUnmeasuredOneIsStillTheOneThatMatters,
    );

  });

  group('GEN-05419 :: the ledger reopens', () {
    gate(
      'GEN-05419-G6',
      'The ledger was four rows at the end of the last batch.',
      'Steps 457, 463, 472 and 475',
      () => HabotReleaseSignoff.itWasFourAtTheEndOfTheLastBatch,
    );

    gate(
      'GEN-05419-G7',
      'And is five now.',
      'Because this row cannot be signed either',
      () => HabotReleaseSignoff.theLedgerNowSpansTwoBatches,
    );

    gate(
      'GEN-05419-G8',
      'Because nobody was named.',
      'It did not get worse from anything built here; nothing happened',
      () =>
          !HabotReleaseSignoff.anOwnerWasNamedSinceStep475 &&
          HabotReleaseSignoff.ledgerNote.contains('nothing happened'),
    );

  });

  group('GEN-05419 :: what this batch documents', () {
    gate(
      'GEN-05419-G9',
      'Twenty library files, twenty evidence files, two hundred gates.',
      'Which is what "the completed configuration" amounts to',
      () => HabotReleaseSignoff.theConfigurationIsDocumented,
    );

    gate(
      'GEN-05419-G10',
      'Five obligations met, harness rebuilt, and the row reports Partial.',
      'Two of three actions done, and the third is a person\'s act',
      () =>
          HabotReleaseSignoff.obligations.length == 5 &&
          HabotReleaseSignoff.obligations.values.every((bool b) => b) &&
          HabotReleaseSignoff.harnessNote.contains('previous nineteen used') &&
          HabotReleaseSignoff.qualitativeOutput == 'Partial',
    );
  });

  tearDownAll(() {
    final int ledger = HabotReleaseSignoff.ledgerSize;
    final int gatesTotal = HabotReleaseSignoff.gates;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05419',
        atomicStepReferenceId: 'GEN-05419',
        setupStepAction:
            'COLUMN NOTE: this row is Step 475 character for character twenty '
            'rows later, the second instruction-identical pair in the track '
            'after Steps 458 and 465 and the first to cross a batch boundary, '
            'so the duplicate register has to span batches; it asks for three '
            'things and its band still measures two, leaving the marking of a '
            'step as done unscored; and the signature ledger that closed at '
            'four rows reopens at five, because no accountable owner has been '
            'named since Step 475, so the row reports Partial. Atomic Step: '
            '"Document the completed configuration, mark the step as done in '
            'the project tracker, and obtain sign-off to proceed to the next '
            'step"',
        implementationOrder: 495,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Document the completed configuration, mark the step as done in':
              'twenty library files, twenty evidence files and $gatesTotal '
              'gates documented and the sheet re-marked; the signature ledger '
              'reopens at $ledger rows, none of them named',
          'Completion Status': 'Partial',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Documentation & Sign-off Completeness',
            observed:
                'PARTIAL, AND THE LEDGER REOPENS AT $ledger. This row is Step '
                '475 character for character twenty rows later, the second '
                'instruction-identical pair in the track after Steps 458 and '
                '465 and the first to cross a batch boundary, so the duplicate '
                'register has to span batches. It asks for three things and '
                'its band still measures two. Step 475 closed with four rows '
                'awaiting a signature and the remark that one list of named '
                'owners would clear them; nobody was named, so this is the '
                'fifth.',
            floor: 'Undocumented / no sign-off obtained',
            optimal: 'Fully documented in tracker with stakeholder sign-off',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Rows awaiting a named accountable owner',
            observed:
                '$ledger, across two batches. The build can verify acceptance '
                'criteria; it cannot sign. This batch documents twenty library '
                'files, twenty evidence files and $gatesTotal gates, and was '
                'produced after the build workspace was reclaimed, so the '
                'generator, the verifiers and the sweep were rebuilt from the '
                'repository itself before any of it was written -- the first '
                'batch in the track produced without the tooling the previous '
                'nineteen used.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/release/release_signoff.dart',
        ],
      ),
    );
  });
}
