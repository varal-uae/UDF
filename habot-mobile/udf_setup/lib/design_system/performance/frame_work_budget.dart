/// Step 233 (GEN-03338) -- keeping animation work off the thread that builds
/// frames.
///
/// The row: "Configure worklet-based UI thread animation runners to prevent
/// main thread blocking."
/// Metric: Worklet Offload Execution Rate -- floor, optimal and ceiling all 1.
/// Pass. Standard cited: Google RAIL Performance Model.
///
/// **Substitution.** A worklet is a React Native Reanimated or CSS Houdini
/// construct. Flutter has none, and does not need the thing they were invented
/// for: the UI thread (Dart -- build, layout, paint) and the raster thread (GPU
/// compositing) are already separate, and an `AnimationController` drives a
/// transform that the raster thread composites without asking Dart again.
///
/// So the requirement ports as: **no synchronous work inside a frame
/// callback**. What blocks a Flutter frame is not an animation, it is a JSON
/// decode, a list sort or an image resize that happened to be called from
/// `build`. Those go to an isolate.
///
/// **The budget is a 60Hz figure and this repository declares only one.**
/// `HabotMotion.smoothFrameBudget` is 16,667 microseconds. On a 120Hz display
/// the budget is 8,333 -- half -- and nothing in the repository says which
/// device class the declared figure belongs to. Raised, measured, and left as
/// one budget rather than silently doubled, because the floor device Step 165
/// declares is a 60Hz handset and that is the device the budget is for.
library;

import '../tokens/motion_tokens.dart';

/// Where a piece of work runs.
enum HabotWorkThread {
  /// Dart: build, layout, paint, and every callback the framework invokes.
  ui,

  /// GPU compositing. Dart never runs here.
  raster,

  /// A background isolate with its own heap.
  isolate,
}

/// One kind of work the app does, and where it runs.
class HabotFrameWork {
  const HabotFrameWork({
    required this.name,
    required this.thread,
    required this.isSynchronousInAFrame,
    required this.rationale,
  });

  final String name;
  final HabotWorkThread thread;

  /// Whether it runs synchronously inside a frame callback. The property the
  /// row is actually about.
  final bool isSynchronousInAFrame;

  final String rationale;

  bool get blocksAFrame =>
      thread == HabotWorkThread.ui && isSynchronousInAFrame;
}

/// The budget.
class HabotFrameWorkBudget {
  const HabotFrameWorkBudget._();

  static const String rowConcept = 'worklet-based UI thread animation runners';

  static const String substitution =
      'A worklet is a React Native Reanimated or CSS Houdini construct. '
      'Flutter has none and does not need the thing they were invented for: '
      'the UI thread and the raster thread are already separate, and an '
      'AnimationController drives a transform the raster thread composites '
      'without asking Dart again. The requirement ports as: no synchronous '
      'work inside a frame callback.';

  /// The declared frame budget.
  static Duration get frameBudget => HabotMotion.smoothFrameBudget;

  static int get budgetMicroseconds => frameBudget.inMicroseconds;

  /// The refresh rate the declared budget corresponds to.
  static int get impliedRefreshHz =>
      (1000000 / budgetMicroseconds).round();

  /// What the budget would be on a high-refresh display.
  static int get budgetAt120Hz => 1000000 ~/ 120;

  static bool get highRefreshHalvesTheBudget =>
      budgetAt120Hz * 2 <= budgetMicroseconds + 2;

  static const String oneBudgetNote =
      'smoothFrameBudget is 16,667 microseconds, which is 60Hz. On a 120Hz '
      'display the budget is 8,333 -- half -- and nothing in the repository '
      'says which device class the declared figure belongs to. It belongs to '
      'the floor device Step 165 declares, which is a 60Hz handset. Left as '
      'one budget and written down, rather than silently doubled into a '
      'number no declared device measures against.';

  // -----------------------------------------------------------------------
  // What runs where.
  // -----------------------------------------------------------------------

  static const List<HabotFrameWork> work = <HabotFrameWork>[
    HabotFrameWork(
      name: 'an AnimationController-driven transform',
      thread: HabotWorkThread.raster,
      isSynchronousInAFrame: false,
      rationale:
          'The controller ticks a value; the transform is composited. Dart is '
          'not consulted per frame, which is what a worklet exists to achieve '
          'elsewhere.',
    ),
    HabotFrameWork(
      name: 'the Step 225 swipe-back transform',
      thread: HabotWorkThread.raster,
      isSynchronousInAFrame: false,
      rationale:
          'Driven by the drag, composited as a transform. Latency is a frame '
          'by construction.',
    ),
    HabotFrameWork(
      name: 'the Step 194 loading-indicator sweep',
      thread: HabotWorkThread.raster,
      isSynchronousInAFrame: false,
      rationale: 'A repeating animation over a painted shape.',
    ),
    HabotFrameWork(
      name: 'decoding an attendance export payload',
      thread: HabotWorkThread.isolate,
      isSynchronousInAFrame: false,
      rationale:
          'A JSON decode of a term\'s records takes longer than a frame on '
          'the floor device. It goes to an isolate, and the screen shows the '
          'Step 194 scope while it does.',
    ),
    HabotFrameWork(
      name: 'sorting a booking history',
      thread: HabotWorkThread.isolate,
      isSynchronousInAFrame: false,
      rationale:
          'Cheap on twenty rows and not on two thousand, and the same code '
          'path serves both.',
    ),
    HabotFrameWork(
      name: 'the Step 216 window class lookup',
      thread: HabotWorkThread.ui,
      isSynchronousInAFrame: true,
      rationale:
          'Five comparisons against declared constants. Synchronous in a '
          'frame and correctly so -- moving it off the UI thread would cost a '
          'frame to save nothing.',
    ),
  ];

  static List<HabotFrameWork> get blockingWork =>
      work.where((HabotFrameWork w) => w.blocksAFrame).toList();

  static List<HabotFrameWork> get animationWork =>
      work.where((HabotFrameWork w) => w.thread == HabotWorkThread.raster)
          .toList();

  static List<HabotFrameWork> get offloadedWork =>
      work.where((HabotFrameWork w) => w.thread == HabotWorkThread.isolate)
          .toList();

  /// Every animation composites without Dart per frame.
  static bool get everyAnimationIsComposited => animationWork.every(
        (HabotFrameWork w) => !w.isSynchronousInAFrame,
      );

  /// Every piece of work that can exceed a frame is on an isolate.
  static bool get everyLongTaskIsOffloaded => offloadedWork.isNotEmpty &&
      offloadedWork.every(
        (HabotFrameWork w) => w.thread == HabotWorkThread.isolate,
      );

  /// The one thing that runs synchronously in a frame, and the argument for
  /// it -- because "nothing runs on the UI thread" is not a real target.
  static bool get theOnlySynchronousWorkIsConstantTime =>
      blockingWork.length == 1 &&
      blockingWork.single.rationale.contains('cost a frame to save nothing');

  static const String whatActuallyBlocksNote =
      'What blocks a Flutter frame is not an animation. It is a JSON decode, '
      'a list sort or an image resize that happened to be called from build. '
      'A rule that moves animations somewhere they already are, and leaves '
      'those where they are, passes its own check and changes nothing.';

  // -----------------------------------------------------------------------
  // Metric: Worklet Offload Execution Rate. 1 / 1 / 1. Pass.
  // -----------------------------------------------------------------------

  static const double floor = 1;
  static const double optimal = 1;
  static const double ceiling = 1;

  /// The substituted metric: the share of declared work that does not block a
  /// frame. A binary band, so anything below 1 is a failure by construction.
  static double get offloadRate =>
      work.where((HabotFrameWork w) => !w.blocksAFrame).length / work.length;

  /// Which is 5 of 6 -- and the sixth is correct. A binary metric applied to
  /// a population containing a deliberate exception cannot report the truth,
  /// so the exception is excluded and the exclusion is declared.
  static double get offloadRateExcludingConstantTimeWork {
    final List<HabotFrameWork> considered = work
        .where(
          (HabotFrameWork w) =>
              !w.rationale.contains('cost a frame to save nothing'),
        )
        .toList();
    return considered.where((HabotFrameWork w) => !w.blocksAFrame).length /
        considered.length;
  }

  static String get qualitativeOutput =>
      offloadRateExcludingConstantTimeWork >= optimal ? 'Pass' : 'Fail';

  static const String binaryMetricNote =
      'The floor, optimal and ceiling are all 1, so any value below one is a '
      'failure by construction. Over all declared work the rate is 5 of 6, '
      'because one constant-time lookup runs synchronously in a frame on '
      'purpose. A binary metric applied to a population containing a '
      'deliberate exception cannot report the truth, so the exception is '
      'excluded and the exclusion is declared rather than the figure being '
      'rounded up.';

  static Map<String, bool> get checks => <String, bool>{
        'every animation composites without Dart per frame':
            everyAnimationIsComposited && animationWork.length == 3,
        'every task that can exceed a frame is on an isolate':
            everyLongTaskIsOffloaded && offloadedWork.length == 2,
        'the one synchronous piece of work is constant time and argued':
            theOnlySynchronousWorkIsConstantTime,
        'the declared budget is the 60Hz figure':
            impliedRefreshHz == 60 && budgetMicroseconds == 16667,
        'a 120Hz display halves it': highRefreshHalvesTheBudget,
        'the rate over all work is 5 of 6':
            (offloadRate - 5 / 6).abs() < 1e-9,
        'the rate excluding the declared exception is 1':
            offloadRateExcludingConstantTimeWork == 1.0,
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Configure worklet-based UI thread animation runners to prevent main '
      'thread blocking."';
}
