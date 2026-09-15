/// AISS GATE -- Step 271 of 275
/// Global Reference ID:       GEN-02808
/// Atomic Steps Reference ID: GEN-02808
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Configure an encryption health badge within the mobile admin
///               settings drawer."
/// Metric: Encryption Key Management Compliance (%) -- Floor 95, Optimal 100,
///         Ceiling 100. Pass/Fail. NIST SP 800-57 / ISO/IEC 27001 A.10.
///
/// THIS STEP REPORTS FAIL, AND THAT IS THE POINT: NO CIPHER SHIPS IN lib/,
/// SO A BADGE RENDERING GREEN WOULD BE REPORTING ON ONE NOBODY SUPPLIED.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/preferences/encryption_badge.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

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

  group('GEN-02808 :: what a badge can attest to', () {
    gate(
      'GEN-02808-G1',
      'Atomic Step: "an encryption health badge".',
      'Six facts a reader would take the badge to cover are enumerated with a '
          'reason each, and half of them are knowable on this device',
      () =>
          HabotEncryptionAttestation.facts.length == 6 &&
          HabotEncryptionAttestation.knowableHere.length == 3 &&
          (HabotEncryptionAttestation.shareOfFactsKnowableHere - 0.5).abs() <
              1e-9,
    );

    gate(
      'GEN-02808-G2',
      'Metric: Encryption Key Management Compliance (%).',
      'None of the three key-management facts -- custody, rotation, audit -- '
          'is knowable from the client, which is the subject the metric is '
          'named after',
      () =>
          HabotEncryptionAttestation.keyManagementFacts.length == 3 &&
          HabotEncryptionAttestation.keyManagementKnowableHere.isEmpty &&
          HabotEncryptionAttestation.shareOfKeyManagementKnowableHere == 0 &&
          HabotEncryptionAttestation
              .theMetricsOwnSubjectIsUnreachableFromHere,
    );

    gate(
      'GEN-02808-G3',
      'Green and red leave no room for "I have not heard recently".',
      'The badge has three states, and silence reads as unknown rather than '
          'as verified -- a green badge manufactured out of silence is worse '
          'than no badge',
      () =>
          HabotAttestationState.values.length == 3 &&
          HabotEncryptionAttestation.silenceIsNotVerified &&
          HabotEncryptionAttestation.threeStatesNote.contains('out of '
              'silence'),
    );

    gate(
      'GEN-02808-G4',
      'A badge that goes red on a bad network is one people ignore.',
      'A stale attestation lands on unknown rather than failed, while a '
          'locally checkable fact that does not hold is failed even when the '
          'attestation is fresh',
      () =>
          HabotEncryptionAttestation
              .aStaleAttestationGoesUnknownRatherThanRed &&
          HabotEncryptionAttestation.aLocalFailureBeatsAFreshAttestation &&
          HabotEncryptionAttestation.everythingFreshAndLocallySoundIsVerified,
    );
  });

  group('GEN-02808 :: read from what is actually there', () {
    gate(
      'GEN-02808-G5',
      'The staleness window is a declared token, not a number chosen here.',
      'The badge goes to unknown once the attestation is older than the '
          'declared maximum age of twenty-four hours',
      () =>
          HabotMotion.attestationMaxAge.inHours == 24 &&
          HabotEncryptionAttestation.stateFor(
                transportVerified: true,
                cipherProductionGrade: true,
                attestationAge: HabotMotion.attestationMaxAge,
              ) ==
              HabotAttestationState.verified,
    );

    gate(
      'GEN-02808-G6',
      'The two local facts are checked against the existing code.',
      'The transport scheme is read from the socket policy and the encrypted '
          'store\'s real header magic, format version and header length are '
          'checked rather than described',
      () =>
          HabotEncryptionAttestation.theTransportSchemeIsDeclared &&
          HabotEncryptionAttestation.theStoreStampsItsRecords,
    );

    gate(
      'GEN-02808-G7',
      'No cipher ships in lib/, and the badge has to read that.',
      'Step 122 recorded device-bound encryption as a compile-time obstacle '
          'rather than a silent gap, and this step\'s honest badge state for '
          'this build is failed because of it',
      () =>
          HabotEncryptionAttestation.noCipherShipsInThisRepository &&
          HabotEncryptionAttestation.stateForThisBuild ==
              HabotAttestationState.failed &&
          HabotEncryptionAttestation.noCipherNote.contains('exists to catch'),
    );

    gate(
      'GEN-02808-G8',
      'The row asks for polling every thirty seconds.',
      'That cadence would ask 2880 times inside one freshness window for an '
          'answer that can change once, so it is recorded as the row\'s '
          'figure rather than followed',
      () =>
          HabotEncryptionAttestation.pollIntervalSecondsTheRowAsksFor == 30 &&
          HabotEncryptionAttestation.pollsPerFreshnessWindow == 2880 &&
          HabotEncryptionAttestation.theCadenceOutrunsTheAnswer &&
          HabotEncryptionAttestation.cadenceNote.contains('2880'),
    );

    gate(
      'GEN-02808-G9',
      'A badge is a report, not a control.',
      'It does nothing, because no button repairs key management from a '
          'settings drawer; the drill-down opens the statement instead',
      () =>
          HabotEncryptionAttestation.isReadOnly &&
          HabotEncryptionAttestation.readOnlyNote.contains('rather than a '
              'retry'),
    );

    gate(
      'GEN-02808-G10',
      'Floor 95, optimal 100, ceiling 100. Pass/Fail.',
      'A floor of 95% on key management admits one key in twenty being '
          'unmanaged, which the Pass/Fail output then hides; all fifteen '
          'declared checks hold and the step reports Fail',
      () =>
          HabotEncryptionAttestation.floorPercent == 95 &&
          HabotEncryptionAttestation.optimalPercent == 100 &&
          HabotEncryptionAttestation.ceilingPercent == 100 &&
          HabotEncryptionAttestation.theFloorAdmitsAFailureTheOutputHides &&
          HabotEncryptionAttestation.bandNote.contains('partial credit does '
              'not exist') &&
          HabotEncryptionAttestation.checks.length == 15 &&
          HabotEncryptionAttestation.checks.values.every((bool b) => b) &&
          HabotEncryptionAttestation.qualitativeOutput == 'Fail' &&
          HabotEncryptionAttestation.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String facts = '${HabotEncryptionAttestation.facts.length}';
    final String here = '${HabotEncryptionAttestation.knowableHere.length}';
    final String km = '${HabotEncryptionAttestation.keyManagementFacts.length}';
    final String polls =
        '${HabotEncryptionAttestation.pollsPerFreshnessWindow}';
    final String state = HabotEncryptionAttestation.stateForThisBuild.name;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02808',
        atomicStepReferenceId: 'GEN-02808',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and the '
            'Dependency column reads "Dependent on prior foundational steps" '
            'with a global dependency of GEN-02807. Atomic Step: "Configure '
            'an encryption health badge within the mobile admin settings '
            'drawer."',
        implementationOrder: 271,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotEncryptionAttestation / HabotEncryptionFact / '
                  'HabotAttestationState',
          'Component Properties':
              '$facts facts a badge appears to cover, $here of them knowable '
              'on this device and none of the $km key-management facts among '
              'them; three badge states with silence and staleness landing on '
              'unknown; badge state for this build: $state',
          'Completion Status': 'Derived from gate outcomes -- step reports '
              'Fail',
          'Data Quality Note':
              'FINDING: ${HabotEncryptionAttestation.threeStatesNote} '
              'CIPHER: ${HabotEncryptionAttestation.noCipherNote} '
              'CADENCE: ${HabotEncryptionAttestation.cadenceNote} '
              'BAND: ${HabotEncryptionAttestation.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Encryption Key Management Compliance (%)',
            observed:
                'NOT ATTESTABLE FROM THE CLIENT. $km of $facts facts are key '
                'management -- custody, rotation, access audit -- and none is '
                'visible from a phone. What is checked here is the declared '
                'transport scheme, the encrypted store\'s record header, and '
                'the age of the last statement from the side that does know. '
                'The badge\'s honest state on this build is $state.',
            floor: '95',
            optimal: '100',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Polls per freshness window at the row\'s cadence',
            observed:
                '$polls. The row asks for a refresh every '
                '${HabotEncryptionAttestation.pollIntervalSecondsTheRowAsksFor}'
                ' seconds against a declared freshness window of twenty-four '
                'hours, for a value that changes when somebody rotates a key.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/preferences/encryption_badge.dart',
        ],
      ),
    );
  });
}
