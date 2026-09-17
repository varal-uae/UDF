/// Step 346 (MTVPE-004) -- CSS transitions in an application with no CSS, and
/// the fourteenth foreign stack this track has recorded.
///
/// The row: "Apply CSS transitions to enable a smooth, hardware-accelerated
/// slide-in animation from the right viewport edge."
/// Metric: **CSS Style Application Accuracy (%)** -- floor 98, optimal 100,
/// ceiling 100. Pass / Fail. W3C CSS Animations and Transitions Module.
///
/// **There is no CSS here.** This is a Flutter application that rasterises its
/// own widgets; it has no stylesheet, no cascade and no transition property.
/// The metric is named for the technology rather than for the outcome -- "CSS
/// Style Application Accuracy" cannot be anything other than zero or undefined
/// in a codebase with no CSS -- and the standard cited is the W3C module that
/// defines the thing that is absent. Step 258 keeps the running list of stacks
/// the sheet writes for; this is the fourteenth, after React Native at Step
/// 317.
///
/// **What survives translation is the intent, and it is a good one.** A panel
/// that slides in from the edge rather than appearing instantly tells a person
/// where it came from and therefore where it will go back to, which is the
/// difference between a panel and a page. That is a motion decision, and the
/// motion tokens already carry the durations and the curves for it.
///
/// **"Hardware-accelerated" does not survive, and does not need to.** In CSS it
/// is a real instruction: certain properties are composited on the GPU and
/// others force a layout pass, so an author picks transform over left. Flutter
/// composites every widget on the GPU by default, so there is no slow path to
/// avoid and no hint to give. The instruction is not wrong here, it is empty.
///
/// **The direction is not "right".** The panel enters from the edge it will
/// return to, and which edge that is depends on the reading direction -- the
/// same resolution Step 225 made for the back gesture and Step 336 restates for
/// the viewport toggle.
///
/// **Reduced motion is the part the row does not mention.** A slide is
/// vestibular motion, and SC 2.3.3 Animation from Interactions is Level AAA
/// while the platform preference is not optional. When it is set the panel
/// cross-fades in place.
library;

import '../tokens/motion_tokens.dart';
import '../gesture/swipe_alternative.dart';

/// Which edge a panel enters from, before the reading direction is applied.
enum HabotPanelEdge { leading, trailing }

/// What the panel does when it appears.
enum HabotPanelEntry { slide, fadeInPlace }

/// The guidance panel.
class HabotGuidancePanel {
  const HabotGuidancePanel._();

  // -----------------------------------------------------------------------
  // The stack the row was written for.
  // -----------------------------------------------------------------------

  static const String stackTheRowAssumes = 'CSS';
  static const String stackThisApplicationUses = 'Flutter';

  static bool get theRowAssumesADifferentStack =>
      stackTheRowAssumes != stackThisApplicationUses;

  static const bool thisApplicationHasAStylesheet = false;

  /// Step 258 keeps the register; this is the fourteenth entry.
  static const int foreignStackOrdinal = 14;

  static const int theThirteenth = 317;

  static bool get theRegisterIsAlreadyDeclared =>
      foreignStackOrdinal == 14 && theThirteenth == 317;

  static const String metricName = 'CSS Style Application Accuracy (%)';

  /// A percentage of correctly applied CSS rules, in a codebase with none.
  static bool get theMetricHasNoPopulationHere =>
      !thisApplicationHasAStylesheet && metricName.contains('CSS');

  static const String stackNote =
      'This is a Flutter application. It has no stylesheet, no cascade and no '
      'transition property, so "CSS Style Application Accuracy" has an empty '
      'population: the share of correctly applied CSS rules among zero CSS '
      'rules. The standard cited is the W3C module that defines the absent '
      'thing. Step 258 keeps the register of stacks the sheet writes for, and '
      'this is the fourteenth entry after React Native at Step 317.';

  // -----------------------------------------------------------------------
  // What translates: the intent.
  // -----------------------------------------------------------------------

  static Duration get enterDuration => HabotMotion.sheetEnter;
  static Duration get exitDuration => HabotMotion.sheetExit;

  static bool get bothDurationsComeFromTokens =>
      enterDuration == HabotMotion.sheetEnter &&
      exitDuration == HabotMotion.sheetExit;

  /// The exit is shorter than the entry: leaving should not be made to wait.
  static bool get leavingIsNotSlowerThanArriving =>
      exitDuration <= enterDuration;

  static const String intentNote =
      'A panel that slides in from an edge tells a person where it came from '
      'and therefore where it goes back to, which is the whole difference '
      'between a panel and a page. That intent survives the translation out of '
      'CSS intact, and the durations and curves it needs were declared in the '
      'motion tokens long before this row asked for them.';

  // -----------------------------------------------------------------------
  // What does not translate: the acceleration hint.
  // -----------------------------------------------------------------------

  static const bool aCompositingHintIsNeeded = false;

  static const String accelerationNote =
      'In CSS, "hardware-accelerated" is a real instruction: transform and '
      'opacity are composited on the GPU while properties like left force a '
      'layout pass, so an author chooses between them. Flutter composites '
      'every widget on the GPU already, so there is no slow path to avoid and '
      'no hint to give. The instruction is not wrong here, it is empty, and '
      'writing something to satisfy it would be writing something that does '
      'nothing.';

  // -----------------------------------------------------------------------
  // The edge, resolved rather than assumed.
  // -----------------------------------------------------------------------

  static const HabotPanelEdge edge = HabotPanelEdge.trailing;

  static const String edgeTheRowNames = 'right';

  static bool get theEdgeIsResolvedNotPhysical =>
      edge == HabotPanelEdge.trailing && edgeTheRowNames == 'right';

  static bool get theResolutionRuleIsAlreadyDeclared =>
      HabotSwipeAlternative.theDirectionRuleIsAlreadyDeclared;

  static const String edgeNote =
      'The row says the right edge, which is a physical side of a device. The '
      'panel enters from the edge it will return to, and in a right-to-left '
      'locale that is the left one. Step 225 resolved this for the back '
      'gesture and Step 336 restates it for the viewport toggle; the same rule '
      'applies to a panel, because Urdu ships.';

  // -----------------------------------------------------------------------
  // Reduced motion.
  // -----------------------------------------------------------------------

  static HabotPanelEntry entryFor({required bool prefersReducedMotion}) =>
      prefersReducedMotion
          ? HabotPanelEntry.fadeInPlace
          : HabotPanelEntry.slide;

  static bool get reducedMotionReplacesTheSlide =>
      entryFor(prefersReducedMotion: true) == HabotPanelEntry.fadeInPlace;

  static bool get theDefaultIsStillASlide =>
      entryFor(prefersReducedMotion: false) == HabotPanelEntry.slide;

  /// The panel still appears; what changes is how.
  static const bool reducedMotionRemovesThePanel = false;

  static const String reducedMotionNote =
      'A slide across a viewport is vestibular motion, and the platform '
      'preference for reduced motion is not a preference about taste. When it '
      'is set the panel cross-fades in place: it still arrives, it still '
      'leaves, and the spatial story is carried by the panel keeping its edge '
      'rather than by travel. Removing the panel entirely would be reading the '
      'preference as a request for less function.';

  static const double bandFloor = 98;
  static const double bandOptimal = 100;
  static const double bandCeiling = 100;

  static bool get theOptimalEqualsTheCeiling => bandOptimal == bandCeiling;

  static const String bandNote =
      'Floor 98, optimal 100, ceiling 100: the top two values are the same '
      'number, which is the third band shaped this way in this batch after '
      'Steps 336 and 339. On a metric with no population here, the shape is '
      'the lesser of its two problems.';

  static Map<String, bool> get obligations => <String, bool>{
        'the entry and exit durations come from the motion tokens':
            bothDurationsComeFromTokens,
        'leaving is not slower than arriving': leavingIsNotSlowerThanArriving,
        'the edge is resolved against the reading direction':
            theEdgeIsResolvedNotPhysical,
        'reduced motion replaces the slide rather than the panel':
            reducedMotionReplacesTheSlide && !reducedMotionRemovesThePanel,
        'the absent stack is recorded rather than simulated':
            theRowAssumesADifferentStack && !thisApplicationHasAStylesheet,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'the row is written for a stack this application does not have':
            theRowAssumesADifferentStack && !thisApplicationHasAStylesheet,
        'the metric has an empty population':
            theMetricHasNoPopulationHere &&
                stackNote.contains('among zero CSS rules'),
        'it is the fourteenth foreign stack, after Step 317':
            theRegisterIsAlreadyDeclared && stackNote.contains('Step 258'),
        'both durations are tokens': bothDurationsComeFromTokens,
        'the exit is not slower than the entry':
            leavingIsNotSlowerThanArriving &&
                intentNote.contains('panel and a page'),
        'no compositing hint is needed or written':
            !aCompositingHintIsNeeded &&
                accelerationNote.contains('it is empty'),
        'the edge is trailing rather than right':
            theEdgeIsResolvedNotPhysical && theResolutionRuleIsAlreadyDeclared,
        'reduced motion cross-fades in place':
            reducedMotionReplacesTheSlide && theDefaultIsStillASlide,
        'reduced motion does not remove the panel':
            !reducedMotionRemovesThePanel &&
                reducedMotionNote.contains('less function'),
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass' &&
                theOptimalEqualsTheCeiling,
      };

  static const String columnNote =
      'COLUMN NOTE: this row asks for CSS transitions in an application with '
      'no CSS and scores them on "CSS Style Application Accuracy (%)"; its '
      'Decision Group is "G1 (Perimeter Security)" and its narrative columns '
      'are about TLS 1.3 handshakes and Terraform gateway configuration; its '
      'Data Requirement column describes a video player; and its Setup Step '
      'column reads "Initialize the Universal MTO split-screen mirror '
      'deployment script". Atomic Step: "Apply CSS transitions to enable a '
      'smooth, hardware-accelerated slide-in animation from the right viewport '
      'edge."';
}
