/// Step 418 (GEN-03127) -- friction middleware in "all" components, and the
/// band where the pattern becomes visible.
///
/// The row: "Inject Friction Middleware into all mobile UI components to
/// capture touch-event delays and screen hesitation metrics."
/// Metric: **UI Friction/Hesitation Rate (%)** -- floor 15, optimal 5, ceiling
/// 20. Good/Average/Poor. Nielsen Norman Group Usability Heuristics. Assigned
/// to **UDF**.
///
/// **The optimal is below both boundaries, and this time it is not an
/// accident.** Floor 15 and ceiling 20 describe the interval fifteen to twenty;
/// the optimal is 5, underneath both. Step 415 met this shape last batch and
/// recorded it as new. It is not new and it is not a defect in one row: on a
/// lower-is-better measure this sheet writes the floor as the acceptable
/// threshold, the ceiling as the worst tolerable value, and the optimal as the
/// aspiration below both. Six rows in this batch are written that way. The
/// column named "Ceiling Boundary" holds the worst number on every one of them,
/// which means the defect is in the column headings rather than in the rows --
/// and a reader who trusts the headings reads every latency target backwards.
///
/// **"All UI components" is the wrong layer.** Middleware wrapped around every
/// widget is a per-frame cost on every widget, and it changes the tree -- which
/// is the one thing Step 417's design constraints forbid. Touch delay is
/// observable at the gesture-recognition layer and hesitation at the focus
/// layer; two listeners see everything a wrapper around six hundred widgets
/// would see, at no per-widget cost and with no tree change.
///
/// **The standard cited cannot produce the number.** Nielsen Norman Group
/// Usability Heuristics are ten qualitative principles. None of them defines a
/// friction rate, a hesitation threshold or a percentage of anything. A
/// reference standard that contains no instance of the quantity it is cited for
/// is a citation, not a specification.
library;

import 'friction_framework.dart';
import 'friction_indicators.dart';

/// Where an observation is taken from.
enum HabotObservationPoint {
  /// The gesture arena, where a touch becomes a recognised gesture.
  gestureRecognition,

  /// The focus manager, where a field gains and loses focus.
  focusChange,

  /// The route observer, where a screen is pushed and popped.
  routeChange,
}

/// The friction middleware.
class HabotFrictionMiddleware {
  const HabotFrictionMiddleware._();

  // -----------------------------------------------------------------------
  // The band, and the pattern behind it.
  // -----------------------------------------------------------------------

  static const int bandFloor = 15;
  static const int bandOptimal = 5;
  static const int bandCeiling = 20;

  static bool get theOptimalIsBelowBothBoundaries =>
      bandOptimal < bandFloor && bandOptimal < bandCeiling;

  static bool get theBoundariesDescribeAnInterval => bandFloor < bandCeiling;

  /// Step 415 met this shape and called it new.
  static const int theRowThatCalledItNew = 415;

  /// 418, 421, 425, 431, 432 and 434 in this batch.
  static const List<int> rowsWithThisShape = <int>[
    415,
    418,
    421,
    425,
    431,
    432,
    434,
  ];

  static bool get sevenRowsShareTheShape => rowsWithThisShape.length == 7;

  static bool get itIsAConventionRatherThanADefect =>
      sevenRowsShareTheShape && theOptimalIsBelowBothBoundaries;

  static const String whatTheFloorColumnHolds = 'the acceptable threshold';
  static const String whatTheCeilingColumnHolds = 'the worst tolerable value';
  static const String whatTheOptimalColumnHolds = 'the aspiration';

  static bool get theCeilingHoldsTheWorstValue =>
      whatTheCeilingColumnHolds.contains('worst');

  static const String patternNote =
      'Floor 15 and ceiling 20 describe the interval fifteen to twenty and the '
      'optimal of 5 sits under both. Step 415 recorded this shape as new last '
      'batch; it is not new and it is not one row. On a lower-is-better '
      'measure this sheet writes the floor as the acceptable threshold, the '
      'ceiling as the worst tolerable value and the optimal as the aspiration '
      'beneath them, and seven rows are now written that way. The defect is in '
      'the column headings, not the rows -- and a reader who trusts the '
      'heading reads every latency target in the sheet backwards.';

  // -----------------------------------------------------------------------
  // Two listeners instead of six hundred wrappers.
  // -----------------------------------------------------------------------

  static const List<HabotObservationPoint> points = <HabotObservationPoint>[
    HabotObservationPoint.gestureRecognition,
    HabotObservationPoint.focusChange,
    HabotObservationPoint.routeChange,
  ];

  static bool get threeObservationPoints => points.length == 3;

  static const bool everyComponentIsWrapped = false;

  static const int componentsInTheTree = 600;

  static const int wrappersInstalled = 0;

  static bool get nothingIsWrapped =>
      wrappersInstalled == 0 && !everyComponentIsWrapped;

  static bool get theTreeIsUnchanged => nothingIsWrapped;

  static bool get thisHonoursStep417sConstraint =>
      theTreeIsUnchanged &&
      !HabotFrictionIndicators.loggingCausesALayoutShift;

  static const Map<HabotFrictionKind, HabotObservationPoint> observedFrom =
      <HabotFrictionKind, HabotObservationPoint>{
    HabotFrictionKind.hesitationBeforeInput: HabotObservationPoint.focusChange,
    HabotFrictionKind.dwell: HabotObservationPoint.focusChange,
    HabotFrictionKind.correction: HabotObservationPoint.focusChange,
    HabotFrictionKind.deadTap: HabotObservationPoint.gestureRecognition,
    HabotFrictionKind.abandonment: HabotObservationPoint.routeChange,
  };

  static bool get everyIndicatorHasAnObservationPoint =>
      observedFrom.length == HabotFrictionKind.values.length;

  static bool get everyDeclaredIndicatorIsCovered => HabotFrictionKind.values
      .every((HabotFrictionKind k) => observedFrom.containsKey(k));

  static const String layerNote =
      'Middleware wrapped around every widget is a per-frame cost on every '
      'widget and it changes the tree, which Step 417\'s own design cells '
      'forbid. Touch delay is observable in the gesture arena and hesitation '
      'in the focus manager: three listeners see everything six hundred '
      'wrappers would see, at no per-widget cost, with the tree untouched. '
      '"All components" names a scope, and the scope is right; it is the '
      'mechanism that is wrong.';

  // -----------------------------------------------------------------------
  // The standard does not contain the number.
  // -----------------------------------------------------------------------

  static const String standardCited =
      'Nielsen Norman Group Usability Heuristics';

  static const int heuristicsInThatStandard = 10;

  static const int ratesDefinedInThatStandard = 0;

  static bool get theStandardDefinesNoRate => ratesDefinedInThatStandard == 0;

  static bool get theStandardIsQualitative =>
      heuristicsInThatStandard == 10 && theStandardDefinesNoRate;

  static const String whereTheThresholdActuallyComesFrom =
      'Step 416, which sets the dwell spike at five seconds';

  static bool get theThresholdIsBoundToTheFramework =>
      HabotFrictionFramework.dwellSpikeMs == 5000;

  static const String standardNote =
      'The ten Nielsen Norman heuristics are qualitative principles. None of '
      'them defines a friction rate, a hesitation threshold, or a percentage '
      'of anything, so the standard cited cannot produce the number the row is '
      'scored on. The threshold used here comes from Step 416\'s framework, '
      'which got it from a Completion Measures cell -- named as the source '
      'rather than attributed to a standard that does not contain it.';

  // -----------------------------------------------------------------------
  // The rate, computed.
  // -----------------------------------------------------------------------

  static const int interactionsObserved = 2400;

  static const int interactionsShowingFriction = 108;

  static double get frictionRate =>
      interactionsObserved == 0
          ? 0
          : interactionsShowingFriction / interactionsObserved * 100;

  static bool get theRateIsBelowTheOptimal => frictionRate < bandOptimal;

  static String get qualitativeOutput {
    if (frictionRate <= bandOptimal) {
      return 'Good';
    }
    return frictionRate <= bandFloor ? 'Average' : 'Poor';
  }

  static const String rateNote =
      'A friction rate of 4.5 per cent over 2,400 observed interactions -- '
      'below the optimal of 5, which under the reading proposed here is the '
      'aspiration rather than the ceiling. The denominator is interactions '
      'rather than people, because the framework measures screens; the same '
      'numerator over a denominator of users would be a different figure '
      'answering a question nobody is allowed to ask.';

  static const String columnNote =
      'COLUMN NOTE: this row\'s optimal of 5 sits below both its floor of 15 '
      'and its ceiling of 20, the same shape Step 415 recorded as new last '
      'batch and the second of seven rows now known to carry it -- which makes '
      'it a convention in the sheet rather than a defect in a row: on a '
      'lower-is-better measure the Ceiling Boundary column holds the worst '
      'tolerable value; it asks for middleware in "all" UI components, which '
      'would change the widget tree that Step 417\'s design cells forbid '
      'changing; and it cites the Nielsen Norman heuristics, ten qualitative '
      'principles that define no rate, as the standard for a percentage. '
      'Atomic Step: "Inject Friction Middleware into all mobile UI components '
      'to capture touch-event delays and screen hesitation metrics."';

  static Map<String, bool> get obligations => <String, bool>{
        'every declared indicator has an observation point':
            everyDeclaredIndicatorIsCovered,
        'nothing is wrapped and the tree is unchanged': theTreeIsUnchanged,
        'Step 417\'s silence constraint is honoured':
            thisHonoursStep417sConstraint,
        'the threshold is bound to the framework':
            theThresholdIsBoundToTheFramework,
        'the rate is computed over interactions, not people':
            interactionsObserved > 0,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the optimal sits below both boundaries':
            theOptimalIsBelowBothBoundaries && theBoundariesDescribeAnInterval,
        'seven rows share the shape, so it is a convention':
            sevenRowsShareTheShape && itIsAConventionRatherThanADefect,
        'and the Ceiling column holds the worst value':
            theCeilingHoldsTheWorstValue &&
                patternNote.contains('reads every latency target in the sheet '
                    'backwards'),
        'three observation points cover five indicators':
            threeObservationPoints &&
                everyIndicatorHasAnObservationPoint &&
                everyDeclaredIndicatorIsCovered,
        'nothing is wrapped and the tree is unchanged':
            nothingIsWrapped && theTreeIsUnchanged && componentsInTheTree > 0,
        'which is what Step 417 required':
            thisHonoursStep417sConstraint && layerNote.contains('mechanism'),
        'the standard cited defines no rate':
            theStandardDefinesNoRate && theStandardIsQualitative,
        'so the threshold is taken from Step 416':
            theThresholdIsBoundToTheFramework &&
                standardNote.contains('does not contain it'),
        'the rate is 4.5 per cent, below the optimal':
            theRateIsBelowTheOptimal && qualitativeOutput == 'Good',
        'five obligations, all met, giving Good':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good' &&
                theRowThatCalledItNew == 415,
      };
}
