/// AISS GATE -- Step 352 of 355
/// Global Reference ID:       GEN-02511
/// Atomic Steps Reference ID: GEN-02511
/// Setup Step (Action): (the generic engineering-console boilerplate --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Require text confirmation (e.g., typing DEACTIVATE) inside
///               the modal to proceed."
/// Metric: UI Compliance Rate (%) -- floor 0.95, optimal 1, ceiling 1.
///         Pass / Fail. Material Design 3, WCAG 2.2 AA, W3C Web Standards.
///
/// THE DATA REQUIREMENT CELL READS "DATA/ARTIFACTS TO PREPARE: DEACTIVATE".
/// THE SECOND GENERATOR ARTEFACT IN THIS BATCH, AND THE ONE THAT DOES NOT
/// KNOW IT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/dialogs/typed_confirmation.dart';

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

  group('GEN-02511 :: the artefact cell', () {
    gate(
      'GEN-02511-G1',
      'Data Requirement: "Data/artifacts to prepare: DEACTIVATE".',
      'The example word lifted out of the Atomic Step\'s parenthesis and '
          'printed where the artefact list belongs',
      () =>
          HabotTypedConfirmation.theArtefactCellIsTheExampleWord &&
          HabotTypedConfirmation.dataRequirementArtefact == 'DEACTIVATE',
    );

    gate(
      'GEN-02511-G2',
      'Second generator artefact in this batch, after Step 347.',
      'And the difference is that Step 347\'s cell knows what it is saying',
      () =>
          HabotTypedConfirmation.theOtherGeneratorArtefactRow == 347 &&
          HabotTypedConfirmation.generatorNote
              .contains('knows what it is saying'),
    );
  });

  group('GEN-02511 :: five locales, one word', () {
    gate(
      'GEN-02511-G3',
      'Every shipped locale has its own confirmation word.',
      'Five locales from Step 139, five distinct words, none shared',
      () =>
          HabotTypedConfirmation.everyLocaleHasItsOwnWord &&
          HabotTypedConfirmation.noTwoLocalesShareAWord &&
          HabotTypedConfirmation.shippedLocales.length == 5,
    );

    gate(
      'GEN-02511-G4',
      'Two of the five are not in Latin script.',
      'Asking somebody reading Urdu to type a Latin-script English word means '
          'leaving the dialog\'s language, switching keyboard, and switching '
          'back -- a different task with a different failure rate',
      () =>
          HabotTypedConfirmation.nonLatinLocales == 2 &&
          HabotTypedConfirmation.localisationNote
              .contains('switching keyboard'),
    );
  });

  group('GEN-02511 :: what the comparison forgives', () {
    gate(
      'GEN-02511-G5',
      'Four of five worked attempts are accepted.',
      'Case and a trailing space are not the thing being confirmed',
      () =>
          HabotTypedConfirmation.fourOfFiveAreAccepted &&
          HabotTypedConfirmation.attempts.length == 5,
    );

    gate(
      'GEN-02511-G6',
      'A word pasted with a zero-width space is accepted.',
      'Step 302 found those survive trim; the code points here are Step 302\'s '
          'list rather than a second one',
      () =>
          HabotTypedConfirmation.theZeroWidthPasteIsAccepted &&
          HabotTypedConfirmation.theInvisibleRuleIsReused,
    );

    gate(
      'GEN-02511-G7',
      'A different word is still refused.',
      'Permissiveness is argued rather than assumed: the risk this control '
          'guards against is acting without meaning to, not typing carelessly',
      () =>
          HabotTypedConfirmation.theWrongWordIsRefused &&
          HabotTypedConfirmation.comparisonNote
              .contains('acting without meaning to'),
    );
  });

  group('GEN-02511 :: why it exists in this batch', () {
    gate(
      'GEN-02511-G8',
      'It is Step 339\'s single-pointer alternative.',
      'Typing a word costs attention and needs no travel, so a person using a '
          'switch gets the same protection rather than an easier version',
      () =>
          HabotTypedConfirmation.itIsStep339sAlternative &&
          !HabotTypedConfirmation.itRequiresAPathGesture &&
          HabotTypedConfirmation.alternativeNote
              .contains('dangerous action'),
    );

    gate(
      'GEN-02511-G9',
      'Floor 0.95, optimal 1, ceiling 1.',
      'The top two values are the same number, which is the fourth band shaped '
          'this way in this batch after Steps 336, 339 and 346',
      () =>
          HabotTypedConfirmation.theOptimalEqualsTheCeiling &&
          HabotTypedConfirmation.collapsedTopsInThisBatch == 4 &&
          HabotTypedConfirmation.complianceRate == 1,
    );

    gate(
      'GEN-02511-G10',
      'Output reported as Pass / Fail.',
      'Six obligations, all met, giving Pass; all ten declared checks hold',
      () =>
          HabotTypedConfirmation.obligations.length == 6 &&
          HabotTypedConfirmation.obligations.values.every((bool b) => b) &&
          HabotTypedConfirmation.qualitativeOutput == 'Pass' &&
          HabotTypedConfirmation.checks.length == 10 &&
          HabotTypedConfirmation.checks.values.every((bool b) => b) &&
          HabotTypedConfirmation.columnNote.contains('DEACTIVATE'),
    );
  });

  tearDownAll(() {
    final int accepted = HabotTypedConfirmation.acceptedAttempts;
    final int locales = HabotTypedConfirmation.shippedLocales.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02511',
        atomicStepReferenceId: 'GEN-02511',
        setupStepAction:
            'COLUMN NOTE: the Data Requirement column on this row reads '
            '"Data/artifacts to prepare: DEACTIVATE", which is the example '
            'word from the Atomic Step printed where the artefact list '
            'belongs; the band sets a floor of 0.95 against an optimal and a '
            'ceiling both written "1"; and every narrative column is the '
            'generic engineering-console boilerplate. Atomic Step: "Require '
            'text confirmation (e.g., typing DEACTIVATE) inside the modal to '
            'proceed."',
        implementationOrder: 352,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'DEACTIVATE':
              'the confirmation word is localised across $locales shipped '
                  'locales rather than typed in English by everybody',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              '$accepted of 5 worked attempts are accepted: exact, lower case, '
                  'trailing space and a zero-width paste; a different word is '
                  'refused',
          'Data Quality Note':
              'GENERATOR: ${HabotTypedConfirmation.generatorNote} '
              'LOCALISATION: ${HabotTypedConfirmation.localisationNote} '
              'COMPARISON: ${HabotTypedConfirmation.comparisonNote} '
              'ALTERNATIVE: ${HabotTypedConfirmation.alternativeNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Compliance Rate (%)',
            observed:
                '1, over the population named here: the share of shipped '
                'locales carrying their own distinct confirmation word. The '
                'band repeats itself, with an optimal and a ceiling both at 1 '
                '-- fourth such band in this batch after Steps 336, 339 and '
                '346. The row\'s Data Requirement cell also holds the word '
                'DEACTIVATE as the artefact to prepare, which is the '
                'generator\'s own output printed as a requirement; Step 347 '
                'has the same shape and knows it.',
            floor: '0.95',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Shipped locales asked to type a foreign word',
            observed:
                '0 of $locales. The word is localised, so the control asks for '
                'a word the person is already reading. Two of the five locales '
                'are not in Latin script, where an English confirmation word '
                'is not friction but a different task: leave the dialog\'s '
                'language, switch keyboard, type a word you may not recognise, '
                'switch back. The comparison forgives case, surrounding space '
                'and the zero-width characters Step 302 found survive trim, '
                'and still refuses a different word.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dialogs/typed_confirmation.dart',
        ],
      ),
    );
  });
}
