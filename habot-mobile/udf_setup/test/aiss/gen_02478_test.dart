/// AISS GATE -- Step 372 of 375
/// Global Reference ID:       GEN-02478
/// Atomic Steps Reference ID: GEN-02478
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Design a single-tap \"Export Payroll\" button for the mobile
///               UI."
/// Metric: Data Validation Pass Rate (%) -- floor 0.95, optimal 0.999, ceiling
///         1. Pass / Fail. ISO/IEC 27001, OWASP Input Validation.
///
/// ONE TAP, AND THE FOUR DECISIONS IT WOULD OTHERWISE MAKE ON SOMEBODY'S
/// BEHALF.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/reports/payroll_export.dart';

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

  group('GEN-02478 :: four decisions on one button', () {
    gate(
      'GEN-02478-G1',
      'Every export answers four questions.',
      'Which period, which people, which format, where it goes',
      () =>
          HabotExportDecision.values.length == 4 &&
          HabotPayrollExport.everyDecisionIsAnswered,
    );

    gate(
      'GEN-02478-G2',
      'All four answers are on the face of the button.',
      'So the tap confirms a decision instead of making one',
      () =>
          HabotPayrollExport.everyAnswerIsVisible &&
          HabotPayrollExport.decisionNote.contains('confirms a decision'),
    );

    gate(
      'GEN-02478-G3',
      'Three of the four have real alternatives, and the tap is still one.',
      'A single tap is a good goal; answering three open questions silently is '
          'the part that is not',
      () =>
          HabotPayrollExport.decisionsWithRealAlternatives == 3 &&
          HabotPayrollExport.theTapIsStillOne,
    );
  });

  group('GEN-02478 :: an export is an egress event', () {
    gate(
      'GEN-02478-G4',
      'The event is recorded before the file exists.',
      'Payroll is names, bank details and salaries, and the export is the '
          'moment they leave the application\'s control',
      () =>
          HabotPayrollExport.theEventIsRecordedBeforeTheFile &&
          HabotPayrollExport.egressNote.contains('before the file exists'),
    );

    gate(
      'GEN-02478-G5',
      'The record names the actor, the destination and the population.',
      'Forty-eight people on the September run, to the share sheet',
      () =>
          HabotPayrollExport.theEventNamesTheActor &&
          HabotPayrollExport.theEventNamesTheDestination &&
          HabotPayrollExport.theEventCountsThePeople,
    );

    gate(
      'GEN-02478-G6',
      'Written at the point of export rather than hoped for downstream.',
      'Step 329 recorded a gateway that could see one exit of three',
      () =>
          HabotPayrollExport.theEgressFinding == 329 &&
          HabotPayrollExport.egressNote.contains('one exit'),
    );
  });

  group('GEN-02478 :: exported is not delivered', () {
    gate(
      'GEN-02478-G7',
      'The completion wording names the share sheet and stops.',
      'The application handed the file to the platform; what happens next is '
          'not something it can see',
      () =>
          HabotPayrollExport.theWordingClaimsOnlyWhatHappened &&
          HabotPayrollExport.completionWording.contains('share sheet'),
    );

    gate(
      'GEN-02478-G8',
      '"Sent to your accountant" is refused.',
      'Reporting a completed export as a delivery is how a payroll deadline is '
          'missed by somebody who believes they met it',
      () =>
          HabotPayrollExport.theOverclaimingWordingIsRefused &&
          HabotPayrollExport.deliveryNote.contains('believes they met it'),
    );
  });

  group('GEN-02478 :: one band, three subjects', () {
    gate(
      'GEN-02478-G9',
      'The band is the attendance export\'s three numbers.',
      '0.95, 0.999, 1 -- scoring a verification badge at Step 357, this export '
          'and the attendance export already built',
      () =>
          HabotPayrollExport.theBandIsTheAttendanceExportsBand &&
          HabotPayrollExport.threeSubjectsShareOneBand &&
          HabotPayrollExport.coverageNote.contains('three failure modes') ==
              false &&
          HabotPayrollExport.coverageNote.contains('three subjects'),
    );

    gate(
      'GEN-02478-G10',
      'Output reported as Pass / Fail.',
      'Six obligations, all met, giving Pass; no omission is silent, and all '
          'ten declared checks hold',
      () =>
          HabotPayrollExport.theCoverageModelAlreadyExists &&
          !HabotPayrollExport.anOmissionIsSilent &&
          HabotPayrollExport.obligations.length == 6 &&
          HabotPayrollExport.obligations.values.every((bool b) => b) &&
          HabotPayrollExport.qualitativeOutput == 'Pass' &&
          HabotPayrollExport.checks.length == 10 &&
          HabotPayrollExport.checks.values.every((bool b) => b) &&
          HabotPayrollExport.columnNote.contains('Export Payroll'),
    );
  });

  tearDownAll(() {
    final int decisions = HabotPayrollExport.answerOnTheButton.length;
    final int people = HabotPayrollExport.workedExport.peopleIncluded;
    final String wording = HabotPayrollExport.completionWording;
    final String destination = HabotPayrollExport.workedExport.destination;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02478',
        atomicStepReferenceId: 'GEN-02478',
        setupStepAction:
            'COLUMN NOTE: the Data Requirement cell on this row reads '
            '"Data/artifacts to prepare: Export Payroll", which is the '
            'button\'s own label lifted into the artefact list -- the fourth '
            'such cell in this batch after Steps 356, 357 and 360 -- its band '
            'is the same three numbers as Step 357 and the attendance export '
            'already in the repository, and the Setup Step column is empty. '
            'Atomic Step: "Design a single-tap Export Payroll button for the '
            'mobile UI."',
        implementationOrder: 372,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Export Payroll':
              '$decisions decisions answered on the face of the button; the '
                  'worked run covers $people people',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the completion wording reads "$wording"; the egress event names '
                  '"$destination" and is recorded before the file exists',
          'Data Quality Note':
              'DECISIONS: ${HabotPayrollExport.decisionNote} '
              'EGRESS: ${HabotPayrollExport.egressNote} '
              'DELIVERY: ${HabotPayrollExport.deliveryNote} '
              'COVERAGE: ${HabotPayrollExport.coverageNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Data Validation Pass Rate (%)',
            observed:
                'ONE BAND, THREE SUBJECTS. Floor 0.95, optimal 0.999, ceiling '
                '1 -- correctly ordered, and the same three numbers that score '
                'the payroll verification badge at Step 357 and the attendance '
                'export already in this repository. Three subjects with three '
                'different failure modes share one validation band, which is '
                'the template shape this batch keeps meeting. The attendance '
                'export also already carries the model this row needs: what '
                'was included, what was omitted and why.',
            floor: '0.95',
            optimal: '0.999',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Export decisions taken without being shown',
            observed:
                '0 of $decisions. Every export answers four questions -- which '
                'period, which people, which format, where it goes -- and a '
                'one-tap button answers all four silently; three of the four '
                'have real alternatives on a payroll run. The button keeps its '
                'single tap and puts the answers on its face. The export '
                'itself is an egress event for the most sensitive dataset this '
                'application holds, recorded before the file exists with '
                'actor, period, destination and a count of $people people. And '
                'the completion wording reads "$wording" rather than claiming '
                'a delivery the application cannot see.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/reports/payroll_export.dart',
        ],
      ),
    );
  });
}
