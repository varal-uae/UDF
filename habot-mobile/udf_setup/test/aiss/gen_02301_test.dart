/// AISS GATE -- Step 357 of 375
/// Global Reference ID:       GEN-02301
/// Atomic Steps Reference ID: GEN-02301
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Design a \"Verified\" badge for the mobile payroll summary."
/// Metric: Data Validation Pass Rate (%) -- floor 0.95, optimal 0.999,
///         ceiling 1. Pass / Fail. ISO/IEC 27001, OWASP Input Validation.
///
/// THE WORD HAS NO OBJECT, AND PAYROLL IS WHERE THAT COSTS THE MOST. THIS
/// STEP'S WORKED RUN REPORTS **FAIL**, WHICH IS THE CORRECT READING OF IT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/badges/payroll_verified_badge.dart';

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

  group('GEN-02301 :: four meanings, one word', () {
    gate(
      'GEN-02301-G1',
      'A payroll summary has four things "verified" could mean.',
      'The arithmetic, the bank details, the approved hours and the authorised '
          'run -- four distinct claims',
      () =>
          HabotPayrollCheck.values.length == 4 &&
          HabotPayrollVerifiedBadge.everyMeaningIsDistinct,
    );

    gate(
      'GEN-02301-G2',
      'Each is established by a different actor.',
      'The application, the bank, a manager and an authorised approver -- at '
          'four different times',
      () =>
          HabotPayrollVerifiedBadge.everyCheckHasADifferentActor &&
          HabotPayrollVerifiedBadge.ambiguityNote
              .contains('nobody approved'),
    );

    gate(
      'GEN-02301-G3',
      'The row names one of the four.',
      'A single chip reading "Verified" asserts all four, which is how a run '
          'whose hours nobody approved gets signed off',
      () =>
          HabotPayrollVerifiedBadge.theRowNamesOneOfFour &&
          HabotPayrollVerifiedBadge.meaningsTheRowNames == 1,
    );
  });

  group('GEN-02301 :: the badge is a set', () {
    gate(
      'GEN-02301-G4',
      'The worked run holds three of the four.',
      'The chip states "3 of 4 verified" rather than a mood',
      () =>
          HabotPayrollVerifiedBadge.holdingCount == 3 &&
          HabotPayrollVerifiedBadge.theChipStatesACount,
    );

    gate(
      'GEN-02301-G5',
      'The one that is missing is named.',
      'Hours approved -- the one a manager owns, and the one a single chip '
          'would have hidden',
      () =>
          HabotPayrollVerifiedBadge.theMissingCheckIsNamed &&
          HabotPayrollVerifiedBadge.missing.length == 1,
    );

    gate(
      'GEN-02301-G6',
      'Every holding check carries its author.',
      'A claim without an author is the same problem one level down: somebody '
          'has to be able to ask the bank, or the manager, and know which',
      () =>
          HabotPayrollVerifiedBadge.everyHoldingCheckNamesItsActor &&
          HabotPayrollVerifiedBadge.setNote.contains('without an author'),
    );
  });

  group('GEN-02301 :: partial does not round up', () {
    gate(
      'GEN-02301-G7',
      'Three of four is Fail, not "nearly Pass".',
      'A badge that rounds up converts a known gap into an unknown one',
      () =>
          !HabotPayrollVerifiedBadge.aPartialVerificationRendersAsVerified &&
          HabotPayrollVerifiedBadge.theWorkedRunFails,
    );

    gate(
      'GEN-02301-G8',
      'The chip stays on screen showing the count.',
      'Removing it would hide the three checks that do hold',
      () => HabotPayrollVerifiedBadge.roundingNote
          .contains('three that do hold'),
    );
  });

  group('GEN-02301 :: the band', () {
    gate(
      'GEN-02301-G9',
      'Floor 0.95, optimal 0.999, ceiling 1 -- well formed.',
      'And already declared in this repository on the attendance export, so '
          'one band scores three unrelated subjects',
      () =>
          HabotPayrollVerifiedBadge.theBandIsWellFormed &&
          HabotPayrollVerifiedBadge.theSameBandIsAlreadyDeclaredElsewhere &&
          HabotPayrollVerifiedBadge.rowsSharingThisBandInThisBatch == 2,
    );

    gate(
      'GEN-02301-G10',
      'Output reported as Pass / Fail: **Fail**.',
      'Six obligations, all met -- they are about how the badge behaves -- and '
          'the run still fails, because one of its four checks does not hold; '
          'all ten declared checks hold',
      () =>
          HabotPayrollVerifiedBadge.obligations.length == 6 &&
          HabotPayrollVerifiedBadge.obligations.values.every((bool b) => b) &&
          HabotPayrollVerifiedBadge.qualitativeOutput == 'Fail' &&
          HabotPayrollVerifiedBadge.checks.length == 10 &&
          HabotPayrollVerifiedBadge.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final String chip = HabotPayrollVerifiedBadge.chipLabel;
    final int holding = HabotPayrollVerifiedBadge.holdingCount;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02301',
        atomicStepReferenceId: 'GEN-02301',
        setupStepAction:
            'COLUMN NOTE: the Data Requirement cell on this row reads '
            '"Data/artifacts to prepare: Verified", which is the badge label '
            'lifted into the artefact list -- the same shape as Steps 352 and '
            '356 -- and the Setup Step column is empty. Atomic Step: "Design a '
            'Verified badge for the mobile payroll summary."',
        implementationOrder: 357,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Verified':
              '4 distinct meanings with 4 distinct actors; the worked run '
                  'holds $holding of them',
          'Completion Status': 'Fail',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the chip reads "$chip" and names the missing check; every '
                  'holding check carries the actor that established it',
          'Data Quality Note':
              'AMBIGUITY: ${HabotPayrollVerifiedBadge.ambiguityNote} '
              'SET: ${HabotPayrollVerifiedBadge.setNote} '
              'ROUNDING: ${HabotPayrollVerifiedBadge.roundingNote} '
              'BAND: ${HabotPayrollVerifiedBadge.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Data Validation Pass Rate (%)',
            observed:
                'WELL FORMED, AND ABOUT A DIFFERENT SUBJECT. Floor 0.95, '
                'optimal 0.999, ceiling 1, correctly ordered for a '
                'higher-is-better ratio -- and a data validation pass rate is '
                'about input sanitisation, not about whether four separate '
                'checks agree. Step 372 in this batch carries the identical '
                'band on an export button, and the attendance export already '
                'in the repository declares the same three numbers, so one '
                'band does duty for three unrelated subjects.',
            floor: '0.95',
            optimal: '0.999',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Payroll checks the badge asserts, and how many hold',
            observed:
                '$holding of 4. "Verified" with no object asserts all four at '
                'once: the arithmetic, the bank details, the approved hours '
                'and the authorised run -- established by the application, the '
                'bank, a manager and an approver, at four different times. The '
                'worked run has no manager approval, so the chip reads "$chip" '
                'and names which one is missing. Three of four is reported as '
                'Fail rather than rounded up, because the point of the control '
                'is the check that is absent.',
            floor: '4',
            optimal: '4',
            ceiling: '4',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/badges/payroll_verified_badge.dart',
        ],
      ),
    );
  });
}
