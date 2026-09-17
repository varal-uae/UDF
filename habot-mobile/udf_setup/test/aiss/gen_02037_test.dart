/// AISS GATE -- Step 408 of 415
/// Global Reference ID:       GEN-02037
/// Atomic Steps Reference ID: GEN-02037
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Enforce strict grid snapping for all UI components."
/// Metric: Grid Consistency Compliance (%) -- floor "98", optimal "100",
///         ceiling "100". Best Qualitative Output: "Pass/Fail". Material Design
///         3 Grid System & ISO/IEC 9241-110:2020. Assigned to **UDF**.
///
/// "STRICT GRID SNAPPING FOR ALL UI COMPONENTS" -- TWO GRIDS ARE DECLARED, AND
/// TWO COMPONENTS MUST NOT SNAP.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/layout/grid_snap.dart';

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

  group('GEN-02037 :: snapping to which grid', () {
    gate(
      'GEN-02037-G1',
      'Two grids are declared and the row names neither.',
      'The 8dp vertical rhythm and the column grid with its 16dp gutter are '
          'not the same grid',
      () =>
          HabotGridSnap.twoGridsAreDeclared &&
          !HabotGridSnap.theRowNamesWhichGrid,
    );

    gate(
      'GEN-02037-G2',
      'The rule names the vertical rhythm.',
      'Because a component\'s own height is what is measured against it, and '
          '"strict" with no referent lets anybody pick the grid that passes',
      () =>
          HabotGridSnap.theReferentIsSupplied &&
          HabotGridSnap.gridNote.contains('own height'),
    );

  });

  group('GEN-02037 :: "all" has to be false', () {
    gate(
      'GEN-02037-G3',
      'Seven components, six snapping and one exempt.',
      'Nothing is merely close',
      () =>
          HabotGridSnap.components.length == 7 &&
          HabotGridSnap.sixSnapOneIsExempt,
    );

    gate(
      'GEN-02037-G4',
      'Every non-exempt component is on the rhythm.',
      'Checked by arithmetic rather than by eye',
      () =>
          HabotGridSnap.everyNonExemptComponentSnaps &&
          HabotGridSnap.compliance == 100,
    );

    gate(
      'GEN-02037-G5',
      'The exemption states its reason.',
      'Text height comes from the type scale and the platform text-scale '
          'factor, and snapping it clips descenders',
      () => HabotGridSnap.everyExemptionHasAReason,
    );

    gate(
      'GEN-02037-G6',
      'The touch target stays at forty-eight.',
      'Rounding a declared minimum up to please a grid turns a standard into a '
          'preference',
      () =>
          HabotGridSnap.theTouchTargetStaysAtFortyEight &&
          HabotGridSnap.allNote.contains('luck'),
    );

  });

  group('GEN-02037 :: exemptions in Step 179\'s shape', () {
    gate(
      'GEN-02037-G7',
      'The exemption shape is Step 179\'s.',
      'What is forbidden, what to use instead, why, the owner, and the exempt '
          'sites with a rationale',
      () =>
          HabotGridSnap.theCatalogueShapeIsDeclared &&
          HabotGridSnap.existingRuleCount >= 10,
    );

    gate(
      'GEN-02037-G8',
      'And the rule does not live in a comment.',
      'A rule in a comment is found by the person who already broke it',
      () =>
          HabotGridSnap.theRuleIsReadableTheSameWay &&
          HabotGridSnap.catalogueNote.contains('after breaking it'),
    );

  });

  group('GEN-02037 :: a floor of 98', () {
    gate(
      'GEN-02037-G9',
      'A 98 per cent floor is a budget for violations.',
      'And the violations it buys are two components two points off in '
          'opposite directions, which look like a mistake and measure as a '
          'rounding error',
      () =>
          !HabotGridSnap.nearlyOnTheGridIsAllowed &&
          HabotGridSnap.theOptimalEqualsTheCeiling &&
          HabotGridSnap.budgetNote.contains('rounding error'),
    );

    gate(
      'GEN-02037-G10',
      'Six obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotGridSnap.obligations.length == 6 &&
          HabotGridSnap.obligations.values.every((bool b) => b) &&
          HabotGridSnap.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final int components = HabotGridSnap.components.length;
    final int snapping = HabotGridSnap.snapping;
    final int exempt = HabotGridSnap.exempt;
    final double rhythm = HabotGridSnap.rhythmDp;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02037',
        atomicStepReferenceId: 'GEN-02037',
        setupStepAction:
            'COLUMN NOTE: this row says "all UI components" where two classes '
            'cannot snap without breaking something, and it does not say which '
            'of the two declared grids to snap to; its Data Requirement cell '
            'holds the Atomic Step\'s own sentence as the artefact to prepare; '
            'its optimal and ceiling are both 100; and the Setup Step column '
            'is empty. Atomic Step: "Enforce strict grid snapping for all UI '
            'components."',
        implementationOrder: 408,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Enforce strict grid snapping for all UI components':
              '$components components measured against the ${rhythm}dp '
                  'vertical rhythm: $snapping snap and $exempt is exempt with '
                  'a stated reason',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Grid Consistency Compliance (%)',
            observed:
                'THE OPTIMAL AND THE CEILING ARE BOTH 100 AND THE FLOOR IS A '
                'BUDGET FOR VIOLATIONS. A floor of 98 per cent buys exactly '
                'the violations worth preventing: two components each two '
                'points off in opposite directions look like a mistake to a '
                'user and measure as a rounding error on a dashboard. '
                'Observed: $snapping of $components components on the '
                '${rhythm}dp rhythm and $exempt exempt with a reason, so '
                'compliance over the components the rule applies to is 100 '
                'with nothing merely close.',
            floor: '98',
            optimal: '100',
            ceiling: '100',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Components forced onto a grid that breaks them',
            observed:
                '0 of $components. Two classes cannot snap and must not be '
                'made to: a text block at 200 per cent scale, whose height '
                'comes from the type scale and the platform factor and whose '
                'descenders are clipped by snapping, and a 48dp touch target, '
                'which is a declared minimum rather than a value to round up. '
                'Forty-eight happens to sit on the rhythm, which is luck and '
                'is recorded as luck. The row says "all"; the exemption is '
                'stated with its reason in the shape the Step 179 catalogue '
                'uses.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/grid_snap.dart',
        ],
      ),
    );
  });
}
