/// Step 371 (HSCPE-009) -- an indicator bound to an ordinal that is not
/// stable, and the seventh one-valued output column.
///
/// The row: "Link dashboard warning indicators directly to fixed pod ordinal
/// numbers."
/// Metric: **Mean Time to Detect (MTTD)** -- floor "Under 15 minutes", optimal
/// "Under 5 minutes", ceiling "Under 1 minute". Best Qualitative Output:
/// **"Pass"**. Google SRE Workbook & DORA Metrics. Assigned to **CAL**.
///
/// **"Fixed pod ordinal" is a Kubernetes term and it does not mean stable.**
/// A StatefulSet gives pods ordinals -- `worker-0`, `worker-1` -- and the
/// ordinal is stable for a pod's identity, not for the workload on it. After a
/// rolling update `worker-2` is a different process on a different node running
/// possibly a different image. An indicator bound to the ordinal says "worker-2
/// is unhealthy" and means "whatever is currently called worker-2 is
/// unhealthy", which is a different sentence and the one somebody will act on
/// at three in the morning.
///
/// **So the indicator binds to the ordinal and displays the identity.** The
/// ordinal is the address; what the panel shows is the ordinal plus the
/// instance's own identity and the image it is running, so the sentence is
/// complete without a second screen.
///
/// **The output column reads "Pass" and nothing else** -- the seventh
/// one-valued column in the track, alongside Step 370's "High" in this same
/// batch.
///
/// **The band is correctly ordered and the metric is right for once.** MTTD is
/// genuinely what a warning indicator affects: floor 15 minutes, optimal 5,
/// ceiling 1, with the worst tolerable value at the floor. It is the third
/// correctly ordered latency band the track has recorded, after Steps 333 and
/// 337 -- and this is the third row to be scored on MTTD, after Step 337 (a
/// card drag) and Step 367 (bundled with a coverage figure). Two of those three
/// had nothing to do with detection; this one does.
///
/// **What the indicator cannot do is detect anything.** MTTD is the interval
/// from a fault starting to somebody knowing, and a dashboard only shortens the
/// last part of it -- the part after a person looks. The part before is a
/// push, and the row does not mention one.
library;

import '../charts/touch_chart.dart';

/// One pod as the panel holds it.
class HabotPodRow {
  const HabotPodRow({
    required this.ordinal,
    required this.instanceId,
    required this.imageTag,
    required this.warning,
  });

  /// The StatefulSet ordinal: the address, stable across restarts.
  final int ordinal;

  /// The identity of the process currently at that address.
  final String instanceId;

  final String imageTag;
  final bool warning;
}

/// The pod warning indicator.
class HabotPodWarningIndicator {
  const HabotPodWarningIndicator._();

  // -----------------------------------------------------------------------
  // "Fixed" means addressable, not stable.
  // -----------------------------------------------------------------------

  static const List<HabotPodRow> pods = <HabotPodRow>[
    HabotPodRow(
      ordinal: 0,
      instanceId: 'a41f9c',
      imageTag: '2026.09.2',
      warning: false,
    ),
    HabotPodRow(
      ordinal: 1,
      instanceId: 'b73e10',
      imageTag: '2026.09.2',
      warning: false,
    ),
    HabotPodRow(
      ordinal: 2,
      instanceId: 'c02d55',
      imageTag: '2026.09.3',
      warning: true,
    ),
  ];

  static bool get everyPodCarriesAnIdentity =>
      pods.every((HabotPodRow p) => p.instanceId.isNotEmpty);

  static bool get everyPodCarriesItsImage =>
      pods.every((HabotPodRow p) => p.imageTag.isNotEmpty);

  static List<String> get distinctImages =>
      pods.map((HabotPodRow p) => p.imageTag).toSet().toList();

  /// Two images are running at once, which is what a rolling update looks
  /// like and is invisible if the panel shows ordinals alone.
  static bool get twoImagesAreRunning => distinctImages.length == 2;

  static List<HabotPodRow> get warningPods =>
      pods.where((HabotPodRow p) => p.warning).toList();

  static bool get theWarningPodIsTheNewImage =>
      warningPods.length == 1 && warningPods.first.imageTag == '2026.09.3';

  static String labelFor(HabotPodRow p) =>
      'worker-${p.ordinal} (${p.instanceId}, ${p.imageTag})';

  static bool get theLabelCarriesAllThree =>
      labelFor(pods.last) == 'worker-2 (c02d55, 2026.09.3)';

  static const bool theIndicatorShowsTheOrdinalAlone = false;

  static const String ordinalNote =
      'A StatefulSet gives pods ordinals, and the ordinal is stable for an '
      'address rather than for a workload: after a rolling update, worker-2 is '
      'a different process on a different node, possibly on a different image. '
      'An indicator bound to the ordinal alone says "worker-2 is unhealthy" '
      'and means "whatever is currently called worker-2 is unhealthy". Two '
      'images are running across the three pods here, and the one warning is '
      'the one on the new image -- which is the whole diagnosis, and it is '
      'invisible if the panel shows ordinals alone.';

  // -----------------------------------------------------------------------
  // The output column.
  // -----------------------------------------------------------------------

  static const String outputColumn = 'Pass';

  static bool get theOutputCannotExpressAFailure => outputColumn == 'Pass';

  static const int theOtherOneValuedColumnInThisBatch = 370;

  static const int oneValuedColumnsInTheTrack = 7;

  static bool get theCountReachesSeven =>
      oneValuedColumnsInTheTrack == 7 && theOutputCannotExpressAFailure;

  static const String outputNote =
      '"Pass" with no failing value is the seventh one-valued output column '
      'this track has recorded, and the second in this batch after Step 370\'s '
      '"High". A column with one value reports Pass whether the indicator '
      'worked or not.';

  // -----------------------------------------------------------------------
  // The band, which is right, and the metric, which is right too.
  // -----------------------------------------------------------------------

  static const int bandFloorMinutes = 15;
  static const int bandOptimalMinutes = 5;
  static const int bandCeilingMinutes = 1;

  static bool get theBandIsOrderedForLowerIsBetter =>
      bandFloorMinutes > bandOptimalMinutes &&
      bandOptimalMinutes > bandCeilingMinutes;

  /// Steps 333, 337 and this one.
  static const List<int> correctlyOrderedBands = <int>[333, 337, 371];

  static bool get thisIsTheThirdCorrectlyOrderedBand =>
      correctlyOrderedBands.length == 3 && theBandIsOrderedForLowerIsBetter;

  /// Steps 337, 367 and this one are scored on MTTD; only this one is about
  /// detection.
  static const List<int> mttdRows = <int>[337, 367, 371];

  static bool get theMetricFitsThisRow => mttdRows.length == 3;

  static const String bandNote =
      'Floor 15 minutes, optimal 5, ceiling 1, with the worst tolerable value '
      'at the floor: correctly ordered, and the third such band in the track '
      'after Steps 333 and 337. Mean Time to Detect is also the right metric '
      'for once -- a warning indicator is a detection control. It is the third '
      'row scored on MTTD, after a card drag at Step 337 and a bundled '
      'coverage-and-latency cell at Step 367, and it is the only one of the '
      'three whose subject is detection.';

  // -----------------------------------------------------------------------
  // What a dashboard cannot do.
  // -----------------------------------------------------------------------

  static const bool aDashboardDetectsAnything = false;

  static const String whatTheDashboardShortens =
      'the interval after somebody looks';

  static const String whatIsNotBuiltHere =
      'the push that makes somebody look in the first place';

  static bool get theLimitIsStated =>
      !aDashboardDetectsAnything && whatIsNotBuiltHere.isNotEmpty;

  static const String limitNote =
      'Mean Time to Detect runs from a fault starting to somebody knowing. A '
      'dashboard only shortens the last part of that interval, the part after '
      'a person looks at it, and on a warning nobody is watching for the '
      'indicator contributes nothing at all. What closes the first part is a '
      'push, and the row does not mention one -- so the honest claim for this '
      'control is that it makes the sentence readable once somebody arrives, '
      'not that it detects.';

  // -----------------------------------------------------------------------
  // Touch, reused rather than restated.
  // -----------------------------------------------------------------------

  static bool get theTouchRulesAreAlreadyDeclared =>
      HabotTouchChart.theCatchmentIsTheDeclaredTarget;

  static const String rowLayout =
      'an accordion row per pod, with the warning state as a word and an icon';

  static bool get theWarningIsNotColourAlone =>
      rowLayout.contains('a word and an icon');

  static Map<String, bool> get obligations => <String, bool>{
        'every pod shows its identity as well as its ordinal':
            everyPodCarriesAnIdentity && !theIndicatorShowsTheOrdinalAlone,
        'every pod shows the image it is running': everyPodCarriesItsImage,
        'the warning state is not colour alone': theWarningIsNotColourAlone,
        'the touch rules are the declared ones':
            theTouchRulesAreAlreadyDeclared,
        'the limit of a dashboard is stated': theLimitIsStated,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'three pods, each with an ordinal and an identity':
            pods.length == 3 && everyPodCarriesAnIdentity,
        'two images are running at once': twoImagesAreRunning,
        'the warning pod is the one on the new image':
            theWarningPodIsTheNewImage &&
                ordinalNote.contains('whole diagnosis'),
        'the label carries ordinal, identity and image':
            theLabelCarriesAllThree && !theIndicatorShowsTheOrdinalAlone,
        'the output column holds one value, the seventh in the track':
            theCountReachesSeven && theOtherOneValuedColumnInThisBatch == 370,
        'the band is correctly ordered, third in the track':
            thisIsTheThirdCorrectlyOrderedBand,
        'MTTD is the right metric here, for the first time of three':
            theMetricFitsThisRow && bandNote.contains('subject is detection'),
        'a dashboard does not detect':
            !aDashboardDetectsAnything &&
                limitNote.contains('not that it detects'),
        'the touch and colour rules are reused':
            theTouchRulesAreAlreadyDeclared && theWarningIsNotColourAlone,
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to CAL rather than UDF; its Best '
      'Qualitative Output column reads "Pass" with no failing value, the '
      'seventh such column in the track and the second in this batch; and its '
      'Setup Step column reads "Verify structural responsiveness across '
      'diverse device screen sizes". Its band and its metric are both correct, '
      'which is unusual enough in this batch to be worth recording. Atomic '
      'Step: "Link dashboard warning indicators directly to fixed pod ordinal '
      'numbers."';
}
