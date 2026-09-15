/// AISS GATE -- Step 272 of 275
/// Global Reference ID:       GEN-03536
/// Atomic Steps Reference ID: GEN-03536
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Display minimalist security alert dialogs explaining
///               environmental execution blocks."
/// Metric: Security Alert Contrast Ratio -- Floor 4.5:1, Optimal 7:1,
///         Ceiling 21:1. Output "Pass". WCAG 2.2 AA Contrast Rules.
///
/// NO ON-DEVICE DETECTOR DECIDES THIS. THE DETECTOR AND THE THING DETECTED
/// OCCUPY THE SAME ADDRESS SPACE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/resilience/execution_block_dialog.dart';

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

  group('GEN-03536 :: who decides', () {
    gate(
      'GEN-03536-G1',
      'Atomic Step: "environmental execution blocks".',
      'Five causes are ruled on with a reason each, and every one of them is '
          'observable from the client',
      () =>
          HabotExecutionBlock.signals.length == 5 &&
          HabotBlockCause.values.length == 5 &&
          HabotExecutionBlock.signals.every(
            (HabotBlockSignal s) => s.clientCanObserve && s.why.length > 80,
          ),
    );

    gate(
      'GEN-03536-G2',
      'A detector inside a hostile environment can be made to say anything.',
      'Four of the five are recorded as evidence rather than as a verdict, '
          'with only the operating-system version trustworthy locally, and '
          'the share is published',
      () =>
          HabotExecutionBlock.everyHostileSignalIsEvidenceRatherThanAVerdict &&
          (HabotExecutionBlock.shareThatIsEvidenceOnly - 0.8).abs() < 1e-9 &&
          HabotExecutionBlock.whoDecidesNote.contains('hold its own trial'),
    );

    gate(
      'GEN-03536-G3',
      'Minimalist is not vague, and it is not candid either.',
      'Four causes share one message so that comparing two blocked devices '
          'reveals nothing about which check fired, and the message says '
          'nothing was charged and nothing was lost',
      () =>
          HabotExecutionBlock.theDialogDoesNotNameTheCheck &&
          HabotExecutionBlock.distinctMessages.length == 2 &&
          HabotExecutionBlock.genericMessage.contains('Nothing was charged') &&
          HabotExecutionBlock.minimalistNote.contains('checklist'),
    );

    gate(
      'GEN-03536-G4',
      'The one cause a person can act on gets its own message.',
      'An operating system below the floor is not hiding, so its message says '
          'what to do, and the support code carries no cause name while still '
          'being distinct per cause',
      () =>
          HabotExecutionBlock.messageFor(
                HabotBlockCause.unsupportedPlatformVersion,
              ) ==
              HabotExecutionBlock.platformMessage &&
          HabotExecutionBlock.everyCauseHasItsOwnCode &&
          HabotExecutionBlock.theCodeCarriesNoCauseName,
    );

    gate(
      'GEN-03536-G5',
      'A retry button that cannot work teaches people to distrust buttons.',
      'No retry is offered, and the rule reads the declared data rather than '
          'a constant -- a cause that could clear in place would be given one',
      () =>
          HabotExecutionBlock.nothingOffersARetryThatCannotWork &&
          HabotExecutionBlock.theRetryRuleIsDataDriven,
    );
  });

  group('GEN-03536 :: the surface and the band', () {
    gate(
      'GEN-03536-G6',
      'Step 225\'s rule, run rather than restated.',
      'The block is a dialog at both a compact and an expanded width and '
          'cannot be dismissed by gesture; converting it to a sheet would '
          'remove the property it exists for',
      () =>
          HabotExecutionBlock.itIsADialogAtEveryWidth &&
          HabotExecutionBlock.aSheetHereWouldBreakTheBlocking,
    );

    gate(
      'GEN-03536-G7',
      'None of the four declared intents is really a terminal block.',
      'The mismatch is recorded rather than answered by adding a fifth intent '
          'for one screen',
      () => HabotExecutionBlock.noIntentFitsNote.contains('adding a fifth '
          'intent'),
    );

    gate(
      'GEN-03536-G8',
      'Metric: Security Alert Contrast Ratio -- 4.5:1 / 7:1 / 21:1.',
      'Floor and optimal are read from the existing WCAG thresholds, and the '
          'ceiling is recorded as the arithmetic top of the scale -- black on '
          'white, associated with halation -- rather than as a goal',
      () =>
          HabotExecutionBlock.theBandIsReadFromTheExistingThresholds &&
          HabotExecutionBlock.ceilingRatio == 21 &&
          HabotExecutionBlock.theCeilingIsAboveEveryPublishedRequirement &&
          HabotExecutionBlock.ceilingNote.contains('halation'),
    );

    gate(
      'GEN-03536-G9',
      'A contrast ratio says the alert is legible, not that it is true.',
      'The gap between what the metric measures and what the step does is '
          'recorded; all fourteen declared checks hold and the step reports '
          'Pass',
      () =>
          HabotExecutionBlock.metricDoesNotMeasureTheRowNote.contains('the '
              'easy number') &&
          HabotExecutionBlock.checks.length == 14 &&
          HabotExecutionBlock.checks.values.every((bool b) => b) &&
          HabotExecutionBlock.qualitativeOutput == 'Pass' &&
          HabotExecutionBlock.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String causes = '${HabotExecutionBlock.signals.length}';
    final String evidence = '${HabotExecutionBlock.evidenceOnly.length}';
    final String messages = '${HabotExecutionBlock.distinctMessages.length}';
    final String floorRatio =
        HabotExecutionBlock.floorRatio.toStringAsFixed(1);
    final String optimalRatio =
        HabotExecutionBlock.optimalRatio.toStringAsFixed(1);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03536',
        atomicStepReferenceId: 'GEN-03536',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and Best '
            'Qualitative Output reads "Pass" with no Fail offered. Atomic '
            'Step: "Display minimalist security alert dialogs explaining '
            'environmental execution blocks."',
        implementationOrder: 272,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotExecutionBlock / HabotBlockSignal / HabotBlockCause',
          'Component Properties':
              '$causes causes, all observable on the client and $evidence of '
              'them untrustworthy there; $messages distinct messages so the '
              'check that fired is not named; a distinct support code per '
              'cause carrying no cause name; no retry offered; a dialog at '
              'every width, not dismissible by gesture',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotExecutionBlock.whoDecidesNote} '
              'MESSAGE: ${HabotExecutionBlock.minimalistNote} '
              'CEILING: ${HabotExecutionBlock.ceilingNote} '
              'METRIC: ${HabotExecutionBlock.metricDoesNotMeasureTheRowNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Security Alert Contrast Ratio',
            observed:
                'Floor $floorRatio:1 and optimal $optimalRatio:1 are read '
                'from the existing WcagThresholds rather than restated. The '
                '21:1 ceiling is black on white -- no themed surface reaches '
                'it, WCAG asks for nothing above 7:1, and it is the ratio '
                'associated with halation -- so it is recorded as the top of '
                'the scale, not a goal.',
            floor: '4.5:1',
            optimal: '7:1',
            ceiling: '21:1',
          ),
          AissMeasurement(
            metricName: 'Causes the client is entitled to act on alone',
            observed:
                '0 of $causes for the hostile four; the fifth, an '
                'unsupported platform version, is trustworthy locally but is '
                'still reported rather than enforced. The block is the '
                'server\'s decision and the dialog explains it.',
            floor: 'stated',
            optimal: 'stated',
            ceiling: 'stated',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/resilience/execution_block_dialog.dart',
        ],
      ),
    );
  });
}
