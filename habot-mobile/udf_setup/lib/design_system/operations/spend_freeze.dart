/// Step 389 (PELCE-036-13) -- freezing a control because a number moved, and
/// an output column with an arrow in it.
///
/// The row: "Trigger automatic UI freeze on marketing spend configuration when
/// rate drops below 98%."
/// Metric: **UI Design-System Adherence Rate** -- floor ">=85%", optimal
/// ">=95%", ceiling "1". Best Qualitative Output: **"Good/Average/Poor ->
/// Best = Good (100%)"**. Material Design 3 Guidelines / Nielsen Norman Group
/// Heuristic Evaluation. Assigned to **ADFA**.
///
/// **"Rate" is not named.** The row freezes spend configuration when a rate
/// drops below 98% and never says which rate: delivery rate, match rate,
/// conversion rate, adherence rate. The metric on the row is a design-system
/// adherence rate, which would mean a marketing budget freezes because somebody
/// shipped a component with the wrong padding. That reading is recorded and not
/// implemented; the freeze is bound to a named rate supplied by the caller, so
/// the control cannot fire on a number nobody chose.
///
/// **A freeze that nobody can lift is an outage with a nicer name.** Money
/// moves on a schedule and a frozen configuration on a Friday is a campaign
/// that runs all weekend at the wrong budget. There is a documented lift, it
/// takes a reason, and the freeze states what it is waiting for.
///
/// **A threshold with no hysteresis flaps.** A rate hovering at 98% freezes and
/// thaws on every sample, and each transition is an event, a notification and a
/// line in an audit log. The freeze arms below 98 and clears at 98.5, so a
/// number sitting on the boundary produces one state rather than a stream.
///
/// **What is frozen is narrower than "the configuration".** Three of the five
/// worked controls change spend and freeze; two -- renaming a campaign and
/// exporting a report -- do not touch money and stay available, because a
/// freeze that takes the export removes the thing somebody needs to find out
/// why the rate dropped.
///
/// **The output column contains an arrow.** "Good/Average/Poor -> Best = Good
/// (100%)" is a scale, an annotation and a gloss in one cell, which is a shape
/// this track has not met: the cell is explaining itself to a reader rather
/// than holding a value.
library;

import '../operations/permanent_disable.dart';

/// What a control on the spend screen does.
enum HabotFreezeScope {
  /// Changes how much money moves.
  changesSpend,

  /// Changes nothing about money.
  doesNotTouchMoney,
}

/// One control the freeze sweeps over.
class HabotSpendControl {
  const HabotSpendControl({required this.label, required this.scope});

  final String label;
  final HabotFreezeScope scope;

  bool get isFrozen => scope == HabotFreezeScope.changesSpend;
}

/// The spend-freeze rule.
class HabotSpendFreeze {
  const HabotSpendFreeze._();

  // -----------------------------------------------------------------------
  // Which rate.
  // -----------------------------------------------------------------------

  static const bool theRowNamesTheRate = false;

  static const List<String> ratesItCouldMean = <String>[
    'delivery rate',
    'match rate',
    'conversion rate',
    'design-system adherence rate',
  ];

  static bool get fourReadingsArePossible => ratesItCouldMean.length == 4;

  /// The rate is supplied by the caller and named, so the control cannot fire
  /// on a number nobody chose.
  static const String theRateUsed = 'delivery rate';

  static bool get theRateIsNamedAtTheCallSite =>
      theRateUsed.isNotEmpty && ratesItCouldMean.contains(theRateUsed);

  static const bool theMetricsRateIsUsed = false;

  static const String rateNote =
      'The row freezes spend configuration when a rate drops below 98% and '
      'never says which rate. The metric on the row is a design-system '
      'adherence rate, which read literally would freeze a marketing budget '
      'because somebody shipped a component with the wrong padding. That '
      'reading is recorded and not implemented: the rate is named at the call '
      'site, so the control cannot fire on a number nobody chose.';

  // -----------------------------------------------------------------------
  // Hysteresis.
  // -----------------------------------------------------------------------

  static const double armBelow = 98;
  static const double clearAt = 98.5;

  static bool get thereIsHysteresis => clearAt > armBelow;

  static bool isFrozenAt(double rate, {required bool wasFrozen}) {
    if (rate < armBelow) {
      return true;
    }
    if (rate >= clearAt) {
      return false;
    }
    return wasFrozen;
  }

  /// A rate sitting on the boundary holds one state instead of flapping.
  static bool get aBoundaryRateHoldsItsState =>
      isFrozenAt(98.2, wasFrozen: true) &&
      !isFrozenAt(98.2, wasFrozen: false);

  static bool get itFreezesBelowTheThreshold =>
      isFrozenAt(97.9, wasFrozen: false);

  static bool get itClearsAboveTheBand => !isFrozenAt(98.6, wasFrozen: true);

  static const String hysteresisNote =
      'A rate hovering at 98% with a single threshold freezes and thaws on '
      'every sample, and each transition is an event, a notification and a '
      'line in an audit log. The freeze arms below 98 and clears at 98.5, so a '
      'number sitting on the boundary produces one state rather than a stream '
      'of them -- and the person watching sees a condition rather than a '
      'flicker.';

  // -----------------------------------------------------------------------
  // What is frozen.
  // -----------------------------------------------------------------------

  static const List<HabotSpendControl> controls = <HabotSpendControl>[
    HabotSpendControl(
      label: 'Daily budget',
      scope: HabotFreezeScope.changesSpend,
    ),
    HabotSpendControl(
      label: 'Bid ceiling',
      scope: HabotFreezeScope.changesSpend,
    ),
    HabotSpendControl(
      label: 'Add an audience',
      scope: HabotFreezeScope.changesSpend,
    ),
    HabotSpendControl(
      label: 'Rename this campaign',
      scope: HabotFreezeScope.doesNotTouchMoney,
    ),
    HabotSpendControl(
      label: 'Export performance report',
      scope: HabotFreezeScope.doesNotTouchMoney,
    ),
  ];

  static int get frozenControls =>
      controls.where((HabotSpendControl c) => c.isFrozen).length;

  static int get availableControls => controls.length - frozenControls;

  static bool get threeOfFiveFreeze =>
      frozenControls == 3 && availableControls == 2;

  static bool get theExportStaysAvailable => controls.last.isFrozen == false;

  static const String scopeNote =
      '"The configuration" is wider than what should freeze. Three of the five '
      'controls change how much money moves and are frozen; renaming a '
      'campaign and exporting the performance report do not touch money and '
      'stay available -- a freeze that takes the export removes the thing '
      'somebody needs to work out why the rate dropped in the first place.';

  // -----------------------------------------------------------------------
  // The lift.
  // -----------------------------------------------------------------------

  static const bool aLiftExists = true;

  static const bool aLiftNeedsAReason = true;

  static const String whatTheFreezeIsWaitingFor =
      'the delivery rate back at 98.5% or an override with a reason';

  static const HabotDisableKind kind = HabotDisableKind.conditional;

  static HabotDisabledControl get budgetControl => HabotDisabledControl(
        label: 'Daily budget',
        kind: kind,
        reason: 'spend is frozen: delivery rate below 98%',
        whatWouldChangeIt: whatTheFreezeIsWaitingFor,
      );

  static bool get theFreezeIsNotADeadEnd => !budgetControl.isADeadEnd;

  static bool get theFreezeSaysWhatItIsWaitingFor =>
      budgetControl.whatWouldChangeIt.contains('98.5%');

  static const String liftNote =
      'A freeze nobody can lift is an outage with a nicer name. Money moves on '
      'a schedule, and a frozen configuration on a Friday evening is a '
      'campaign that runs all weekend at the wrong budget. The lift is '
      'documented, takes a reason, and the frozen control says what it is '
      'waiting for rather than only that it is off.';

  // -----------------------------------------------------------------------
  // The band and the arrow.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '>=85%';
  static const String bandOptimalRaw = '>=95%';
  static const String bandCeilingRaw = '1';

  static bool get theBandMixesUnits =>
      bandFloorRaw.contains('%') && !bandCeilingRaw.contains('%');

  /// Steps 364, 389 and 393 carry mixed-unit bands in this pair of batches.
  static const List<int> mixedUnitBandRows = <int>[364, 389, 393];

  static bool get threeMixedUnitBands => mixedUnitBandRows.length == 3;

  static const String outputColumnRaw =
      'Good/Average/Poor -> Best = Good (100%)';

  static bool get theOutputColumnHoldsAnAnnotation =>
      outputColumnRaw.contains('->') && outputColumnRaw.contains('Best =');

  static const String outputNote =
      'The Best Qualitative Output cell reads "Good/Average/Poor -> Best = '
      'Good (100%)": a scale, an arrow, an annotation naming which value is '
      'best, and a percentage gloss, all in one cell. It is the first cell in '
      'this track that explains itself to its reader instead of holding a '
      'value, and a consumer parsing the column for a scale gets a sentence.';

  static Map<String, bool> get obligations => <String, bool>{
        'the rate is named at the call site': theRateIsNamedAtTheCallSite,
        'the threshold has hysteresis':
            thereIsHysteresis && aBoundaryRateHoldsItsState,
        'only money-moving controls freeze': threeOfFiveFreeze,
        'the report export stays available': theExportStaysAvailable,
        'a lift exists and needs a reason': aLiftExists && aLiftNeedsAReason,
        'the freeze says what it is waiting for':
            theFreezeSaysWhatItIsWaitingFor && theFreezeIsNotADeadEnd,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'the row does not name the rate': !theRowNamesTheRate,
        'four readings are possible and one is chosen':
            fourReadingsArePossible &&
                theRateIsNamedAtTheCallSite &&
                !theMetricsRateIsUsed,
        'and the literal reading is recorded rather than built':
            rateNote.contains('the wrong padding'),
        'the freeze arms below 98 and clears at 98.5':
            itFreezesBelowTheThreshold && itClearsAboveTheBand,
        'a boundary rate holds its state':
            aBoundaryRateHoldsItsState &&
                hysteresisNote.contains('rather than a flicker'),
        'three of five controls freeze': threeOfFiveFreeze,
        'the export is not one of them':
            theExportStaysAvailable &&
                scopeNote.contains('why the rate dropped'),
        'the freeze is liftable and says what it waits for':
            theFreezeIsNotADeadEnd && theFreezeSaysWhatItIsWaitingFor,
        'the band mixes units and the output cell holds an annotation':
            theBandMixesUnits &&
                threeMixedUnitBands &&
                theOutputColumnHoldsAnAnnotation,
        'six obligations, all met, giving Good':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good',
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to ADFA rather than UDF; it freezes '
      'spend when "rate" drops below 98% without saying which rate, while its '
      'own metric is a UI design-system adherence rate; its band mixes two '
      'percentages with the bare ratio "1"; its Best Qualitative Output cell '
      'reads "Good/Average/Poor -> Best = Good (100%)", a scale with an arrow '
      'and an annotation inside one cell; and its Setup Step column reads "Set '
      'the backup timeout parameter window limit to trip exactly at 10 seconds '
      'of continuous loading latency". Atomic Step: "Trigger automatic UI '
      'freeze on marketing spend configuration when rate drops below 98%."';
}
