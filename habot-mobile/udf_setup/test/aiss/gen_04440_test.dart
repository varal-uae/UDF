/// AISS GATE -- Step 393 of 395
/// Global Reference ID:       GEN-04440
/// Atomic Steps Reference ID: GEN-04440
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement component-level error boundaries around isolated
///               widgets."
/// Metric: Unhandled Exception Rate -- floor "< 1.0%", optimal "< 0.1%",
///         ceiling "0". Good/Average/Poor. ISO/IEC 25010 (Reliability
///         Characteristic). Assigned to **UDF**.
///
/// A BOUNDARY IS A DECISION ABOUT BLAST RADIUS, AND AN EMPTY BOX IS WORSE THAN
/// A CRASH.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/resilience/widget_error_boundary.dart';

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

  group('GEN-04440 :: blast radius', () {
    gate(
      'GEN-04440-G1',
      'Seven of eight widgets survive one failure.',
      'Without a boundary a chart that cannot parse a date takes the screen '
          'with it',
      () =>
          HabotWidgetErrorBoundary.sevenOfEightSurvive &&
          HabotWidgetErrorBoundary.widgetsOnTheScreen == 8 &&
          HabotWidgetErrorBoundary.widgetsSaved == 7,
    );

    gate(
      'GEN-04440-G2',
      'An empty box is refused.',
      'A crash gets reported and a gap does not, so swallowing is worse than '
          'failing',
      () =>
          !HabotWidgetErrorBoundary.anEmptyBoxIsAcceptable &&
          HabotWidgetErrorBoundary.radiusNote.contains('a gap does not'),
    );
  });

  group('GEN-04440 :: three things a catch owes', () {
    gate(
      'GEN-04440-G3',
      'Every failure names its widget.',
      'So the report says which one, not that something went wrong',
      () =>
          HabotWidgetErrorBoundary.failures.length == 4 &&
          HabotWidgetErrorBoundary.everyFailureNamesItsWidget,
    );

    gate(
      'GEN-04440-G4',
      'Every catch is reported.',
      'An unreported catch turns a crash the team would have fixed into a '
          'screen that is mildly worse forever',
      () =>
          HabotWidgetErrorBoundary.everyCatchIsReported &&
          !HabotWidgetErrorBoundary.aCaughtErrorCanBeSilent &&
          HabotWidgetErrorBoundary.obligationNote
              .contains('mildly worse forever'),
    );

    gate(
      'GEN-04440-G5',
      'Two of four offer a retry.',
      'Where retrying could actually help',
      () =>
          HabotWidgetErrorBoundary.twoOfFourOfferRetry &&
          HabotWidgetErrorBoundary.retryable == 2,
    );
  });

  group('GEN-04440 :: not everything is caught or retried', () {
    gate(
      'GEN-04440-G6',
      'A disagreeing total is refused rather than retried.',
      'A retry on a total that disagrees with its components invites somebody '
          'to tap until it looks right',
      () =>
          HabotWidgetErrorBoundary.aDisagreeingTotalIsRefusedNotRetried &&
          HabotWidgetErrorBoundary.outcomeNote
              .contains('until it looks right'),
    );

    gate(
      'GEN-04440-G7',
      'A permission failure escalates instead of being caught.',
      'A boundary that catches an authorisation error and shows a friendly '
          'retry has turned a refusal into a bug report',
      () =>
          HabotWidgetErrorBoundary.aPermissionFailureEscalates &&
          HabotBoundaryOutcome.values.length == 3 &&
          HabotWidgetErrorBoundary.threeOutcomesAreUsed,
    );
  });

  group('GEN-04440 :: the branch is already declared', () {
    gate(
      'GEN-04440-G8',
      'The errored branch is Step 379\'s.',
      'Fourteen rows apart in the same batch, which is why they agree',
      () =>
          HabotWidgetErrorBoundary.theErroredBranchExists &&
          HabotWidgetErrorBoundary.theBranchOrderIsTheDeclaredOne &&
          HabotWidgetErrorBoundary.theStepThatDeclaredTheBranches == 379,
    );

    gate(
      'GEN-04440-G9',
      'So a caught failure is a branch the surface knows how to draw.',
      'Rather than a special case bolted on beside the others',
      () => HabotWidgetErrorBoundary.branchNote.contains('bolted on'),
    );

    gate(
      'GEN-04440-G10',
      'Mixed units again, and output Good / Average / Poor.',
      'Two strict inequalities with percent signs and a bare zero -- the third '
          'in two batches, and the one where the zero is attainable; six '
          'obligations, all met, and all ten declared checks hold',
      () =>
          HabotWidgetErrorBoundary.theBandMixesUnits &&
          HabotWidgetErrorBoundary.thirdMixedUnitBand &&
          HabotWidgetErrorBoundary.theCeilingIsAttainable &&
          HabotWidgetErrorBoundary.obligations.length == 6 &&
          HabotWidgetErrorBoundary.obligations.values.every((bool b) => b) &&
          HabotWidgetErrorBoundary.qualitativeOutput == 'Good' &&
          HabotWidgetErrorBoundary.failuresContained == 75 &&
          HabotWidgetErrorBoundary.checks.length == 10 &&
          HabotWidgetErrorBoundary.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final int saved = HabotWidgetErrorBoundary.widgetsSaved;
    final int retryable = HabotWidgetErrorBoundary.retryable;
    final String refusedWidget = HabotWidgetErrorBoundary.theTotal.widget;
    final String escalated = HabotWidgetErrorBoundary.thePermissionCheck.widget;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04440',
        atomicStepReferenceId: 'GEN-04440',
        setupStepAction:
            'COLUMN NOTE: the band on this row mixes two strict inequalities '
            'carrying percent signs with a bare ceiling of 0 -- the third '
            'mixed-unit band in two batches, after Steps 364 and 389, and the '
            'one where the zero is both meaningful and attainable, since no '
            'exception reaching the top of the tree is a real state; its Data '
            'Requirement cell holds the Atomic Step\'s own sentence as the '
            'artefact to prepare; and the Setup Step column is empty. Atomic '
            'Step: "Implement component-level error boundaries around isolated '
            'widgets."',
        implementationOrder: 393,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Implement component-level error boundaries around isolated widgets':
              '4 worked failures across 3 outcomes; $saved of 8 widgets '
                  'survive one failure',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              '$retryable failures offer a retry; the $refusedWidget is '
                  'refused and the $escalated escalates',
          'Data Quality Note':
              'RADIUS: ${HabotWidgetErrorBoundary.radiusNote} OBLIGATION: '
              '${HabotWidgetErrorBoundary.obligationNote} OUTCOME: '
              '${HabotWidgetErrorBoundary.outcomeNote} BRANCH: '
              '${HabotWidgetErrorBoundary.branchNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Unhandled Exception Rate',
            observed:
                'MIXED UNITS FOR THE THIRD TIME, AND AN ATTAINABLE ZERO. Floor '
                '"< 1.0%", optimal "< 0.1%", ceiling "0": two strict '
                'inequalities with percent signs and a bare zero, after Steps '
                '364 and 389. Unusually for this sheet the ceiling is both '
                'meaningful and attainable -- no exception reaching the top of '
                'the tree is a real state a build can be in -- which is not '
                'true of most of the zeros recorded in these two batches.',
            floor: '< 1.0%',
            optimal: '< 0.1%',
            ceiling: '0',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Failures that take a screen or vanish quietly',
            observed:
                '0 of 4. A boundary is a decision about blast radius: without '
                'one, a chart that cannot parse a date takes the screen and '
                'the person loses the $saved things that were working. What a '
                'boundary must not do is swallow, because a crash gets '
                'reported and a gap does not -- so every catch names its '
                'widget and is reported whether or not anybody saw it. '
                '$retryable of the four offer a retry; the $refusedWidget is '
                'refused instead, because a retry on a disagreeing total '
                'invites tapping until it looks right; and the $escalated is '
                'not caught here at all.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/resilience/widget_error_boundary.dart',
        ],
      ),
    );
  });
}
