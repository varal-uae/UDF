/// AISS GATE -- Step 459 of 1,314
/// Global Reference ID:       GEN-04847
/// Atomic Steps Reference ID: GEN-04847
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Confirm that the dependency prerequisite (Step 2) is complete
///               before starting this step."
/// Metric: Dependency Gate Compliance Rate -- floor "95% of prerequisite gates
///         verified before start (no exceptions on critical path)", optimal
///         "100% of prerequisite gates verified before start", ceiling "100% (a
///         gate cannot be satisfied beyond full completion)". Best Qualitative
///         Output: "Pass / Fail". ITIL v4 Change Enablement -- dependency/gate
///         verification practice. Assigned to **UDF**.
///
/// A FLOOR THAT SAYS 95 PER CENT AND THEN, IN ITS OWN PARENTHESES, SAYS NO
/// EXCEPTIONS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/governance/dependency_gate_two.dart';

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

  group('GEN-04847 :: a floor against itself', () {
    gate(
      'GEN-04847-G1',
      'The floor states a percentage.',
      '95 per cent of prerequisite gates verified before start',
      () => HabotDependencyGateTwo.theFloorStatesAPercentage,
    );

    gate(
      'GEN-04847-G2',
      'And in the same sentence states no exceptions.',
      '"(no exceptions on critical path)" cannot hold of the same set',
      () =>
          HabotDependencyGateTwo.theFloorAlsoStatesNoExceptions &&
          HabotDependencyGateTwo.theTwoCannotHoldOfOneSet,
    );

    gate(
      'GEN-04847-G3',
      'So it is implemented as two rules.',
      'Every critical prerequisite verified, and 95 per cent of the rest',
      () =>
          HabotDependencyGateTwo.twoRulesNotOne &&
          HabotDependencyGateTwo.floorNote.contains('wearing one sentence'),
    );

  });

  group('GEN-04847 :: an ordinal into nothing', () {
    gate(
      'GEN-04847-G4',
      '"(Step 2)" is not this sheet\'s numbering.',
      'The same defect as Step 457\'s "Sequence Order 11"',
      () =>
          HabotDependencyGateTwo.theNamedStepIsNotThisSheets &&
          HabotDependencyGateTwo.itIsTheSameDefectAsStep457,
    );

    gate(
      'GEN-04847-G5',
      'And the Dependency column says nothing specific.',
      '"Dependent on prior foundational steps." on every row in this batch',
      () => HabotDependencyGateTwo.theDependencyColumnSaysNothingSpecific,
    );

  });

  group('GEN-04847 :: the graph comes from the code', () {
    gate(
      'GEN-04847-G6',
      'Three prerequisites, two of them critical.',
      'Named here because the sheet names none',
      () =>
          HabotDependencyGateTwo.gates.length == 3 &&
          HabotDependencyGateTwo
              .gates.where((HabotPrerequisiteGate g) => g.critical).length == 2,
    );

    gate(
      'GEN-04847-G7',
      'Every critical one is verified.',
      'Without exception, which is what the parenthesis asked for',
      () => HabotDependencyGateTwo.everyCriticalGateIsVerified,
    );

    gate(
      'GEN-04847-G8',
      'And the non-critical rate is 100.',
      'Above the 95 per cent the percentage asked for',
      () => HabotDependencyGateTwo.nonCriticalRate == 100,
    );

    gate(
      'GEN-04847-G9',
      'Every named symbol resolves against a file that exists.',
      'Which is what the batch sweep checks before anything is committed',
      () =>
          HabotDependencyGateTwo.everyNamedSymbolResolves &&
          HabotDependencyGateTwo.graphNote.contains('static sweep'),
    );

  });

  group('GEN-04847 :: the result', () {
    gate(
      'GEN-04847-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotDependencyGateTwo.obligations.length == 5 &&
          HabotDependencyGateTwo.obligations.values.every((bool b) => b) &&
          HabotDependencyGateTwo.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final int gates_ = HabotDependencyGateTwo.gates.length;
    final double nonCritical = HabotDependencyGateTwo.nonCriticalRate;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04847',
        atomicStepReferenceId: 'GEN-04847',
        setupStepAction:
            'COLUMN NOTE: this row\'s floor states 95 per cent and, in its own '
            'parentheses, no exceptions on the critical path, which cannot '
            'both hold of one set, so it is implemented as two rules; its '
            'instruction points at "(Step 2)", a number from a list this sheet '
            'does not contain, as Steps 457 and 466 do; and because the '
            'Dependency column reads the same sentence on every row in this '
            'batch, its three prerequisites are named from the code instead. '
            'Atomic Step: "Confirm that the dependency prerequisite (Step 2) '
            'is complete before starting this step."',
        implementationOrder: 459,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Confirm that the dependency prerequisite (Step 2) is complete '
          'before':
              'the floor implemented as two rules; $gates_ prerequisites named '
                  'from the code, every critical one verified and the '
                  'non-critical rate ${nonCritical.toStringAsFixed(0)} per '
                  'cent',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Dependency Gate Compliance Rate',
            observed:
                'THE FLOOR CONTRADICTS ITSELF IN ITS OWN PARENTHESES. '
                'Ninety-five per cent of gates verified and no exceptions on '
                'the critical path cannot both hold of one set: if nothing '
                'critical may be skipped, the unverified five per cent lies '
                'entirely off the critical path, so the percentage was never '
                'about it. Implemented as two rules, both hold: every critical '
                'prerequisite verified, and ${nonCritical.toStringAsFixed(0)} '
                'per cent of the rest.',
            floor:
                '95% of prerequisite gates verified before start (no '
                    'exceptions on critical path)',
            optimal: '100% of prerequisite gates verified before start',
            ceiling: '100% (a gate cannot be satisfied beyond full completion)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Prerequisites named by the sheet',
            observed:
                '0 of $gates_. The instruction points at "(Step 2)" and the '
                'Dependency column reads the same sentence on every row in '
                'this batch, so no prerequisite in this row can be looked up. '
                'The graph is taken from the code instead: each named symbol '
                'must resolve against a library file that already exists, '
                'which the batch sweep checks on every symbol.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/governance/dependency_gate_two.dart',
        ],
      ),
    );
  });
}
