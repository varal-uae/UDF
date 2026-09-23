/// AISS GATE -- Step 457 of 1,314
/// Global Reference ID:       GEN-04792
/// Atomic Steps Reference ID: GEN-04792
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Confirm the expected output is achieved and mark Sequence
///               Order 11 complete: Fully tested biometric re-entry wrapper
///               with PIN fallback."
/// Metric: Milestone Sign-off / Definition-of-Done Compliance -- floor "100% of
///         stated acceptance criteria verified before sign-off", optimal "100%
///         verified, formally signed off by the accountable owner", ceiling
///         "100% (sign-off is binary; cannot exceed complete)". Best
///         Qualitative Output: "Complete / Partial / Not Complete". Scrum.org
///         Definition of Done / PMI PMBOK Milestone Acceptance practice.
///         Assigned to **DEA**.
///
/// THE FIRST OF FOUR ROWS WHOSE BEST POSSIBLE OUTCOME IS A SIGNATURE NOBODY
/// HERE CAN GIVE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/governance/biometric_signoff.dart';

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

  group('GEN-04792 :: verified, unsigned', () {
    gate(
      'GEN-04792-G1',
      'Five acceptance criteria, all verified.',
      'The floor of this band is work, and the work is done',
      () =>
          HabotBiometricSignoff.acceptanceCriteria.length == 5 &&
          HabotBiometricSignoff.everyCriterionIsVerified,
    );

    gate(
      'GEN-04792-G2',
      'And no accountable owner has signed.',
      'The optimal of this band is a person\'s act',
      () =>
          !HabotBiometricSignoff.anAccountableOwnerHasSigned &&
          !HabotBiometricSignoff.aSignatureIsClaimed,
    );

    gate(
      'GEN-04792-G3',
      'Four rows in this batch wait on the same signature.',
      'Steps 457, 463, 472 and 475, none of them naming an owner',
      () =>
          HabotSignoffLedger.count == 4 &&
          HabotSignoffLedger.nobodyIsNamed &&
          HabotBiometricSignoff.theFirstRowAwaitingSignature,
    );

  });

  group('GEN-04792 :: a number from a sheet that does not exist', () {
    gate(
      'GEN-04792-G4',
      '"Sequence Order 11" is not this sheet\'s numbering.',
      'This row sits at sequence 21,501 of 1,314 matched rows',
      () =>
          HabotBiometricSignoff.theNamedSequenceIsNotThisSheets &&
          HabotBiometricSignoff.threeSuchRows,
    );

  });

  group('GEN-04792 :: the PIN is not a fallback', () {
    gate(
      'GEN-04792-G5',
      'The PIN is reachable before any biometric failure.',
      'A route offered only after the preferred one fails costs time when '
          'there is none',
      () => HabotBiometricSignoff.thePinIsReachableFromTheStart,
    );

    gate(
      'GEN-04792-G6',
      'Three sensor failures fall back rather than lock out.',
      'The limit applies to the sensor, not to the person',
      () =>
          HabotBiometricSignoff.failuresFallBackRatherThanLockOut &&
          HabotBiometricSignoff
              .pinNote.contains('rather than stopping the person'),
    );

  });

  group('GEN-04792 :: nothing that could rebuild a face', () {
    gate(
      'GEN-04792-G7',
      'The wrapper receives a yes or a no from the enclave.',
      'Nothing that could reconstruct a fingerprint or a face',
      () => HabotBiometricSignoff.nothingReconstructableIsStored,
    );

    gate(
      'GEN-04792-G8',
      'And nothing is backed up.',
      'A template that leaves the device is a template somebody keeps',
      () =>
          !HabotBiometricSignoff.templateIsBackedUp &&
          !HabotBiometricSignoff.templateLeavesTheDevice,
    );

    gate(
      'GEN-04792-G9',
      'Accessibility services skip the wrapper.',
      'A re-entry gate that fights a screen reader locks out the people it '
          'should not',
      () => HabotBiometricSignoff.theWrapperIsSkippedForAccessibilityServices,
    );

    gate(
      'GEN-04792-G10',
      'Five obligations met, and the row reports Partial.',
      'Verified is not signed, and claiming otherwise would be a lie',
      () =>
          HabotBiometricSignoff.obligations.length == 5 &&
          HabotBiometricSignoff.obligations.values.every((bool b) => b) &&
          HabotBiometricSignoff.qualitativeOutput == 'Partial',
    );
  });

  tearDownAll(() {
    final int criteria = HabotBiometricSignoff.acceptanceCriteria.length;
    final int waiting = HabotSignoffLedger.count;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04792',
        atomicStepReferenceId: 'GEN-04792',
        setupStepAction:
            'COLUMN NOTE: this row\'s floor is reachable and its optimal is a '
            'human signature, so with every acceptance criterion verified and '
            'no owner named it reports Partial -- the first of four rows in '
            'this batch that stop there for the same reason; its instruction '
            'points at "Sequence Order 11", a number from a local list this '
            'sheet does not contain, as Steps 459 and 466 do; and its subject '
            'is built so the PIN is a first-class route rather than a fallback '
            'and no biometric template leaves the device. Atomic Step: '
            '"Confirm the expected output is achieved and mark Sequence Order '
            '11 complete: Fully tested biometric re-entry wrapper with PIN '
            'fallback."',
        implementationOrder: 457,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Confirm the expected output is achieved and mark Sequence Order':
              '$criteria acceptance criteria verified and no owner named; '
                  '$waiting rows in this batch wait on the same signature',
          'Completion Status': 'Partial',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Milestone Sign-off / Definition-of-Done Compliance',
            observed:
                'PARTIAL. The floor of this band -- every stated acceptance '
                'criterion verified before sign-off -- is work, and $criteria '
                'of $criteria are verified. The optimal adds a formal '
                'signature from an accountable owner, which is a person\'s act '
                'and cannot happen in this session. Reporting Complete would '
                'claim a sign-off that did not occur. $waiting rows in this '
                'batch stop here for the same reason, and one list of named '
                'owners closes all four.',
            floor:
                '100% of stated acceptance criteria verified before sign-off',
            optimal:
                '100% verified, formally signed off by the accountable owner',
            ceiling: '100% (sign-off is binary; cannot exceed complete)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Biometric templates leaving the device',
            observed:
                '0. The wrapper receives a yes or a no from the platform '
                'enclave; nothing that could reconstruct a fingerprint or a '
                'face is stored, transmitted or backed up. The PIN is offered '
                'alongside the sensor from the start rather than after it '
                'fails, because somebody wearing gloves, with a cut finger, or '
                'holding a child cannot present a fingerprint.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/governance/biometric_signoff.dart',
        ],
      ),
    );
  });
}
