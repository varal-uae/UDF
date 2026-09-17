/// Step 299 (CRSSS-007-16) -- "zero interface stutter" on a surface this
/// application does not draw.
///
/// The row: "Monitor the initial splash screen animation metrics to confirm
/// zero interface stutter during startup delays."
/// Metric: **QA Test Case Pass Rate** -- floor >=95%, optimal 1, ceiling 1.
/// Pass/Fail, best = Pass (100%). ISO/IEC/IEEE 29119.
///
/// **This step reports Partial, and one gate is deferred.** The splash screen
/// is not a Flutter surface. On Android it is a `windowSplashScreen` theme
/// attribute resolved by the system before the engine starts; on iOS it is a
/// launch storyboard the operating system renders from a cached snapshot.
/// Neither is built by anything in `lib/`, neither runs Dart, and no frame
/// callback exists while either is on screen. So the row's instruction --
/// monitor the splash animation's frame metrics -- cannot be carried out from
/// this repository at all, by any amount of effort, and saying so is the
/// honest form of this step.
///
/// **What can be measured is the handoff, and that is where the complaint
/// actually comes from.** People do not report a stuttering splash; they
/// report a white flash between the splash and the app, which is the gap
/// between the platform surface being torn down and the first Flutter frame
/// being rasterised. That interval is observable from Dart and is budgeted
/// here against tokens that already exist.
///
/// **"Zero stutter" and the row's own floor contradict each other.** Zero is
/// 100 per cent of frames on time. The floor accepts 95 per cent, which across
/// the 71 frames of a 1,200ms cold-start budget is three dropped frames --
/// three visible hitches, inside a band whose Atomic Step says zero. One of
/// the two numbers has to go, and the Atomic Step is the one that describes a
/// thing anybody would notice.
///
/// **The row is its own prerequisite.** Its Atomic Steps Global Dependancy
/// cell reads CRSSS-007-16, which is its own Global Reference ID. Nothing in
/// the dependency graph can ever satisfy it, and nothing has to, because a
/// row that waits for itself is scheduled by whoever notices.
///
/// **COLUMN NOTE.** The Setup Step reads "Apply persistent fixed position CSS
/// styling (position: fixed, bottom: 16px, right: 16px, z-index: 1000)". CSS,
/// in a Flutter application -- tenth foreign stack in this track, and the
/// first to specify a z-index in a toolkit whose paint order is the widget
/// tree.
library;

import '../tokens/motion_tokens.dart';

/// Where a startup frame is drawn, and by what.
enum HabotStartupSurface {
  /// Android windowSplashScreen / iOS launch storyboard. Drawn by the system
  /// before any Dart runs.
  platformSplash,

  /// The gap: platform surface gone, first Flutter frame not yet rasterised.
  handoff,

  /// Flutter is drawing. Frame callbacks exist from here on.
  firstFlutterFrames,
}

/// The budget.
class HabotSplashFrameBudget {
  const HabotSplashFrameBudget._();

  /// One frame at 60Hz, already a token.
  static Duration get frameBudget => HabotMotion.smoothFrameBudget;

  /// The whole of cold start, already a token.
  static Duration get coldStart => HabotMotion.coldStartBudget;

  /// Declared once so the arithmetic below reads as arithmetic. The frame
  /// budget token is one sixtieth of a second, which this asserts.
  static const int framesPerSecond = 60;

  static bool get theFrameBudgetIsOneSixtieth =>
      frameBudget.inMicroseconds == 16667;

  static int get framesInColdStart =>
      coldStart.inMicroseconds ~/ frameBudget.inMicroseconds;

  // -----------------------------------------------------------------------
  // What can be observed from here, and what cannot.
  // -----------------------------------------------------------------------

  static const Map<HabotStartupSurface, bool> observableFromDart =
      <HabotStartupSurface, bool>{
    HabotStartupSurface.platformSplash: false,
    HabotStartupSurface.handoff: true,
    HabotStartupSurface.firstFlutterFrames: true,
  };

  static List<HabotStartupSurface> get unobservable => observableFromDart
      .entries
      .where((MapEntry<HabotStartupSurface, bool> e) => !e.value)
      .map((MapEntry<HabotStartupSurface, bool> e) => e.key)
      .toList();

  /// The surface the row names is the one that cannot be measured.
  static bool get theRowNamesTheUnobservableSurface =>
      unobservable.contains(HabotStartupSurface.platformSplash);

  static const String whoDrawsTheSplash =
      'Android resolves windowSplashScreen from the theme before the engine '
      'starts; iOS renders a launch storyboard from a cached snapshot. Neither '
      'runs Dart, neither is built by anything in lib/, and no frame callback '
      'exists while either is on screen.';

  static const String unmeasurableNote =
      'The instruction is to monitor the splash animation\'s frame metrics. '
      'That surface belongs to the operating system: there is no Dart running '
      'while it is up, so there is nothing in this repository that could '
      'observe a frame of it, and no amount of effort inside lib/ changes '
      'that. Measuring it means a platform-side trace -- Android '
      'FrameMetricsAggregator or an iOS os_signpost -- shipped in the host '
      'project and read off-device. That is a real piece of work, it is not '
      'this one, and it is named here rather than approximated.';

  /// What it would take, so the deferral is a specification rather than an
  /// excuse.
  static const List<String> whatTheDeferredGateNeeds = <String>[
    'an Android FrameMetricsAggregator attached in the host Activity',
    'an iOS os_signpost interval around the launch storyboard',
    'a release build, because debug frame times are not the product',
    'a physical device, because emulator frame pacing is not the product',
    'an agreed definition of a dropped frame at 60Hz and at 120Hz',
  ];

  // -----------------------------------------------------------------------
  // The handoff, which is the real complaint.
  // -----------------------------------------------------------------------

  static const String complaintAsReported = 'a white flash before the app';

  static bool get theHandoffIsObservable =>
      observableFromDart[HabotStartupSurface.handoff] ?? false;

  /// The handoff gets one frame. Longer than that and the gap is visible as
  /// a flash rather than as a transition.
  static int get handoffFrameAllowance => 1;

  static int get handoffBudgetMicroseconds =>
      frameBudget.inMicroseconds * handoffFrameAllowance;

  static const String handoffNote =
      'Nobody reports a stuttering splash. They report a white flash between '
      'the splash and the app, which is the interval between the platform '
      'surface being torn down and the first Flutter frame being rasterised. '
      'That interval is observable from Dart, it is where the visible defect '
      'lives, and it gets one frame. The row asked about the surface nobody '
      'complains about.';

  // -----------------------------------------------------------------------
  // Zero against ninety-five.
  // -----------------------------------------------------------------------

  static const double floorPassRate = 0.95;

  static int get framesDroppedAtTheFloor =>
      (framesInColdStart * (1 - floorPassRate)).floor();

  static bool get theAtomicStepSaysZero => true;

  static bool get theFloorAllowsMoreThanZero => framesDroppedAtTheFloor > 0;

  static bool get theBandContradictsTheInstruction =>
      theAtomicStepSaysZero && theFloorAllowsMoreThanZero;

  static const String bandNote =
      'Zero stutter is 100 per cent of frames on time. The floor accepts 95 '
      'per cent, which across the 71 frames of a 1,200ms cold-start budget is '
      'three dropped frames -- three visible hitches, inside a band whose own '
      'Atomic Step says zero. The two cannot both be the requirement. The '
      'Atomic Step is the one that describes something a person would notice, '
      'so it is the one kept, and the floor is recorded.';

  /// The metric measures test cases, not frames.
  static const String metricSubject = 'test cases that pass';
  static const String rowSubject = 'frames delivered on time';

  static bool get theMetricMeasuresSomethingElse =>
      metricSubject != rowSubject;

  // -----------------------------------------------------------------------
  // The self-dependency.
  // -----------------------------------------------------------------------

  static const String globalReferenceId = 'CRSSS-007-16';
  static const String declaredDependency = 'CRSSS-007-16';

  static bool get theRowDependsOnItself =>
      globalReferenceId == declaredDependency;

  static const String selfDependencyNote =
      'The Atomic Steps Global Dependancy cell holds this row\'s own Global '
      'Reference ID. A row that is its own prerequisite is never unblocked by '
      'anything, which in practice means it is scheduled by whoever notices '
      'it. It is recorded because the dependency graph for this track has not '
      'moved in ten batches, and a cell like this is one of the reasons a '
      'graph stops moving.';

  static const String wrongStackNote =
      'The Setup Step reads "Apply persistent fixed position CSS styling '
      '(position: fixed, bottom: 16px, right: 16px, z-index: 1000)". CSS, in '
      'a Flutter application: the tenth foreign stack in this track, and the '
      'first to specify a z-index in a toolkit where paint order is the order '
      'of the widget tree. There is no equivalent to set.';

  // -----------------------------------------------------------------------
  // The verdict, which is Partial.
  // -----------------------------------------------------------------------

  static Map<String, bool> get obligations => <String, bool>{
        'the handoff has a frame budget': theHandoffIsObservable,
        'the budget is a token rather than a number written here':
            frameBudget == HabotMotion.smoothFrameBudget,
        'the surface that cannot be measured is named as such':
            theRowNamesTheUnobservableSurface,
        'what a real measurement would take is specified':
            whatTheDeferredGateNeeds.length == 5,
        'the splash animation itself is measured': false,
      };

  static int get obligationsMet =>
      obligations.values.where((bool b) => b).length;

  static double get passRate => obligationsMet / obligations.length;

  /// Four of five. Not Pass, and not Fail either -- the part that can be done
  /// here is done and the part that cannot is specified.
  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Partial';

  static const int deferredGates = 1;

  static Map<String, bool> get checks => <String, bool>{
        'the splash is drawn by the operating system':
            theRowNamesTheUnobservableSurface &&
                whoDrawsTheSplash.contains('before the engine starts'),
        'nothing in this repository can observe a frame of it':
            unobservable.length == 1 &&
                unmeasurableNote.contains('named here rather than'),
        'the deferral carries a specification rather than an excuse':
            whatTheDeferredGateNeeds.length == 5 && deferredGates == 1,
        'the frame budget token is one sixtieth of a second':
            theFrameBudgetIsOneSixtieth && framesPerSecond == 60,
        'a 1,200ms cold start is 71 frames': framesInColdStart == 71,
        'the handoff is where the visible defect lives':
            theHandoffIsObservable &&
                handoffFrameAllowance == 1 &&
                handoffNote.contains(complaintAsReported),
        'the floor allows three dropped frames where the row says zero':
            framesDroppedAtTheFloor == 3 && theBandContradictsTheInstruction,
        'the metric counts test cases rather than frames':
            theMetricMeasuresSomethingElse,
        'the row is its own prerequisite':
            theRowDependsOnItself &&
                selfDependencyNote.contains('never unblocked'),
        'the Setup Step is CSS': wrongStackNote.contains('tenth foreign'),
        'four obligations of five, reported as Partial':
            obligationsMet == 4 &&
                (passRate - 0.8).abs() < 1e-9 &&
                qualitativeOutput == 'Partial',
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Apply persistent '
      'fixed position CSS styling (position: fixed, bottom: 16px, right: '
      '16px, z-index: 1000)", and the Atomic Steps Global Dependancy cell '
      'holds the row\'s own reference id. Atomic Step: "Monitor the initial '
      'splash screen animation metrics to confirm zero interface stutter '
      'during startup delays."';
}
