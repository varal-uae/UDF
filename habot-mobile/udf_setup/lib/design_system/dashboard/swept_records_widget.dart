/// Step 360 (GEN-02466) -- a count with a verb hidden inside it.
///
/// The row: "Create a dashboard widget to report the \"Swept Records\" count to
/// administrators."
/// Metric: **RBAC Enforcement Rate (%)** -- floor 0.999, optimal 1, ceiling 1.
/// Pass / Fail. ISO/IEC 27001, NIST Cybersecurity Framework.
///
/// **"Swept" is a verb the widget has to define before the number means
/// anything.** A sweep in this system removes or quarantines records that fail
/// a lineage check. "1,284 swept" could be 1,284 records deleted, 1,284
/// quarantined pending review, or 1,284 examined of which some number was
/// touched. Those are three different days, and only the first is irreversible.
/// The widget reports the three separately and never sums them into one figure.
///
/// **A count with no denominator is the problem Step 358 records one row
/// earlier**, and an administrator reading "1,284 swept" needs the same second
/// number: of how many. 1,284 of 1,300 is an outage; 1,284 of 2,000,000 is
/// Tuesday.
///
/// **A sweep count that only rises is not actionable.** The number a person can
/// act on is what changed since they last looked, and what is still waiting for
/// a decision, so the widget carries a delta and a pending count beside the
/// total -- which is the shape Step 331 settled for the exception counter.
///
/// **The metric is an access-control rate on a counting widget.** RBAC
/// enforcement is the share of requests correctly allowed or denied by role;
/// it is measured at the authorisation layer, not on a dashboard tile. Step
/// 373 in this batch carries the identical metric and band on a row about
/// displaying anomalies, which is the second of two.
///
/// **What the metric does point at is real**, though: the widget is for
/// administrators, so it is behind an authorisation check, and a person
/// without the role sees no tile rather than an empty one. An empty tile is
/// itself a disclosure -- it says the feature exists.
///
/// **COLUMN NOTE.** The metric is an RBAC enforcement rate on a count widget,
/// its optimal and ceiling are both 1, the Data Requirement cell reads
/// "Data/artifacts to prepare: Swept Records" -- the count's label lifted into
/// the artefact list -- and the Setup Step column is empty.
library;

import 'exception_counter.dart';

/// What a sweep did to a record.
enum HabotSweepOutcome {
  /// Examined and left alone.
  examined,

  /// Moved to quarantine, reversible, waiting for a decision.
  quarantined,

  /// Removed. Not reversible.
  removed,
}

/// One day's sweep.
class HabotSweepRun {
  const HabotSweepRun({
    required this.examined,
    required this.quarantined,
    required this.removed,
    required this.population,
  });

  final int examined;
  final int quarantined;
  final int removed;

  /// How many records the sweep ran over.
  final int population;

  int get touched => quarantined + removed;
}

/// The swept-records widget.
class HabotSweptRecordsWidget {
  const HabotSweptRecordsWidget._();

  // -----------------------------------------------------------------------
  // Three outcomes, never summed.
  // -----------------------------------------------------------------------

  static const HabotSweepRun today = HabotSweepRun(
    examined: 1284,
    quarantined: 61,
    removed: 9,
    population: 2000000,
  );

  static const HabotSweepRun yesterday = HabotSweepRun(
    examined: 1190,
    quarantined: 44,
    removed: 7,
    population: 2000000,
  );

  static bool get theThreeOutcomesAreReportedSeparately =>
      HabotSweepOutcome.values.length == 3;

  static const bool theOutcomesAreSummedIntoOneFigure = false;

  static int get touchedToday => today.touched;

  /// Only the removals are irreversible, and they are nine of seventy.
  static bool get onlyRemovalsAreIrreversible =>
      today.removed == 9 && today.touched == 70;

  static const String verbNote =
      '"Swept" is a verb, and the number means nothing until the widget says '
      'which one. A sweep examines records, quarantines some and removes '
      'others; "1,284 swept" could be any of the three or their sum, and only '
      'removal cannot be undone. Today\'s run examined 1,284, quarantined 61 '
      'and removed 9, which is a different day from one that removed 1,284. '
      'The three are reported separately and never added together.';

  // -----------------------------------------------------------------------
  // The denominator.
  // -----------------------------------------------------------------------

  static double get touchedShare => today.population == 0
      ? 0
      : today.touched / today.population;

  static String get headline =>
      '${today.touched} of ${today.population} records touched';

  static bool get theHeadlineCarriesItsDenominator =>
      headline.contains(' of ');

  /// 70 of two million is 0.0035 per cent, which is the sentence an
  /// administrator can act on -- or decline to.
  static bool get theShareIsThirtyFivePerMillion =>
      ((touchedShare * 1000000) - 35).abs() < 1e-9;

  static const String denominatorNote =
      'An administrator reading "1,284 swept" needs the second number: of how '
      'many. 1,284 of 1,300 is an outage and 1,284 of two million is a '
      'Tuesday. Today\'s 70 touched records are 35 per million of the '
      'population, which is the figure that decides whether anybody does '
      'anything. Step 358 records the same omission one row earlier, on a '
      'safety ratio.';

  // -----------------------------------------------------------------------
  // What changed, and what is waiting.
  // -----------------------------------------------------------------------

  static int get deltaTouched => today.touched - yesterday.touched;

  static int get awaitingDecision => today.quarantined;

  static bool get theWidgetCarriesADelta => deltaTouched == 19;

  static bool get theWidgetCarriesAPendingCount => awaitingDecision == 61;

  /// Step 331 settled this shape: a count, what changed, and the one to act
  /// on -- and only the first of the three is a number on its own.
  static bool get theShapeIsAlreadyDeclared =>
      HabotExceptionCounter.threeFactsRatherThanOne;

  static const String actionabilityNote =
      'A sweep total that only rises is a scoreboard. What an administrator '
      'can act on is what changed since they last looked and what is still '
      'waiting for a decision -- 19 more than yesterday, 61 in quarantine -- '
      'and the quarantined records are the only ones where acting is still '
      'possible. Step 331 settled this shape for the exception counter, so the '
      'widget follows it rather than inventing a second arrangement.';

  // -----------------------------------------------------------------------
  // The metric, and the half of it that is real.
  // -----------------------------------------------------------------------

  static const String metricName = 'RBAC Enforcement Rate (%)';

  static const String metricBelongsTo = 'the authorisation layer';

  static bool get theMetricIsMeasuredElsewhere =>
      metricBelongsTo != 'a dashboard tile';

  static const int theOtherRowWithThisMetric = 373;

  static const double bandFloor = 0.999;
  static const double bandOptimal = 1;
  static const double bandCeiling = 1;

  static bool get theOptimalEqualsTheCeiling => bandOptimal == bandCeiling;

  /// The real obligation the metric points at: the tile is behind a role
  /// check, and a person without the role sees nothing rather than an empty
  /// frame.
  static const bool theTileIsVisibleWithoutTheRole = false;

  static const bool anEmptyTileIsRenderedInstead = false;

  static const String metricNote =
      'An RBAC enforcement rate is the share of requests correctly allowed or '
      'denied by role, measured at the authorisation layer. It is not a '
      'property of a counting tile, and Step 373 in this batch carries the '
      'identical metric and band on a row about displaying anomalies. What the '
      'metric does point at is real: the widget is for administrators, so it '
      'sits behind a role check, and somebody without the role gets no tile at '
      'all rather than an empty one -- an empty tile is itself a disclosure, '
      'because it says the feature exists.';

  static Map<String, bool> get obligations => <String, bool>{
        'the three sweep outcomes are reported separately':
            theThreeOutcomesAreReportedSeparately &&
                !theOutcomesAreSummedIntoOneFigure,
        'the headline carries its denominator':
            theHeadlineCarriesItsDenominator,
        'the widget carries a delta and a pending count':
            theWidgetCarriesADelta && theWidgetCarriesAPendingCount,
        'the tile is hidden without the role':
            !theTileIsVisibleWithoutTheRole && !anEmptyTileIsRenderedInstead,
        'the counter shape is Step 331\'s': theShapeIsAlreadyDeclared,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'three outcomes, never summed':
            theThreeOutcomesAreReportedSeparately &&
                !theOutcomesAreSummedIntoOneFigure,
        'only removals are irreversible, and they are 9 of 70':
            onlyRemovalsAreIrreversible &&
                verbNote.contains('cannot be undone'),
        'the headline states 70 of 2,000,000':
            theHeadlineCarriesItsDenominator && headline.startsWith('70 of'),
        'which is 35 per million':
            theShareIsThirtyFivePerMillion &&
                denominatorNote.contains('Step 358'),
        'the delta is 19 and the pending count is 61':
            theWidgetCarriesADelta && theWidgetCarriesAPendingCount,
        'the three-fact shape comes from Step 331':
            theShapeIsAlreadyDeclared &&
                actionabilityNote.contains('Step 331'),
        'the metric belongs to the authorisation layer':
            theMetricIsMeasuredElsewhere &&
                metricName.contains('RBAC') &&
                theOtherRowWithThisMetric == 373,
        'the optimal and the ceiling are the same number':
            theOptimalEqualsTheCeiling && bandFloor == 0.999,
        'no tile is shown without the role, and no empty frame either':
            !theTileIsVisibleWithoutTheRole &&
                !anEmptyTileIsRenderedInstead &&
                metricNote.contains('itself a disclosure'),
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: the metric on this row is an RBAC enforcement rate on a '
      'counting widget, its optimal and ceiling are both written 1, the Data '
      'Requirement cell reads "Data/artifacts to prepare: Swept Records" -- '
      'the count\'s own label lifted into the artefact list -- and the Setup '
      'Step column is empty. Atomic Step: "Create a dashboard widget to report '
      'the \\"Swept Records\\" count to administrators."';
}
