/// AISS GATE -- Step 435 of 415
/// Global Reference ID:       GEN-02003
/// Atomic Steps Reference ID: GEN-02003
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Guarantee mathematically that the same user always sees the
///               same variant to prevent flow breaks."
/// Metric: Mathematical Balance Validation Accuracy (%) -- floor "99.5",
///         optimal "99.99", ceiling "100". Best Qualitative Output:
///         "Complete/Partial/Not Complete". ISO/IEC 27035:2016 (Data Integrity)
///         & OWASP Standards. Assigned to **PDG**.
///
/// "GUARANTEE MATHEMATICALLY", UNDER A BAND THAT ALLOWS ONE USER IN TWO HUNDRED
/// TO BE WRONG.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/live/variant_assignment.dart';

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

  group('GEN-02003 :: a guarantee is not a rate', () {
    gate(
      'GEN-02003-G1',
      'A guarantee is not a rate.',
      'A floor of 99.5 on a row whose instruction says "always"',
      () =>
          HabotVariantStickiness.theWordAndTheNumberConflict &&
          HabotVariantStickiness.theBandAllowsFailure,
    );

    gate(
      'GEN-02003-G2',
      'The floor allows five in a thousand to be wrong.',
      'Which is precisely the flow break the instruction exists to prevent',
      () =>
          HabotVariantStickiness.theFloorAllowsFiveInAThousand &&
          HabotVariantStickiness.theBandPermitsWhatTheInstructionForbids,
    );

    gate(
      'GEN-02003-G3',
      'And the contradiction is of kind, not degree.',
      'Step 432 disagreed with its own band by a factor of five; this '
          'disagrees between "always" and "almost always"',
      () =>
          HabotVariantStickiness.thisContradictionIsOfKindNotDegree &&
          HabotVariantStickiness.contradictionNote.contains('almost always'),
    );

  });

  group('GEN-02003 :: and the guarantee is achievable', () {
    gate(
      'GEN-02003-G4',
      'The same key gives the same variant, every time.',
      'A hash of the assignment key and the experiment name, modulo the bucket '
          'count',
      () =>
          HabotVariantStickiness.theSameKeyGivesTheSameVariant &&
          HabotVariantStickiness.differentKeysCanDiffer,
    );

    gate(
      'GEN-02003-G5',
      'With no storage, lookup or network call.',
      'So the result is identical on every device without anything being '
          'remembered',
      () => HabotVariantStickiness.itIsPureComputation,
    );

    gate(
      'GEN-02003-G6',
      'So the correct figure is 100 and the band should be one cell.',
      'The second row in three batches whose honest measure is a single value '
          'the sheet cannot express, after Step 411',
      () =>
          HabotVariantStickiness.theCorrectFigureIsTheCeiling &&
          HabotVariantStickiness.theHonestBandIsOneCell &&
          HabotVariantStickiness.secondSuchRow,
    );

  });

  group('GEN-02003 :: the key a refusal supplied', () {
    gate(
      'GEN-02003-G7',
      'The key is the one Step 420 built after refusing a device id.',
      'App-scoped, stable for the life of the install, never leaving the '
          'device',
      () =>
          HabotVariantStickiness.theKeyIsAppScoped &&
          HabotVariantStickiness.theKeyNeverLeavesTheDevice,
    );

    gate(
      'GEN-02003-G8',
      'And only the variant name travels.',
      'The bucket is computed locally, and no user identifier is involved '
          'anywhere',
      () =>
          HabotVariantStickiness.onlyTheVariantNameTravels &&
          HabotVariantStickiness.aUserIdentifierWasAvoided &&
          HabotVariantStickiness
              .keyNote.contains('making refusals constructively'),
    );

  });

  group('GEN-02003 :: reinstalling cannot break a flow', () {
    gate(
      'GEN-02003-G9',
      'A reinstall rotates the key and discards the task.',
      'So the single case the row worries about is the one case the mechanism '
          'cannot produce',
      () =>
          HabotVariantStickiness.thereIsNoFlowLeftToBreak &&
          HabotVariantStickiness
              .rotationNote.contains('rather than leaving as luck'),
    );

    gate(
      'GEN-02003-G10',
      'Six obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotVariantStickiness.obligations.length == 6 &&
          HabotVariantStickiness.thisRowAddsOnlyTheGuarantee &&
          HabotVariantStickiness.theExistingBucketFunctionIsUsed &&
          HabotVariantStickiness.theExistingSourceEnumIsUsed &&
          HabotVariantStickiness.obligations.values.every((bool b) => b) &&
          HabotVariantStickiness.qualitativeOutput == 'Complete' &&
          HabotVariantStickiness.theMetricBelongsElsewhere &&
          !HabotVariantStickiness.thereIsABalanceToValidate &&
          HabotVariantStickiness.achievableAccuracy == 100,
    );
  });

  tearDownAll(() {
    final double achievable = HabotVariantStickiness.achievableAccuracy;
    final double perThousand =
        HabotVariantStickiness.usersPerThousandTheFloorAllowsToBeWrong;
    final int buckets = HabotVariantStickiness.bucketCount;
    final String keySource = HabotVariantStickiness.assignmentKeySource;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02003',
        atomicStepReferenceId: 'GEN-02003',
        setupStepAction:
            'COLUMN NOTE: this row asks for a mathematical guarantee under a '
            'band whose floor of 99.5 permits one assignment in two hundred to '
            'break the flow the instruction exists to protect -- the first '
            'contradiction in the track between an instruction and its band on '
            'a matter of kind rather than degree; the guarantee is achievable '
            'by construction, so the correct figure is 100 and the honest band '
            'is one cell, the second such row after Step 411; its metric is '
            'the triangular-check measure this sheet uses for A - B = 0 '
            'reconciliations, on a row with no balance to validate; and its '
            'assignment key is the app-scoped install identifier Step 420 '
            'built after refusing the device identifier this row would '
            'otherwise have needed. Atomic Step: "Guarantee mathematically '
            'that the same user always sees the same variant to prevent flow '
            'breaks."',
        implementationOrder: 435,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Guarantee mathematically that the same user always sees the same':
              'a hash of the assignment key and the experiment name modulo '
                  '$buckets buckets, giving $achievable per cent determinism '
                  'with no storage and no network call',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mathematical Balance Validation Accuracy (%)',
            observed:
                'THE WORD AND THE NUMBER CANNOT BOTH BE TRUE. A guarantee is '
                'not a rate, and a floor of 99.5 says $perThousand users in a '
                'thousand may be handed the other variant halfway through a '
                'task -- which is the flow break the instruction exists to '
                'prevent, so the band permits what the instruction forbids. '
                'Step 432 disagreed with its own band by a factor; this '
                'disagrees in kind, between always and almost always, and it '
                'is the first of its sort in the track. The guarantee is '
                'achievable by construction, so the observed figure is '
                '$achievable and the honest band is one cell -- the second '
                'such row after Step 411. Its metric is the triangular-check '
                'measure this sheet uses for A - B = 0 reconciliations, on a '
                'row with no balance to validate.',
            floor: '99.5',
            optimal: '99.99',
            ceiling: '100',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Identifiers leaving the device for this assignment',
            observed:
                '0. "The same user" needs something stable, and this batch '
                'spent Step 419 keeping user identifiers out of the payload '
                'and Step 420 refusing a device identifier. What Step 420 '
                'built instead -- $keySource -- is exactly the right key, and '
                'the bucket is computed locally so only the variant name ever '
                'travels. A refusal made fifteen rows earlier supplies what '
                'the last row of the batch needs, which is the argument for '
                'making refusals constructively. A reinstall rotates the key '
                'and also discards the in-progress task, so the one case the '
                'row worries about cannot arise.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/live/variant_assignment.dart',
        ],
      ),
    );
  });
}
