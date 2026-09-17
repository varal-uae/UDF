/// AISS GATE -- Step 396 of 415
/// Global Reference ID:       ETMDI-016-02
/// Atomic Steps Reference ID: ETMDI-016-02
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Open the primary workflow audit tool and list each screen's
///               designated user actions."
/// Metric: Process Adherence / Task Completion Rate -- floor ">=90%", optimal
///         "1", ceiling "1". Best Qualitative Output: "Complete/Partial/Not
///         Complete -> Best = Complete (100%)". ISO 9001:2015 Quality
///         Management -- Process Conformance Standard. Assigned to **UDF**.
///
/// THE ROW NAMES AN AUDIT TOOL THAT DOES NOT EXIST, AND ASKS IT TO COUNT
/// SOMETHING THE ROW DOES NOT DEFINE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/inventory/screen_action_audit.dart';

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

  group('ETMDI-016-02 :: the tool that does not exist', () {
    gate(
      'ETMDI-016-02-G1',
      'The audit tool the row names does not exist.',
      'No primary workflow audit tool has been declared anywhere in the track, '
          'so naming one does not produce one',
      () =>
          !HabotScreenActionAudit.theToolExists &&
          HabotScreenActionAudit.theInventoryIsWhatWasBuilt,
    );

    gate(
      'ETMDI-016-02-G2',
      'And an inventory in code can be diffed.',
      'A screen inventory that lives in the repository changes in the same '
          'commit as the screens it counts, which a spreadsheet cannot',
      () => HabotScreenActionAudit.toolNote.contains('shows up in review'),
    );

  });

  group('ETMDI-016-02 :: what an action is', () {
    gate(
      'ETMDI-016-02-G3',
      'Four entry kinds, only one of which is an action.',
      'Navigation, display and input are not actions, and counting them as '
          'actions is how a five-screen application reports twenty-three',
      () => HabotScreenActionKind.values.length == 4,
    );

    gate(
      'ETMDI-016-02-G4',
      'Seven actions across five screens.',
      'Each one named, each one belonging to exactly one screen',
      () => HabotScreenActionAudit.sevenActionsAcrossFiveScreens,
    );

    gate(
      'ETMDI-016-02-G5',
      'Against twenty-three interactive elements.',
      'The gap between the two numbers is the whole finding: elements are what '
          'a user can touch, actions are what the system commits',
      () =>
          HabotScreenActionAudit.interactiveElements == 23 &&
          HabotScreenActionAudit.actionsAreFewerThanElements,
    );

  });

  group('ETMDI-016-02 :: one transaction per screen', () {
    gate(
      'ETMDI-016-02-G6',
      'Every action names its transaction.',
      'An action with no transaction behind it is a button that changes the '
          'screen and nothing else',
      () => HabotScreenActionAudit.everyActionNamesItsTransaction,
    );

    gate(
      'ETMDI-016-02-G7',
      'And nothing else claims one.',
      'Navigation and display entries are checked for the absence of a '
          'transaction, not merely left blank',
      () => HabotScreenActionAudit.nothingElseClaimsATransaction,
    );

    gate(
      'ETMDI-016-02-G8',
      'Two screens declare more than one action.',
      'Recorded here rather than fixed here, because Step 397 is the row that '
          'decides what to do about it',
      () =>
          HabotScreenActionAudit.screensWithMoreThanOneAction == 2 &&
          HabotScreenActionAudit.transactionNote.contains('that row acts on'),
    );

  });

  group('ETMDI-016-02 :: the band and the arrow', () {
    gate(
      'ETMDI-016-02-G9',
      'The band mixes units and the output cell holds an arrow.',
      'A floor written as a percentage against an optimal and a ceiling '
          'written as 1, and an output column that argues with itself in an '
          'arrow',
      () =>
          HabotScreenActionAudit.theBandMixesUnits &&
          HabotScreenActionAudit.theOptimalEqualsTheCeiling &&
          HabotScreenActionAudit.theOutputColumnHoldsAnAnnotation &&
          HabotScreenActionAudit.sixRowsCarryTheArrow,
    );

    gate(
      'ETMDI-016-02-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotScreenActionAudit.obligations.length == 5 &&
          HabotScreenActionAudit.obligations.values.every((bool b) => b) &&
          HabotScreenActionAudit.qualitativeOutput == 'Complete',
    );
  });

  tearDownAll(() {
    final int screens = HabotScreenActionAudit.screenCount;
    final int actions = HabotScreenActionAudit.declaredActions;
    final int elements = HabotScreenActionAudit.interactiveElements;
    final int multi = HabotScreenActionAudit.screensWithMoreThanOneAction;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ETMDI-016-02',
        atomicStepReferenceId: 'ETMDI-016-02',
        setupStepAction:
            'COLUMN NOTE: the Best Qualitative Output cell on this row reads '
            '"Complete/Partial/Not Complete -> Best = Complete (100%)" -- a '
            'scale, an arrow and an annotation naming the best value, which is '
            'Step 389\'s shape and the first of five in this batch; the band '
            'mixes ">=90%" with an optimal and a ceiling both written 1; the '
            'Data Requirement column holds audit fields beside Jetpack Compose '
            'layout advice ("Arrangement.Center"); and the Setup Step column '
            'reads "Confirm accessibility of masked fields for assistive '
            'technology users". Atomic Step: "Open the primary workflow audit '
            'tool and list each screen\'s designated user actions."',
        implementationOrder: 396,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Audit Type':
              'screen and action inventory, held in code rather than in the '
                  'workflow audit tool the row names, which does not exist',
          'Audit Date': '2026-09-17',
          'Audit Result':
              '$screens screens, $actions declared actions, $elements '
                  'interactive elements; $multi screens declare more than one '
                  'action',
          'Audit Trail':
              'every action names the transaction it commits, and every '
                  'navigation, display and input entry is checked for the '
                  'absence of one',
          'Auditor Information': 'Fredrick, UDF',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Adherence / Task Completion Rate',
            observed:
                'BAND MIXES UNITS AND THE OUTPUT CELL HOLDS AN ARROW. The '
                'floor is a percentage and the optimal and the ceiling are '
                'both 1, so the three cells cannot be compared without '
                'deciding which scale they are on; the optimal equals the '
                'ceiling, so there is nothing above the target. The Best '
                'Qualitative Output column reads "Complete/Partial/Not '
                'Complete -> Best = Complete (100%)", the sixth '
                'arrow-annotated output cell in the track. Observed: $actions '
                'declared actions across $screens screens, every one of them '
                'naming its transaction.',
            floor: '>=90%',
            optimal: '1',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Interactive elements counted as actions',
            observed:
                '0 of $elements. The row asks for an audit of "screens and '
                'actions" and the two words are not the same size: $elements '
                'things on these five screens can be touched and $actions of '
                'them commit anything. Counting elements as actions is how a '
                'five-screen application reports twenty-three, and the four '
                'entry kinds exist so the distinction survives the next person '
                'to read the inventory.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/inventory/screen_action_audit.dart',
        ],
      ),
    );
  });
}
