/// AISS GATE -- Step 294 of 295
/// Global Reference ID:       BLGTA-033
/// Atomic Steps Reference ID: BLGTA-033
/// Setup Step (Action): "Embed translucent padding layers to scale compact
///                      icon layers safely to 48x48dp." (DIFFERENT SUBJECT)
/// Atomic Step: "Instruct the frontend interface layout assembler to cleanly
///               lock and disable action pathways if background authorization
///               parameters are unverified."
/// Metric: General Process/Execution Quality -- Floor "70% conformance",
///         Optimal "100% conformance", Ceiling "100% conformance + continuous
///         audit". Good / Average / Poor. ISO 9001:2015.
///
/// DISABLED IS NOT SECURE, AND "UNVERIFIED" IS THREE STATES RATHER THAN TWO.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/operations/authorisation_lock.dart';

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

  group('BLGTA-033 :: three states, not two', () {
    gate(
      'BLGTA-033-G1',
      'Atomic Step: "if background authorization parameters are unverified".',
      'Verified-and-allowed, verified-and-refused and not-yet-known map to '
          'three distinct pathway states rather than two',
      () =>
          HabotAuthorisationLock.everyAuthorityStateHasItsOwnPathwayState &&
          HabotAuthorityState.values.length == 3 &&
          HabotAuthorisationLock.pendingIsNotRefused,
    );

    gate(
      'BLGTA-033-G2',
      'A two-state reading treats a slow check as a refusal.',
      'The naive version is kept as an executable contrast: it locks out the '
          'person on the worst connection and tells them they may not do '
          'something they may',
      () =>
          HabotAuthorisationLock.theNaiveReadingLocksOutSlowConnections &&
          HabotAuthorisationLock.threeStatesNote
              .contains('silence is not a verdict'),
    );

    gate(
      'BLGTA-033-G3',
      'Every non-available state says something.',
      'The refusal names who can change it and the pending state names '
          'nothing to do, because there is nothing to do and inventing an '
          'action would be worse than saying so',
      () =>
          HabotAuthorisationLock.everyNonAvailableStateSaysSomething &&
          HabotAuthorisationLock.theRefusalNamesWhoCanChangeIt,
    );
  });

  group('BLGTA-033 :: what the lock is', () {
    gate(
      'BLGTA-033-G4',
      'A disabled control is a hint, not a boundary.',
      'The lock is named as mistake-prevention rather than security, and the '
          'reason -- a team that believes the client enforces something stops '
          'checking that the server does -- is recorded as the actual '
          'vulnerability',
      () =>
          !HabotAuthorisationLock.theLockIsSecurity &&
          HabotAuthorisationLock.theLockPreventsMistakes &&
          HabotAuthorisationLock.notSecurityNote
              .contains('the actual vulnerability'),
    );

    gate(
      'BLGTA-033-G5',
      'Every pathway is refused at the source as well.',
      'Four pathways, all enforced server-side, each saying why it is on the '
          'list -- a pathway where that were false would be one the client '
          'was pretending to protect',
      () =>
          HabotAuthorisationLock.pathways.length == 4 &&
          HabotAuthorisationLock.everyPathwayIsEnforcedServerSide &&
          HabotAuthorisationLock.everyPathwayGivesAReason,
    );

    gate(
      'BLGTA-033-G6',
      'A locked pathway is not a dead end.',
      'The property Step 292 established is read from that step rather than '
          're-declared here',
      () => HabotAuthorisationLock.lockedPathwaysAreNotDeadEnds,
    );
  });

  group('BLGTA-033 :: the band', () {
    gate(
      'BLGTA-033-G7',
      'Floor: "70% conformance".',
      'Three action pathways in ten locked wrongly, and on this subject a '
          'wrongly unlocked pathway is the only kind anybody hears about; 70% '
          'of a rule is not a weaker rule, it is no rule',
      () =>
          HabotAuthorisationLock.theFloorAllowsThreeInTen &&
          HabotAuthorisationLock.floorNote.contains('it is no rule'),
    );

    gate(
      'BLGTA-033-G8',
      'Ceiling: "100% conformance + continuous audit".',
      'The only ceiling in this batch that asks for something real above the '
          'optimal and names what it is',
      () => HabotAuthorisationLock.theCeilingAddsSomethingRealAboveTheOptimal,
    );

    gate(
      'BLGTA-033-G9',
      'Output: Good / Average / Poor.',
      'Seven declared obligations, all met, giving 1.0 and a Good; all nine '
          'declared checks hold',
      () =>
          HabotAuthorisationLock.obligations.length == 7 &&
          HabotAuthorisationLock.obligations.values.every((bool b) => b) &&
          HabotAuthorisationLock.conformance == 1.0 &&
          HabotAuthorisationLock.qualitativeOutput == 'Good' &&
          HabotAuthorisationLock.checks.length == 9 &&
          HabotAuthorisationLock.checks.values.every((bool b) => b) &&
          HabotAuthorisationLock.columnNote.contains('insurance premium'),
    );
  });

  tearDownAll(() {
    final String refused =
        HabotAuthorisationLock.reasonFor(HabotAuthorityState.verifiedRefused);
    final String pending =
        HabotAuthorisationLock.reasonFor(HabotAuthorityState.pending);
    final String wrongAtFloor =
        '${HabotAuthorisationLock.pathwaysWrongAtFloor}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'BLGTA-033',
        atomicStepReferenceId: 'BLGTA-033',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Embed '
            'translucent padding layers to scale compact icon layers safely '
            'to 48x48dp", and every narrative column is about an insurance '
            'premium calculator. Atomic Step: "Instruct the frontend '
            'interface layout assembler to cleanly lock and disable action '
            'pathways if background authorization parameters are unverified."',
        implementationOrder: 294,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Frontend Technology': 'Flutter, Dart',
          'Build Configuration':
              '${HabotAuthorityState.values.length} authority states mapped to '
                  '${HabotPathwayState.values.length} pathway states; '
                  '${HabotAuthorisationLock.pathways.length} action pathways, '
                  'every one enforced server-side',
          'Component Properties':
              'refused reads "$refused"; pending reads "$pending"; locked '
                  'pathways are conditional and name what would change them',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotAuthorisationLock.notSecurityNote} '
              'STATES: ${HabotAuthorisationLock.threeStatesNote} '
              'BAND: ${HabotAuthorisationLock.floorNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'General Process/Execution Quality',
            observed:
                '100% over ${HabotAuthorisationLock.obligations.length} '
                'declared obligations. The row\'s 70% floor would allow '
                '$wrongAtFloor action pathways in ten to be locked wrongly, '
                'and on this subject the wrongly unlocked ones are the only '
                'kind anybody hears about.',
            floor: '70% conformance',
            optimal: '100% conformance',
            ceiling: '100% conformance + continuous audit',
          ),
          AissMeasurement(
            metricName: 'Action pathways the client alone protects',
            observed:
                '0 of ${HabotAuthorisationLock.pathways.length}. Every one is '
                'refused at the server independently; the interface lock '
                'prevents honest mistakes and is named as that rather than as '
                'security.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/operations/authorisation_lock.dart',
        ],
      ),
    );
  });
}
