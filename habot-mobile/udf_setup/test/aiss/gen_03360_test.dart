/// AISS GATE -- Step 245 of 255
/// Global Reference ID:       GEN-03360
/// Atomic Steps Reference ID: GEN-03360
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Build client-side validation logic confirming all signature
///               and field inputs are populated."
/// Metric: Field Input Validation Pass Rate -- Floor 1, Optimal 1, Ceiling 1.
///         Pass. Standard cited: Poka-Yoke Safeguard Mechanics.
///
/// A SPACE IS POPULATED. Seven of eight vectors pass the check this row's
/// wording asks for and should not, and a required field nobody registered is
/// not incomplete -- it is invisible.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/completeness_rules.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double rate = 0;

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

  group('GEN-03360 :: populated is not filled in', () {
    gate(
      'GEN-03360-G1',
      'Atomic Step: "confirming all signature and field inputs are '
          'POPULATED."',
      'All eight vectors pass the emptiness check the row\'s wording asks for, '
          'and seven of them are empty of anything a person supplied -- a '
          'space, a tab, a no-break space, a zero-width space, four '
          'whitespace characters, a one-point signature and a zero-byte file',
      () =>
          HabotCompletenessRules.cases.length == 8 &&
          HabotCompletenessRules.naiveAcceptanceRate == 1.0 &&
          HabotCompletenessRules.caughtHereOnly.length == 7,
    );

    gate(
      'GEN-03360-G2',
      'A rule that rejects everything passes its own test.',
      'The eighth vector is one visible character and it is accepted here and '
          'by the naive check both, so the seven-of-eight figure is about a '
          'rule that discriminates rather than one that simply says no',
      () =>
          HabotCompletenessRules.theControlStillPasses &&
          HabotCompletenessRules.passHere.length == 1 &&
          (HabotCompletenessRules.acceptanceRateHere - 0.125).abs() < 1e-9,
    );

    gate(
      'GEN-03360-G3',
      'A trim that only knows about 0x20 keeps the other ten.',
      'Eleven code points are discounted, including the no-break space that '
          'arrives by paste from a web page and the zero-width space that is '
          'invisible on every screen and cannot be debugged by looking at it',
      () =>
          HabotCompletenessRules.invisibleCodeUnits.length == 11 &&
          HabotCompletenessRules.isInvisible(0xA0) &&
          HabotCompletenessRules.isInvisible(0x200B) &&
          HabotCompletenessRules.isInvisible(0xFEFF) &&
          !HabotCompletenessRules.isInvisible(0x78),
    );

    gate(
      'GEN-03360-G4',
      'The vectors and the implementation must not drift apart.',
      'Every declared vector is re-checked against the live string functions, '
          'with the invisible characters built from their code points rather '
          'than pasted into the source where nobody could review them',
      () => HabotCompletenessRules.liveStringsAgreeWithTheVectors,
    );
  });

  group('GEN-03360 :: signatures, and the half the row omits', () {
    gate(
      'GEN-03360-G5',
      'The row names signatures first.',
      'A signature needs two stroke points, because one is a finger touching '
          'the glass and lifting -- and each of the four kinds of content '
          'carries its own minimum with the reason for it',
      () =>
          HabotCompletenessRules.minimums.length ==
              HabotContentKind.values.length &&
          HabotCompletenessRules
                  .minimumFor(HabotContentKind.signature)
                  .minimum ==
              2 &&
          HabotCompletenessRules.minimumFor(HabotContentKind.attachment)
              .unit ==
              'byte' &&
          HabotCompletenessRules.minimums.every(
            (HabotMinimumContent m) => m.why.length > 60,
          ),
    );

    gate(
      'GEN-03360-G6',
      'HabotFormGate.canSubmit requires every REGISTERED field to be valid.',
      'A required field nobody registered does not block submission -- it is '
          'not incomplete, it is invisible -- so the required set is derived '
          'from the form\'s declared field list rather than accumulated from '
          'whichever widgets happened to be built',
      () =>
          HabotCompletenessRules.anUnregisteredFieldIsInvisible &&
          HabotCompletenessRules.unenforcedFields(
            declared: <String>{'a', 'b', 'c'},
            registered: <String>{'a', 'b', 'c'},
          ).isEmpty &&
          HabotCompletenessRules.registrationNote
              .contains('it is invisible'),
    );

    gate(
      'GEN-03360-G7',
      'Field Input Validation Pass Rate -- floor, optimal and ceiling all 1.',
      'All nine checks hold and every vector reaches the verdict it was chosen '
          'to reach against the live functions, so the step reports Pass',
      () {
        rate = HabotCompletenessRules.fieldInputValidationPassRate;
        return HabotCompletenessRules.checks.length == 9 &&
            HabotCompletenessRules.checks.values.every((bool b) => b) &&
            rate == 1 &&
            rate >= HabotCompletenessRules.floor &&
            HabotCompletenessRules.qualitativeOutput == 'Pass' &&
            HabotCompletenessRules.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03360',
        atomicStepReferenceId: 'GEN-03360',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Build client-side validation logic confirming all '
            'signature and field inputs are populated."',
        implementationOrder: 245,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotCompletenessRules / HabotEmptinessCase',
          'Component Properties':
              '${HabotContentKind.values.length} kinds of content each with a '
              'minimum and a reason; '
              '${HabotCompletenessRules.invisibleCodeUnits.length} code '
              'points discounted; ${HabotCompletenessRules.cases.length} '
              'vectors of which '
              '${HabotCompletenessRules.caughtHereOnly.length} pass an '
              'emptiness check and fail this one',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotCompletenessRules.populatedIsNotFilledNote} '
              'CONTROL: '
              '${HabotCompletenessRules.notStricterAboutEverythingNote} '
              'SECOND FINDING: ${HabotCompletenessRules.registrationNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Field Input Validation Pass Rate',
            observed:
                '${rate.toStringAsFixed(2)} -- every vector reaches the '
                'verdict it was chosen to reach, checked against the live '
                'string functions rather than against the declared lengths.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Vectors an isNotEmpty check would accept',
            observed:
                '${HabotCompletenessRules.passNaively.length} of '
                '${HabotCompletenessRules.cases.length}, against '
                '${HabotCompletenessRules.passHere.length} here. The one that '
                'passes both is the control: a single visible character.',
            floor: '1 of 8',
            optimal: '1 of 8',
            ceiling: '8 of 8',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/completeness_rules.dart',
        ],
      ),
    );
  });
}
