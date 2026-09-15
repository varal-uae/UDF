/// AISS GATE -- Step 289 of 295
/// Global Reference ID:       ETMDI-016-11
/// Atomic Steps Reference ID: ETMDI-016-11
/// Setup Step (Action): "Apply a fade/crossfade transition between the
///                      editable and locked visual states." (BELONGS TO THE
///                      DISABLED-STATE ROWS)
/// Atomic Step: "Strip out secondary form fields, dual call-to-action buttons,
///               and unrelated informational text from each single-task
///               screen."
/// Metric: Process Execution Quality Score -- Floor ">=90%", Optimal ">=98%",
///         Ceiling 1. Good / Average / Poor. ISO 9001:2015.
///
/// STRIPPING WITHOUT A DESTINATION IS DELETING, AND ONE OF THE NINE ELEMENTS
/// HAS NOWHERE TO GO.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/single_task_screen.dart';

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

  group('ETMDI-016-11 :: strip, and where it goes', () {
    gate(
      'ETMDI-016-11-G1',
      'Atomic Step: "Strip out secondary form fields".',
      'Nine elements are classified with a reason each: three stay, five move '
          'to a declared destination, and one has none',
      () =>
          HabotSingleTaskScreen.elements.length == 9 &&
          HabotSingleTaskScreen.everyElementIsExplained &&
          HabotSingleTaskScreen.theAuditFoundOneWithNowhereToGo,
    );

    gate(
      'ETMDI-016-11-G2',
      'Two thirds of the screen leaves it.',
      'The reduction the row wants is achieved and measured rather than '
          'asserted',
      () => (HabotSingleTaskScreen.shareRemoved - 2 / 3).abs() < 1e-9,
    );

    gate(
      'ETMDI-016-11-G3',
      'A taxonomy nobody uses was invented rather than derived.',
      'Every relocation kind appears in the audit, so the vocabulary came '
          'from the screen rather than being illustrated by it',
      () => HabotSingleTaskScreen.everyRelocationKindIsUsed,
    );

    gate(
      'ETMDI-016-11-G4',
      'The element with no destination is the output of the audit.',
      'A referral code nobody owns and nothing reads is reported rather than '
          'quietly removed under the heading of tidying up',
      () =>
          HabotSingleTaskScreen.withNoDestination.length == 1 &&
          HabotSingleTaskScreen.noDestinationNote.contains('tidying up'),
    );
  });

  group('ETMDI-016-11 :: emphasis, and centring', () {
    gate(
      'ETMDI-016-11-G5',
      'Atomic Step: "dual call-to-action buttons".',
      'Two actions remain and one of them is high emphasis, because the '
          'defect is two buttons of equal weight rather than two buttons',
      () =>
          HabotSingleTaskScreen.actions.length == 2 &&
          HabotSingleTaskScreen.highEmphasisActions == 1 &&
          HabotSingleTaskScreen.atMostOneHighEmphasisAction,
    );

    gate(
      'ETMDI-016-11-G6',
      'Read as a count, the rule removes the way back.',
      'The way back survives, and the cost of the count reading is recorded '
          'rather than argued',
      () =>
          HabotSingleTaskScreen.theCountRuleWouldHaveRemovedTheWayBack &&
          HabotSingleTaskScreen.thereIsStillAWayBack &&
          HabotSingleTaskScreen.emphasisNote.contains('most expensive thing'),
    );

    gate(
      'ETMDI-016-11-G7',
      'Row design note: "Arrangement.Center".',
      'Jetpack Compose, paired with the Compose call Step 217 already '
          'recorded -- and wrong for a form regardless, because a vertically '
          'centred form jumps when the keyboard opens',
      () =>
          HabotSingleTaskScreen.thisIsTheSecondComposeRow &&
          HabotSingleTaskScreen.aFormIsNotCentred &&
          HabotSingleTaskScreen.aSingleMessageStateIs &&
          HabotSingleTaskScreen.centringNote
              .contains('jumps when the keyboard opens'),
    );

    gate(
      'ETMDI-016-11-G8',
      'Metric: Process Execution Quality Score -- 90% / 98% / 1.',
      'Six obligations, all met, giving Good; all ten declared checks hold',
      () =>
          HabotSingleTaskScreen.obligations.length == 6 &&
          HabotSingleTaskScreen.obligations.values.every((bool b) => b) &&
          HabotSingleTaskScreen.qualityScore == 1.0 &&
          HabotSingleTaskScreen.qualitativeOutput == 'Good' &&
          HabotSingleTaskScreen.checks.length == 10 &&
          HabotSingleTaskScreen.checks.values.every((bool b) => b) &&
          HabotSingleTaskScreen.columnNote.contains('crossfade'),
    );
  });

  tearDownAll(() {
    final String staying = '${HabotSingleTaskScreen.staying.length}';
    final String moved = '${HabotSingleTaskScreen.relocated.length}';
    final String lost = '${HabotSingleTaskScreen.withNoDestination.length}';
    final String share =
        (HabotSingleTaskScreen.shareRemoved * 100).toStringAsFixed(1);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ETMDI-016-11',
        atomicStepReferenceId: 'ETMDI-016-11',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Apply a '
            'fade/crossfade transition between the editable and locked visual '
            'states", which belongs to the disabled-state rows at the end of '
            'this batch. Atomic Step: "Strip out secondary form fields, dual '
            'call-to-action buttons, and unrelated informational text from '
            'each single-task screen."',
        implementationOrder: 289,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSingleTaskScreen / HabotScreenElement',
          'Component Properties':
              '${HabotSingleTaskScreen.elements.length} elements audited: '
              '$staying essential, $moved relocated to a declared '
              'destination, $lost with none ($share% removed); two actions, '
              'one of them high emphasis; centring refused for anything with '
              'a field in it',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotSingleTaskScreen.noDestinationNote} '
              'EMPHASIS: ${HabotSingleTaskScreen.emphasisNote} '
              'CENTRING: ${HabotSingleTaskScreen.centringNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Execution Quality Score',
            observed:
                '100% over ${HabotSingleTaskScreen.obligations.length} '
                'declared obligations: every element classified with a '
                'reason, every departure given a destination or reported, one '
                'high-emphasis action, a way back kept, and centring refused '
                'where a field is present.',
            floor: '>=90%',
            optimal: '>=98%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Elements stripped with nowhere to go',
            observed:
                '$lost of ${HabotSingleTaskScreen.elements.length}. It is '
                'reported rather than removed, because stripping without a '
                'destination is a data loss nobody notices until the value is '
                'asked for.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/single_task_screen.dart',
        ],
      ),
    );
  });
}
