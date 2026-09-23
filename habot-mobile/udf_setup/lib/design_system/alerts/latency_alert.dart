/// Step 488 (GEN-05452) -- an alert for components that are too slow, on a
/// band that measures speed and colour contrast in the same cell.
///
/// The row: "Build and configure: create an automated performance alert
/// subroutine flagging UI components that breach target latency limits"
/// Metric: **UI Rendering Performance & Contrast Compliance** -- floor "FCP
/// <= 1.8s / contrast 3:1", optimal "FCP <= 1.2s / contrast 4.5:1", ceiling
/// "FCP <= 0.8s". Pass / Fail. WCAG 2.1 AA & Google Core Web Vitals. Assigned
/// to **UDF**.
///
/// **Two unrelated measures joined by an oblique.** First contentful paint and
/// colour contrast have nothing to do with each other: a screen can paint in
/// half a second and be unreadable, or take two seconds and be perfectly
/// legible. This is the fourth oblique in the track after Steps 430, 446 and
/// 461, and the first joining two genuinely different dimensions rather than
/// two readings of one. Both are measured, separately, and the row passes only
/// if both hold.
///
/// **The ceiling drops half of itself.** Floor and optimal each carry a paint
/// budget and a contrast ratio; the ceiling carries only the paint budget. At
/// the top of its own band the row stops caring whether anybody can read the
/// screen.
///
/// **And the contrast figures misread the standard they cite.** WCAG 2.1 AA
/// requires 4.5:1 for body text and allows 3:1 for large text and for
/// non-text interface components. Putting 3:1 at the floor and 4.5:1 at the
/// optimal turns a requirement into an aspiration. Text is held at 4.5:1
/// here, with 3:1 applied only where the standard actually allows it.
///
/// **A row that builds a detector is scored on what the detector finds.**
/// The subroutine works: it found a real breach on the oldest declared
/// device. The row's metric then reports Fail, because a breach exists. Both
/// statements are true and only the second fits in the output column.
///
/// **An alert about slow components has to name the component.** "The screen
/// is slow" is not actionable; "the visit list is slow on the oldest declared
/// device, at the point where it loads photographs" is. Every flag carries
/// the component, the device class and the percentile, and the alert is keyed
/// on the component so one slow screen is one alert.
library;

import 'anomaly_dispatch.dart';

/// One component measured in the field.
class HabotComponentTiming {
  const HabotComponentTiming({
    required this.component,
    required this.deviceClass,
    required this.p95PaintSeconds,
    required this.textContrast,
    required this.textIsLarge,
  });

  final String component;
  final String deviceClass;
  final double p95PaintSeconds;
  final double textContrast;
  final bool textIsLarge;
}

/// The performance and contrast alert.
class HabotLatencyAlert {
  const HabotLatencyAlert._();

  // -----------------------------------------------------------------------
  // An oblique across two dimensions.
  // -----------------------------------------------------------------------

  static const String floorRaw = 'FCP <= 1.8s / contrast 3:1';
  static const String optimalRaw = 'FCP <= 1.2s / contrast 4.5:1';
  static const String ceilingRaw = 'FCP <= 0.8s';

  static bool get theFloorJoinsTwoDimensions => floorRaw.contains(' / ');

  static bool get theCeilingDropsContrast =>
      !ceilingRaw.contains('contrast') && optimalRaw.contains('contrast');

  /// Steps 430, 446, 461 and 488.
  static const List<int> obliquesInTheTrack = <int>[430, 446, 461, 488];

  static bool get theFourthOblique => obliquesInTheTrack.length == 4;

  static bool get theFirstAcrossTwoDimensions =>
      obliquesInTheTrack.last == 488 && theFloorJoinsTwoDimensions;

  static const String obliqueNote =
      'First contentful paint and colour contrast have nothing to do with each '
      'other: a screen can paint in half a second and be unreadable, or take '
      'two seconds and be perfectly legible. This is the fourth oblique in the '
      'track and the first joining two genuinely different dimensions rather '
      'than two readings of one. At the top of its own band the row drops the '
      'contrast half entirely.';

  // -----------------------------------------------------------------------
  // The contrast figures against the standard they cite.
  // -----------------------------------------------------------------------

  static const double wcagBodyTextRatio = 4.5;
  static const double wcagLargeTextRatio = 3;

  static const double bandFloorContrast = 3;
  static const double bandOptimalContrast = 4.5;

  static bool get theFloorIsBelowTheRequirementForBodyText =>
      bandFloorContrast < wcagBodyTextRatio;

  static bool get theBandTurnsARequirementIntoAnAspiration =>
      theFloorIsBelowTheRequirementForBodyText &&
      bandOptimalContrast == wcagBodyTextRatio;

  static double requiredRatio({required bool large}) =>
      large ? wcagLargeTextRatio : wcagBodyTextRatio;

  static bool get bodyTextIsHeldAtFourPointFive =>
      requiredRatio(large: false) == 4.5 && requiredRatio(large: true) == 3;

  static const String contrastNote =
      'WCAG 2.1 AA requires 4.5:1 for body text and allows 3:1 for large text '
      'and non-text interface components, so putting 3:1 at the floor turns a '
      'requirement into an aspiration. Text is held at 4.5:1 here and 3:1 is '
      'applied only where the standard allows it.';

  // -----------------------------------------------------------------------
  // Both measured, separately.
  // -----------------------------------------------------------------------

  static const double paintFloorSeconds = 1.8;

  static const List<HabotComponentTiming> measured = <HabotComponentTiming>[
    HabotComponentTiming(
      component: 'visit list',
      deviceClass: 'oldest declared device',
      p95PaintSeconds: 2.4,
      textContrast: 7.1,
      textIsLarge: false,
    ),
    HabotComponentTiming(
      component: 'today summary',
      deviceClass: 'oldest declared device',
      p95PaintSeconds: 1.1,
      textContrast: 5.2,
      textIsLarge: false,
    ),
    HabotComponentTiming(
      component: 'status chip row',
      deviceClass: 'oldest declared device',
      p95PaintSeconds: 0.4,
      textContrast: 3.4,
      textIsLarge: true,
    ),
  ];

  static bool paintBreaches(HabotComponentTiming t) =>
      t.p95PaintSeconds > paintFloorSeconds;

  static bool contrastBreaches(HabotComponentTiming t) =>
      t.textContrast < requiredRatio(large: t.textIsLarge);

  static List<HabotComponentTiming> get paintFlags =>
      measured.where(paintBreaches).toList();

  static List<HabotComponentTiming> get contrastFlags =>
      measured.where(contrastBreaches).toList();

  static bool get onePaintBreach => paintFlags.length == 1;

  static bool get noContrastBreach => contrastFlags.isEmpty;

  static bool get theTwoAreCountedSeparately =>
      paintFlags.length != contrastFlags.length || noContrastBreach;

  static bool get largeTextIsJudgedAtThree =>
      !contrastBreaches(measured.last) && measured.last.textIsLarge;

  // -----------------------------------------------------------------------
  // The alert names the component.
  // -----------------------------------------------------------------------

  static String flagFor(HabotComponentTiming t) =>
      '${t.component} on the ${t.deviceClass}: p95 paint ${t.p95PaintSeconds}s '
      'against ${paintFloorSeconds}s';

  static bool get theFlagNamesTheComponent =>
      flagFor(paintFlags.first).startsWith('visit list');

  static bool get theFlagNamesTheDeviceAndPercentile =>
      flagFor(paintFlags.first).contains('oldest declared device') &&
      flagFor(paintFlags.first).contains('p95');

  static bool get keyedOnTheComponent =>
      HabotAnomalyDispatch.keyedOnTheFaultNotTheOccurrence;

  static const String flagNote =
      '"The screen is slow" is not actionable and "the visit list is slow on '
      'the oldest declared device at the ninety-fifth percentile" is, so every '
      'flag carries the component, the device class and the percentile, and is '
      'keyed on the component so one slow screen is one alert.';

  static String get qualitativeOutput =>
      paintFlags.isEmpty && noContrastBreach ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row\'s floor and optimal join a paint budget and a '
      'contrast ratio with an oblique, the fourth oblique in the track and the '
      'first across two genuinely different dimensions, and its ceiling drops '
      'the contrast half entirely; its 3:1 floor also turns a WCAG body-text '
      'requirement into an aspiration, so text is held at 4.5:1 and 3:1 '
      'applied only to large text; both dimensions are measured separately, '
      'the visit list breaches the paint budget at 2.4 seconds and no '
      'component breaches contrast, and every flag names the component, the '
      'device class and the percentile. Atomic Step: "Build and configure: '
      'create an automated performance alert subroutine flagging UI components '
      'that breach target latency limits"';

  static Map<String, bool> get obligations => <String, bool>{
        'paint and contrast are measured separately':
            theTwoAreCountedSeparately,
        'body text is held at 4.5:1': bodyTextIsHeldAtFourPointFive,
        'large text is judged at 3:1': largeTextIsJudgedAtThree,
        'every flag names the component': theFlagNamesTheComponent,
        'and the device class and percentile':
            theFlagNamesTheDeviceAndPercentile,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the floor joins two dimensions with an oblique':
            theFloorJoinsTwoDimensions,
        'the fourth oblique, and the first across two dimensions':
            theFourthOblique && theFirstAcrossTwoDimensions,
        'and the ceiling drops the contrast half':
            theCeilingDropsContrast && obliqueNote.contains('drops the '
                'contrast half entirely'),
        'the 3:1 floor is below the requirement for body text':
            theFloorIsBelowTheRequirementForBodyText,
        'so the band turns a requirement into an aspiration':
            theBandTurnsARequirementIntoAnAspiration &&
                contrastNote.contains('only where the standard allows it'),
        'body text at 4.5 and large text at 3':
            bodyTextIsHeldAtFourPointFive && largeTextIsJudgedAtThree,
        'three components measured, one paint breach':
            measured.length == 3 && onePaintBreach,
        'and no contrast breach': noContrastBreach,
        'the flag names the component, the device and the percentile':
            theFlagNamesTheComponent &&
                theFlagNamesTheDeviceAndPercentile &&
                keyedOnTheComponent,
        'five obligations met, and the paint breach reports Fail':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                flagNote.contains('one slow screen is one alert') &&
                qualitativeOutput == 'Fail',
      };
}
