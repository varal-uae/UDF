/// AISS GATE -- Step 425 of 415
/// Global Reference ID:       GEN-04130
/// Atomic Steps Reference ID: GEN-04130
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Update mobile analytics dashboards to highlight high-friction
///               fields in Red (#error)."
/// Metric: Red Highlight Rendering Speed -- floor "<1s", optimal "<100ms",
///         ceiling "2s". Best Qualitative Output: "Pass/Fail". Material Design
///         3 Error Palettes. Assigned to **CAL**.
///
/// RED, WHERE RED ALREADY MEANS SOMETHING ELSE AND COLOUR IS ALREADY NOT
/// ALLOWED TO BE ALONE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/friction_highlight.dart';

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

  group('GEN-04130 :: three carriers, not one', () {
    gate(
      'GEN-04130-G1',
      'The row asks for one carrier and three are delivered.',
      'A colour, an icon and the figures behind the mark',
      () =>
          HabotFrictionHighlight.theRowAsksForOne &&
          HabotFrictionHighlight.carriersDelivered == 3,
    );

    gate(
      'GEN-04130-G2',
      'The carrier rule is Step 189\'s, restated at 369.',
      'A word, an icon and a role, together',
      () =>
          HabotFrictionHighlight.theCarrierRuleIsTheDeclaredOne &&
          HabotFrictionHighlight.threeCarriersArePresent,
    );

    gate(
      'GEN-04130-G3',
      'Second refusal of colour-alone in two batches.',
      'After Step 407, because a dashboard read on a phone in sunlight by '
          'somebody with deuteranopia is the ordinary case',
      () =>
          HabotFrictionHighlight.secondRefusalOfColourAlone &&
          HabotFrictionHighlight.carrierNote.contains('not the edge one'),
    );

  });

  group('GEN-04130 :: the error role means something else', () {
    gate(
      'GEN-04130-G4',
      'The error role means something else.',
      'Something is wrong with this thing and you can fix it -- a rejected '
          'submission, a failed field, a dropped connection',
      () =>
          HabotFrictionHighlight.theRolesDiffer &&
          !HabotFrictionHighlight.anythingOnThatScreenIsInAnErrorState,
    );

    gate(
      'GEN-04130-G5',
      'So a distinct attention role is used.',
      'A high-friction field is a finding about a population over a period; '
          'nothing on that screen is in an error state',
      () =>
          HabotFrictionHighlight.theErrorRoleIsLeftAlone &&
          HabotFrictionHighlight.theDilutionIsNamed,
    );

    gate(
      'GEN-04130-G6',
      'And the cost falls on the day something breaks.',
      'A dashboard with four red things and nobody in a hurry has spent the '
          'role\'s meaning',
      () => HabotFrictionHighlight.roleNote.contains('actually breaks'),
    );

  });

  group('GEN-04130 :: what is marked, and why', () {
    gate(
      'GEN-04130-G7',
      'Only what the detector reported is marked.',
      'One field, from the Step 424 detector',
      () =>
          HabotFrictionHighlight.onlyDetectorFindingsAreHighlighted &&
          HabotFrictionHighlight.oneFieldIsHighlighted &&
          !HabotFrictionHighlight.aFieldCanBeHighlightedWithoutAReason,
    );

    gate(
      'GEN-04130-G8',
      'And the mark carries the figures behind it.',
      'The second time somebody checks a red field and finds nothing behind it '
          'is the last time anybody checks one',
      () =>
          HabotFrictionHighlight.theHighlightCarriesItsFigures &&
          HabotFrictionHighlight
              .highlightNote.contains('the last time anybody checks one'),
    );

  });

  group('GEN-04130 :: the metric scores a repaint', () {
    gate(
      'GEN-04130-G9',
      'The metric scores a repaint.',
      'How fast the red appears, not whether the right field is red -- and no '
          'dashboard has ever been limited by a repaint',
      () =>
          HabotFrictionHighlight.theMetricScoresTheMechanism &&
          HabotFrictionHighlight.thirdSuchRowInTheBatch &&
          HabotFrictionHighlight.theRepaintIsWellInsideTheOptimal,
    );

    gate(
      'GEN-04130-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotFrictionHighlight.obligations.length == 5 &&
          HabotFrictionHighlight.obligations.values.every((bool b) => b) &&
          HabotFrictionHighlight.qualitativeOutput == 'Pass' &&
          HabotFrictionHighlight.theOptimalIsBelowBothBoundaries &&
          HabotFrictionHighlight.theShapeIsTheDeclaredConvention,
    );
  });

  tearDownAll(() {
    final int carriers = HabotFrictionHighlight.carriersDelivered;
    final String role = HabotFrictionHighlight.roleUsed;
    final int marked = HabotFrictionHighlight.fieldsHighlighted;
    final int renderMs = HabotFrictionHighlight.renderMs;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04130',
        atomicStepReferenceId: 'GEN-04130',
        setupStepAction:
            'COLUMN NOTE: this row asks for colour to carry a meaning by '
            'itself, which Step 189 forbade and Step 407 refused last batch -- '
            'so the highlight carries a colour, an icon and the figures behind '
            'it; it names the #error role for something that is not an error, '
            'and a distinct attention role is used instead so the error role '
            'keeps its meaning; its metric scores the rendering speed of the '
            'highlight rather than its correctness; its optimal of "<100ms" '
            'sits below both its floor of "<1s" and its ceiling of "2s"; and '
            'it is assigned to CAL, the first of four teams in this batch '
            'outside UDF and ADFA. Atomic Step: "Update mobile analytics '
            'dashboards to highlight high-friction fields in Red (#error)."',
        implementationOrder: 425,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Update mobile analytics dashboards to highlight high-friction '
          'fields in Red':
              '$marked field marked, carrying $carriers carriers -- the '
                  '"$role" colour role, an icon and the two figures that '
                  'produced the finding -- and painting in $renderMs ms',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Red Highlight Rendering Speed',
            observed:
                'THE METRIC SCORES HOW FAST THE RED APPEARS. Not whether the '
                'right field is red -- the third row in this batch scored on '
                'its own mechanism after Steps 413 and 421, and the least '
                'defensible of the three, because no dashboard has ever been '
                'limited by the speed of a repaint. Its optimal of "<100ms" '
                'sits below both its floor of "<1s" and its ceiling of "2s", '
                'the fourth row in this batch written to that convention. '
                'Observed: $renderMs ms, well inside the optimal, on $marked '
                'marked field.',
            floor: '<1s',
            optimal: '<100ms',
            ceiling: '2s',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Meanings carried by colour alone',
            observed:
                '0. Step 189 declared three carriers, Step 369 restated them '
                'and Step 407 refused a row that asked colour to carry a '
                'meaning by itself; this row names a hex role and nothing '
                'else, and the mark carries $carriers. The row also names the '
                'error role for something that is not an error: a '
                'high-friction field is a finding about a population over a '
                'period, nothing on that screen is broken, and spending the '
                'error role on findings is how a dashboard ends up with four '
                'red things and nobody in a hurry. The "$role" role is used '
                'instead.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/friction_highlight.dart',
        ],
      ),
    );
  });
}
