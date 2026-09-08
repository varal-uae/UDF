/// AISS GATE -- Step 136 of 155
/// Global Reference ID:       ANSA-012
/// Atomic Steps Reference ID: ANSA-012-A02
/// Setup Step (Action): "Establish Contextual Navigation Header Framework."
/// Atomic Step: "Create the ContextualHeaderModule component file."
/// Metric: Layout Structural Consistency (Responsive Grid Compliance) --
///         Floor "90% of components on shared layout pattern", Optimal "100%",
///         Ceiling "100% (cannot exceed)".
///
/// THE FIRST DEPENDENCY-SATISFIED ROW IN THE SHEET. Dependency Count 1,
/// Dependency (Atomic Step Serial No) 4 -- which is ANSA-012-A01, built at
/// Step 9. Steps 1-135 were all zero-dependency rows.
///
/// THE COMPONENT FILE EXISTS AND IS NOT REBUILT. The work is the metric.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/layout/shared_layout_conformance.dart';
import 'package:udf_setup/design_system/navigation/contextual_header.dart';
import 'package:udf_setup/design_system/tokens/grid_tokens.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';

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

  group('ANSA-012-A02 :: the module the row names', () {
    gate(
      'ANSA-012-A02-G1',
      'Atomic Step: "Create the ContextualHeaderModule COMPONENT FILE." Step 9 '
          '(ANSA-012-A01) created it.',
      'The module exists, is named in the inventory, is on a shared layout '
          'pattern, and the decision not to recreate it is recorded in the '
          'code rather than left to a commit message',
      () {
        final HabotLayoutComponent module = HabotSharedLayout.components
            .firstWhere((HabotLayoutComponent c) => c.name ==
                'ContextualHeaderModule');
        return module.file == HabotSharedLayout.contextualHeaderModule &&
            module.file.endsWith('navigation/contextual_header.dart') &&
            module.isOnSharedPattern &&
            module.owningStep.contains('Step 9') &&
            HabotSharedLayout.notRebuiltNote.contains('two definitions of one '
                'surface');
      },
    );

    gate(
      'ANSA-012-A02-G2',
      'The row is only reachable because its dependency was satisfied. That is '
          'new: every one of Steps 1-135 was a zero-dependency row.',
      'The dependency relationship is recorded in the code, naming the serial '
          'and the step that discharged it, so the build order can be audited '
          'against the sheet rather than taken on trust',
      () =>
          HabotSharedLayout.dependencyNote.contains('Serial No) = 4') &&
          HabotSharedLayout.dependencyNote.contains('ANSA-012-A01') &&
          HabotSharedLayout.dependencyNote.contains('Step 9') &&
          HabotSharedLayout.dependencyNote.contains('zero-dependency'),
    );

    gate(
      'ANSA-012-A02-G3',
      'A module that is only named in an inventory is a claim. The header has '
          'to actually be the thing described.',
      'The real header still carries the framework Step 9 built -- a title '
          'policy that caps rather than clips, an elevation policy driven by '
          'scroll, and a compact action budget -- so the inventory entry '
          'describes a component that exists',
      () =>
          HabotContextualHeader.maxVisibleActionsCompact == 2 &&
          HabotContextualHeader.maxVisibleActionsWide == 4 &&
          HabotContextualHeader.maxVisibleActionsFor(HabotGrid.minSupportedWidth) ==
              HabotContextualHeader.maxVisibleActionsCompact &&
          HeaderTitlePolicy.maxChars == HabotDensity.maxHeaderTitleChars &&
          HeaderTitlePolicy.isWithinBounds(
            HeaderTitlePolicy.cap(
              'A contextual header title long enough to need capping',
            ),
          ),
    );
  });

  group('ANSA-012-A02 :: the metric nobody had computed', () {
    gate(
      'ANSA-012-A02-G4',
      'Metric: "% of components on shared layout pattern". Floor 90%, optimal '
          '100%.',
      'The rate is computed over a named inventory rather than asserted, every '
          'component sits on a declared pattern, and the figure reports in the '
          'row own Complete/Partial/Not Complete vocabulary',
      () =>
          HabotSharedLayout.components.length >= 10 &&
          HabotSharedLayout.complianceRate == 1.0 &&
          HabotSharedLayout.complianceRate >= HabotSharedLayout.floor &&
          HabotSharedLayout.offPattern.isEmpty &&
          HabotSharedLayout.qualitativeOutput == 'Complete',
    );

    gate(
      'ANSA-012-A02-G5',
      'A compliance rate that cannot fall is not a measurement.',
      'The inventory can represent a component that builds its own layout, and '
          'one added would lower the rate and be named -- checked by '
          'constructing the failing case rather than by trusting the type',
      () {
        const HabotLayoutComponent rogue = HabotLayoutComponent(
          name: 'RogueSurface',
          file: 'lib/design_system/rogue.dart',
          pattern: null,
          owningStep: 'none',
        );
        final List<HabotLayoutComponent> withRogue =
            <HabotLayoutComponent>[...HabotSharedLayout.components, rogue];
        final int onPattern = withRogue
            .where((HabotLayoutComponent c) => c.isOnSharedPattern)
            .length;
        final double degraded = onPattern / withRogue.length;
        return !rogue.isOnSharedPattern &&
            degraded < HabotSharedLayout.complianceRate &&
            degraded < 1.0;
      },
    );

    gate(
      'ANSA-012-A02-G6',
      'A pattern nothing is built on is a pattern that was abandoned without '
          'being deleted, and it inflates the appearance of consistency.',
      'Every declared layout pattern has at least one component on it, so the '
          'set of patterns is the set actually in use',
      () =>
          HabotSharedLayout.patternsInUse.length ==
              HabotLayoutPattern.values.length &&
          HabotLayoutPattern.values.every(
            HabotSharedLayout.patternsInUse.contains,
          ),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ANSA-012',
        atomicStepReferenceId: 'ANSA-012-A02',
        setupStepAction: 'Establish Contextual Navigation Header Framework.',
        implementationOrder: 136,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSharedLayout / ContextualHeaderModule',
          'Component Properties':
              '${HabotSharedLayout.components.length} components inventoried '
              'across ${HabotLayoutPattern.values.length} shared layout '
              'patterns; the header module itself is '
              '${HabotSharedLayout.contextualHeaderModule}',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Dependency Count 1, dependency serial 4 (ANSA-012-A01, Step 9) '
              '-- the first row in the sheet whose declared dependency this '
              'project had satisfied. The component file the row names was '
              'created at Step 9 and is verified here, not recreated.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName:
                'Layout Structural Consistency (Responsive Grid Compliance)',
            observed:
                '${(HabotSharedLayout.complianceRate * 100).toStringAsFixed(0)}'
                '% -- ${HabotSharedLayout.components.length} of '
                '${HabotSharedLayout.components.length} inventoried components '
                'sit on a declared shared layout pattern, and all '
                '${HabotLayoutPattern.values.length} patterns are in use. The '
                'rate is demonstrably able to fall: a component with no '
                'pattern lowers it and is named.',
            floor: '90% of components on shared layout pattern',
            optimal: '100% of components on shared layout pattern',
            ceiling: '100% (cannot exceed)',
          ),
          const AissMeasurement(
            metricName: 'Second header modules created',
            observed:
                '0. The file this row asks for was created at Step 9; a second '
                'one would be two definitions of one surface. The work in this '
                'row is the metric, which no earlier step computed.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/shared_layout_conformance.dart',
        ],
      ),
    );
  });
}
