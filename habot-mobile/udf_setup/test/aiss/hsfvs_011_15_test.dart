/// AISS GATE -- Step 281 of 295
/// Global Reference ID:       HSFVS-011-15
/// Atomic Steps Reference ID: HSFVS-011-15
/// Setup Step (Action): "Locate API request ingestion gateway service
///                      responsible for object uploads." (DIFFERENT SUBJECT)
/// Atomic Step: "Implement an M3 AlertDialog to interrupt the user flow
///               securely upon a hard stop."
/// Metric: Observability / Alert Coverage -- Floor ">=90%", Optimal 1,
///         Ceiling 1. Good / Average / Poor. Google SRE Handbook.
///
/// A HARD STOP IS NOT AN ERROR CATEGORY AND NOT ONE OF THE FOUR SURFACE
/// INTENTS. TWO VOCABULARIES, THE SAME MISSING CONCEPT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/feedback/hard_stop_dialog.dart';

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

  group('HSFVS-011-15 :: the missing slot', () {
    gate(
      'HSFVS-011-15-G1',
      'Atomic Step: "upon a hard stop".',
      'Nine error categories are declared and none of them is terminal, '
          'checked over the enum\'s own names so a later addition breaks this '
          'gate rather than passing it',
      () =>
          HabotHardStopDialog.declaredErrorCategories == 9 &&
          HabotHardStopDialog.noErrorCategoryIsTerminal,
    );

    gate(
      'HSFVS-011-15-G2',
      'Step 272 found the same hole in the surface taxonomy.',
      'No surface intent is terminal either, so two vocabularies are missing '
          'the same concept and the pair is a recommendation rather than a '
          'coincidence',
      () =>
          HabotHardStopDialog.noSurfaceIntentIsTerminal &&
          HabotHardStopDialog.bothVocabulariesAreMissingTheSameConcept &&
          HabotHardStopDialog.missingSlotNote
              .contains('rather than done quietly'),
    );

    gate(
      'HSFVS-011-15-G3',
      'The surface still has to block.',
      'Mapped to the intent whose properties are right, it is a dialog at '
          'every width and cannot be swiped away',
      () =>
          HabotHardStopDialog.itIsADialogAtEveryWidth &&
          HabotHardStopDialog.itCannotBeSwipedAway,
    );
  });

  group('HSFVS-011-15 :: what it says, and when it listens', () {
    gate(
      'HSFVS-011-15-G4',
      'Three obligations: what happened, what it cost, what to do.',
      'The worked message carries all three, contains no code, and states the '
          'cost even though the answer is nothing',
      () =>
          HabotHardStopDialog.theMessageIsComplete &&
          HabotHardStopDialog.everyObligationIsNamed &&
          HabotHardStopDialog.obligationsOfTheMessage.length == 3,
    );

    gate(
      'HSFVS-011-15-G5',
      'Retrying cannot help after a hard stop.',
      'No retry is offered, and the template set cannot express the case '
          'because it keys retryability on a category this has none of -- '
          'open decision 26 reached from the other side',
      () =>
          HabotHardStopDialog.theTemplateSetCannotExpressThis &&
          HabotHardStopDialog.noRetryNote.contains('open decision 26'),
    );

    gate(
      'HSFVS-011-15-G6',
      'An interrupting dialog arrives under a moving thumb.',
      'A tap arriving on the same frame is ignored and the actions become '
          'live only after the declared enter transition',
      () => HabotHardStopDialog.aTapArrivingWithTheDialogIsIgnored,
    );

    gate(
      'HSFVS-011-15-G7',
      'A reflex confirmation should confirm the harmless action.',
      'The safe action holds initial focus and differs from the secondary '
          'one, and the reason a dialog that flickers past is worse than none '
          'is recorded',
      () =>
          HabotHardStopDialog.theSafeActionIsTheFocusedOne &&
          HabotHardStopDialog.movingThumbNote
              .contains('a screen that flickered'),
    );

    gate(
      'HSFVS-011-15-G8',
      'Metric: Observability / Alert Coverage, cited to the SRE Handbook.',
      'That is the share of failure modes that page an operator; this is a '
          'dialog that tells a person. The substitution is stated, the twin '
          'on Step 282 is named, and six coverage obligations all hold',
      () =>
          HabotHardStopDialog.coverage.length == 6 &&
          HabotHardStopDialog.coverage.values.every((bool b) => b) &&
          HabotHardStopDialog.coverageRate == 1.0 &&
          HabotHardStopDialog.qualitativeOutput == 'Good' &&
          HabotHardStopDialog.twoKindsOfAlertNote.contains('Step 282') &&
          HabotHardStopDialog.checks.length == 10 &&
          HabotHardStopDialog.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final String categories =
        '${HabotHardStopDialog.declaredErrorCategories}';
    final String settle =
        '${HabotHardStopDialog.inputSettleWindow.inMilliseconds}ms';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'HSFVS-011-15',
        atomicStepReferenceId: 'HSFVS-011-15',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Locate API '
            'request ingestion gateway service responsible for object '
            'uploads", a different subject. Atomic Step: "Implement an M3 '
            'AlertDialog to interrupt the user flow securely upon a hard '
            'stop."',
        implementationOrder: 281,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotHardStopDialog / HabotHardStop',
          'Component Properties':
              '$categories declared error categories, none terminal; four '
              'surface intents, none terminal; a blocking dialog at every '
              'width; a three-part message with no code in it; no retry; '
              'actions live after $settle',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotHardStopDialog.missingSlotNote} '
              'RETRY: ${HabotHardStopDialog.noRetryNote} '
              'TIMING: ${HabotHardStopDialog.movingThumbNote} '
              'METRIC: ${HabotHardStopDialog.twoKindsOfAlertNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Observability / Alert Coverage',
            observed:
                'NOT THE SAME KIND OF ALERT. The SRE Handbook measures the '
                'share of failure modes that page an operator; this is a '
                'dialog that tells the person holding the phone. Substituted: '
                'coverage over the six obligations this dialog has, which is '
                '100%.',
            floor: '>=90%',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Vocabularies with a slot for a terminal stop',
            observed:
                '0 of 2. Neither the nine error categories nor the four '
                'surface intents has one, and Step 272 reached the same gap '
                'from an environmental block. Recorded as a recommendation '
                'because closing it edits gated files from earlier steps.',
            floor: '2 of 2',
            optimal: '2 of 2',
            ceiling: '2 of 2',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/feedback/hard_stop_dialog.dart',
        ],
      ),
    );
  });
}
