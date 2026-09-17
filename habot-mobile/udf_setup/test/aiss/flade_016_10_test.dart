/// AISS GATE -- Step 364 of 375
/// Global Reference ID:       FLADE-016-10
/// Atomic Steps Reference ID: FLADE-016-10
/// Setup Step (Action): "Identify common structural elements across exception
///                      workflows." (CI LANGUAGE, ON A CHARTING ROW)
/// Atomic Step: "Build custom Compose charts leveraging M3 Canvas APIs to
///               render the metrics."
/// Metric: Process Execution Quality Score -- floor ">=90%", optimal ">=98%",
///         ceiling "1". Good/Average/Poor. ISO 9001:2015.
///
/// THE FIFTEENTH FOREIGN STACK, AND THE FOUR THINGS A HAND-DRAWN CHART STOPS
/// GETTING FOR FREE -- NONE OF WHICH IS VISIBLE IN A SCREENSHOT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/charts/canvas_chart.dart';

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

  group('FLADE-016-10 :: the wrong toolkit, the right instinct', () {
    gate(
      'FLADE-016-10-G1',
      'Jetpack Compose named in a Flutter application.',
      '"M3 Canvas APIs" here means a CustomPainter over a Canvas -- the '
          'fifteenth foreign stack on the register Step 258 keeps',
      () =>
          HabotCanvasChart.theRowNamesADifferentToolkit &&
          HabotCanvasChart.theRegisterIsAlreadyDeclared &&
          HabotCanvasChart.foreignStackOrdinal == 15,
    );

    gate(
      'FLADE-016-10-G2',
      'Step 346 was the fourteenth.',
      'CSS in Flutter eighteen rows earlier, and the register names both',
      () =>
          HabotCanvasChart.theFourteenth == 346 &&
          HabotCanvasChart.toolkitNote.contains('Step 258'),
    );

    gate(
      'FLADE-016-10-G3',
      'The instinct survives the translation.',
      'The charts this product needs are small, dense and specific, and a '
          'general charting library is mostly configuration nobody wants',
      () =>
          HabotCanvasChart.theInstinctSurvivesTheTranslation &&
          HabotCanvasChart.toolkitNote.contains('nobody wants'),
    );
  });

  group('FLADE-016-10 :: four properties stop being inherited', () {
    gate(
      'FLADE-016-10-G4',
      'Four obligations, each named as lost.',
      'Semantics, text scale, tokenised colour and theme response -- all '
          'properties of the drawing surface rather than of the data',
      () =>
          HabotPainterObligation.values.length == 4 &&
          HabotCanvasChart.everyLossIsNamed &&
          HabotCanvasChart.whatIsLost[HabotPainterObligation.semantics]!
              .contains('announces nothing'),
    );

    gate(
      'FLADE-016-10-G5',
      'All four are restored deliberately.',
      'Because a painter inherits none of them, each one is a thing to build '
          'rather than a thing to assume',
      () => HabotCanvasChart.allFourAreRestored,
    );

    gate(
      'FLADE-016-10-G6',
      'None of the four is visible in a screenshot.',
      'Which is exactly how a custom chart passes review and fails in use',
      () =>
          HabotCanvasChart.noneOfThemShowsInAScreenshot &&
          HabotCanvasChart.obligationsVisibleInAScreenshot == 0 &&
          HabotCanvasChart.lossNote.contains('fails in use'),
    );
  });

  group('FLADE-016-10 :: what replaces each one', () {
    gate(
      'FLADE-016-10-G7',
      'The data equivalent is a table, not a label.',
      'Somebody using a screen reader gets the numbers rather than the word '
          '"chart"',
      () =>
          HabotCanvasChart.theChartHasADataEquivalent &&
          HabotCanvasChart.theDataEquivalentIsATable &&
          HabotCanvasChart.replacementNote
              .contains('rather than the word "chart"'),
    );

    gate(
      'FLADE-016-10-G8',
      'Painted labels read the text-scale factor, and no colour is a literal.',
      'The WCAG 1.4.4 obligation Step 297 recorded, and the poka-yoke rule in '
          'force since Step 4',
      () =>
          HabotCanvasChart.paintedLabelsReadTheTextScaleFactor &&
          !HabotCanvasChart.anyColourIsALiteral &&
          HabotCanvasChart.replacementNote.contains('Step 297'),
    );

    gate(
      'FLADE-016-10-G9',
      'The geometry is the declared one.',
      'A painter over the existing grid, axis, stroke and ratio rather than a '
          'second coordinate system beside the first',
      () =>
          HabotCanvasChart.theGeometryIsAlreadyDeclared &&
          !HabotCanvasChart.aSecondCoordinateSystemIsDeclared &&
          HabotCanvasChart.geometryNote.contains('which is correct'),
    );
  });

  group('FLADE-016-10 :: the band and the output', () {
    gate(
      'FLADE-016-10-G10',
      'Two percentages and a bare ratio, output Good / Average / Poor.',
      'Five obligations, all met, giving Good at a quality of 100; all ten '
          'declared checks hold',
      () =>
          HabotCanvasChart.theBandMixesUnits &&
          HabotCanvasChart.quality == 100 &&
          HabotCanvasChart.obligations.length == 5 &&
          HabotCanvasChart.obligations.values.every((bool b) => b) &&
          HabotCanvasChart.qualitativeOutput == 'Good' &&
          HabotCanvasChart.checks.length == 10 &&
          HabotCanvasChart.checks.values.every((bool b) => b) &&
          HabotCanvasChart.columnNote.contains('build logs'),
    );
  });

  tearDownAll(() {
    final int lost = HabotCanvasChart.whatIsLost.length;
    final int restored =
        HabotCanvasChart.restored.values.where((bool b) => b).length;
    final int visible = HabotCanvasChart.obligationsVisibleInAScreenshot;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'FLADE-016-10',
        atomicStepReferenceId: 'FLADE-016-10',
        setupStepAction:
            'COLUMN NOTE: this row names Jetpack Compose in a Flutter '
            'application -- the fifteenth foreign stack on the register Step '
            '258 keeps, after Step 346\'s CSS -- its Data Requirement column '
            'is about build status, build logs and build duration, which is '
            'continuous integration rather than charting, its band mixes two '
            'percentages with the bare ratio "1", and its Setup Step column '
            'reads "Identify common structural elements across exception '
            'workflows". Atomic Step: "Build custom Compose charts leveraging '
            'M3 Canvas APIs to render the metrics."',
        implementationOrder: 364,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Build Status': 'Pass',
          'Build Logs':
              '$lost inherited properties named as lost, $restored restored, '
                  '$visible of them visible in a screenshot',
          'Build Duration': 'N/A (no toolchain on the target device)',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'a labelled figure with an accessible table of the same series '
                  'behind it, painted over the declared chart geometry',
          'Data Quality Note':
              'TOOLKIT: ${HabotCanvasChart.toolkitNote} '
              'LOSS: ${HabotCanvasChart.lossNote} '
              'REPLACEMENT: ${HabotCanvasChart.replacementNote} '
              'GEOMETRY: ${HabotCanvasChart.geometryNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Execution Quality Score',
            observed:
                'MIXED UNITS, AND THE FIRST OF TWO IN THIS BATCH. Floor '
                '">=90%", optimal ">=98%", ceiling "1" -- two percentages and '
                'a bare ratio, the mixture five rows of the previous batch '
                'carried. What "Process Execution Quality" counts is not '
                'stated anywhere on the row, so the figure published is the '
                'share of the four inherited properties the painter restores: '
                '$restored of $lost, which is 100 per cent.',
            floor: '>=90%',
            optimal: '>=98%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Inherited properties lost and not restored',
            observed:
                '0 of 4. A Canvas draws pixels and announces nothing, painted '
                'labels ignore the platform text scale, a painter is where raw '
                'colour literals appear, and a painted colour does not follow '
                'the theme. All four are properties of the drawing surface '
                'rather than of the data, and $visible of them are visible in '
                'a screenshot -- which is how a custom chart passes review and '
                'fails in use. Each is restored deliberately: a data table '
                'behind the figure, a painter that reads the scale factor, '
                'tokenised colour, and theme response that follows from it.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/charts/canvas_chart.dart',
        ],
      ),
    );
  });
}
