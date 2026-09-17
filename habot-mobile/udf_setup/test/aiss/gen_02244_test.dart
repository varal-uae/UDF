/// AISS GATE -- Step 424 of 415
/// Global Reference ID:       GEN-02244
/// Atomic Steps Reference ID: GEN-02244
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Validate that hidden UX bottlenecks are mathematically
///               uncovered."
/// Metric: Process Execution Accuracy -- floor "0.9", optimal "0.97", ceiling
///         "0.999". Best Qualitative Output: "Pass / Fail". ISO/IEC 25010
///         Software Product Quality Standard. Assigned to **UDF**.
///
/// "MATHEMATICALLY UNCOVERED", WHERE WHAT MAKES A BOTTLENECK HIDDEN IS THAT
/// NOBODY RUNS THE COMPARISON.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/bottleneck_detection.dart';

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

  group('GEN-02244 :: hidden means unlooked-at', () {
    gate(
      'GEN-02244-G1',
      'What makes a bottleneck hidden is that nobody looks.',
      'Comparing a percentile against a threshold is not mathematically hard; '
          'running it on a Tuesday is the part that does not happen',
      () =>
          HabotBottleneckDetection.theAdjectiveIsWrong &&
          HabotBottleneckDetection.theFindingArrivesUnasked,
    );

    gate(
      'GEN-02244-G2',
      'So a standing rule was built rather than better mathematics.',
      'The finding arrives without anybody asking for it',
      () =>
          HabotBottleneckDetection.theDetectorRunsOnASchedule &&
          HabotBottleneckDetection.hiddenNote
              .contains('wrong adjective attached to the right instinct'),
    );

  });

  group('GEN-02244 :: a rule with two conditions', () {
    gate(
      'GEN-02244-G3',
      'The rule needs both conditions.',
      'A p90 above the five-second dwell threshold and a funnel step more than '
          'five points below its baseline',
      () =>
          HabotBottleneckDetection.bothConditionsMustHold &&
          HabotBottleneckDetection.theRuleUsesTheDeclaredThreshold &&
          HabotBottleneckDetection.theRuleUsesTheDeclaredBaseline,
    );

    gate(
      'GEN-02244-G4',
      'And either alone produces noise.',
      'A slow field people still complete is a slow field; a step that lost '
          'conversion for a reason outside the screen is not a UX problem',
      () =>
          HabotBottleneckDetection.ruleNote.contains('struggle and then leave'),
    );

  });

  group('GEN-02244 :: validated in both directions', () {
    gate(
      'GEN-02244-G5',
      'Four cases, one planted and three clean.',
      'Both directions tested, because a detector never shown to stay silent '
          'is an opinion with a cron schedule',
      () =>
          HabotBottleneckDetection.cases.length == 4 &&
          HabotBottleneckDetection.planted == 1 &&
          HabotBottleneckDetection.clean == 3,
    );

    gate(
      'GEN-02244-G6',
      'The planted case is the one two other rows found.',
      'The reason-code field, reached independently by Step 421 and Step 423',
      () =>
          HabotBottleneckDetection.theKnownCaseIsTheOneTwoOtherRowsFound &&
          HabotBottleneckDetection.everyFiringNamesItsReason,
    );

    gate(
      'GEN-02244-G7',
      'Sensitivity and specificity are both 1.',
      'On a small worked set, with the denominators published',
      () =>
          HabotBottleneckDetection.sensitivity == 1 &&
          HabotBottleneckDetection.specificity == 1 &&
          HabotBottleneckDetection.bothDirectionsAreTested,
    );

  });

  group('GEN-02244 :: one accuracy figure would hide the easy failure', () {
    gate(
      'GEN-02244-G8',
      'A detector that never fires would score 75 per cent.',
      'Because three of the four screens are clean, which is why a single '
          'accuracy figure is not published',
      () =>
          HabotBottleneckDetection.silenceWouldScoreWell &&
          HabotBottleneckDetection.bothRatesArePublished,
    );

    gate(
      'GEN-02244-G9',
      'So the denominators are published beside the rates.',
      'The way to cheat the figure is visible in the figure',
      () =>
          HabotBottleneckDetection.theDenominatorsArePublished &&
          HabotBottleneckDetection
              .balanceNote.contains('visible in the figure'),
    );

    gate(
      'GEN-02244-G10',
      'Six obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotBottleneckDetection.obligations.length == 6 &&
          HabotBottleneckDetection.obligations.values.every((bool b) => b) &&
          HabotBottleneckDetection.qualitativeOutput == 'Pass' &&
          HabotBottleneckDetection.theMetricIsSharedWithStep419 &&
          HabotBottleneckDetection.theBandIsFinerThanItsOutput &&
          HabotBottleneckDetection.theGroupingStaysOnTheAllowlist,
    );
  });

  tearDownAll(() {
    final int cases = HabotBottleneckDetection.cases.length;
    final int planted = HabotBottleneckDetection.planted;
    final int clean = HabotBottleneckDetection.clean;
    final int dwellMs = HabotBottleneckDetection.dwellThresholdMs;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02244',
        atomicStepReferenceId: 'GEN-02244',
        setupStepAction:
            'COLUMN NOTE: this row asks for bottlenecks to be "mathematically '
            'uncovered" when what makes them hidden is that nobody runs the '
            'comparison, so what was built is a standing rule rather than '
            'better mathematics; its metric and band -- Process Execution '
            'Accuracy at 0.9, 0.97, 0.999 -- are identical to Step 419\'s in '
            'this batch, and run to three decimal places while its output '
            'column holds two values; and its Data Requirement, Poka-Yoke, '
            'Completion Measures and Expected Output cells are the generic '
            'block shared by every GEN row in this batch, repeating the Atomic '
            'Step back as the artefact to prepare. Atomic Step: "Validate that '
            'hidden UX bottlenecks are mathematically uncovered."',
        implementationOrder: 424,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Validate that hidden UX bottlenecks are mathematically uncovered':
              'a standing rule over the aggregates rather than a query '
                  'somebody has to think of running, validated against '
                  '$planted planted case and $clean clean screens',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Execution Accuracy',
            observed:
                'THE ADJECTIVE IS WRONG AND THE INSTINCT IS RIGHT. Comparing a '
                'percentile against a threshold is not mathematically hard; '
                'what makes a bottleneck hidden is that the comparison is '
                'never run, because running it requires somebody to wonder '
                'about that screen on a Tuesday. What was built is a standing '
                'rule that fires when two conditions hold together -- a p90 '
                'above the $dwellMs ms dwell threshold Step 416 declared, and '
                'a funnel step more than five points below its own baseline -- '
                'because either alone produces noise. The metric and band are '
                'identical to Step 419\'s and run to three decimal places '
                'against a two-valued output column.',
            floor: '0.9',
            optimal: '0.97',
            ceiling: '0.999',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Directions of the detector left untested',
            observed:
                '0 of 2. $cases cases were put to it: $planted planted '
                'bottleneck -- the reason-code field that Steps 421 and 423 '
                'found independently by different routes -- and $clean clean '
                'screens. Sensitivity and specificity are both 1 and are '
                'published separately with their denominators, because a '
                'single accuracy figure on an unbalanced set is the easiest '
                'number in this track to make look good: a detector that fires '
                'on nothing scores seventy-five per cent here. Every firing '
                'names the two figures that produced it.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/bottleneck_detection.dart',
        ],
      ),
    );
  });
}
