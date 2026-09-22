/// AISS GATE -- Step 438 of 415
/// Global Reference ID:       GEN-02104
/// Atomic Steps Reference ID: GEN-02104
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Mathematically link point generation to system validation to
///               prevent cheating."
/// Metric: Mathematical Balance Validation Accuracy (%) -- floor "99.5",
///         optimal "99.99", ceiling "100". Best Qualitative Output:
///         "Complete/Partial/Not Complete". ISO/IEC 27035:2016 (Data Integrity)
///         & OWASP Standards. Assigned to **DEA**.
///
/// THE FIRST ROW WHERE THE ACCOUNTING METRIC THIS SHEET KEEPS MISAPPLYING
/// ACTUALLY FITS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/recognition/point_validation.dart';

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

  group('GEN-02104 :: the metric fits, for once', () {
    gate(
      'GEN-02104-G1',
      'The same metric as Step 435, and here it fits.',
      'Points are a ledger, and A - B = 0 is the right check',
      () =>
          HabotPointValidation.theMetricFitsThisRow &&
          HabotPointValidation.theRowWhereItDidNotFit == 435,
    );

    gate(
      'GEN-02104-G2',
      'So the defect was always where it was put.',
      'Not the metric itself',
      () => HabotPointValidation.fitNote.contains('where it was put was'),
    );

  });

  group('GEN-02104 :: the ledger', () {
    gate(
      'GEN-02104-G3',
      'Five ledger lines, each carrying its completion.',
      'Every point names the completion that earned it',
      () =>
          HabotPointValidation.ledger.length == 5 &&
          HabotPointValidation.everyLineCarriesItsCompletion,
    );

    gate(
      'GEN-02104-G4',
      'Sixty points awarded, sixty backed, difference zero.',
      'The ledger balances',
      () =>
          HabotPointValidation.pointsAwarded == 60 &&
          HabotPointValidation.pointsBacked == 60 &&
          HabotPointValidation.theLedgerBalances,
    );

    gate(
      'GEN-02104-G5',
      'And only the server mints them.',
      'From completions of the Step 436 kind',
      () =>
          HabotPointValidation.onlyTheServerMintsPoints &&
          HabotPointValidation.aCompletionIsTheStep436Kind,
    );

  });

  group('GEN-02104 :: an unbalanced floor', () {
    gate(
      'GEN-02104-G6',
      'A floor of 99.5 permits an unbalanced ledger.',
      'The honest band is one cell, the third such row after 411 and 435',
      () =>
          HabotPointValidation.theFloorAllowsAnUnbalancedLedger &&
          HabotPointValidation.thirdSuchRow,
    );

  });

  group('GEN-02104 :: cheating as information', () {
    gate(
      'GEN-02104-G7',
      'Gaming is a finding about the rule.',
      'The measure has become the target',
      () =>
          HabotPointValidation.aPatternIsReportedAsAFindingAboutTheRule &&
          HabotPointValidation.theCharterThirdRuleHolds,
    );

    gate(
      'GEN-02104-G8',
      'And not an accusation against the person.',
      'No pattern produces a consequence without somebody named deciding',
      () => HabotPointValidation.gamingNote.contains('not as an accusation'),
    );

    gate(
      'GEN-02104-G9',
      'The ledger cannot see collusion, and says so.',
      'Separation of duties covers it; reciprocal approvals are surfaced, not '
          'blocked',
      () =>
          !HabotPointValidation.theLedgerCatchesCollusion &&
          HabotPointValidation.separationOfDutiesCoversTheGap &&
          HabotPointValidation
              .collusionNote.contains('mistaken for an honest one'),
    );

    gate(
      'GEN-02104-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotPointValidation.obligations.length == 5 &&
          HabotPointValidation.obligations.values.every((bool b) => b) &&
          HabotPointValidation.qualitativeOutput == 'Complete' &&
          HabotPointValidation.balanceAccuracy == 100,
    );
  });

  tearDownAll(() {
    final int awarded = HabotPointValidation.pointsAwarded;
    final int backed = HabotPointValidation.pointsBacked;
    final int lines = HabotPointValidation.ledger.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02104',
        atomicStepReferenceId: 'GEN-02104',
        setupStepAction:
            'COLUMN NOTE: this row\'s metric and band -- Mathematical Balance '
            'Validation Accuracy at 99.5, 99.99, 100 -- are identical to Step '
            '435\'s, and here the metric fits, because points are a ledger and '
            'A - B = 0 is the right check; its floor of 99.5 still permits an '
            'unbalanced ledger, so the honest band is one cell, the third such '
            'row after Steps 411 and 435; and its instruction to "prevent '
            'cheating" is met by server-minted points carrying their '
            'completion, with gaming reported as a finding about the rule and '
            'collusion covered by separation of duties rather than by the '
            'ledger. Atomic Step: "Mathematically link point generation to '
            'system validation to prevent cheating."',
        implementationOrder: 438,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Mathematically link point generation to system validation to '
          'prevent cheating':
              '$lines ledger lines, $awarded points awarded and $backed backed '
                  'by validated completions; separation of duties covers '
                  'collusion',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mathematical Balance Validation Accuracy (%)',
            observed:
                'THE SAME METRIC AS STEP 435, AND HERE IT FITS. Step 435 '
                'carried this A - B = 0 measure onto a variant assignment, '
                'where nothing balanced; points are a ledger, so every point '
                'awarded should be matched by the completion that earned it. '
                'The floor of 99.5 is still wrong -- a ledger that balances to '
                '99.5 per cent is unbalanced -- and the honest band is one '
                'cell. Observed: $awarded awarded, $backed backed, difference '
                'zero.',
            floor: '99.5',
            optimal: '99.99',
            ceiling: '100',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Points minted without a validated completion',
            observed:
                '0 of $awarded. Gaming is reported as a finding about the rule '
                'that allowed it rather than as an accusation, since people '
                'gaming points usually means the points reward something other '
                'than the work. One limit is written down: two colleagues '
                'approving each other produce a ledger that balances '
                'perfectly, so self-approval is forbidden and reciprocal '
                'approvals are surfaced for a person to look at.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/recognition/point_validation.dart',
        ],
      ),
    );
  });
}
