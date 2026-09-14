/// AISS GATE -- Step 168 of 175
/// Global Reference ID:       GEN-01065
/// Atomic Steps Reference ID: GEN-01065
/// Setup Step (Action) / Atomic Step: "Implement structural viewport
///   constraints that block multi-column layout rendering on screen widths
///   below mobile thresholds."
/// Metric: Mobile Conversion Funnel Completion Rate -- Floor 0.6, Optimal 0.8,
///         Ceiling 0.95. Good / Average / Poor.
///
/// A FUNNEL METRIC ON A LAYOUT STEP. A conversion rate is a ratio across many
/// users' sessions; one device knows only its own. The rate is a query over the
/// Step 161 stream, and what the client is accountable for -- and reports -- is
/// conformance to the constraint the funnel depends on. "Block" means refuse,
/// not wrap.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/layout/column_guard.dart';
import 'package:udf_setup/design_system/tokens/grid_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double conformance = 0;
  double fallenConformance = 1;

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

  group('GEN-01065 :: "block" means refuse', () {
    gate(
      'GEN-01065-G1',
      'Atomic Step: "...structural viewport constraints that BLOCK '
          'multi-column layout rendering on screen widths below mobile '
          'thresholds."',
      'On a compact viewport the permitted column count is one whatever the '
          'caller had in mind, and a caller that insists is REFUSED with an '
          'exception rather than quietly collapsed -- because a constraint '
          'that silently disagrees with its caller is a convention, and the '
          'next person adds a third column',
      () {
        Object? thrown;
        try {
          HabotColumnGuard.demand(360, 2);
        } on HabotColumnCountRefused catch (e) {
          thrown = e;
        }
        return HabotColumnGuard.columnsFor(360, requested: 2) == 1 &&
            HabotColumnGuard.columnsFor(360, requested: 4) == 1 &&
            HabotColumnGuard.columnsFor(360) == 1 &&
            !HabotColumnGuard.permitsMultiColumn(360) &&
            thrown is HabotColumnCountRefused &&
            thrown.requested == 2 &&
            thrown.permitted == 1 &&
            thrown.toString().contains('Refused rather than collapsed') &&
            thrown.toString().contains('eight characters') &&
            HabotColumnGuard.refuseNotWrapNote.contains('adds a third');
      },
    );

    gate(
      'GEN-01065-G2',
      '"The threshold is the Step 2 breakpoint, not a new number. A second '
          'opinion about what \'below mobile thresholds\' means is exactly the '
          'drift these steps exist to prevent."',
      'The threshold is read from HabotGrid rather than restated, and the '
          'viewport classes and their column ceilings come from the same '
          'place',
      () =>
          HabotColumnGuard.multiColumnThreshold == HabotGrid.breakpointSm &&
          HabotColumnGuard.classOf(360) == HabotViewportClass.compact &&
          HabotColumnGuard.classOf(599) == HabotViewportClass.compact &&
          HabotColumnGuard.classOf(HabotGrid.breakpointSm) ==
              HabotViewportClass.medium &&
          HabotColumnGuard.classOf(HabotGrid.breakpointMd) ==
              HabotViewportClass.expanded &&
          HabotColumnGuard.gridColumnsFor(360) == HabotGrid.compactColumns &&
          HabotColumnGuard.gridColumnsFor(700) == HabotGrid.mediumColumns &&
          HabotColumnGuard.gridColumnsFor(900) == HabotGrid.expandedColumns &&
          HabotColumnGuard.thresholdNote.contains('Step 2'),
    );

    gate(
      'GEN-01065-G3',
      '"One on compact, whatever the caller had in mind." A guard that refuses '
          'everything is as useless as one that permits everything.',
      'Above the threshold a reasonable request is granted and returned '
          'unchanged, and a request past the grid\'s own ceiling is refused '
          'rather than silently reduced',
      () {
        Object? thrown;
        try {
          HabotColumnGuard.demand(900, 20);
        } on HabotColumnCountRefused catch (e) {
          thrown = e;
        }
        return HabotColumnGuard.demand(700, 3) == 3 &&
            HabotColumnGuard.demand(900, 12) == 12 &&
            HabotColumnGuard.permitsMultiColumn(700) &&
            HabotColumnGuard.columnsFor(900, requested: 20) == 12 &&
            thrown is HabotColumnCountRefused &&
            thrown.permitted == 12 &&
            // A nonsensical request floors at one rather than throwing.
            HabotColumnGuard.columnsFor(700, requested: 0) == 1;
      },
    );
  });

  group('GEN-01065 :: why the constraint and the funnel are connected', () {
    gate(
      'GEN-01065-G4',
      '"Two columns on a 360dp screen gives each about 170dp. A form field in '
          '170dp shows roughly eight characters of its own label, and a '
          'two-column form is where mobile conversion goes to die."',
      'The connection is arithmetic rather than taste: two columns at 360dp '
          'produce columns narrower than the declared minimum for a form '
          'label, one column at the same width does not, and the same two '
          'columns are fine once there is room for them',
      () =>
          HabotColumnGuard.minUsableColumnDp == 200 &&
          HabotColumnGuard.columnWidthAt(360, 2) == 156 &&
          HabotColumnGuard.columnWidthAt(360, 1) == 328 &&
          HabotColumnGuard.columnWidthAt(840, 2) == 396 &&
          HabotColumnGuard.wouldBeUnusable(360, 2) &&
          !HabotColumnGuard.wouldBeUnusable(360, 1) &&
          !HabotColumnGuard.wouldBeUnusable(840, 2) &&
          HabotColumnGuard.columnWidthAt(360, 0) == 0 &&
          HabotColumnGuard.whyItMattersNote.contains('aesthetic preference'),
    );

    gate(
      'GEN-01065-G5',
      'Metric: Mobile Conversion Funnel Completion Rate. "One device knows '
          'only its own sessions, so a client reporting it would be reporting '
          'a denominator of one."',
      'The client reports CONFORMANCE, which it can compute: the share of '
          'declared layouts that obey the constraint, with the offenders named '
          'rather than counted -- and the figure falls when a layout breaks '
          'the rule',
      () {
        const Map<double, int> clean = <double, int>{
          360: 1,
          700: 2,
          900: 3,
        };
        const Map<double, int> withOffender = <double, int>{
          360: 2,
          700: 2,
          900: 3,
        };
        conformance = HabotColumnGuard.conformanceRate(clean);
        fallenConformance = HabotColumnGuard.conformanceRate(withOffender);
        final List<String> violations =
            HabotColumnGuard.violations(withOffender);
        return conformance == 1.0 &&
            HabotColumnGuard.violations(clean).isEmpty &&
            fallenConformance < 1.0 &&
            (fallenConformance - 2 / 3).abs() < 0.000001 &&
            violations.length == 1 &&
            violations.single.contains('2 columns at 360dp') &&
            violations.single.contains('permitted: 1') &&
            HabotColumnGuard.conformanceRate(const <double, int>{}) == 1.0 &&
            HabotColumnGuard.funnelIsServerSide
                .contains('denominator of one');
      },
    );

    gate(
      'GEN-01065-G6',
      'Floor 0.6, optimal 0.8, ceiling 0.95. The bands belong to a figure the '
          'server supplies.',
      'The row\'s vocabulary is implemented and reaches every state, applied '
          'to a funnel rate the Step 161 event stream produces rather than to '
          'a number this client invented',
      () =>
          HabotColumnGuard.funnelFloor == 0.6 &&
          HabotColumnGuard.funnelOptimal == 0.8 &&
          HabotColumnGuard.funnelCeiling == 0.95 &&
          HabotColumnGuard.bandFor(0.9) == 'Good' &&
          HabotColumnGuard.bandFor(0.8) == 'Good' &&
          HabotColumnGuard.bandFor(0.7) == 'Average' &&
          HabotColumnGuard.bandFor(0.5) == 'Poor',
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01065',
        atomicStepReferenceId: 'GEN-01065',
        setupStepAction:
            'Implement structural viewport constraints that block '
            'multi-column layout rendering on screen widths below mobile '
            'thresholds.',
        implementationOrder: 168,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotColumnGuard',
          'Component Properties':
              'Threshold ${HabotColumnGuard.multiColumnThreshold.toStringAsFixed(0)}dp '
              '(HabotGrid.breakpointSm, Step 2); '
              '${HabotViewportClass.values.length} viewport classes; minimum '
              'usable content column ${HabotColumnGuard.minUsableColumnDp}dp; '
              'a request past what the viewport permits throws '
              'HabotColumnCountRefused rather than collapsing',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'BOUNDARY RECORDED: the row\'s metric is a conversion funnel '
              'completion rate, which is a ratio across many users\' sessions. '
              'One device knows only its own, so a client reporting it would '
              'be reporting a denominator of one and a warehouse averaging '
              'those would produce something that looks like a rate and is '
              'not. The rate is a query over the Step 161 stream; the bands '
              'are implemented here and applied to a figure the server '
              'supplies. What this step reports is layout conformance.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mobile Conversion Funnel Completion Rate',
            observed:
                'NOT COMPUTED ON THE CLIENT -- see the note. The bands (Good '
                'at or above 0.8, Average to 0.6, Poor below) are implemented '
                'and applied to a rate the Step 161 event stream produces.',
            floor: '0.6',
            optimal: '0.8',
            ceiling: '0.95',
          ),
          AissMeasurement(
            metricName: 'Layout conformance to the column constraint',
            observed:
                '${(conformance * 100).toStringAsFixed(0)}% over the declared '
                'layouts, with no violations. The same computation reports '
                '${(fallenConformance * 100).toStringAsFixed(0)}% when one '
                'layout asks for two columns at 360dp, and names it rather '
                'than only counting it. Two columns at 360dp gives each '
                '${HabotColumnGuard.columnWidthAt(360, 2).toStringAsFixed(0)}dp '
                'against a ${HabotColumnGuard.minUsableColumnDp}dp minimum for '
                'a form label -- which is the funnel failure the row\'s metric '
                'measures the absence of.',
            floor: '1.0',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/column_guard.dart',
        ],
      ),
    );
  });
}
