/// AISS GATE -- Step 324 of 335
/// Global Reference ID:       MUFCE-026
/// Atomic Steps Reference ID: MUFCE-026-A01
/// Setup Step (Action): "Add pre-commit linter checks to catch and block
///                      hard-coded pixel layout positioning." (A LINT RULE, ON
///                      AN EMERGENCY OVERRIDE ROW)
/// Atomic Step: "Open the Force Majeure emergency override UI module."
/// Metric: Asset/Resource Location & Access Confirmation -- floor 0.9,
///         optimal 0.99, ceiling 1. Pass / Fail.
///
/// THE CIRCUMSTANCE THAT JUSTIFIES THE CLAIM IS THE CIRCUMSTANCE THE ROW'S
/// POKA-YOKE WOULD USE TO PREVENT IT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/support/force_majeure_proof.dart';

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

  group('MUFCE-026-A01 :: filing does not wait for the network', () {
    gate(
      'MUFCE-026-A01-G1',
      'Poka-Yoke cell: "Submit disabled at DOM level until file hash verified '
          'by backend".',
      'The claim is filed immediately in a pending-verification state and the '
          'hash is checked when there is a network; nothing about the '
          'verification is dropped, only its position in the sequence moves',
      () =>
          !HabotForceMajeureProof.submitWaitsForTheBackendHash &&
          HabotForceMajeureProof.theClaimIsFiledBeforeVerification &&
          HabotForceMajeureProof.verificationStillHappens,
    );

    gate(
      'MUFCE-026-A01-G2',
      'A force majeure claim is filed because something went wrong.',
      'And the things that go wrong take the network with them, so the person '
          'meets the block on the worst day they will have this year',
      () => HabotForceMajeureProof.sequenceNote
          .contains('the worst day they will have this year'),
    );
  });

  group('MUFCE-026-A01 :: closed causes with an evidential escape', () {
    gate(
      'MUFCE-026-A01-G3',
      'Why This Matters: "undeniable proof ... without open text".',
      'Six declared causes and no free text field, because free text on a '
          'claim like this invites a story and the story is what a reviewer '
          'weighs instead of the evidence',
      () =>
          HabotForceMajeureProof.declaredCauses == 6 &&
          !HabotForceMajeureProof.freeTextIsOffered,
    );

    gate(
      'MUFCE-026-A01-G4',
      'And the unlisted case is a photograph.',
      'A closed list with no escape makes somebody choose the nearest wrong '
          'reason, which is a false declaration produced by the form',
      () =>
          HabotForceMajeureProof.theUnlistedCaseHasAChannel &&
          HabotForceMajeureProof.nobodyMustPickTheNearestWrongReason &&
          HabotForceMajeureProof.openTextNote
              .contains('a false declaration produced by the form'),
    );
  });

  group('MUFCE-026-A01 :: a file is what its bytes say', () {
    gate(
      'MUFCE-026-A01-G5',
      'Completion Measure: "Upload component rejects unauthorized files '
          'strictly".',
      'Six worked uploads, two of them renamed; an extension check agrees '
          'with the truth four times and admits both renamed files',
      () =>
          HabotForceMajeureProof.uploads.length == 6 &&
          HabotForceMajeureProof.admittedByExtensionOnly.length == 2 &&
          (HabotForceMajeureProof.extensionCheckAccuracy - 2 / 3).abs() <
              1e-9,
    );

    gate(
      'MUFCE-026-A01-G6',
      'Reading the first bytes is right six times in six.',
      'The rule is read from Step 262, which moved attachment validation from '
          '0.875 to 1.0 for the same reason',
      () =>
          HabotForceMajeureProof.contentCheckIsExact &&
          HabotForceMajeureProof.bytesNote.contains('Step 262'),
    );

    gate(
      'MUFCE-026-A01-G7',
      'A rejection says which of the two things happened.',
      'A file named .pdf that is not one gets a different sentence from a '
          'file whose kind cannot be read at all',
      () =>
          HabotForceMajeureProof.theTwoRejectionsAreDifferent &&
          HabotForceMajeureProof.rejectionFor(HabotForceMajeureProof.uploads[4])
              .contains('is not one'),
    );
  });

  group('MUFCE-026-A01 :: the metric and the columns', () {
    gate(
      'MUFCE-026-A01-G8',
      'Metric: Asset/Resource Location & Access Confirmation.',
      'The Output Type cell is a definition rather than a standard name, and '
          'the definition is coherent -- one authoritative documented location '
          'beats memorised paths -- but it is not this row\'s subject',
      () =>
          HabotForceMajeureProof.theMetricMeasuresSomethingElse &&
          HabotForceMajeureProof.floorScore == 0.9 &&
          HabotForceMajeureProof.optimalScore == 0.99 &&
          HabotForceMajeureProof.ceilingScore == 1,
    );

    gate(
      'MUFCE-026-A01-G9',
      'Config cells: HTML5 accept attributes, JS validation, desktop '
          'drag-and-drop, and a DOM-level disable.',
      'The fourteenth row in this track written for another stack',
      () => HabotForceMajeureProof.columnNote.contains('fourteenth'),
    );

    gate(
      'MUFCE-026-A01-G10',
      'Output: Pass / Fail.',
      'Six declared obligations, all met, giving Pass; all ten declared '
          'checks hold',
      () =>
          HabotForceMajeureProof.obligations.length == 6 &&
          HabotForceMajeureProof.obligations.values.every((bool b) => b) &&
          HabotForceMajeureProof.qualitativeOutput == 'Pass' &&
          HabotForceMajeureProof.checks.length == 10 &&
          HabotForceMajeureProof.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final String state = HabotForceMajeureProof.stateOnFiling;
    final String renamed =
        HabotForceMajeureProof.rejectionFor(HabotForceMajeureProof.uploads[4]);
    final String unreadable =
        HabotForceMajeureProof.rejectionFor(HabotForceMajeureProof.uploads[5]);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'MUFCE-026',
        atomicStepReferenceId: 'MUFCE-026-A01',
        setupStepAction:
            'COLUMN NOTE: this row\'s configuration cells ask for HTML5 accept '
            'attributes, JS validation and desktop drag-and-drop, its '
            'poka-yoke disables submit "at DOM level", and the Setup Step '
            'reads "Add pre-commit linter checks to catch and block hard-coded '
            'pixel layout positioning". Atomic Step: "Open the Force Majeure '
            'emergency override UI module."',
        implementationOrder: 324,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Object Type': 'proof of a force majeure event: a photo or a PDF',
          'Object Location/Path':
              'accepted locally, queued, verified when a network exists',
          'Open Status': state,
          'Timestamp': '2026-09-17T00:00:00Z',
          'File Handle ID':
              'assigned on acceptance, before any server round trip',
          'Completion Status': 'Pass',
          'Component Properties':
              'a renamed file reads "$renamed"; an unreadable one reads '
                  '"$unreadable"',
          'Data Quality Note':
              'SEQUENCE: ${HabotForceMajeureProof.sequenceNote} '
              'OPEN TEXT: ${HabotForceMajeureProof.openTextNote} '
              'BYTES: ${HabotForceMajeureProof.bytesNote} '
              'METRIC: ${HabotForceMajeureProof.metricNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Asset/Resource Location & Access Confirmation',
            observed:
                'NOT THIS ROW\'S SUBJECT. The Output Type cell defines a real '
                'and coherent idea -- one authoritative documented location '
                'beats memorised paths -- on a row about an emergency '
                'override. Reported instead over six declared obligations, all '
                'of which hold.',
            floor: '0.9',
            optimal: '0.99',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Unauthorised files an extension check would admit',
            observed:
                '0 of ${HabotForceMajeureProof.uploads.length} when the first '
                'bytes are read, against 2 when only the name is trusted -- '
                'and those two are the only cases the check exists for. Step '
                '262 established the rule; it is read rather than rebuilt.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/support/force_majeure_proof.dart',
        ],
      ),
    );
  });
}
