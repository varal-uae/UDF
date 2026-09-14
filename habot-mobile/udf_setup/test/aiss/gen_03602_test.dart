/// AISS GATE -- Step 180 of 195
/// Global Reference ID:       GEN-03602
/// Atomic Steps Reference ID: GEN-03602
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Activate the self-chasing mechanism: Non-standard UI code
///               fails automated build checks, forcing developers to use
///               tokenized library components."
/// Metric: Developer Build Intercept Enforcement -- Floor 1, Optimal 1,
///         Ceiling 1. Pass / Fail.
///
/// THE INTERCEPT HAS BEEN ACTIVE SINCE STEP 4. What this step adds is the half
/// that was never built: it could not be measured. An intercept nobody
/// measures degrades without anyone deciding to let it.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/a11y_rules.dart';
import 'package:udf_setup/design_system/tokens/build_intercept.dart';
import 'package:udf_setup/design_system/tokens/governance_rules.dart';

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

  group('GEN-03602 :: the intercept, which already existed', () {
    gate(
      'GEN-03602-G1',
      'Atomic Step: "Non-standard UI code FAILS automated build checks."',
      'The guard is a blocking stage of the verification script rather than a '
          'report, and every rule in the catalogue is a blocking rule -- an '
          'advisory rule is possible in the model, and none is declared',
      () =>
          HabotBuildIntercept.isBlocking &&
          HabotBuildIntercept.guardStage.id == 'G-C' &&
          HabotBuildIntercept.script == 'tool/verify_aiss.sh' &&
          HabotBuildIntercept.blockingRuleCount ==
              HabotBuildIntercept.ruleCount &&
          HabotBuildIntercept.ruleCount == 16 &&
          HabotRuleSeverity.values.length == 2,
    );

    gate(
      'GEN-03602-G2',
      '"A codebase with raw hexes in it should not get as far as being told '
          'its tests pass."',
      'The guard runs BEFORE the test suite in the declared stage order, which '
          'is what makes it an intercept rather than a report filed after the '
          'fact',
      () {
        final List<String> ids = HabotBuildIntercept.stages
            .map((HabotInterceptStage s) => s.id)
            .toList();
        return HabotBuildIntercept.runsBeforeTests &&
            ids.indexOf('G-C') < ids.indexOf('G-D') &&
            HabotBuildIntercept.stages.length == 5 &&
            HabotBuildIntercept.stages
                .where((HabotInterceptStage s) => s.blocks)
                .length ==
                4 &&
            // The roll-up is the one stage that does not block: evidence is
            // written after the decision, not as part of it.
            !HabotBuildIntercept.stages.last.blocks;
      },
    );

    gate(
      'GEN-03602-G3',
      'Scope: the scanners walk lib/. What they do not walk is worth stating.',
      'The scanned root and the deliberate exclusions are declared with '
          'reasons, including the one that matters -- test fixtures have to be '
          'able to contain the constructs the rules forbid, or the rules could '
          'not be tested against planted violations',
      () =>
          HabotBuildIntercept.scannedRoot == 'lib/' &&
          HabotBuildIntercept.outsideScan.length == 3 &&
          HabotBuildIntercept.outsideScan['test/']!
              .contains('planted violations') &&
          HabotBuildIntercept.outsideScan.values
              .every((String r) => r.length > 15),
    );
  });

  group('GEN-03602 :: what was not measurable before', () {
    gate(
      'GEN-03602-G4',
      '"Each exemption is individually reasonable -- which is exactly what '
          'makes the aggregate the thing to watch."',
      'The exemption count across both rule families is pinned to a declared '
          'budget, so adding one changes a number in a diff rather than adding '
          'a line to a set literal nobody counts',
      () =>
          HabotBuildIntercept.exemptionsCarried ==
              HabotBuildIntercept.exemptionBudget &&
          HabotBuildIntercept.exemptionBudget == 21 &&
          HabotBuildIntercept.withinBudget &&
          HabotBuildIntercept.exemptionsCarried ==
              HabotGovernanceRules.exemptions.length +
                  HabotA11yRules.all.fold<int>(
                    0,
                    (int sum, HabotA11yRule r) => sum + r.exemptPaths.length,
                  ) &&
          HabotBuildIntercept.exemptionDriftNote
              .contains('without anyone deciding to let it'),
    );

    gate(
      'GEN-03602-G5',
      '"Forcing developers to use tokenized library components" is a claim '
          'about what happens after the build stops.',
      'No rule stops a developer without naming the component to use instead, '
          'and every exemption in either family carries a reason -- the two '
          'things that separate an intercept from an obstacle',
      () =>
          HabotBuildIntercept.rulesWithoutAnAlternative.isEmpty &&
          HabotBuildIntercept.unexplainedExemptions.isEmpty &&
          HabotBuildIntercept.insteadNote
              .contains('difference between an intercept and an obstacle'),
    );

    gate(
      'GEN-03602-G6',
      'Metric: Developer Build Intercept Enforcement -- 1 at every bound.',
      'Every enforcement condition holds and the figure is a conjunction '
          'rather than a rate, because the row gives no room between its floor '
          'and its ceiling for a partial answer',
      () =>
          HabotBuildIntercept.isEnforced &&
          HabotBuildIntercept.enforcementChecks.length == 6 &&
          HabotBuildIntercept.enforcementChecks.values.every((bool b) => b) &&
          HabotBuildIntercept.qualitativeOutput == 'Pass' &&
          HabotBuildIntercept.floor == 1 &&
          HabotBuildIntercept.optimal == 1 &&
          HabotBuildIntercept.ceiling == 1,
    );

    gate(
      'GEN-03602-G7',
      'A rule that admits no exemption is the strongest form a rule takes, and '
          'is worth counting separately.',
      'The absolute rules across both families are identified: the two hover '
          'rules, whose construct is unreachable on a touch device at all, and '
          'the two accessibility rules with no sanctioned implementation site',
      () =>
          HabotBuildIntercept.absoluteRuleCount == 4 &&
          HabotBuildIntercept.alreadyActiveNote.contains('since Step 4') &&
          HabotBuildIntercept.alreadyActiveNote
              .contains('could not be measured') &&
          HabotBuildIntercept.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03602',
        atomicStepReferenceId: 'GEN-03602',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Activate the self-chasing mechanism: Non-standard UI code '
            'fails automated build checks, forcing developers to use tokenized '
            'library components."',
        implementationOrder: 180,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotBuildIntercept',
          'Component Properties':
              '${HabotBuildIntercept.ruleCount} blocking rules over '
              '${HabotBuildIntercept.scannedRoot}; guard at stage '
              '${HabotBuildIntercept.guardStage.id} of '
              '${HabotBuildIntercept.stages.length}, before the test suite; '
              '${HabotBuildIntercept.exemptionsCarried} exemptions against a '
              'declared budget of ${HabotBuildIntercept.exemptionBudget}; '
              '${HabotBuildIntercept.absoluteRuleCount} rules admitting no '
              'exemption at all',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'ALREADY ACTIVE, AND SAYING SO IS THE POINT: verify_aiss.sh has '
              'run the poka-yoke guard at stage G-C, before the tests, and '
              'exited non-zero on the first violation since Step 4. The row '
              'asks for the mechanism to be activated; it is. What this step '
              'adds is the half that was never built -- three questions had no '
              'answer here: how much of the codebase is under the guard, how '
              'many exemptions the rule set carries, and whether that number '
              'went up.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Developer Build Intercept Enforcement',
            observed:
                'All ${HabotBuildIntercept.enforcementChecks.length} '
                'conditions hold: blocking rather than advisory, running '
                'before the tests, every rule blocking, every rule naming its '
                'alternative, every exemption explained, and the exemption '
                'count within budget.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Exemptions carried against the declared budget',
            observed:
                '${HabotBuildIntercept.exemptionsCarried} of '
                '${HabotBuildIntercept.exemptionBudget}. Pinning the count is '
                'the point: each exemption is individually reasonable, which '
                'is exactly what makes the aggregate the thing to watch. An '
                'addition now changes a declared number in a diff rather than '
                'adding one more line to a set literal.',
            floor: '<= 21',
            optimal: '<= 21',
            ceiling: '21',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tokens/build_intercept.dart',
        ],
      ),
    );
  });
}
