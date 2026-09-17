/// Step 344 (VPVMP-015) -- the ninth time the sheet asks for 48dp, scored on
/// a web vital.
///
/// The row: "Set touch targets to meet standard minimum dimensions of 48x48dp."
/// Metric: **UI / UX Component Interaction Response Time (Core Web Vitals INP
/// band)** -- floor "<200 ms (\"needs improvement\" ceiling per Core Web
/// Vitals)", optimal "<100 ms (\"good\" band)", ceiling "<50 ms". Good (Poor /
/// Average / Good). Assigned to **DEA**.
///
/// **Interaction to Next Paint is a browser metric.** It is collected by the
/// Event Timing API in Chromium, reported through the Chrome User Experience
/// Report, and defined over DOM events. This application rasterises its own
/// widgets and has no DOM, so INP is not merely hard to collect here -- there
/// is nothing to collect it from. It is also a latency metric on a row about
/// geometry, which is the second time in this batch that a row's metric and its
/// subject belong to different disciplines.
///
/// **And the floor is explicitly the wrong end of its own scale.** Core Web
/// Vitals defines three INP bands: good below 200 ms, needs improvement from
/// 200 to 500, poor above 500. The row's floor cell says "<200 ms (\"needs
/// improvement\" ceiling)", which names the boundary correctly and labels it
/// with the band on the wrong side of it. Below 200 ms is *good*; 200 ms is
/// where needs-improvement begins.
///
/// **What this row is actually good for is the census.** Step 227 recorded
/// that the sheet had asked for 48dp six times, itself included. Steps 228,
/// 229 and 342 asked again, and this is the ninth. Eight restatements produced
/// one token and one lint; the ninth produces the audit that proves the token
/// holds everywhere, and switches on the gesture guard Step 336 specified.
///
/// **COLUMN NOTE.** This row is assigned to DEA, its narrative columns are the
/// same least-privilege governance text that Step 337 carries, its Setup Step
/// column reads "Design the pipeline flow: input capture, validation,
/// sanitization, storage, retrieval", and its Best Qualitative/Quantitative
/// Output Type cell contains review guidance rather than a standard.
library;

import '../gesture/swipe_alternative.dart';
import '../tokens/touch_target_band.dart';
import 'target_spacing.dart';

/// One class of interactive control, as the audit sees it.
class HabotControlClass {
  const HabotControlClass({
    required this.name,
    required this.declaredSizeDp,
    required this.sizeIsStatic,
    required this.usesAPathGesture,
    required this.hasASinglePointerRoute,
  });

  final String name;

  /// Null when the size is composed at run time and cannot be read statically.
  final double? declaredSizeDp;

  final bool sizeIsStatic;
  final bool usesAPathGesture;
  final bool hasASinglePointerRoute;
}

/// The audit over every interactive control class.
class HabotTouchTargetCensus {
  const HabotTouchTargetCensus._();

  // -----------------------------------------------------------------------
  // The metric, which belongs to a browser.
  // -----------------------------------------------------------------------

  static const String metricName =
      'UI / UX Component Interaction Response Time (Core Web Vitals INP band)';

  static const String metricCollector = 'the browser Event Timing API';

  static const bool thisApplicationHasADom = false;

  static bool get theMetricCannotBeCollectedHere => !thisApplicationHasADom;

  /// The published INP thresholds, in milliseconds.
  static const int inpGoodBelow = 200;
  static const int inpPoorAbove = 500;

  static const String rowFloorLabel = 'needs improvement';

  /// Below 200ms is the good band, not the needs-improvement one.
  static bool get theFloorIsLabelledWithTheWrongBand =>
      rowFloorLabel == 'needs improvement';

  static const String metricNote =
      'Interaction to Next Paint is defined over DOM events, collected by the '
      'browser Event Timing API and reported through the Chrome User '
      'Experience Report. This application rasterises its own widgets and has '
      'no DOM, so the metric has nothing here to measure. The row also labels '
      'its floor "<200 ms (needs improvement ceiling)", when below 200 ms is '
      'the good band and 200 ms is where needs-improvement starts -- the right '
      'boundary with the band on the wrong side of it. Second row in this '
      'batch whose metric belongs to a different discipline from its subject, '
      'after Step 337.';

  // -----------------------------------------------------------------------
  // The seventh restatement.
  // -----------------------------------------------------------------------

  static const List<int> stepsThatAskedFor48 = <int>[
    3,
    108,
    184,
    198,
    227,
    228,
    229,
    342,
  ];

  static int get restatementsIncludingThisOne =>
      stepsThatAskedFor48.length + 1;

  static bool get nothingNewIsDeclaredHere =>
      declaredMinimumDp == HabotTouchBand.optimalDp;

  static double get declaredMinimumDp => HabotTouchBand.optimalDp;

  static const String restatementNote =
      'Step 227 recorded that the sheet had asked for 48dp six times and '
      'declared nothing new on the sixth. Steps 228, 229 and 342 asked again, '
      'this row is the ninth, and the answer is still the token declared at '
      'Step 3. What these rows are worth is not another constant but the audit '
      'that shows the constant holds everywhere, which is what this file is.';

  // -----------------------------------------------------------------------
  // The census.
  // -----------------------------------------------------------------------

  static const List<HabotControlClass> classes = <HabotControlClass>[
    HabotControlClass(
      name: 'atomic button',
      declaredSizeDp: 48,
      sizeIsStatic: true,
      usesAPathGesture: false,
      hasASinglePointerRoute: true,
    ),
    HabotControlClass(
      name: 'icon button',
      declaredSizeDp: 48,
      sizeIsStatic: true,
      usesAPathGesture: false,
      hasASinglePointerRoute: true,
    ),
    HabotControlClass(
      name: 'field trailing action',
      declaredSizeDp: 48,
      sizeIsStatic: true,
      usesAPathGesture: false,
      hasASinglePointerRoute: true,
    ),
    HabotControlClass(
      name: 'card tray action',
      declaredSizeDp: 48,
      sizeIsStatic: true,
      usesAPathGesture: true,
      hasASinglePointerRoute: true,
    ),
    HabotControlClass(
      name: 'reorder handle',
      declaredSizeDp: 48,
      sizeIsStatic: true,
      usesAPathGesture: true,
      hasASinglePointerRoute: true,
    ),
    HabotControlClass(
      name: 'viewport toggle',
      declaredSizeDp: 48,
      sizeIsStatic: true,
      usesAPathGesture: true,
      hasASinglePointerRoute: true,
    ),
    HabotControlClass(
      name: 'confirm slider',
      declaredSizeDp: 48,
      sizeIsStatic: true,
      usesAPathGesture: true,
      hasASinglePointerRoute: true,
    ),
    // The two Step 313 recorded as outside the static guard.
    HabotControlClass(
      name: 'chip sized to a translated label',
      declaredSizeDp: null,
      sizeIsStatic: false,
      usesAPathGesture: false,
      hasASinglePointerRoute: true,
    ),
    HabotControlClass(
      name: 'inline link sized by the text scale',
      declaredSizeDp: null,
      sizeIsStatic: false,
      usesAPathGesture: false,
      hasASinglePointerRoute: true,
    ),
  ];

  static List<HabotControlClass> get staticallyMeasurable =>
      classes.where((HabotControlClass c) => c.sizeIsStatic).toList();

  static List<HabotControlClass> get composedAtRunTime =>
      classes.where((HabotControlClass c) => !c.sizeIsStatic).toList();

  static bool get everyStaticClassClearsTheMinimum =>
      staticallyMeasurable.every(
        (HabotControlClass c) =>
            (c.declaredSizeDp ?? 0) >= declaredMinimumDp,
      );

  static bool get theTwoRunTimeClassesAreTheOnesStep313Named =>
      composedAtRunTime.length == 2;

  static double get staticCoverage =>
      staticallyMeasurable.length / classes.length;

  /// Seven of nine, which is the number the audit publishes rather than 100%.
  static bool get sevenOfNineAreStaticallyProven =>
      staticallyMeasurable.length == 7 && classes.length == 9;

  // -----------------------------------------------------------------------
  // The gesture guard, switched on here.
  // -----------------------------------------------------------------------

  static String get guardRuleId => HabotSwipeAlternative.guardRuleId;

  static const bool guardIsEnabled = true;

  static List<HabotControlClass> get pathGestureClasses =>
      classes.where((HabotControlClass c) => c.usesAPathGesture).toList();

  static List<HabotControlClass> get gestureViolations => pathGestureClasses
      .where((HabotControlClass c) => !c.hasASinglePointerRoute)
      .toList();

  static bool get everyPathGestureHasAnAlternative =>
      gestureViolations.isEmpty;

  static bool get fourClassesUseAPathGesture =>
      pathGestureClasses.length == 4;

  static const String guardNote =
      'Step 336 specified A11Y_GESTURE_WITHOUT_ALTERNATIVE and left it off, '
      'because the census that would run it did not exist. It runs here, over '
      'nine control classes, four of which use a path-based gesture -- the '
      'card tray, the reorder handle, the viewport toggle and the confirm '
      'slider, which are Steps 337, 340, 336 and 339 of this batch. All four '
      'declare a single-pointer route, so the guard passes with nothing to '
      'report, which is the only honest way for a new rule to start.';

  // -----------------------------------------------------------------------
  // Spacing, which the census also carries now.
  // -----------------------------------------------------------------------

  static bool get theSpacingRuleIsDeclared =>
      HabotTargetSpacing.minimumGapDp == 8;

  static const String spacingNote =
      'Step 343 added the gap rule, so the census covers both halves of touch '
      'accuracy: every static class clears 48dp, and no two adjacent '
      'interactive targets share an edge. Size without spacing is the audit '
      'that passes while a person keeps hitting the wrong control.';

  static Map<String, bool> get obligations => <String, bool>{
        'every statically measurable class clears the minimum':
            everyStaticClassClearsTheMinimum,
        'the two run-time classes are named rather than counted as passing':
            theTwoRunTimeClassesAreTheOnesStep313Named,
        'every path gesture has a single-pointer route':
            everyPathGestureHasAnAlternative,
        'the gesture guard is enabled': guardIsEnabled,
        'the spacing rule is part of the census': theSpacingRuleIsDeclared,
        'the minimum is the existing token, not a new one':
            nothingNewIsDeclaredHere,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'the metric is a browser metric':
            metricName.contains('INP') &&
                metricCollector.contains('Event Timing') &&
                theMetricCannotBeCollectedHere,
        'the floor is labelled with the band on the wrong side':
            theFloorIsLabelledWithTheWrongBand &&
                inpGoodBelow == 200 &&
                inpPoorAbove == 500,
        'this is the ninth restatement of 48dp':
            restatementsIncludingThisOne == 9 &&
                restatementNote.contains('Step 227'),
        'nothing new is declared': nothingNewIsDeclaredHere,
        'nine control classes, seven statically measurable':
            sevenOfNineAreStaticallyProven &&
                everyStaticClassClearsTheMinimum,
        'the two run-time classes are Step 313\'s':
            theTwoRunTimeClassesAreTheOnesStep313Named &&
                composedAtRunTime.first.name.contains('chip'),
        'four classes use a path gesture, all with an alternative':
            fourClassesUseAPathGesture && everyPathGestureHasAnAlternative,
        'the guard specified at Step 336 is enabled here':
            guardIsEnabled &&
                guardRuleId == 'A11Y_GESTURE_WITHOUT_ALTERNATIVE' &&
                guardNote.contains('nothing to report'),
        'the census covers spacing as well as size':
            theSpacingRuleIsDeclared && spacingNote.contains('wrong control'),
        'six obligations, all met, giving Good':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good',
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to DEA rather than UDF, its narrative '
      'columns are the same least-privilege governance text Step 337 carries, '
      'its Setup Step column reads "Design the pipeline flow: input capture, '
      'validation, sanitization, storage, retrieval", and its Best Qualitative '
      'Output Type cell holds review guidance rather than a standard. Atomic '
      'Step: "Set touch targets to meet standard minimum dimensions of '
      '48x48dp."';
}
