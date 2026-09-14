/// AISS GATE -- Step 216 of 235
/// Global Reference ID:       GEN-01694
/// Atomic Steps Reference ID: GEN-01694
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Map the 0-599dp width range to the WindowWidthClass.Compact
///               designation."
/// Metric: Step Completion Rate (%) -- Floor 90, Optimal 99, Ceiling 100.
///         Complete/Partial/Not Complete.
///
/// THIS REPOSITORY ALREADY DECLARES THAT BOUNDARY FOUR TIMES, BEHIND TWO ENUMS
/// WITH IDENTICAL MEMBER NAMES. The row asks for a fifth site and a third
/// enum. What was missing was the MD3 naming, the two classes MD3 added in
/// 2024, and a check that the sites already here agree.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/layout/column_guard.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/layout/window_size_class.dart';
import 'package:udf_setup/design_system/tokens/grid_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double completion = 0;

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

  void deferredGate(String id, String source, String description, String why) {
    test('[$id] (DEFERRED) $description', () {
      gates.add(
        AissGate(
          id: id,
          requirementSource: source,
          description: description,
          passed: false,
          deferred: true,
          detail: why,
        ),
      );
      expect(why.isNotEmpty, isTrue);
    });
  }

  group('GEN-01694 :: the mapping the row asks for', () {
    gate(
      'GEN-01694-G1',
      'Atomic Step: "Map the 0-599dp width range to the '
          'WindowWidthClass.Compact designation."',
      'The range is exactly 0 to 599 and 600 is not in it, and the boundary is '
          'read from the Step 2 constant rather than written as a number here',
      () =>
          HabotWindowSizeClass.compactCoversZeroTo599 &&
          HabotWindowSizeClass.boundaryFor(HabotMd3WindowClass.medium)
                  .minWidthDp ==
              HabotGrid.breakpointSm &&
          HabotWindowSizeClass.boundaryFor(HabotMd3WindowClass.compact)
                  .md3Name ==
              'WindowWidthSizeClass.Compact',
    );

    gate(
      'GEN-01694-G2',
      'Material 3 revised the ladder in 2024: Expanded is now 840-1199, with '
          'Large at 1200-1599 and Extra-large at 1600+.',
      'All five MD3 classes are declared with their MD3 names, and the two '
          'this repository has no behaviour for are marked as such and folded '
          'onto expanded explicitly rather than inherited by accident',
      () =>
          HabotMd3WindowClass.values.length == 5 &&
          HabotWindowSizeClass.ladder.length == 5 &&
          HabotWindowSizeClass.unsupportedClasses.length == 2 &&
          HabotWindowSizeClass.supportedEquivalentOf(
                HabotMd3WindowClass.large,
              ) ==
              HabotMd3WindowClass.expanded &&
          HabotWindowSizeClass.supportedEquivalentOf(
                HabotMd3WindowClass.extraLarge,
              ) ==
              HabotMd3WindowClass.expanded &&
          HabotWindowSizeClass.classOf(1600) ==
              HabotMd3WindowClass.extraLarge,
    );

    gate(
      'GEN-01694-G3',
      'A fractional width between two declared ranges must not fall through '
          'to a default.',
      'The lookup is monotone over the whole real line: 599.5 is compact, '
          '839.9 is medium, and no width produces a class lower than one below '
          'it',
      () {
        final List<double> probe = <double>[
          -10,
          0,
          599.5,
          600,
          839.9,
          840,
          1199.5,
          1200,
          5000,
        ];
        bool monotone = true;
        int previous = -1;
        for (final double w in probe) {
          final int index = HabotMd3WindowClass.values
              .indexOf(HabotWindowSizeClass.classOf(w));
          if (index < previous) {
            monotone = false;
          }
          previous = index;
        }
        return monotone &&
            HabotWindowSizeClass.classOf(599.5) ==
                HabotMd3WindowClass.compact &&
            HabotWindowSizeClass.classOf(839.9) ==
                HabotMd3WindowClass.medium &&
            HabotWindowSizeClass.classOf(-10) == HabotMd3WindowClass.compact;
      },
    );
  });

  group('GEN-01694 :: four declarations, two enums', () {
    gate(
      'GEN-01694-G4',
      '"HabotGrid.breakpointSm, the breakpointCompact aliases, '
          'HabotGrid.windowClassFor and HabotColumnGuard.classOf."',
      'All four sites are named, and the two existing enums agree at every '
          'boundary, one either side of each, and every declared device width '
          '-- so the duplication is redundant rather than divergent, which is '
          'the only version of it that is safe to leave in place',
      () =>
          HabotWindowSizeClass.declarationSites.length == 4 &&
          HabotWindowSizeClass.reconciliationWidths.length >= 8 &&
          HabotWindowSizeClass.enumDisagreements.isEmpty &&
          HabotWindowSizeClass.enumsAgreeAt(HabotGrid.breakpointSm) &&
          HabotWindowSizeClass.enumsAgreeAt(HabotGrid.breakpointMd - 1) &&
          HabotGrid.windowClassFor(500).name ==
              HabotColumnGuard.classOf(500).name,
    );

    gate(
      'GEN-01694-G5',
      'A fifth mapping that disagreed with the four already here would be '
          'worse than no mapping at all.',
      'This step\'s MD3 mapping agrees with both existing enums at every '
          'reconciliation width once the two unsupported classes are folded '
          'down',
      () =>
          HabotWindowSizeClass.mappingDisagreements.isEmpty &&
          HabotWindowSizeClass.agreesWithRepoAt(320) &&
          HabotWindowSizeClass.agreesWithRepoAt(744) &&
          HabotWindowSizeClass.agreesWithRepoAt(1280) &&
          HabotWindowSizeClass.fifthDeclarationNote
              .contains('not another mapping'),
    );

    gate(
      'GEN-01694-G6',
      '"HabotGrid.navigationCollapse is 768, which sits on none of the MD3 '
          'rungs."',
      'A fourth boundary is measured rather than argued: there are widths at '
          'which the navigation is collapsed and the grid class is not '
          'compact, and the iPad Mini in portrait at 744dp is one of them',
      () {
        final List<HabotDeviceProfile> caught =
            HabotWindowSizeClass.devicesInTheConflictBand;
        return HabotWindowSizeClass.navigationBoundaryConflicts.isNotEmpty &&
            caught.length == 1 &&
            caught.single.widthDp == 744 &&
            HabotGrid.navigationIsCollapsed(744) &&
            HabotWindowSizeClass.classOf(744) ==
                HabotMd3WindowClass.medium &&
            HabotGrid.navigationCollapse != HabotGrid.breakpointSm &&
            HabotGrid.navigationCollapse != HabotGrid.breakpointMd;
      },
    );

    gate(
      'GEN-01694-G7',
      'Metric: Step Completion Rate (%) -- floor 90, optimal 99.',
      'All eight declared checks hold, giving 100 -- including the one the '
          'four existing declaration sites never state: that the class is a '
          'property of the window, so halving a 1024dp tablet window moves the '
          'app from expanded to compact with no rebuild it asked for',
      () {
        completion = HabotWindowSizeClass.completionRate;
        return HabotWindowSizeClass.checks.length == 8 &&
            HabotWindowSizeClass.checks.values.every((bool b) => b) &&
            completion == 100 &&
            completion >= HabotWindowSizeClass.optimal &&
            HabotWindowSizeClass.qualitativeOutput == 'Complete' &&
            HabotWindowSizeClass.classIsAPropertyOfTheWindow &&
            HabotWindowSizeClass.splittingChangesClass(1024) &&
            HabotWindowSizeClass.classOf(
                  HabotWindowSizeClass.splitWindowWidth(1024),
                ) ==
                HabotMd3WindowClass.compact &&
            HabotWindowSizeClass.columnNote.contains('EMPTY');
      },
    );

    deferredGate(
      'GEN-01694-G8',
      'Two enums with identical member names over identical boundaries.',
      'HabotWindowClass and HabotViewportClass are collapsed into one type',
      'HabotWindowClass is used by five files and HabotViewportClass by one, '
          'and they are owned by Step 2 and Step 169 respectively. Collapsing '
          'them is a rename across six files that this step has no mandate to '
          'make, so the duplication is measured and proved harmless instead: '
          'the two agree at every boundary, one either side of each, and every '
          'declared device width. Raised as an open item.',
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01694',
        atomicStepReferenceId: 'GEN-01694',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Map the 0-599dp width range to the '
            'WindowWidthClass.Compact designation."',
        implementationOrder: 216,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotWindowSizeClass / HabotMd3WindowClass',
          'Component Properties':
              '${HabotMd3WindowClass.values.length} MD3 classes with their MD3 '
              'names, ${HabotWindowSizeClass.unsupportedClasses.length} of '
              'them folded onto expanded explicitly; boundaries read from the '
              'Step 2 constants; '
              '${HabotWindowSizeClass.declarationSites.length} existing '
              'declaration sites reconciled across '
              '${HabotWindowSizeClass.reconciliationWidths.length} widths',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: the compact/medium/expanded boundaries are declared '
              'FOUR times in this repository -- HabotGrid.breakpointSm and '
              'breakpointMd, the breakpointCompact/Medium/Expanded aliases for '
              'the same constants, HabotGrid.windowClassFor onto '
              'HabotWindowClass, and HabotColumnGuard.classOf onto '
              'HabotViewportClass. Two enums, three identical member names '
              'each, one pair of constants underneath. The row asks for a '
              'fifth site and a third enum, and a fifth mapping that disagreed '
              'with the four already here would be worse than none. What was '
              'actually missing: the MD3 NAME for each class, the two classes '
              'MD3 added in 2024 (Large at 1200, Extra-large at 1600), and a '
              'check that the existing sites agree -- they do, at every '
              'boundary and every declared device width. SECOND FINDING: '
              'HabotGrid.navigationCollapse is 768, which sits on none of the '
              'MD3 rungs, so between 768 and 839 the navigation is collapsed '
              'while the grid class is medium. The iPad Mini in portrait, at '
              '744dp, is the declared device that lands there. THIRD: the '
              'class is a property of the WINDOW, not the device -- halving a '
              '1024dp tablet window puts the app at 512dp, which is compact. '
              'ONE DEFERRED GATE: collapsing the two enums is a rename across '
              'six files this step has no mandate to make.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Step Completion Rate (%)',
            observed:
                '${completion.toStringAsFixed(0)} over '
                '${HabotWindowSizeClass.checks.length} checks: the row\'s '
                '0-599 mapping, all five MD3 classes named, the two '
                'unsupported ones folded explicitly, both existing enums '
                'reconciled, boundaries read from Step 2, the fourth boundary '
                'measured, and the window-not-device property demonstrated.',
            floor: '90',
            optimal: '99',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Declaration sites reconciled',
            observed:
                '${HabotWindowSizeClass.declarationSites.length} sites, '
                '${HabotWindowSizeClass.reconciliationWidths.length} widths, '
                '${HabotWindowSizeClass.enumDisagreements.length} '
                'disagreements. The duplication is redundant rather than '
                'divergent, which is the only version of it that is safe to '
                'leave in place -- and it is left in place, as a deferred '
                'item, because collapsing it is a rename across six files.',
            floor: '0 disagreements',
            optimal: '0 disagreements',
            ceiling: '0 disagreements',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/window_size_class.dart',
        ],
      ),
    );
  });
}
