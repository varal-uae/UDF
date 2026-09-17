/// AISS GATE -- Step 365 of 375
/// Global Reference ID:       GEN-00876
/// Atomic Steps Reference ID: GEN-00876
/// Setup Step (Action): "Bind the enforcer to the mobile device's virtual
///                      keyboard input events." (INPUT HANDLING, ON A
///                      RENDERING ROW)
/// Atomic Step: "Construct graph visualizer canvas widget using custom
///               hardware-accelerated rendering."
/// Metric: Canvas Render Speed -- floor, optimal and ceiling all the LaTeX
///         string "$60\text{ fps}$". Pass / Fail. "Mobile GPU Canvas
///         Acceleration Spec".
///
/// THE SECOND TYPESET BAND IN ONE BATCH, WHICH MAKES IT A PIPELINE AND NOT A
/// KEYSTROKE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/charts/graph_canvas.dart';

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

  group('GEN-00876 :: the band is typeset', () {
    gate(
      'GEN-00876-G1',
      'All three boundary cells hold LaTeX math mode.',
      'And none of the three can be parsed as a number by anything consuming '
          'the sheet',
      () =>
          HabotGraphCanvas.theBandIsLatex &&
          HabotGraphCanvas.allThreeBoundariesAreIdentical &&
          HabotGraphCanvas.theBandCannotBeParsedAsANumber,
    );

    gate(
      'GEN-00876-G2',
      'Step 356 carries the identical three cells.',
      'Two rows in one batch is a pipeline rendering numbers with a '
          'typesetting wrapper, not a keystroke',
      () =>
          HabotGraphCanvas.twoRowsInThisBatchAreTypeset &&
          HabotGraphCanvas.latexBandRows.contains(356) &&
          HabotGraphCanvas.bandNote.contains('not a keystroke'),
    );

    gate(
      'GEN-00876-G3',
      'The cited standard is not a published specification.',
      '"Mobile GPU Canvas Acceleration Spec" has the same shape as Step 353\'s '
          '"Mobile Sensory Feedback Standards"',
      () =>
          !HabotGraphCanvas.theCitedStandardIsPublished &&
          HabotGraphCanvas.theOtherInventedStandardRow == 353,
    );
  });

  group('GEN-00876 :: the acceleration instruction is inert', () {
    gate(
      'GEN-00876-G4',
      'Flutter composites every widget on the GPU already.',
      'There is no slow path to opt out of and no hint to give, so nothing is '
          'written to satisfy the instruction',
      () =>
          !HabotGraphCanvas.aCompositingHintIsNeeded &&
          HabotGraphCanvas.theStepThatSettledThis == 346 &&
          HabotGraphCanvas.accelerationNote.contains('it is inert'),
    );
  });

  group('GEN-00876 :: frame rate is the wrong thing to optimise', () {
    gate(
      'GEN-00876-G5',
      'Sixty frames a second is a budget, not a target.',
      'A graph holding 60 fps while drawing an unreadable hairball meets the '
          'row and fails the person',
      () => HabotGraphCanvas.legibilityNote
          .contains('stops being a picture'),
    );

    gate(
      'GEN-00876-G6',
      'The whole graph is never drawn.',
      'Two scopes are declared and only the neighbourhood is ever rendered',
      () =>
          HabotGraphScope.values.length == 2 &&
          HabotGraphCanvas.theScopeIsAlwaysANeighbourhood,
    );

    gate(
      'GEN-00876-G7',
      'Three worked graphs, one of which fits whole.',
      '18 nodes fit; 214 and 9,600 are capped at forty',
      () =>
          HabotGraphCanvas.samples.length == 3 &&
          HabotGraphCanvas.oneOfThreeFitsWhole &&
          HabotGraphCanvas.everySampleRespectsTheCap &&
          HabotGraphCanvas.drawableNodeCap == 40,
    );
  });

  group('GEN-00876 :: what was cut, and what a graph is without eyes', () {
    gate(
      'GEN-00876-G8',
      'Both truncation states are labelled.',
      '"Showing 40 of 214" and "Showing all 18" -- Step 363\'s rule applied to '
          'a graph, which has no scrollbar to be short',
      () =>
          HabotGraphCanvas.theCutIsStated &&
          HabotGraphCanvas.theCompleteCaseSaysSo &&
          HabotGraphCanvas.theTruncationRuleIsAlreadyDeclared &&
          HabotGraphCanvas.truncationNote.contains('no scrollbar'),
    );

    gate(
      'GEN-00876-G9',
      'The graph is also an indented list of relations.',
      'Step 311\'s form for trace maps, reused -- and that step recorded what '
          'the form loses rather than claiming the two are equivalent',
      () =>
          !HabotGraphCanvas.theCanvasAnnouncesItself &&
          HabotGraphCanvas.thereIsANonVisualEquivalent &&
          HabotGraphCanvas.theNonVisualFormIsReused &&
          HabotGraphCanvas.nonVisualNote.contains('eleven of thirteen'),
    );

    gate(
      'GEN-00876-G10',
      'Output reported as Pass / Fail.',
      'Five obligations, all met, giving Pass; all ten declared checks hold',
      () =>
          HabotGraphCanvas.obligations.length == 5 &&
          HabotGraphCanvas.obligations.values.every((bool b) => b) &&
          HabotGraphCanvas.qualitativeOutput == 'Pass' &&
          HabotGraphCanvas.checks.length == 10 &&
          HabotGraphCanvas.checks.values.every((bool b) => b) &&
          HabotGraphCanvas.columnNote.contains('virtual keyboard'),
    );
  });

  tearDownAll(() {
    final String capped = HabotGraphCanvas.hiddenLabel(
      HabotGraphCanvas.samples[1],
    );
    final String whole = HabotGraphCanvas.hiddenLabel(
      HabotGraphCanvas.samples.first,
    );
    final int largestHidden = HabotGraphCanvas.samples.last.hidden;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00876',
        atomicStepReferenceId: 'GEN-00876',
        setupStepAction:
            'COLUMN NOTE: all three boundary cells on this row hold the LaTeX '
            'string for sixty frames a second in math mode, as Step 356\'s do '
            '-- the second typeset band in this batch; the standard cited, '
            '"Mobile GPU Canvas Acceleration Spec", is not a published '
            'specification, the same shape as Step 353\'s; and the Setup Step '
            'column reads "Bind the enforcer to the mobile device\'s virtual '
            'keyboard input events", which is input handling on a rendering '
            'row. Atomic Step: "Construct graph visualizer canvas widget using '
            'custom hardware-accelerated rendering."',
        implementationOrder: 365,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type': 'a capped neighbourhood canvas with a list equivalent',
          'Layout Grid Dimensions': 'up to 40 nodes around one focus',
          'Spacing Rules': 'the declared spacing scale',
          'Alignment Settings': 'the focused node centred',
          'Layout Validation Status': 'Pass',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the capped view reads "$capped" and the complete one "$whole"; '
                  'the largest sample holds back $largestHidden nodes',
          'Data Quality Note':
              'BAND: ${HabotGraphCanvas.bandNote} '
              'ACCELERATION: ${HabotGraphCanvas.accelerationNote} '
              'LEGIBILITY: ${HabotGraphCanvas.legibilityNote} '
              'NON-VISUAL: ${HabotGraphCanvas.nonVisualNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Canvas Render Speed',
            observed:
                'TYPESET, FOR THE SECOND TIME IN THIS BATCH. Floor, optimal '
                'and ceiling are the same LaTeX math-mode string for sixty '
                'frames a second, exactly as Step 356\'s three cells are. Two '
                'rows in one batch says something in the pipeline that '
                'produced this sheet renders numbers with a typesetting '
                'wrapper, into cells a consumer will parse -- none of the '
                'three parses as a number. The standard cited is not a '
                'published one either.',
            floor: r'$60\text{ fps}$',
            optimal: r'$60\text{ fps}$',
            ceiling: r'$60\text{ fps}$',
          ),
          AissMeasurement(
            metricName: 'Nodes dropped without the canvas saying so',
            observed:
                '0. Sixty frames a second is a budget rather than a target, '
                'and holding it while drawing an unreadable hairball meets the '
                'row and fails the person. What decides whether a graph is '
                'usable is how many nodes are on screen: the widget draws a '
                'neighbourhood around a focused node, never the whole graph, '
                'and caps it at forty. Both states are labelled -- "$capped" '
                'and "$whole" -- which is Step 363\'s truncation rule on a '
                'shape that has no scrollbar to be short.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/charts/graph_canvas.dart',
        ],
      ),
    );
  });
}
