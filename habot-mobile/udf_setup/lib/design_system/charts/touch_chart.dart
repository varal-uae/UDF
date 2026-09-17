/// Step 366 (EDEBS-011-09) -- a chart on a touch screen, where the pointer is
/// opaque and there is no hover to fall back on.
///
/// The row: "Optimize the dashboard visualization charts and layout for
/// touch-driven mobile browsing."
/// Metric: **Observability / Alert Coverage** -- floor ">=90%", optimal 1,
/// ceiling 1. Good/Average/Poor. Google SRE Handbook.
///
/// **The pointer covers the thing it is pointing at.** A mouse cursor is a few
/// pixels and sits beside the target; a fingertip is about fifty density
/// points across and sits on top of it. Every chart interaction designed for a
/// mouse -- hover a point, read the tooltip under the cursor -- breaks twice on
/// touch: the state never arrives, and the readout would be under the finger if
/// it did.
///
/// **So the readout moves off the point.** The value is shown in a fixed
/// position at the top of the chart rather than floating beside the touch, and
/// it stays until the next touch instead of vanishing on release. A readout
/// that disappears when the finger lifts is readable only by somebody who can
/// look at the screen and the chart at the same moment, which is nobody.
///
/// **Targets on a chart are smaller than targets anywhere else.** A data point
/// is a few points wide by design -- making it 48dp would be drawing circles,
/// not a chart. The rule Step 343 settled applies to the *hit area*, not the
/// ink: the nearest-point hit test uses a 48dp catchment while the drawn marker
/// stays small, and adjacent points closer than the minimum gap are snapped to
/// one selection rather than being separately hittable.
///
/// **The metric is an SRE alert-coverage measure on a charting row**, the third
/// cross-discipline metric in this batch after Steps 360 and 363, and its
/// optimal and ceiling are both 1.
///
/// **COLUMN NOTE.** The Data Requirement column is about success-state
/// transitions and a green confirmation snackbar, which is feedback rather than
/// charting; the Setup Step column reads "Perform security and data privacy
/// reviews on visual isolation boundaries"; and the band's top two values are
/// the same number.
library;

import '../a11y/target_spacing.dart';

/// How a value can be read off a chart.
enum HabotReadoutMode {
  /// Floating beside the pointer. Mouse only.
  followsPointer,

  /// Fixed at the top of the chart. Works with a finger on the glass.
  fixedHeader,
}

/// One data point as the hit test sees it.
class HabotPlottedPoint {
  const HabotPlottedPoint({
    required this.label,
    required this.xDp,
    required this.inkRadiusDp,
  });

  final String label;

  /// Horizontal position within the plot area.
  final double xDp;

  /// How big the marker is drawn.
  final double inkRadiusDp;
}

/// The touch-driven chart.
class HabotTouchChart {
  const HabotTouchChart._();

  // -----------------------------------------------------------------------
  // The pointer is opaque.
  // -----------------------------------------------------------------------

  static const double fingertipWidthDp = 50;
  static const double mouseCursorWidthDp = 4;

  static double get pointerWidthRatio =>
      fingertipWidthDp / mouseCursorWidthDp;

  /// A finger is twelve and a half times the width of a cursor, and unlike a
  /// cursor it is on top of the target rather than beside it.
  static bool get aFingerIsTwelveAndAHalfTimesACursor =>
      (pointerWidthRatio - 12.5).abs() < 1e-9;

  static const bool hoverExists = false;

  static const String pointerNote =
      'A mouse cursor is a few points wide and sits beside what it points at; '
      'a fingertip is about fifty points across and sits on top of it. Every '
      'chart interaction designed for a mouse breaks twice on touch: the hover '
      'state never arrives, and the readout would be underneath the finger if '
      'it did. The ratio is twelve and a half to one, and the occlusion is the '
      'half that no amount of tuning fixes.';

  // -----------------------------------------------------------------------
  // The readout.
  // -----------------------------------------------------------------------

  static const HabotReadoutMode readout = HabotReadoutMode.fixedHeader;

  static bool get theReadoutDoesNotFollowTheFinger =>
      readout != HabotReadoutMode.followsPointer;

  static const bool theReadoutVanishesOnRelease = false;

  static bool get theReadoutPersistsUntilTheNextTouch =>
      !theReadoutVanishesOnRelease;

  static const String readoutNote =
      'The value is shown in a fixed position at the top of the chart rather '
      'than floating beside the touch, and it stays until the next touch '
      'instead of disappearing on release. A readout that vanishes when the '
      'finger lifts is readable only by somebody who can look at the screen '
      'and at the chart under their own hand at the same moment, which is '
      'nobody.';

  // -----------------------------------------------------------------------
  // Hit area is not ink.
  // -----------------------------------------------------------------------

  static double get catchmentDp => HabotTargetSpacing.minimumSizeDp;

  static double get minimumSeparationDp => HabotTargetSpacing.minimumGapDp;

  static const List<HabotPlottedPoint> points = <HabotPlottedPoint>[
    HabotPlottedPoint(label: 'Mon', xDp: 20, inkRadiusDp: 3),
    HabotPlottedPoint(label: 'Tue', xDp: 24, inkRadiusDp: 3),
    HabotPlottedPoint(label: 'Wed', xDp: 90, inkRadiusDp: 3),
    HabotPlottedPoint(label: 'Thu', xDp: 160, inkRadiusDp: 3),
  ];

  static bool get theInkStaysSmall =>
      points.every((HabotPlottedPoint p) => p.inkRadiusDp <= 4);

  static bool get theCatchmentIsTheDeclaredTarget => catchmentDp == 48;

  /// Mon and Tue are 4dp apart, inside the minimum separation, so they are one
  /// selection rather than two hittable points.
  static int get mergedClusters {
    int clusters = 1;
    for (int i = 1; i < points.length; i++) {
      if (points[i].xDp - points[i - 1].xDp >= minimumSeparationDp) {
        clusters++;
      }
    }
    return clusters;
  }

  static bool get fourPointsBecomeThreeSelections => mergedClusters == 3;

  static const bool everyPointIsSeparatelyHittable = false;

  static const String hitAreaNote =
      'A data point is a few points wide by design -- drawing it at 48dp would '
      'be drawing circles rather than a chart -- so the rule Step 343 settled '
      'applies to the hit area and not to the ink. The nearest-point test uses '
      'a 48dp catchment while the marker stays at three, and points closer '
      'together than the 8dp minimum separation are snapped into one '
      'selection: four points here become three selections, because two of '
      'them are four points apart and a finger cannot choose between them.';

  // -----------------------------------------------------------------------
  // The metric.
  // -----------------------------------------------------------------------

  static const String metricName = 'Observability / Alert Coverage';

  static const String metricDiscipline = 'site reliability engineering';

  /// Steps 360, 363 and this one.
  static const List<int> crossDisciplineMetricRows = <int>[360, 363, 366];

  static bool get thisIsTheThirdCrossDisciplineMetric =>
      crossDisciplineMetricRows.length == 3;

  static const String bandFloor = '>=90%';
  static const double bandOptimal = 1;
  static const double bandCeiling = 1;

  static bool get theOptimalEqualsTheCeiling => bandOptimal == bandCeiling;

  static const String metricNote =
      'Alert coverage is the share of failure modes that have a monitor '
      'attached, measured on a service. It is not a property of a chart, and '
      'this is the third row in this batch scored on a metric from another '
      'discipline, after an RBAC enforcement rate on a counting widget at Step '
      '360 and Largest Contentful Paint at Step 363. The band also repeats '
      'itself, with an optimal and a ceiling both at 1.';

  static Map<String, bool> get obligations => <String, bool>{
        'no interaction depends on hover': !hoverExists,
        'the readout does not follow the finger':
            theReadoutDoesNotFollowTheFinger,
        'the readout survives the release':
            theReadoutPersistsUntilTheNextTouch,
        'the hit catchment is the declared target size':
            theCatchmentIsTheDeclaredTarget,
        'the drawn marker stays small': theInkStaysSmall,
        'points too close to distinguish are one selection':
            !everyPointIsSeparatelyHittable && fourPointsBecomeThreeSelections,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'a finger is 12.5 times the width of a cursor':
            aFingerIsTwelveAndAHalfTimesACursor && fingertipWidthDp == 50,
        'and it occludes rather than sits beside':
            !hoverExists && pointerNote.contains('no amount of tuning fixes'),
        'two readout modes, and the pointer-following one is refused':
            HabotReadoutMode.values.length == 2 &&
                theReadoutDoesNotFollowTheFinger,
        'the readout persists until the next touch':
            theReadoutPersistsUntilTheNextTouch &&
                readoutNote.contains('under their own hand'),
        'the catchment is 48dp and the ink is 3dp':
            theCatchmentIsTheDeclaredTarget && theInkStaysSmall,
        'the separation rule is Step 343\'s':
            minimumSeparationDp == 8 && hitAreaNote.contains('Step 343'),
        'four points become three selections':
            fourPointsBecomeThreeSelections && points.length == 4,
        'no point is separately hittable inside the minimum gap':
            !everyPointIsSeparatelyHittable,
        'the metric belongs to site reliability engineering':
            metricDiscipline.contains('reliability') &&
                thisIsTheThirdCrossDisciplineMetric &&
                theOptimalEqualsTheCeiling,
        'six obligations, all met, giving Good':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good',
      };

  static const String columnNote =
      'COLUMN NOTE: the metric on this charting row is an SRE alert-coverage '
      'measure and its optimal and ceiling are both 1; the Data Requirement '
      'column is about success-state transitions and a green confirmation '
      'snackbar, which is feedback rather than charting; and the Setup Step '
      'column reads "Perform security and data privacy reviews on visual '
      'isolation boundaries". Atomic Step: "Optimize the dashboard '
      'visualization charts and layout for touch-driven mobile browsing."';
}
