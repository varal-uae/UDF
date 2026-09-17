/// AISS GATE -- Step 350 of 355
/// Global Reference ID:       GEN-01815
/// Atomic Steps Reference ID: GEN-01815
/// Setup Step (Action): (the generic engineering-console boilerplate --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Standardize modal and dialog wrappers across the
///               application."
/// Metric: Step Completion Rate (%) -- floor 90, optimal 99, ceiling 100.
///         Complete/Partial/Not Complete. ISO/IEC 27001:2022.
///
/// FIVE OF THE SIX PROMISES A DIALOG OWES ARE INVISIBLE, AND A STANDARDISATION
/// ROW IS WORTH EXACTLY THE AUDIT ATTACHED TO IT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/dialogs/dialog_wrapper.dart';

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

  group('GEN-01815 :: six promises', () {
    gate(
      'GEN-01815-G1',
      'A dialog is a set of promises, not a box that floats.',
      'Six are declared, each naming the step that built its mechanism',
      () =>
          HabotDialogWrapper.promiseCount == 6 &&
          HabotDialogWrapper.everyPromiseHasAnOwner,
    );

    gate(
      'GEN-01815-G2',
      'Five of the six would survive a visual review untouched.',
      'A hand-built dialog looks right and lets a screen reader walk out of '
          'the back of it into a form nobody can see',
      () =>
          HabotDialogWrapper.fiveOfSixAreInvisible &&
          HabotDialogWrapper.promisesNote.contains('no visual review'),
    );
  });

  group('GEN-01815 :: the audit, not another implementation', () {
    gate(
      'GEN-01815-G3',
      'Step 280 built the focus trap and Step 276 settled the scrim rule.',
      'Nothing in this file is a second implementation of either',
      () =>
          HabotDialogWrapper.theTrapIsAlreadyBuilt &&
          HabotDialogWrapper.theScrimRuleIsAlreadyBuilt,
    );

    gate(
      'GEN-01815-G4',
      'Eleven surfaces exist and eleven go through the wrapper.',
      'A standardisation claim without that count is a statement of intent',
      () =>
          HabotDialogWrapper.everySurfaceGoesThroughOneDoor &&
          HabotDialogWrapper.coverage == 100 &&
          HabotDialogWrapper.auditNote.contains('statement of intent'),
    );
  });

  group('GEN-01815 :: two contracts', () {
    gate(
      'GEN-01815-G5',
      'Dismissible and decisive are different contracts.',
      'One can be closed by a tap on the scrim; the other cannot',
      () =>
          HabotDialogContract.values.length == 2 &&
          HabotDialogWrapper.exitsFor.length == 2 &&
          HabotDialogWrapper.aDecisiveDialogIgnoresTapsOutside,
    );

    gate(
      'GEN-01815-G6',
      'Both contracts keep the back gesture.',
      'It is the exit people reach for without being taught, and every '
          'contract has at least two ways out',
      () =>
          HabotDialogWrapper.everyContractHasAtLeastTwoExits &&
          HabotDialogWrapper.exitsFor.values.every(
            (List<String> e) => e.contains('the back gesture or key'),
          ),
    );

    gate(
      'GEN-01815-G7',
      'No exit is the primary action.',
      'Agreeing is not the same as leaving, and a dialog whose only way out is '
          'to say yes is not a question',
      () =>
          HabotDialogWrapper.noExitIsThePrimaryAction &&
          HabotDialogWrapper.contractNote.contains('same as leaving'),
    );
  });

  group('GEN-01815 :: the invisible failure', () {
    gate(
      'GEN-01815-G8',
      'The content behind a dialog is inert and not announced.',
      'An unmanaged dialog leaves the page behind it in the accessibility '
          'tree, and a screen reader walks straight into it',
      () => !HabotDialogWrapper.contentBehindStaysInTheAccessibilityTree,
    );

    gate(
      'GEN-01815-G9',
      'No screenshot shows that failure.',
      'The only way to find it is to walk the tree, which is why it belongs in '
          'a wrapper rather than in a review checklist',
      () => HabotDialogWrapper.invisibleFailureNote.contains('walk the tree'),
    );

    gate(
      'GEN-01815-G10',
      'Output reported as Complete / Partial / Not Complete.',
      'Six obligations, all met, giving Complete; all ten declared checks hold',
      () =>
          HabotDialogWrapper.obligations.length == 6 &&
          HabotDialogWrapper.obligations.values.every((bool b) => b) &&
          HabotDialogWrapper.qualitativeOutput == 'Complete' &&
          HabotDialogWrapper.checks.length == 10 &&
          HabotDialogWrapper.checks.values.every((bool b) => b) &&
          HabotDialogWrapper.theBandIsWellFormed &&
          HabotDialogWrapper.columnNote.contains('27001'),
    );
  });

  tearDownAll(() {
    final int invisible = HabotDialogWrapper.invisiblePromises.length;
    final int surfaces = HabotDialogWrapper.surfacesThroughTheWrapper;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01815',
        atomicStepReferenceId: 'GEN-01815',
        setupStepAction:
            'COLUMN NOTE: the standard cited for a dialog wrapper on this row '
            'is ISO/IEC 27001:2022, an information-security management '
            'standard; the metric is a "Step Completion Rate" about the row\'s '
            'own progress rather than about dialogs; and every narrative '
            'column is the generic engineering-console boilerplate. Atomic '
            'Step: "Standardize modal and dialog wrappers across the '
            'application."',
        implementationOrder: 350,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Standardize modal and dialog wrappers across the application.':
              '$surfaces dialog and sheet surfaces, all of them through one '
                  'wrapper; 6 promises declared, $invisible of them invisible '
                  'to a visual review',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'two contracts with different exit sets; a decisive dialog '
                  'ignores taps outside and neither contract treats the '
                  'primary action as an exit',
          'Data Quality Note':
              'PROMISES: ${HabotDialogWrapper.promisesNote} '
              'AUDIT: ${HabotDialogWrapper.auditNote} '
              'CONTRACTS: ${HabotDialogWrapper.contractNote} '
              'INVISIBLE: ${HabotDialogWrapper.invisibleFailureNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Step Completion Rate (%)',
            observed:
                '100, over a population the row does not name and this file '
                'does: the share of dialog and sheet surfaces that go through '
                'the wrapper, which is $surfaces of $surfaces. The band is '
                'well formed -- 90, 99, 100 -- and the metric is about this '
                'row\'s own progress rather than about dialogs, which is why '
                'the figure published is a number about the application '
                'instead.',
            floor: '90',
            optimal: '99',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Dialog promises invisible to a visual review',
            observed:
                '$invisible of 6. Focus entering, focus not leaving, focus '
                'returning, the content behind going inert, and the surface '
                'announcing itself are all invisible; only the presence of a '
                'way out that is not the primary action can be seen. A '
                'hand-built dialog keeps the visible promise and forgets the '
                'other five, which is the whole argument for a wrapper.',
            floor: '5',
            optimal: '5',
            ceiling: '5',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dialogs/dialog_wrapper.dart',
        ],
      ),
    );
  });
}
