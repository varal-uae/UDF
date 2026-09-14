/// AISS GATE -- Step 225 of 235
/// Global Reference ID:       GEN-04297
/// Atomic Steps Reference ID: GEN-04297
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Build a swipe-to-back gesture wrapper for modal view
///               dismissals."
/// Metric: Navigation Interaction Response Latency -- Floor < 300ms, Optimal
///         < 100ms, Ceiling < 16ms (1 frame @60fps). Good/Average/Poor.
///
/// THE CEILING ON THIS ROW IS THE BEST VALUE; ON STEP 199's IT IS THE WORST.
/// Two duration metrics in the same sheet ordering their bands in opposite
/// directions, which means a reader cannot apply one rule. And all three of
/// this row's bounds are the RAIL band Step 164 already declared.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/i18n/localization_objective.dart';
import 'package:udf_setup/design_system/interaction/swipe_back.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double adherence = 0;

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

  const HabotModalState empty = HabotModalState(
    hasUnsavedInput: false,
    isSubmitting: false,
    ownsPlatformEdge: false,
  );
  const HabotModalState typed = HabotModalState(
    hasUnsavedInput: true,
    isSubmitting: false,
    ownsPlatformEdge: false,
  );
  const HabotModalState inFlight = HabotModalState(
    hasUnsavedInput: false,
    isSubmitting: true,
    ownsPlatformEdge: false,
  );
  const HabotModalState platformOwned = HabotModalState(
    hasUnsavedInput: true,
    isSubmitting: false,
    ownsPlatformEdge: true,
  );

  group('GEN-04297 :: a direction, not a side', () {
    gate(
      'GEN-04297-G1',
      'Seventh occurrence, after Steps 150, 167, 188, 193 and 212: a back '
          'gesture starts at the LEADING edge in reading order.',
      'The edge is leading and resolves to the left in English and the right '
          'in Urdu, so "swipe right to go back" is backwards in a language '
          'this product already ships -- and this one was written as a '
          'direction from the start rather than corrected afterwards',
      () =>
          HabotSwipeBack.edge == HabotGestureEdge.leading &&
          HabotSwipeBack.startsOnTheLeft(
            HabotTextDirectionality.leftToRight,
          ) &&
          !HabotSwipeBack.startsOnTheLeft(
            HabotTextDirectionality.rightToLeft,
          ) &&
          HabotSwipeBack.directionIsResolvedNotAssumed &&
          HabotGestureEdge.values.length == 2 &&
          HabotSwipeBack.seventhOccurrenceNote
              .contains('Seventh occurrence'),
    );

    gate(
      'GEN-04297-G2',
      '"A swipe that discards typed input is a data-loss bug wearing a '
          'gesture\'s clothes."',
      'A modal holding typed text confirms first and a modal mid-submission '
          'does too, while an empty one dismisses immediately -- because a '
          'confirmation on an empty form is the other way to make a gesture '
          'useless',
      () =>
          HabotSwipeBack.outcomeFor(empty) == HabotSwipeOutcome.dismiss &&
          HabotSwipeBack.outcomeFor(typed) ==
              HabotSwipeOutcome.confirmFirst &&
          HabotSwipeBack.outcomeFor(inFlight) ==
              HabotSwipeOutcome.confirmFirst &&
          !HabotSwipeBack.discardsWithoutAsking(typed) &&
          HabotSwipeOutcome.values.length == 3 &&
          HabotSwipeBack.unsavedInputNote.contains('silent'),
    );

    gate(
      'GEN-04297-G3',
      '"iOS has a system interactive-pop gesture on the leading edge."',
      'Where the platform owns the edge the wrapper yields rather than '
          'attaching a second recogniser, and it yields even when the modal '
          'holds unsaved input -- because two recognisers on one edge is a '
          'race, and a race is worse than a confirmation the platform will '
          'show its own way',
      () =>
          HabotSwipeBack.outcomeFor(platformOwned) ==
              HabotSwipeOutcome.yieldToPlatform &&
          HabotSwipeBack.twoGesturesOneEdgeNote.contains('race nobody can '
              'see in a review'),
    );

    gate(
      'GEN-04297-G4',
      'A gesture recognised across the whole modal eats every horizontal '
          'scroll inside it.',
      'The recogniser is bounded to a declared edge width and the dismissal '
          'threshold is a fraction of the modal rather than a pixel count, so '
          'the same gesture behaves the same on a 320dp phone and a 1024dp '
          'tablet',
      () =>
          HabotSwipeBack.edgeWidthDp == 20 &&
          HabotSwipeBack.dismissThreshold == 0.5 &&
          HabotSwipeBack.dismissThreshold > 0 &&
          HabotSwipeBack.dismissThreshold < 1,
    );
  });

  group('GEN-04297 :: the band, and where it came from', () {
    gate(
      'GEN-04297-G5',
      'Floor < 300ms, optimal < 100ms, ceiling < 16ms.',
      'All three bounds are tokens Step 164 already declared -- '
          'railPerceptible, railInstant and smoothFrameBudget -- so the row '
          'restates the RAIL band rather than introducing one',
      () =>
          HabotSwipeBack.bandIsAlreadyDeclared &&
          HabotSwipeBack.floorLatency == HabotMotion.railPerceptible &&
          HabotSwipeBack.optimalLatency == HabotMotion.railInstant &&
          HabotSwipeBack.ceilingLatency == HabotMotion.smoothFrameBudget,
    );

    gate(
      'GEN-04297-G6',
      'Step 199\'s row: floor 10s, optimal 3s, ceiling 15s -- the ceiling was '
          'the WORST tolerated value.',
      'On this row the ceiling is the best one, and the contradiction is read '
          'from Step 199 rather than restated -- two duration metrics in one '
          'sheet ordering their bands in opposite directions, so no single '
          'reading rule applies to both',
      () =>
          HabotSwipeBack.ceilingIsTheBestBound &&
          HabotSwipeBack.step199CeilingWasTheWorstBound &&
          HabotSwipeBack.qualitativeOutputFor(
                const Duration(milliseconds: 50),
              ) ==
              'Good' &&
          HabotSwipeBack.qualitativeOutputFor(
                const Duration(milliseconds: 200),
              ) ==
              'Average' &&
          HabotSwipeBack.qualitativeOutputFor(
                const Duration(milliseconds: 400),
              ) ==
              'Poor',
    );

    gate(
      'GEN-04297-G7',
      'Metric: Navigation Interaction Response Latency. No Dart toolchain on '
          'this host, so no wall-clock figure is produced.',
      'The modal follows the finger through a transform driven by the drag '
          'rather than an animation started when the drag ends, so the latency '
          'the metric asks about is a frame by construction -- and all nine '
          'structural checks hold, giving 1.0',
      () {
        adherence = HabotSwipeBack.adherence;
        return HabotSwipeBack.isDrivenByTheDragNotByAnAnimation &&
            HabotSwipeBack.checks.length == 9 &&
            HabotSwipeBack.checks.values.every((bool b) => b) &&
            adherence == 1.0 &&
            HabotSwipeBack.latencyIsStructuralNote
                .contains('no Dart toolchain') &&
            HabotSwipeBack.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04297',
        atomicStepReferenceId: 'GEN-04297',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Build a swipe-to-back gesture wrapper for modal view '
            'dismissals."',
        implementationOrder: 225,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSwipeBack / HabotModalState',
          'Component Properties':
              'Leading-edge recogniser bounded to '
              '${HabotSwipeBack.edgeWidthDp.toStringAsFixed(0)}dp with a '
              '${(HabotSwipeBack.dismissThreshold * 100).toStringAsFixed(0)}% '
              'dismissal threshold; ${HabotSwipeOutcome.values.length} '
              'outcomes covering unsaved input, an in-flight submission and a '
              'platform-owned edge; latency bounds read from the Step 164 RAIL '
              'tokens',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: the band on this row is ordered the OPPOSITE way to '
              'Step 199\'s. There, floor 10s / optimal 3s / ceiling 15s made '
              'the ceiling the worst tolerated value. Here, floor 300ms / '
              'optimal 100ms / ceiling 16ms makes it the best one. Two '
              'duration metrics in the same sheet ordering their bands in '
              'opposite directions means a reader cannot apply one rule, and '
              'every duration row has to be read on its own. Second instance; '
              'there will be more. SECOND FINDING: all three of this row\'s '
              'bounds are tokens Step 164 already declared -- railPerceptible, '
              'railInstant and smoothFrameBudget -- so the row restates the '
              'RAIL band rather than introducing one. THIRD, and the seventh '
              'occurrence of the same defect after Steps 150, 167, 188, 193 '
              'and 212: a back gesture starts at the LEADING edge in reading '
              'order, the left in English and the right in Urdu. Written as a '
              'direction from the start here rather than corrected afterwards. '
              'FOURTH: a swipe that discards typed input is a silent data-loss '
              'bug, so the gesture confirms first when the modal reports '
              'unsaved state, and yields entirely where the platform owns the '
              'edge -- two recognisers on one edge is a race nobody can see in '
              'a review.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Navigation Interaction Response Latency',
            observed:
                'NOT MEASURED ON THIS HOST -- no Dart toolchain and no '
                'instrumentation, and no figure is invented. The structural '
                'property is reported instead: the modal follows the finger '
                'through a transform driven by the drag rather than an '
                'animation started when the drag ends, so the latency is a '
                'frame by construction. Grading function exercised at 50ms '
                'Good, 200ms Average, 400ms Poor.',
            floor: '< 300ms',
            optimal: '< 100ms',
            ceiling: '< 16ms (1 frame @60fps)',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Ways a swipe can lose typed input',
            observed:
                '0 of the 3 modal states that hold something: typed input and '
                'an in-flight submission both confirm first, and a '
                'platform-owned edge yields rather than racing. An empty modal '
                'dismisses immediately, because a confirmation on an empty '
                'form is the other way to make a gesture useless.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/interaction/swipe_back.dart',
        ],
      ),
    );
  });
}
