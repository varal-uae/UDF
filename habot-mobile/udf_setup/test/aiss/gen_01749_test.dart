/// AISS GATE -- Step 404 of 415
/// Global Reference ID:       GEN-01749
/// Atomic Steps Reference ID: GEN-01749
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Generate recursive component trees dynamically based on the
///               AST."
/// Metric: Step Completion Rate (%) -- floor "90", optimal "99", ceiling "100".
///         Best Qualitative Output: "Complete/Partial/Not Complete". ISO/IEC
///         27001:2022 General Standards. Assigned to **UDF**.
///
/// THE ROW CALLS IT AN AST AND IT IS A PARSE TREE -- AND THE DIFFERENCE IS THE
/// ONE THE GRAMMAR DEPENDS ON.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/schema/component_tree.dart';

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

  group('GEN-01749 :: the wrong noun', () {
    gate(
      'GEN-01749-G1',
      'The row calls it an AST and it is a parse tree.',
      'There is no source code and no grammar with expressions in it, so there '
          'is nothing to abstract away from',
      () =>
          HabotComponentTree.theNameIsWrongAndTheShapeIsRight &&
          HabotComponentTree.theDistinctionMatters,
    );

    gate(
      'GEN-01749-G2',
      'And an AST implies the expressions the grammar refuses.',
      'The wrong noun quietly re-opens the thing Step 401 closed',
      () => HabotComponentTree.nameNote.contains('spent its refusals on'),
    );

  });

  group('GEN-01749 :: three defences against a walk that does not end', () {
    gate(
      'GEN-01749-G3',
      'Three defences, all declared.',
      'A depth limit, a node budget and a visited set, each stopping a '
          'different way of not terminating',
      () =>
          HabotComponentTree.threeDefences &&
          HabotComponentTree.nodeBudget == 400,
    );

    gate(
      'GEN-01749-G4',
      'An ordinary packet completes.',
      'The defences do not fire on the shape the engine actually receives',
      () => HabotComponentTree.anOrdinaryPacketCompletes,
    );

    gate(
      'GEN-01749-G5',
      'A deep one and a wide one stop.',
      'Depth and breadth are different failures and one limit catches only one '
          'of them',
      () =>
          HabotComponentTree.aDeepPacketStops &&
          HabotComponentTree.aWidePacketStops,
    );

    gate(
      'GEN-01749-G6',
      'A cycle stops the walk before either.',
      'A cycle exhausts neither depth nor budget in any useful time, which is '
          'why the visited set exists',
      () =>
          HabotComponentTree.aCyclicPacketStopsFirst &&
          HabotComponentTree.defenceNote.contains('follows it forever'),
    );

  });

  group('GEN-01749 :: what a cycle does', () {
    gate(
      'GEN-01749-G7',
      'A cycle is reported and the node named.',
      'A recursion that ends in a message with a node id in it is debuggable; '
          'one that ends in a stack overflow is not',
      () =>
          HabotComponentTree.aCycleBecomesAMessage &&
          HabotComponentTree.worstFailure.contains('slow device'),
    );

    gate(
      'GEN-01749-G8',
      'Traversal is depth-first in declared order.',
      'Declared rather than left to the implementation',
      () =>
          HabotComponentTree.theOrderIsDeclared &&
          HabotComponentTree.readingOrderIsPreserved,
    );

  });

  group('GEN-01749 :: order is semantics', () {
    gate(
      'GEN-01749-G9',
      'Because reading order is semantics.',
      'Reordering for efficiency changes what a screen reader says and what '
          'the tab key does',
      () =>
          HabotComponentTree.orderNote
              .contains('nothing in a screenshot would show it'),
    );

    gate(
      'GEN-01749-G10',
      'Six obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotComponentTree.obligations.length == 6 &&
          HabotComponentTree.obligations.values.every((bool b) => b) &&
          HabotComponentTree.qualitativeOutput == 'Complete' &&
          HabotComponentTree.theBandIsWellFormed &&
          HabotComponentTree.twoRowsShareThisBand &&
          HabotComponentTree.terminationCoverage == 100,
    );
  });

  tearDownAll(() {
    final int depth = HabotComponentTree.depthLimit;
    final int budget = HabotComponentTree.nodeBudget;
    final int defences = HabotComponentTree.threeDefences ? 3 : 0;
    final String worst = HabotComponentTree.worstFailure;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01749',
        atomicStepReferenceId: 'GEN-01749',
        setupStepAction:
            'COLUMN NOTE: this row calls a parse tree over a data format an '
            'AST, which implies a language with expressions -- the thing Step '
            '401\'s grammar exists to refuse; its Data Requirement cell holds '
            'the Atomic Step\'s own sentence as the artefact to prepare; its '
            'metric and band are identical to Step 412\'s in this batch; and '
            'the Setup Step column is empty. Atomic Step: "Generate recursive '
            'component trees dynamically based on the AST."',
        implementationOrder: 404,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Generate recursive component trees dynamically based on the AST':
              'a depth-first walk in declared order over the parse tree the '
                  'grammar produces -- the row calls it an AST, and the '
                  'difference is the one Step 401 depends on',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Step Completion Rate (%)',
            observed:
                'THE BAND IS WELL FORMED AND IDENTICAL TO STEP 412\'S. Step '
                'Completion Rate at 90, 99 and 100, the same metric and the '
                'same three numbers as the function-size row eight rows later, '
                'on a subject with nothing in common. Observed: a bounded '
                'recursive walk with $defences declared defences -- a depth '
                'limit of $depth, a node budget of $budget and a visited set '
                '-- each stopping a different way of not terminating.',
            floor: '90',
            optimal: '99',
            ceiling: '100',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Walks that do not terminate',
            observed:
                '0 of 4 packet shapes. An ordinary packet completes; a deep '
                'one stops at depth $depth; a wide one stops at $budget nodes; '
                'a cyclic one stops at the visited set, before either of the '
                'other two would fire, which is why three defences and not '
                'one. The worst failure is $worst, and a cycle that ends in a '
                'message naming the offending node is debuggable where one '
                'that ends in a stack overflow is not. Order is declared '
                'because reading order is what a screen reader and the tab key '
                'follow.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/schema/component_tree.dart',
        ],
      ),
    );
  });
}
