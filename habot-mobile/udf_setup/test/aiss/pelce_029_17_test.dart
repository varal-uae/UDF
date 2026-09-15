/// AISS GATE -- Step 292 of 295
/// Global Reference ID:       PELCE-029-17
/// Atomic Steps Reference ID: PELCE-029-17
/// Setup Step (Action): "Document the timing framework and usage guidelines
///                      for engineers." (DIFFERENT SUBJECT)
/// Atomic Step: "Permanently disable and visually grey out the 'Release to
///               Tech' button if the reconciliation score != 0."
/// Metric: Design Reconciliation Score -- Floor "<=2 open gaps", Optimal
///         "0 open gaps", Ceiling "0 open gaps". Pass / Fail.
///
/// "PERMANENTLY" WOULD MEAN THE BUTTON NEVER COMES BACK, AND THE FLOOR
/// DESCRIBES A STATE THE SENTENCE ABOVE IT REFUSES.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/operations/permanent_disable.dart';

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

  group('PELCE-029-17 :: the word that is refused', () {
    gate(
      'PELCE-029-17-G1',
      'Atomic Step: "Permanently disable".',
      'The disable is conditional on a value that changes; the latched kind '
          'is declared in the vocabulary so that choosing it would be visible, '
          'and it is not chosen',
      () =>
          HabotPermanentDisable.theLatchedKindIsDeclaredAndUnused &&
          HabotPermanentDisable.kindUsed == HabotDisableKind.conditional,
    );

    gate(
      'PELCE-029-17-G2',
      'A button that used to work and now does not is worked around.',
      'The button comes back when the score reaches zero, and what a latch '
          'would have done with the same sequence is kept as an executable '
          'contrast',
      () =>
          HabotPermanentDisable.theButtonComesBack &&
          HabotPermanentDisable.aLatchWouldNeverComeBack &&
          HabotPermanentDisable.permanentlyNote
              .contains('work around rather than report'),
    );

    gate(
      'PELCE-029-17-G3',
      'Two rows must not disagree about one button.',
      'The enabled state agrees with the gate Step 291 bound, checked on both '
          'the clean and the unbalanced result',
      () => HabotPermanentDisable.itAgreesWithTheGate,
    );
  });

  group('PELCE-029-17 :: grey, and still readable', () {
    gate(
      'PELCE-029-17-G4',
      'A disabled control with no stated reason is a dead end.',
      'The control names its reason and what would change it, and the reason '
          'counts the open gaps rather than describing them vaguely',
      () =>
          HabotPermanentDisable.aDisabledControlIsNotADeadEnd &&
          HabotPermanentDisable.theReasonNamesTheCount,
    );

    gate(
      'PELCE-029-17-G5',
      'One wording per reason in the application.',
      'The sentences come from the Step 254 gate rather than being composed '
          'again here',
      () => HabotPermanentDisable.theSentencesComeFromTheGate,
    );

    gate(
      'PELCE-029-17-G6',
      'Atomic Step: "visually grey out".',
      'At the declared 0.38 disabled opacity a 7:1 label lands near 2.7:1 -- '
          'exempt from the contrast minimum and hard to read outdoors -- so '
          'the label stays legible and the explanation renders at full '
          'contrast beside it',
      () =>
          HabotPermanentDisable.greyingCostsMostOfTheContrast &&
          HabotPermanentDisable.disabledLabelOpacity == 0.38 &&
          HabotPermanentDisable.labelStaysLegible &&
          HabotPermanentDisable.reasonIsOutsideTheGreyedControl,
    );

    gate(
      'PELCE-029-17-G7',
      'A greyed control is where nobody looks for an explanation.',
      'The placement rule is recorded with its reason rather than left as a '
          'layout preference',
      () => HabotPermanentDisable.reasonPlacementNote
          .contains('reads as scenery'),
    );
  });

  group('PELCE-029-17 :: the band that argues with its own row', () {
    gate(
      'PELCE-029-17-G8',
      'Floor "<=2 open gaps" against a rule that disables on "!= 0".',
      'A score of 2 is inside the band and refused by the rule, so the '
          'floor describes a state the sentence above it does not allow',
      () =>
          HabotPermanentDisable.theFloorDescribesARefusedState &&
          HabotPermanentDisable.floorOpenGaps == 2 &&
          HabotPermanentDisable.bandContradictionNote.contains('read last'),
    );

    gate(
      'PELCE-029-17-G9',
      'Optimal and ceiling are both zero.',
      'The band has no room above target either, the same collapse as Steps '
          '271 and 275; all ten declared checks hold and the step reports '
          'Pass',
      () =>
          HabotPermanentDisable.theOptimalAndCeilingAreTheSame &&
          HabotPermanentDisable.checks.length == 10 &&
          HabotPermanentDisable.checks.values.every((bool b) => b) &&
          HabotPermanentDisable.qualitativeOutput == 'Pass' &&
          HabotPermanentDisable.columnNote.contains('share a widget'),
    );
  });

  tearDownAll(() {
    final String retained = HabotPermanentDisable.contrastRetained(7)
        .toStringAsFixed(2);
    final String reason = HabotPermanentDisable.controlFor(2).reason;
    final String fix = HabotPermanentDisable.controlFor(2).whatWouldChangeIt;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'PELCE-029-17',
        atomicStepReferenceId: 'PELCE-029-17',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Document '
            'the timing framework and usage guidelines for engineers", and '
            'the design notes are the same four lines as Step 291 -- the two '
            'rows share a widget description and disagree about what it does. '
            'Atomic Step: "Permanently disable and visually grey out the '
            '\'Release to Tech\' button if the reconciliation score != 0."',
        implementationOrder: 292,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotPermanentDisable / HabotDisabledControl',
          'Component Properties':
              '${HabotDisableKind.values.length} disable kinds, the latched '
              'one declared and unused; enabled state recomputed from the '
              'score rather than latched; reason "$reason" and remedy "$fix" '
              'rendered beside the control at full contrast',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotPermanentDisable.permanentlyNote} '
              'PLACEMENT: ${HabotPermanentDisable.reasonPlacementNote} '
              'CONTRAST: ${HabotPermanentDisable.greyNote} '
              'BAND: ${HabotPermanentDisable.bandContradictionNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Design Reconciliation Score',
            observed:
                'The rule is implemented -- disabled whenever the score is '
                'not zero, enabled the moment it is -- and the band '
                'contradicts it: a floor of 2 open gaps describes a state the '
                'Atomic Step refuses. Optimal and ceiling are both zero, so '
                'there is no room above target either.',
            floor: '<=2 open gaps',
            optimal: '0 open gaps',
            ceiling: '0 open gaps',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Contrast retained by a greyed label',
            observed:
                'About ${retained}:1 for a label that started at 7:1, at the '
                'declared 0.38 disabled opacity. Exempt from the 4.5 minimum '
                'and genuinely hard to read on a bright screen, which is why '
                'the explanation is rendered outside the greyed control '
                'rather than sharing its opacity.',
            floor: 'legible',
            optimal: 'legible',
            ceiling: 'legible',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/operations/permanent_disable.dart',
        ],
      ),
    );
  });
}
