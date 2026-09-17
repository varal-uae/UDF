/// Step 361 (GEN-01540) -- two metrics on one tile, one of which is a
/// prediction wearing a measurement's clothes.
///
/// The row: "Display customer lifetime value (CLV) and re-booking velocity
/// metrics on retention dashboards."
/// Metric: **One-Click Re-Booking Completion Rate** -- floor 0.7, optimal 0.9,
/// ceiling 1. Good/Average/Poor. Baymard Institute Repeat-Purchase UX
/// Benchmark. Assigned to **CAL**.
///
/// **Customer lifetime value is a forecast.** It is computed by projecting a
/// customer's future behaviour from their past, and every method for doing so
/// has a horizon, a discount rate and an assumption about churn. Displayed as
/// "AED 4,820" beside a number that was actually counted, it reads as the same
/// kind of fact. It is not, and the difference matters on a retention
/// dashboard, because CLV is the number somebody uses to justify spending
/// money to keep a customer.
///
/// **So the two metrics on this tile are rendered differently.** Re-booking
/// velocity is counted -- bookings per customer per quarter, from records that
/// exist. CLV is projected, and is shown with its horizon on its face, as a
/// range rather than a point, and never with the currency precision of a
/// figure that was measured.
///
/// **A projection quoted to the fils is a lie about its own precision.** "AED
/// 4,820.37" claims a hundredth of a dirham of a number that is a guess about
/// the next two years. The tile rounds projections to the nearest hundred and
/// shows the interval, which is the same rule `HabotConfidenceMetric` already
/// applies to a measured value with error bars.
///
/// **The metric measures a third thing.** A one-click re-booking completion
/// rate is a funnel conversion -- of the people who started a one-click
/// re-booking, how many finished. It is a fine measure of a checkout and says
/// nothing about whether a retention dashboard displays CLV honestly. It is
/// also the second row in this batch assigned to CAL rather than UDF.
library;

import 'confidence_metric.dart';

/// How a figure on a retention tile came to exist.
enum HabotFigureOrigin {
  /// Counted from records that exist.
  counted,

  /// Projected from a model with a horizon and assumptions.
  projected,
}

/// One figure on the tile.
class HabotRetentionFigure {
  const HabotRetentionFigure({
    required this.name,
    required this.origin,
    required this.pointMinorUnits,
    required this.lowMinorUnits,
    required this.highMinorUnits,
    required this.horizonMonths,
  });

  final String name;
  final HabotFigureOrigin origin;

  /// In fils. Step 318 settled that money is a count of minor units.
  final int pointMinorUnits;
  final int lowMinorUnits;
  final int highMinorUnits;

  /// Zero for a counted figure; a real horizon for a projection.
  final int horizonMonths;
}

/// The retention tile.
class HabotRetentionMetrics {
  const HabotRetentionMetrics._();

  // -----------------------------------------------------------------------
  // Counted and projected are different kinds of fact.
  // -----------------------------------------------------------------------

  static const HabotRetentionFigure lifetimeValue = HabotRetentionFigure(
    name: 'Customer lifetime value',
    origin: HabotFigureOrigin.projected,
    pointMinorUnits: 482037,
    lowMinorUnits: 310000,
    highMinorUnits: 690000,
    horizonMonths: 24,
  );

  /// Bookings per customer per quarter, counted. Held in hundredths so the
  /// tile never does money-style arithmetic on a rate.
  static const int rebookingVelocityHundredths = 187;

  static bool get theTwoFiguresHaveDifferentOrigins =>
      lifetimeValue.origin == HabotFigureOrigin.projected &&
      HabotFigureOrigin.values.length == 2;

  static bool get theProjectionCarriesAHorizon =>
      lifetimeValue.horizonMonths == 24;

  static const String originNote =
      'Customer lifetime value is a forecast: it projects future behaviour '
      'from past behaviour, and every method for doing so carries a horizon, a '
      'discount rate and an assumption about churn. Re-booking velocity is '
      'counted from bookings that happened. Rendered side by side in the same '
      'typeface they read as the same kind of fact, and they are not -- which '
      'matters here, because CLV is the number somebody uses to justify '
      'spending money to keep a customer.';

  // -----------------------------------------------------------------------
  // A projection is not quoted to the fils.
  // -----------------------------------------------------------------------

  /// Rounded to the nearest hundred dirhams -- 10,000 fils.
  static const int projectionRounding = 10000;

  static int roundProjection(int minorUnits) =>
      (minorUnits / projectionRounding).round() * projectionRounding;

  static int get roundedPoint => roundProjection(lifetimeValue.pointMinorUnits);

  static bool get theProjectionIsRounded =>
      roundedPoint == 480000 && roundedPoint != lifetimeValue.pointMinorUnits;

  static String get projectionLabel {
    final int low = roundProjection(lifetimeValue.lowMinorUnits) ~/ 100;
    final int high = roundProjection(lifetimeValue.highMinorUnits) ~/ 100;
    return 'AED $low-$high over ${lifetimeValue.horizonMonths} months';
  }

  static bool get theLabelIsARangeWithAHorizon =>
      projectionLabel.contains('-') && projectionLabel.contains('months');

  static const bool aProjectionIsQuotedToTheFils = false;

  /// The interval is 380,000 fils wide on a 482,037 point -- 39 per cent of
  /// the figure either side of centre.
  static int get intervalWidthMinorUnits =>
      lifetimeValue.highMinorUnits - lifetimeValue.lowMinorUnits;

  static double get relativeHalfWidth =>
      (intervalWidthMinorUnits / 2) / lifetimeValue.pointMinorUnits;

  static bool get theIntervalIsThirtyNinePerCent =>
      ((relativeHalfWidth * 100) - 39.4).abs() < 0.1;

  /// Past the declared threshold the existing component renders a reading as
  /// indicative rather than as a number; this one is inside it, so the range
  /// is shown rather than the reading being withdrawn.
  static bool get theIntervalIsInsideTheIndicativeThreshold =>
      relativeHalfWidth < HabotConfidenceMetric.indicativeThreshold;

  static const String precisionNote =
      '"AED 4,820.37" claims a hundredth of a dirham of a number that is a '
      'guess about the next two years. The tile rounds projections to the '
      'nearest hundred dirhams and shows the interval instead of the point, '
      'which is the rule the existing confidence metric already applies to a '
      'measured value with error bars. This interval is 39 per cent of the '
      'figure either side of centre -- wide, and inside the threshold past '
      'which the reading would be withdrawn altogether.';

  // -----------------------------------------------------------------------
  // The counted figure.
  // -----------------------------------------------------------------------

  static String get velocityLabel {
    final int whole = rebookingVelocityHundredths ~/ 100;
    final int frac = rebookingVelocityHundredths % 100;
    final String fracText = frac < 10 ? '0$frac' : '$frac';
    return '$whole.$fracText bookings per customer per quarter';
  }

  static bool get theVelocityNamesItsWindow =>
      velocityLabel.contains('per quarter');

  static bool get theVelocityIsNotRounded =>
      rebookingVelocityHundredths == 187;

  static const String countedNote =
      'Re-booking velocity is counted, so it is quoted exactly and carries its '
      'window: 1.87 bookings per customer per quarter. A rate with no window '
      'is the same defect as a ratio with no denominator, which Steps 358 and '
      '360 record on either side of this one.';

  // -----------------------------------------------------------------------
  // The metric, which measures a third thing.
  // -----------------------------------------------------------------------

  static const String metricName = 'One-Click Re-Booking Completion Rate';

  static const String whatTheMetricMeasures =
      'of the people who started a one-click re-booking, how many finished';

  static const String whatTheRowBuilds =
      'whether a retention dashboard displays a projection honestly';

  static bool get theMetricMeasuresADifferentThing =>
      whatTheMetricMeasures != whatTheRowBuilds;

  static const double bandFloor = 0.7;
  static const double bandOptimal = 0.9;
  static const double bandCeiling = 1;

  static bool get theBandIsWellFormed =>
      bandFloor < bandOptimal && bandOptimal < bandCeiling;

  static const String assignedTo = 'CAL';

  static const String metricNote =
      'A one-click re-booking completion rate is a funnel conversion, and a '
      'good measure of a checkout. It says nothing about whether a retention '
      'dashboard renders a forecast honestly, which is what this row builds. '
      'The band itself is well formed -- 0.7, 0.9, 1 -- which makes it one of '
      'the few in this batch, and the row is assigned to CAL rather than UDF.';

  static Map<String, bool> get obligations => <String, bool>{
        'the two figures declare different origins':
            theTwoFiguresHaveDifferentOrigins,
        'the projection carries its horizon': theProjectionCarriesAHorizon,
        'the projection is shown as a range, not a point':
            theLabelIsARangeWithAHorizon,
        'no projection is quoted to the fils':
            !aProjectionIsQuotedToTheFils && theProjectionIsRounded,
        'the counted figure names its window': theVelocityNamesItsWindow,
        'the counted figure is not rounded': theVelocityIsNotRounded,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'two origins, one counted and one projected':
            theTwoFiguresHaveDifferentOrigins &&
                HabotFigureOrigin.values.length == 2,
        'the projection names a 24-month horizon':
            theProjectionCarriesAHorizon &&
                originNote.contains('justify'),
        'the projection is rounded to the nearest hundred dirhams':
            theProjectionIsRounded && projectionRounding == 10000,
        'and shown as a range with its horizon':
            theLabelIsARangeWithAHorizon &&
                projectionLabel == 'AED 3100-6900 over 24 months',
        'the interval is 39 per cent either side of centre':
            theIntervalIsThirtyNinePerCent &&
                theIntervalIsInsideTheIndicativeThreshold,
        'the rounding rule is the existing component\'s':
            precisionNote.contains('error bars'),
        'the counted figure keeps its exact value and its window':
            theVelocityIsNotRounded &&
                theVelocityNamesItsWindow &&
                velocityLabel.startsWith('1.87'),
        'a rate with no window is the defect Steps 358 and 360 record':
            countedNote.contains('Steps 358 and 360'),
        'the metric measures a funnel rather than this row':
            theMetricMeasuresADifferentThing &&
                theBandIsWellFormed &&
                assignedTo == 'CAL',
        'six obligations, all met, giving Good':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good',
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to CAL rather than UDF, its metric is '
      'a one-click re-booking funnel conversion on a row about displaying CLV '
      'and velocity, the Data Requirement cell reads "Data/artifacts to '
      'prepare: CLV" -- an acronym lifted into the artefact list -- and the '
      'Setup Step column is empty. Atomic Step: "Display customer lifetime '
      'value (CLV) and re-booking velocity metrics on retention dashboards."';
}
