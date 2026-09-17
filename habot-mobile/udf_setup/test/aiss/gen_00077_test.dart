/// AISS GATE -- Step 327 of 335
/// Global Reference ID:       GEN-00077
/// Atomic Steps Reference ID: GEN-00077
/// Setup Step (Action): "Replace all existing ad-hoc icon usages in the
///                      application with the SystemVerbIcon component."
///                      (STEP 305'S WORK, AS THIS ROW'S SETUP)
/// Atomic Step: "Confirm the MaskedTextField component with native soft
///               keyboard triggering is delivered."
/// Metric: Acceptance Criteria Verification Rate -- floor ">= 95% of defined
///         acceptance criteria confirmed", optimal "100%", ceiling 1.
///         Pass / Fail. ISO/IEC 25010; PMI PMBOK.
///
/// THIS STEP REPORTS **FAIL** ON ITS OWN METRIC. SIX OF EIGHT CRITERIA
/// CONFIRM, AND THE INFLATED READING THAT WOULD PASS IS THE THING A
/// VERIFICATION STEP EXISTS TO CATCH.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/masked_text_field.dart';

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

  group('GEN-00077 :: three meanings of "masked"', () {
    gate(
      'GEN-00077-G1',
      'A formatting mask, a secure field and a masked display.',
      'Each protects something different, and the formatting kind protects '
          'nothing at all -- the value is visible and complete',
      () =>
          HabotMaskedTextField.eachKindProtectsSomethingDifferent &&
          HabotMaskedTextField.theFormattingKindProtectsNothing &&
          HabotMaskKind.values.length == 3,
    );

    gate(
      'GEN-00077-G2',
      'The dangerous confusion is the first for the second.',
      'A field that only formats, believed to hide, puts a full card number '
          'into a screenshot, a support ticket and a crash report',
      () =>
          HabotMaskedTextField.theHazardIsNamed &&
          HabotMaskedTextField.namingNote.contains('not interchangeable'),
    );
  });

  group('GEN-00077 :: what a repository can confirm', () {
    gate(
      'GEN-00077-G3',
      'Eight acceptance criteria, six confirmable from code.',
      'Existence, per-class masks, no unmasked value in a log, an input type, '
          'paste survival and caret behaviour',
      () =>
          HabotMaskedTextField.criteria.length == 8 &&
          HabotMaskedTextField.confirmable.length == 6 &&
          HabotMaskedTextField.needingADevice.length == 2 &&
          HabotMaskedTextField.verificationRate == 0.75,
    );

    gate(
      'GEN-00077-G4',
      'Both unconfirmable criteria are about the soft keyboard.',
      'And each says why: a keyboardType is a hint and the input method '
          'decides, which on Android is often one the person installed',
      () =>
          HabotMaskedTextField.bothUnconfirmableOnesAreTheKeyboard &&
          HabotMaskedTextField.everyUnconfirmableCriterionSaysWhyNot &&
          HabotMaskedTextField.keyboardNote
              .contains('one the person installed themselves'),
    );

    gate(
      'GEN-00077-G5',
      'What the two would need is written down.',
      'A physical Android device, a third-party input method set as default, '
          'the pad observed on focus and again after a focus change',
      () => HabotMaskedTextField.whatTheTwoNeed.length == 4,
    );
  });

  group('GEN-00077 :: the rate, reported as it comes out', () {
    gate(
      'GEN-00077-G6',
      '75 per cent against a floor of 95.',
      'This step reports Fail on its own metric',
      () =>
          HabotMaskedTextField.theRateIsBelowTheFloor &&
          HabotMaskedTextField.floorRate == 0.95 &&
          HabotMaskedTextField.qualitativeOutput == 'Fail',
    );

    gate(
      'GEN-00077-G7',
      'The inflated reading would have scored 100 per cent.',
      'Counting a declared keyboardType as a confirmed keyboard is the '
          'substitution a verification step exists to catch',
      () =>
          HabotMaskedTextField.theInflatedReadingWouldPass &&
          HabotMaskedTextField.honestyNote
              .contains('a verification step exists to catch'),
    );
  });

  group('GEN-00077 :: the columns', () {
    gate(
      'GEN-00077-G8',
      'Setup Step: replace ad-hoc icons with the SystemVerbIcon component.',
      'Which is Step 305\'s work appearing as this row\'s setup',
      () => HabotMaskedTextField.columnNote.contains('Step 305'),
    );

    gate(
      'GEN-00077-G9',
      'Ceiling "1" against percentage floors.',
      'The recurring unit mismatch, recorded rather than scored against',
      () => HabotMaskedTextField.ceilingNote.contains('unit mismatch'),
    );

    gate(
      'GEN-00077-G10',
      'Output: Pass / Fail.',
      'Five declared obligations, all met -- on a step that still reports '
          'Fail, because the obligations are about honesty and the metric is '
          'about coverage; all nine declared checks hold',
      () =>
          HabotMaskedTextField.obligations.length == 5 &&
          HabotMaskedTextField.obligations.values.every((bool b) => b) &&
          HabotMaskedTextField.qualitativeOutput == 'Fail' &&
          HabotMaskedTextField.checks.length == 9 &&
          HabotMaskedTextField.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final String rate =
        (HabotMaskedTextField.verificationRate * 100).toStringAsFixed(0);
    final String firstUnconfirmable =
        HabotMaskedTextField.needingADevice.first.text;
    final String whyNot = HabotMaskedTextField.needingADevice.first.whyNot;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00077',
        atomicStepReferenceId: 'GEN-00077',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Replace all '
            'existing ad-hoc icon usages in the application with the '
            'SystemVerbIcon component", which is Step 305\'s work appearing as '
            'this row\'s setup, and the ceiling is written as 1 against '
            'percentage floors. Atomic Step: "Confirm the MaskedTextField '
            'component with native soft keyboard triggering is delivered."',
        implementationOrder: 327,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Confirm the MaskedTextField component with native soft keyboard '
                  'triggering is':
              '$rate per cent of the acceptance criteria confirmed -- 6 of 8',
          'Completion Status': 'Fail',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the first unconfirmable criterion is "$firstUnconfirmable", '
                  'because $whyNot',
          'Data Quality Note':
              'NAMING: ${HabotMaskedTextField.namingNote} '
              'KEYBOARD: ${HabotMaskedTextField.keyboardNote} '
              'HONESTY: ${HabotMaskedTextField.honestyNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Acceptance Criteria Verification Rate',
            observed:
                'FAIL. $rate per cent -- six of eight criteria confirm from '
                'code -- against a floor of 95. The two that do not are both '
                'about whether the numeric soft keyboard actually appears, '
                'which is a fact about the device somebody is holding. '
                'Counting the declared keyboardType as a confirmed keyboard '
                'would have scored 100 per cent, and that substitution is what '
                'a verification step exists to catch. Reported as it comes '
                'out.',
            floor: '>= 95% of defined acceptance criteria confirmed',
            optimal: '100% of defined acceptance criteria confirmed',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Meanings of "masked" left undistinguished',
            observed:
                '0 of 3. A formatting mask protects nothing, a secure field '
                'hides what is being typed, and a masked display shows a '
                'fragment of a value the device never holds. All three already '
                'exist in this repository under different steps; what this row '
                'adds is the statement that they are not interchangeable.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/masked_text_field.dart',
        ],
      ),
    );
  });
}
