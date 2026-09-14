/// AISS GATE -- Step 220 of 235
/// Global Reference ID:       AWCV-015
/// Atomic Steps Reference ID: AWCV-015
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Define the layout requirements for the split-screen matrix."
/// Metric: Process Execution Quality (%) -- Floor 95, Optimal 99, Ceiling 100.
///         Pass/Fail.
///
/// MECHANICAL SHEET DEFECT: this row's Expected Output is "production-ready
/// data governance operating manual" and its Common Library is
/// governance/roles/operating-model-privileges.json, while its Atomic Step is
/// about layout. Two columns carried onto the wrong row. The Atomic Step is
/// implemented and the mismatch is reported.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/layout/pane_split.dart';
import 'package:udf_setup/design_system/layout/split_matrix_requirements.dart';
import 'package:udf_setup/design_system/layout/window_size_class.dart';
import 'package:udf_setup/design_system/tokens/grid_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double quality = 0;

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

  group('AWCV-015 :: the column defect', () {
    gate(
      'AWCV-015-G1',
      'Expected Output: "production-ready data governance operating manual for '
          'technical workflows." Common Library: '
          '"governance/roles/operating-model-privileges.json." Atomic Step: '
          '"Define the layout requirements for the split-screen matrix."',
      'The two columns describe a data-governance artefact and the Atomic Step '
          'describes a layout, so the columns have been carried onto the wrong '
          'row -- recorded rather than followed, because following them would '
          'produce a privileges file from a row about panes',
      () =>
          HabotSplitMatrix.columnsDescribeADifferentArtefact &&
          HabotSplitMatrix.rowExpectedOutput.contains('governance') &&
          HabotSplitMatrix.rowCommonLibrary.contains('privileges') &&
          HabotSplitMatrix.rowAtomicStep.contains('split-screen matrix') &&
          HabotSplitMatrix.columnMismatchNote.contains('batches 3 and 4'),
    );
  });

  group('AWCV-015 :: the matrix', () {
    gate(
      'AWCV-015-G2',
      '"Layout requirements for the split-screen matrix" is a grid: window '
          'class by pane relation.',
      'Fifteen cells, one per combination, each with a unique id -- so the '
          'matrix is total over both axes rather than covering the '
          'combinations somebody thought of',
      () =>
          HabotSplitMatrix.cellCount == 15 &&
          HabotSplitMatrix.everyCellIsNamed &&
          HabotSplitMatrix.cells
                  .map((HabotMatrixCell c) => c.id)
                  .toSet()
                  .length ==
              15 &&
          HabotMd3WindowClass.values.length *
                  HabotPaneRelation.values.length ==
              15,
    );

    gate(
      'AWCV-015-G3',
      '"A cell that is usable at its widest width tells you nothing."',
      'Each class is evaluated at its narrowest width -- compact at the 320dp '
          'minimum supported width, medium at 600, expanded at 840 -- rather '
          'than at a comfortable one',
      () =>
          HabotSplitMatrix.representativeWidthFor(
                HabotMd3WindowClass.compact,
              ) ==
              HabotGrid.minSupportedWidth &&
          HabotSplitMatrix.representativeWidthFor(
                HabotMd3WindowClass.medium,
              ) ==
              HabotGrid.breakpointSm &&
          HabotSplitMatrix.representativeWidthFor(
                HabotMd3WindowClass.expanded,
              ) ==
              HabotGrid.breakpointMd &&
          HabotSplitMatrix.representativeHeightDp == 568 &&
          HabotSplitMatrix.narrowestWidthNote.contains('comes out broken'),
    );

    gate(
      'AWCV-015-G4',
      'A matrix is worth building only if it answers cells nobody had thought '
          'about.',
      'The two window classes this repository has no behaviour for still have '
          'six cells between them, so Large and Extra-large are answered '
          'rather than left to fall through',
      () =>
          HabotSplitMatrix.cellsForUnsupportedClasses.length == 6 &&
          HabotWindowSizeClass.unsupportedClasses.length == 2 &&
          HabotSplitMatrix.cellFor(
                HabotMd3WindowClass.extraLarge,
                HabotPaneRelation.peers,
              ).presentation ==
              HabotPanePresentation.sideBySide,
    );

    gate(
      'AWCV-015-G5',
      'On a compact window a master and a detail must not both be on screen.',
      'The three compact cells resolve as Step 218 requires -- peers stacked, '
          'master-detail and supporting navigated -- and a navigated cell '
          'gives its pane the whole window, which is why no navigated cell can '
          'be unusable',
      () =>
          HabotSplitMatrix.cellFor(
                HabotMd3WindowClass.compact,
                HabotPaneRelation.peers,
              ).presentation ==
              HabotPanePresentation.stacked &&
          HabotSplitMatrix.cellFor(
                HabotMd3WindowClass.compact,
                HabotPaneRelation.masterDetail,
              ).presentation ==
              HabotPanePresentation.navigated &&
          HabotSplitMatrix.cellFor(
                HabotMd3WindowClass.compact,
                HabotPaneRelation.supporting,
              ).presentation ==
              HabotPanePresentation.navigated &&
          HabotSplitMatrix.everyUnusableCellShowsBothPanes,
    );

    gate(
      'AWCV-015-G6',
      '"A matrix with no unusable cells still has a tightest one, and that is '
          'the cell a change to any of the three inputs breaks first."',
      'No cell leaves its leading pane below the usable minimum, and the '
          'tightest is medium/master-detail at 210dp -- ten above the 200dp '
          'floor, which is the margin the whole matrix is standing on',
      () {
        final HabotMatrixCell tightest = HabotSplitMatrix.tightestCell;
        return HabotSplitMatrix.unusableCells.isEmpty &&
            tightest.windowClass == HabotMd3WindowClass.medium &&
            tightest.relation == HabotPaneRelation.masterDetail &&
            tightest.leadingExtentDp == 210 &&
            HabotSplitMatrix.tightestMarginDp == 10 &&
            tightest.usable;
      },
    );

    gate(
      'AWCV-015-G7',
      'Metric: Process Execution Quality (%) -- floor 95, optimal 99. '
          'Pass/Fail.',
      'All eight declared checks hold, giving 100 and a Pass -- including the '
          'one that records the mismatched columns, because a step that '
          'implemented the right thing and said nothing about the wrong '
          'columns would leave the next reader to rediscover them',
      () {
        quality = HabotSplitMatrix.executionQuality;
        return HabotSplitMatrix.checks.length == 8 &&
            HabotSplitMatrix.checks.values.every((bool b) => b) &&
            quality == 100 &&
            quality >= HabotSplitMatrix.optimal &&
            HabotSplitMatrix.qualitativeOutput == 'Pass' &&
            HabotSplitMatrix.matrixIsTheReadingNote.contains('foldable') &&
            HabotSplitMatrix.columnNote.contains('different row');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'AWCV-015',
        atomicStepReferenceId: 'AWCV-015',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and the '
            'Expected Output and Common Library columns belong to a different '
            'row -- see the Data Quality Note. Atomic Step: "Define the layout '
            'requirements for the split-screen matrix."',
        implementationOrder: 220,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSplitMatrix / HabotMatrixCell',
          'Component Properties':
              '${HabotSplitMatrix.cellCount} cells over '
              '${HabotMd3WindowClass.values.length} window classes and '
              '${HabotPaneRelation.values.length} pane relations; each class '
              'evaluated at its narrowest width and the shortest declared '
              'phone height; every cell carries its presentation, its leading '
              'pane extent and whether that extent is usable',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'MECHANICAL SHEET DEFECT: this row\'s Expected Output is '
              '"production-ready data governance operating manual for '
              'technical workflows" and its Common Library is '
              'governance/roles/operating-model-privileges.json, while its '
              'Atomic Step is about a split-screen layout. Two columns have '
              'been carried onto the wrong row -- the same class of defect as '
              'the eleven mismatched columns recorded in batches 3 and 4. The '
              'Atomic Step is implemented and the mismatch is reported; '
              'following the columns would produce a privileges file from a '
              'row about panes. READING: "layout requirements for the '
              'split-screen matrix" is a grid -- window class by pane '
              'relation -- and writing it as a total function answers in one '
              'place what the four preceding steps leave open one cell at a '
              'time. MEASURED: no cell leaves its leading pane below the 200dp '
              'usable minimum, and the tightest is medium/master-detail at '
              '210dp. Ten dp of margin is what the whole matrix is standing '
              'on, and it is reported rather than left as a green tick.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Execution Quality (%)',
            observed:
                '${quality.toStringAsFixed(0)} over '
                '${HabotSplitMatrix.checks.length} checks: the matrix total '
                'over both axes, each class evaluated at its narrowest width, '
                'the two unsupported classes answered rather than left to fall '
                'through, no unusable cell, and the mismatched columns '
                'recorded.',
            floor: '95',
            optimal: '99',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Tightest cell in the matrix',
            observed:
                '${HabotSplitMatrix.tightestCell.id} at '
                '${HabotSplitMatrix.tightestCell.leadingExtentDp'
                '.toStringAsFixed(0)}dp against a '
                '${HabotPaneSplit.minimumUsablePaneDp.toStringAsFixed(0)}dp '
                'minimum -- a margin of '
                '${HabotSplitMatrix.tightestMarginDp.toStringAsFixed(0)}dp. '
                'The cell that breaks first if the ratio, the minimum or the '
                'medium boundary moves.',
            floor: '200dp',
            optimal: '>=240dp',
            ceiling: 'n/a',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/split_matrix_requirements.dart',
        ],
      ),
    );
  });
}
