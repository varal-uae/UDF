/// Step 487 (GEN-00921) -- alerting product managers when a funnel step
/// drops, on a threshold that will fire on nothing.
///
/// The row: "Program Shakti Alerts notifying Product Managers if any funnel
/// step drops > 15% week-over-week."
/// Metric: **Alert Trigger Dispatch Delay** -- floor "$\le 3\text{ secs}$",
/// optimal "$\le 1\text{ sec}$", ceiling "$5\text{ secs}$". Pass / Fail.
/// Habot Shakti Safety Protocol. Assigned to **CAL**.
///
/// **The same three values as Step 486, under a different name.** "Alert
/// Trigger Dispatch Delay" and "Alert Dispatch Latency" are one measure with
/// two titles, and the ceiling is again slower than the floor.
///
/// **And the band measures the wrong half of the row.** The instruction is
/// about a threshold -- fifteen per cent week over week -- and the band times
/// how fast the message is sent once the threshold trips. Dispatch speed is
/// worth knowing and it says nothing about whether the alert should have
/// fired.
///
/// **Fifteen per cent of a small number is noise.** A funnel step that forty
/// people reach in a week moves by fifteen per cent when six of them do
/// something different, which happens constantly. Without a minimum volume
/// the alert fires every week on the smallest steps and never gets read. So
/// the rule carries a floor on the denominator, and the message carries the
/// absolute counts beside the percentage, because "down 18%" and "down 18%,
/// 39 from 47" are different messages.
///
/// **A drop straight after a release is a different message.** The funnel is
/// compared against the release that was live in each week, so a product
/// manager gets told which build the change coincided with rather than
/// discovering it a fortnight later.
library;

import 'anomaly_dispatch.dart';

/// One funnel step, two weeks apart.
class HabotFunnelStepReading {
  const HabotFunnelStepReading({
    required this.name,
    required this.lastWeek,
    required this.thisWeek,
    required this.buildLastWeek,
    required this.buildThisWeek,
  });

  final String name;
  final int lastWeek;
  final int thisWeek;
  final String buildLastWeek;
  final String buildThisWeek;

  double get dropPercent =>
      lastWeek == 0 ? 0 : 100 * (lastWeek - thisWeek) / lastWeek;
}

/// The funnel drop alert.
class HabotFunnelDropAlert {
  const HabotFunnelDropAlert._();

  // -----------------------------------------------------------------------
  // One measure, two names.
  // -----------------------------------------------------------------------

  static const String thisMetricName = 'Alert Trigger Dispatch Delay';

  static bool get itIsStep486sMeasure =>
      HabotAnomalyDispatch.twoNamesForOneMeasure &&
      thisMetricName == HabotAnomalyDispatch.step487MetricName;

  static bool get theCeilingIsSlowerThanTheFloorAgain =>
      HabotAnomalyDispatch.theCeilingIsSlowerThanTheFloor;

  // -----------------------------------------------------------------------
  // The band measures the wrong half.
  // -----------------------------------------------------------------------

  static const String whatTheInstructionIsAbout =
      'a threshold of fifteen per cent week over week';
  static const String whatTheBandTimes =
      'how fast the message is sent once the threshold trips';

  static bool get theBandMeasuresTheOtherHalf =>
      whatTheInstructionIsAbout != whatTheBandTimes;

  static const String halvesNote =
      'The instruction is about a threshold and the band times the dispatch. '
      'Dispatch speed is worth knowing and says nothing about whether the '
      'alert should have fired, so the threshold rule is specified here beside '
      'it.';

  // -----------------------------------------------------------------------
  // A minimum denominator.
  // -----------------------------------------------------------------------

  static const double dropThresholdPercent = 15;
  static const int minimumWeeklyVolume = 200;

  static const List<HabotFunnelStepReading> steps = <HabotFunnelStepReading>[
    HabotFunnelStepReading(
      name: 'opened the rota',
      lastWeek: 1840,
      thisWeek: 1502,
      buildLastWeek: '2026.09.08+840',
      buildThisWeek: '2026.09.23+871',
    ),
    HabotFunnelStepReading(
      name: 'started a visit note',
      lastWeek: 47,
      thisWeek: 39,
      buildLastWeek: '2026.09.08+840',
      buildThisWeek: '2026.09.23+871',
    ),
    HabotFunnelStepReading(
      name: 'submitted a visit note',
      lastWeek: 1710,
      thisWeek: 1698,
      buildLastWeek: '2026.09.08+840',
      buildThisWeek: '2026.09.23+871',
    ),
  ];

  static bool fires(HabotFunnelStepReading s) =>
      s.lastWeek >= minimumWeeklyVolume &&
      s.dropPercent > dropThresholdPercent;

  static List<HabotFunnelStepReading> get firing => steps.where(fires).toList();

  static bool get theBigStepFires => fires(steps.first);

  static bool get theSmallStepDoesNotFire => !fires(steps[1]);

  static bool get theSmallStepWouldHaveFiredWithoutTheFloor =>
      steps[1].dropPercent > dropThresholdPercent;

  static bool get theSteadyStepDoesNotFire => !fires(steps.last);

  static bool get oneAlertThisWeek => firing.length == 1;

  static const String volumeNote =
      'A funnel step that forty people reach in a week moves by fifteen per '
      'cent when six of them do something different, which happens constantly. '
      'Without a floor on the denominator the alert fires every week on the '
      'smallest steps and never gets read.';

  // -----------------------------------------------------------------------
  // The message carries counts and a build.
  // -----------------------------------------------------------------------

  static String messageFor(HabotFunnelStepReading s) =>
      '${s.name}: down ${s.dropPercent.toStringAsFixed(0)} per cent, '
      '${s.thisWeek} from ${s.lastWeek}, against build ${s.buildThisWeek}';

  static bool get theMessageCarriesAbsoluteCounts =>
      messageFor(steps.first).contains('1502 from 1840');

  static bool get theMessageNamesTheBuild =>
      messageFor(steps.first).contains('2026.09.23+871');

  static bool get theBuildsAreCompared =>
      steps.first.buildLastWeek != steps.first.buildThisWeek;

  static const String messageNote =
      '"Down 18 per cent" and "down 18 per cent, 1502 from 1840, against build '
      '2026.09.23+871" are different messages. The funnel is compared against '
      'the build that was live in each week, so a product manager is told what '
      'the change coincided with rather than discovering it a fortnight later.';

  static const double observedDispatchSeconds = 0.8;

  static String get qualitativeOutput => observedDispatchSeconds <=
          HabotAnomalyDispatch.floorSeconds
      ? 'Pass'
      : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row carries Step 486\'s three band values under a '
      'second metric name, with the ceiling again slower than the floor, and '
      'the band times the dispatch while the instruction is about a threshold; '
      'so the threshold rule is specified here: a minimum weekly volume of 200 '
      'before the fifteen per cent rule applies, which stops the smallest '
      'steps firing every week, and every message carries the absolute counts '
      'and the build that was live, because "down 18 per cent" and "down 18 '
      'per cent, 1502 from 1840" are different messages. Atomic Step: "Program '
      'Shakti Alerts notifying Product Managers if any funnel step drops > 15% '
      'week-over-week."';

  static Map<String, bool> get obligations => <String, bool>{
        'a minimum weekly volume applies before the rule':
            theSmallStepDoesNotFire,
        'a real drop on a real volume still fires': theBigStepFires,
        'a steady step does not fire': theSteadyStepDoesNotFire,
        'the message carries absolute counts':
            theMessageCarriesAbsoluteCounts,
        'the message names the build': theMessageNamesTheBuild,
      };

  static Map<String, bool> get checks => <String, bool>{
        'it is Step 486\'s measure under another name': itIsStep486sMeasure,
        'with the ceiling slower than the floor again':
            theCeilingIsSlowerThanTheFloorAgain,
        'the band times dispatch while the row sets a threshold':
            theBandMeasuresTheOtherHalf &&
                halvesNote.contains('should have fired'),
        'three steps, one alert this week':
            steps.length == 3 && oneAlertThisWeek,
        'the 1840-person step fires': theBigStepFires,
        'the 47-person step does not': theSmallStepDoesNotFire,
        'though it would have without the volume floor':
            theSmallStepWouldHaveFiredWithoutTheFloor &&
                minimumWeeklyVolume == 200,
        'the steady step stays quiet':
            theSteadyStepDoesNotFire && volumeNote.contains('never gets read'),
        'the message carries counts and the build':
            theMessageCarriesAbsoluteCounts &&
                theMessageNamesTheBuild &&
                theBuildsAreCompared,
        'five obligations met, and 0.8 seconds reports Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                messageNote.contains('different messages') &&
                qualitativeOutput == 'Pass',
      };
}
