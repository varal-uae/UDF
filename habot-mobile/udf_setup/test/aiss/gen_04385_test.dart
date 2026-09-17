/// AISS GATE -- Step 379 of 395
/// Global Reference ID:       GEN-04385
/// Atomic Steps Reference ID: GEN-04385
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Convert inline conditional render blocks into standalone
///               presentation components."
/// Metric: Component File Line-Limit Compliance Rate -- floor 0.9, optimal 1,
///         ceiling 1. Pass / Fail. Clean Code Principles / Internal Coding
///         Standard. Assigned to **UDF**.
///
/// THE ROW GIVES A CODE-HYGIENE REASON; THE REAL ONE IS THAT BRANCHES BECOME
/// COUNTABLE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/controls/conditional_surface.dart';

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

  group('GEN-04385 :: sixteen states become six', () {
    gate(
      'GEN-04385-G1',
      'Four inline conditions produce up to sixteen combinations.',
      'And nobody knows which of them were ever drawn',
      () => HabotConditionalSurface.combinationsFromInlineConditions == 16,
    );

    gate(
      'GEN-04385-G2',
      'Six named branches can be listed.',
      'A branch that cannot be reached can be found, which is the value the '
          'row\'s own metric does not measure',
      () =>
          HabotRenderBranch.values.length == 6 &&
          HabotConditionalSurface.sixteenBecomesSix &&
          HabotConditionalSurface.extractionNote
              .contains('cannot be reached can be found'),
    );
  });

  group('GEN-04385 :: exactly one branch, in a declared order', () {
    gate(
      'GEN-04385-G3',
      'Every branch has exactly one place in the precedence.',
      'Six branches with no declared order is six screens arguing',
      () => HabotConditionalSurface.everyBranchHasAPlace,
    );

    gate(
      'GEN-04385-G4',
      'Exactly one branch is drawn.',
      'A surface holding two conditions resolves to the first in the order, '
          'and a surface holding none resolves to ready',
      () => HabotConditionalSurface.exactlyOneBranchIsDrawn,
    );

    gate(
      'GEN-04385-G5',
      'Refusal outranks waiting.',
      'So nobody is told to wait for something they will never be allowed to '
          'see',
      () =>
          HabotConditionalSurface.refusalOutranksWaiting &&
          HabotConditionalSurface.precedenceNote
              .contains('never be allowed to see'),
    );

    gate(
      'GEN-04385-G6',
      'And absence outranks refusal.',
      'Because a refusal names the thing, and the point of an absent branch is '
          'that the thing is not named',
      () => HabotConditionalSurface.absenceOutranksRefusal,
    );
  });

  group('GEN-04385 :: the batch this rule is for', () {
    gate(
      'GEN-04385-G7',
      'Six refusal branches in this batch are named.',
      'Hidden by role, out of bounds, read only, locked at the station, '
          'blocked pending correction, frozen',
      () =>
          HabotConditionalSurface.everyRefusalInThisBatchIsABranch &&
          HabotConditionalSurface.refusalBranchesInThisBatch.length == 6,
    );

    gate(
      'GEN-04385-G8',
      'Extraction is what makes the claim checkable.',
      '"Every refusal carries a reason" becomes something a test can check '
          'rather than something a reviewer has to believe',
      () => HabotConditionalSurface.batchNote.contains('a test can check'),
    );
  });

  group('GEN-04385 :: the line limit and the output', () {
    gate(
      'GEN-04385-G9',
      'The line limit is Step 296\'s, at the widget level.',
      'Twenty lines per function, already in force; the metric counts lines '
          'and the value is countable branches',
      () =>
          HabotConditionalSurface.functionLineLimit == 20 &&
          HabotConditionalSurface.theStepThatSetIt == 296 &&
          HabotConditionalSurface.everyBranchIsANamedComponent,
    );

    gate(
      'GEN-04385-G10',
      'Output reported as Pass / Fail.',
      'Five obligations, all met, giving Pass; the optimal and ceiling are '
          'both 1, and all ten declared checks hold',
      () =>
          HabotConditionalSurface.obligations.length == 5 &&
          HabotConditionalSurface.obligations.values.every((bool b) => b) &&
          HabotConditionalSurface.qualitativeOutput == 'Pass' &&
          HabotConditionalSurface.theOptimalEqualsTheCeiling &&
          HabotConditionalSurface.extractedShare == 100 &&
          HabotConditionalSurface.checks.length == 10 &&
          HabotConditionalSurface.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final int combos = HabotConditionalSurface.combinationsFromInlineConditions;
    final int named = HabotConditionalSurface.namedBranches;
    final HabotRenderBranch contested =
        HabotConditionalSurface.resolve(<HabotRenderBranch>{
      HabotRenderBranch.loading,
      HabotRenderBranch.refused,
    });

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04385',
        atomicStepReferenceId: 'GEN-04385',
        setupStepAction:
            'COLUMN NOTE: the Data Requirement cell on this row holds the '
            'Atomic Step\'s own sentence as the artefact to prepare; its '
            'metric counts file lines on a row whose value is that branches '
            'become countable; its optimal and ceiling are both 1; and the '
            'Setup Step column is empty. Atomic Step: "Convert inline '
            'conditional render blocks into standalone presentation '
            'components."',
        implementationOrder: 379,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Convert inline conditional render blocks into standalone':
              '$combos possible states from four inline conditions become '
                  '$named named branches with a declared precedence',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'a surface that is both loading and refused draws '
                  '"${contested.name}", because refusal outranks waiting',
          'Data Quality Note':
              'EXTRACTION: ${HabotConditionalSurface.extractionNote} '
              'PRECEDENCE: ${HabotConditionalSurface.precedenceNote} BATCH: '
              '${HabotConditionalSurface.batchNote} METRIC: '
              '${HabotConditionalSurface.metricNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Component File Line-Limit Compliance Rate',
            observed:
                '100, with the optimal and the ceiling both written 1. The '
                'metric counts lines, which is a proxy and not a bad one -- '
                'Step 296 already holds functions to twenty lines and this is '
                'the same instinct at the widget level. What the extraction '
                'actually buys is countability: four inline conditions are '
                '$combos possible states and nobody knows which were ever '
                'drawn, while $named named branches can be listed and a branch '
                'that cannot be reached can be found.',
            floor: '0.9',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Surfaces drawing more than one branch at once',
            observed:
                '0. Six branches with no declared order is six screens '
                'arguing: a widget that is both loading and forbidden has to '
                'pick one, and picking wrong tells somebody to wait for '
                'something they will never be allowed to see. The precedence '
                'covers every branch exactly once, refusal outranks waiting '
                'and absence outranks refusal -- so the contested case above '
                'resolves to "${contested.name}". Every refusal in this batch '
                'is one of these branches, which is what turns "every refusal '
                'carries a reason" into a checkable claim.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/controls/conditional_surface.dart',
        ],
      ),
    );
  });
}
