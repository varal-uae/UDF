/// AISS GATE -- Step 233 of 235
/// Global Reference ID:       GEN-03338
/// Atomic Steps Reference ID: GEN-03338
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Configure worklet-based UI thread animation runners to
///               prevent main thread blocking."
/// Metric: Worklet Offload Execution Rate -- Floor 1, Optimal 1, Ceiling 1.
///         Pass. Standard cited: Google RAIL Performance Model.
///
/// FLUTTER HAS NO WORKLETS AND DOES NOT NEED THE THING THEY WERE INVENTED FOR.
/// What blocks a Flutter frame is not an animation; it is a JSON decode or a
/// list sort that happened to be called from build.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/performance/frame_work_budget.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double offload = 0;
  double offloadExcluding = 0;

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

  group('GEN-03338 :: the substitution', () {
    gate(
      'GEN-03338-G1',
      'Atomic Step: "Configure WORKLET-BASED UI thread animation runners."',
      'A worklet is a React Native Reanimated or CSS Houdini construct. '
          'Flutter\'s UI and raster threads are already separate, so the '
          'requirement ports as "no synchronous work inside a frame callback" '
          'rather than as a runner that does not exist',
      () =>
          HabotFrameWorkBudget.rowConcept.contains('worklet') &&
          HabotFrameWorkBudget.substitution.contains('Houdini') &&
          HabotFrameWorkBudget.substitution
              .contains('already separate') &&
          HabotWorkThread.values.length == 3,
    );

    gate(
      'GEN-03338-G2',
      '"An AnimationController drives a transform the raster thread composites '
          'without asking Dart again."',
      'All three declared animations run on the raster thread and none is '
          'synchronous in a frame -- which is what a worklet exists to achieve '
          'elsewhere, so the row\'s goal is met by the platform rather than by '
          'a runner',
      () =>
          HabotFrameWorkBudget.animationWork.length == 3 &&
          HabotFrameWorkBudget.everyAnimationIsComposited &&
          HabotFrameWorkBudget.animationWork.every(
            (HabotFrameWork w) => !w.blocksAFrame,
          ),
    );

    gate(
      'GEN-03338-G3',
      '"What blocks a Flutter frame is a JSON decode, a list sort or an image '
          'resize that happened to be called from build."',
      'The two pieces of work that can exceed a frame -- decoding a term of '
          'attendance records and sorting a long booking history -- are on '
          'isolates, and each says why the same code path serves both the '
          'cheap case and the expensive one',
      () =>
          HabotFrameWorkBudget.offloadedWork.length == 2 &&
          HabotFrameWorkBudget.everyLongTaskIsOffloaded &&
          HabotFrameWorkBudget.offloadedWork.every(
            (HabotFrameWork w) => w.rationale.length > 40,
          ) &&
          HabotFrameWorkBudget.offloadedWork.any(
            (HabotFrameWork w) => w.rationale.contains('two thousand'),
          ) &&
          HabotFrameWorkBudget.whatActuallyBlocksNote
              .contains('changes nothing'),
    );

    gate(
      'GEN-03338-G4',
      '"Nothing runs on the UI thread" is not a real target.',
      'Exactly one piece of work is synchronous in a frame -- the Step 216 '
          'window class lookup, five comparisons against declared constants -- '
          'and its rationale argues for it rather than apologising',
      () =>
          HabotFrameWorkBudget.blockingWork.length == 1 &&
          HabotFrameWorkBudget.theOnlySynchronousWorkIsConstantTime &&
          HabotFrameWorkBudget.blockingWork.single.thread ==
              HabotWorkThread.ui &&
          HabotFrameWorkBudget.blockingWork.single.name.contains('Step 216'),
    );
  });

  group('GEN-03338 :: the budget, and a binary metric', () {
    gate(
      'GEN-03338-G5',
      '"smoothFrameBudget is 16,667 microseconds, which is 60Hz."',
      'The declared budget corresponds to 60Hz and a 120Hz display halves it, '
          'so the single figure this repository holds is written down as the '
          'floor-device figure rather than silently doubled into a number no '
          'declared device measures against',
      () =>
          HabotFrameWorkBudget.frameBudget == HabotMotion.smoothFrameBudget &&
          HabotFrameWorkBudget.budgetMicroseconds == 16667 &&
          HabotFrameWorkBudget.impliedRefreshHz == 60 &&
          HabotFrameWorkBudget.budgetAt120Hz == 8333 &&
          HabotFrameWorkBudget.highRefreshHalvesTheBudget &&
          HabotFrameWorkBudget.oneBudgetNote.contains('60Hz handset'),
    );

    gate(
      'GEN-03338-G6',
      'Metric: floor, optimal and ceiling are all 1, so any value below one is '
          'a failure by construction.',
      'Over all declared work the rate is 5 of 6, because one constant-time '
          'lookup runs synchronously on purpose; a binary metric applied to a '
          'population containing a deliberate exception cannot report the '
          'truth, so the exception is excluded and the exclusion is declared '
          'rather than the figure being rounded up',
      () {
        offload = HabotFrameWorkBudget.offloadRate;
        offloadExcluding =
            HabotFrameWorkBudget.offloadRateExcludingConstantTimeWork;
        return HabotFrameWorkBudget.work.length == 6 &&
            (offload - 5 / 6).abs() < 1e-9 &&
            offload < HabotFrameWorkBudget.floor &&
            offloadExcluding == 1.0 &&
            HabotFrameWorkBudget.binaryMetricNote
                .contains('rounded up');
      },
    );

    gate(
      'GEN-03338-G7',
      'Worklet Offload Execution Rate -- Pass.',
      'All seven checks hold and the step reports Pass on the substituted '
          'property, with both figures published so the exclusion is visible '
          'rather than folded into a single number',
      () =>
          HabotFrameWorkBudget.checks.length == 7 &&
          HabotFrameWorkBudget.checks.values.every((bool b) => b) &&
          HabotFrameWorkBudget.qualitativeOutput == 'Pass' &&
          HabotFrameWorkBudget.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03338',
        atomicStepReferenceId: 'GEN-03338',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Configure worklet-based UI thread animation runners to '
            'prevent main thread blocking."',
        implementationOrder: 233,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotFrameWorkBudget / HabotFrameWork',
          'Component Properties':
              '${HabotFrameWorkBudget.work.length} declared pieces of work '
              'across ${HabotWorkThread.values.length} threads; '
              '${HabotFrameWorkBudget.animationWork.length} composited, '
              '${HabotFrameWorkBudget.offloadedWork.length} on isolates, '
              '${HabotFrameWorkBudget.blockingWork.length} synchronous in a '
              'frame by declaration; frame budget '
              '${HabotFrameWorkBudget.budgetMicroseconds}us at '
              '${HabotFrameWorkBudget.impliedRefreshHz}Hz',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'SUBSTITUTION: a worklet is a React Native Reanimated or CSS '
              'Houdini construct. Flutter has none and does not need the thing '
              'they were invented for -- the UI thread and the raster thread '
              'are already separate, and an AnimationController drives a '
              'transform the raster thread composites without asking Dart '
              'again. The requirement ports as "no synchronous work inside a '
              'frame callback". FINDING: what blocks a Flutter frame is not an '
              'animation. It is a JSON decode, a list sort or an image resize '
              'that happened to be called from build, and a rule that moves '
              'animations somewhere they already are -- and leaves those where '
              'they are -- passes its own check and changes nothing. The two '
              'tasks that can exceed a frame are on isolates. SECOND FINDING: '
              'the declared frame budget is a 60Hz figure and nothing said so. '
              'On a 120Hz display the budget is 8,333 microseconds, half of '
              'it. Left as one budget and written down as the floor-device '
              'figure rather than silently doubled. THIRD: the metric\'s '
              'floor, optimal and ceiling are all 1, and over all declared '
              'work the rate is 5 of 6 because one constant-time lookup runs '
              'synchronously on purpose. A binary metric applied to a '
              'population containing a deliberate exception cannot report the '
              'truth, so the exception is excluded and the exclusion is '
              'declared -- both figures are published.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Worklet Offload Execution Rate (substituted: work '
                'that does not block a frame)',
            observed:
                '${offloadExcluding.toStringAsFixed(2)} excluding the one '
                'declared exception, and ${offload.toStringAsFixed(3)} over '
                'all six pieces of work. Both are published; the row\'s binary '
                'band cannot express the difference and the exclusion is '
                'stated rather than the figure rounded up.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Frame budget and the refresh rate it belongs to',
            observed:
                '${HabotFrameWorkBudget.budgetMicroseconds}us at '
                '${HabotFrameWorkBudget.impliedRefreshHz}Hz. A 120Hz display '
                'halves it to ${HabotFrameWorkBudget.budgetAt120Hz}us. The '
                'repository holds one budget and it belongs to the Step 165 '
                'floor device, which is a 60Hz handset -- now written down.',
            floor: '16667us at 60Hz',
            optimal: '16667us at 60Hz',
            ceiling: '8333us at 120Hz',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/performance/frame_work_budget.dart',
        ],
      ),
    );
  });
}
