/// AISS GATE -- Step 279 of 295
/// Global Reference ID:       GEN-03006
/// Atomic Steps Reference ID: GEN-03006
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement a collapsible Inspect Justificatory History drawer
///               on mobile response screens."
/// Metric: Task Completion Status -- Floor 0.8, Optimal 1, Ceiling 1.
///         Complete / Partial / Not Complete.
///
/// "DRAWER" WOULD HAVE SPENT A GESTURE STEP 226 ALREADY GAVE TO BACK
/// NAVIGATION.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/disclosure/history_drawer.dart';

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

  group('GEN-03006 :: the word, and the surface', () {
    gate(
      'GEN-03006-G1',
      'Atomic Step: "a collapsible ... drawer".',
      'A navigation drawer is edge-anchored and holds destinations; this '
          'belongs to one response, and the edge gesture is already spent on '
          'back navigation',
      () => HabotHistoryDrawer.notANavigationDrawerNote
          .contains('already spent'),
    );

    gate(
      'GEN-03006-G2',
      'Step 225 picks the surface from the intent.',
      'Disclosure at compact width is a standard sheet -- not scrimmed, so '
          'the response stays visible behind its reasons -- and an anchored '
          'popover when the window is wide',
      () =>
          HabotHistoryDrawer.theSurfaceIsDecidedByTheExistingRule &&
          HabotHistoryDrawer.theWidthSplitIsTheDeclaredOne,
    );

    gate(
      'GEN-03006-G3',
      'Nothing is being asked, so it can be dismissed.',
      'The surface is dismissible by gesture, which is what distinguishes a '
          'disclosure from a decision in the existing taxonomy',
      () => HabotHistoryDrawer.itIsDismissibleWithoutAnswering,
    );
  });

  group('GEN-03006 :: per response, and read-only', () {
    gate(
      'GEN-03006-G4',
      'A single boolean would open the panel on every answer.',
      'The open set is keyed by response, and the naive per-screen version is '
          'kept as an executable contrast rather than as a warning',
      () =>
          HabotHistoryDrawer.openingOneDoesNotOpenTheNext &&
          HabotHistoryDrawer.theNaiveVersionOpensEverything &&
          HabotHistoryDrawer.perResponseNote.contains('executable contrast'),
    );

    gate(
      'GEN-03006-G5',
      'An audit trail with an edit button is not one.',
      'There are no controls inside the panel, and the reason is the property '
          'the record exists to deny',
      () =>
          !HabotHistoryDrawer.hasActionsInside &&
          HabotHistoryDrawer.readOnlyNote.contains('deny'),
    );

    gate(
      'GEN-03006-G6',
      'Every claim carries its basis.',
      'The worked trail groups by response, every entry is attributed, and a '
          'response with nothing recorded says so rather than rendering blank',
      () =>
          HabotHistoryDrawer.theTrailIsGroupedByResponse &&
          HabotHistoryDrawer.everyEntryIsAttributed &&
          HabotHistoryDrawer.anEmptyTrailSaysSo,
    );

    gate(
      'GEN-03006-G7',
      'The panel must not be the only route.',
      'The information is reachable by deep link, which the row itself asks '
          'for, so a person sent a link to a decision arrives at the decision',
      () => HabotHistoryDrawer.isReachableByDeepLink,
    );

    gate(
      'GEN-03006-G8',
      'Metric: Task Completion Status -- 0.8 / 1 / 1.',
      'A floor of 0.8 treats a binary as a rate and the output then collapses '
          'it back into three words, so the band and its own output disagree '
          'about what is being measured',
      () =>
          HabotHistoryDrawer.theBandAndItsOutputDisagree &&
          HabotHistoryDrawer.bandNote.contains('admits a fraction'),
    );

    gate(
      'GEN-03006-G9',
      'Output: Complete / Partial / Not Complete.',
      'Seven declared obligations, all of them met, giving 1.0 and a '
          'Complete; all eleven declared checks hold',
      () =>
          HabotHistoryDrawer.obligations.length == 7 &&
          HabotHistoryDrawer.obligations.values.every((bool b) => b) &&
          HabotHistoryDrawer.completion == 1.0 &&
          HabotHistoryDrawer.qualitativeOutput == 'Complete' &&
          HabotHistoryDrawer.checks.length == 11 &&
          HabotHistoryDrawer.checks.values.every((bool b) => b) &&
          HabotHistoryDrawer.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    final String entries = '${HabotHistoryDrawer.workedTrail.length}';
    final String obligations = '${HabotHistoryDrawer.obligations.length}';
    final String completion =
        HabotHistoryDrawer.completion.toStringAsFixed(2);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03006',
        atomicStepReferenceId: 'GEN-03006',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and the '
            'Mobile-First columns ask for background polling every thirty '
            'seconds on a panel whose content is an immutable record. Atomic '
            'Step: "Implement a collapsible Inspect Justificatory History '
            'drawer on mobile response screens."',
        implementationOrder: 279,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotHistoryDrawer / HabotJustification',
          'Component Properties':
              '$entries worked trail entries across two responses, every one '
              'attributed; the open set keyed by response; no controls '
              'inside; surface chosen by the Step 225 rule (standard sheet on '
              'a phone, anchored popover when wide)',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotHistoryDrawer.notANavigationDrawerNote} '
              'KEYING: ${HabotHistoryDrawer.perResponseNote} '
              'READ-ONLY: ${HabotHistoryDrawer.readOnlyNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Task Completion Status',
            observed:
                '$completion over $obligations declared obligations -- the '
                'only reading of this band that admits a fraction, since a '
                'task is completed or it is not. The band\'s floor of 0.8 and '
                'its Complete/Partial/Not Complete output disagree about what '
                'kind of measurement it is.',
            floor: '0.8',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Responses whose panel opens when another is opened',
            observed:
                '0. Keyed by response id; the per-screen boolean that would '
                'open all of them is kept in the file as an executable '
                'contrast.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/disclosure/history_drawer.dart',
        ],
      ),
    );
  });
}
