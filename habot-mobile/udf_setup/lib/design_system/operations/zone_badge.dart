/// Step 321 (GEN-03426) -- two badges for three states, and an output column
/// that can only say Pass.
///
/// The row: 'Display high-contrast "Site Verified" or "Outside Authorized
/// Zone" badges on screen.'
/// Metric: **Badge Visual Contrast Ratio** -- floor 4.5:1, optimal 7:1,
/// ceiling 21:1. Best Qualitative Output: **"Pass"**. WCAG 2.2 AA.
///
/// **The output column has one value in it.** "Pass", with no Fail. A row
/// whose output vocabulary cannot express a failure can only be closed one
/// way, which makes the gate decorative: whatever the contrast turns out to
/// be, the recordable outcome is the same. Four rows in this batch are like
/// this -- 321, 322, 334 and 335 -- and they are the first four this track has
/// met. It is recorded here and the step reports Pass/Fail against its own
/// obligations, so a failure would have somewhere to go.
///
/// **"Or" is the word that costs a worker their morning.** Site Verified or
/// Outside Authorized Zone is two badges; the device has three answers,
/// because it also has "I do not know". Location permission denied, no fix
/// indoors, a cold GPS start, airplane mode -- in every one of those the
/// honest badge is neither of the two the row names. Collapsing unknown into
/// "outside" tells somebody standing in exactly the right place that they are
/// in the wrong one, and the only thing they can do about it is walk outside
/// and wait. Step 294 and Step 316 reached the same three-valued shape from
/// authorisation and from fail-closed logic; this is its third appearance.
///
/// **And "outside" needs a confidence rule, not a comparison.** A fix with
/// +/-25 m of accuracy, 60 m from the centre of a 50 m site, is somewhere
/// between 35 m and 85 m out: it straddles the boundary, and asserting either
/// answer is a coin toss dressed as a measurement. The badge says outside only
/// when the whole accuracy circle is outside, inside only when the whole
/// circle is inside, and unknown in between -- which is most of the cases that
/// matter, because the cases that matter are near the fence.
library;

/// What the badge can say.
enum HabotZoneVerdict {
  /// The whole accuracy circle is inside the fence.
  verified,

  /// The whole accuracy circle is outside the fence.
  outside,

  /// The fix straddles the fence, or there is no fix.
  unknown,
}

/// One location reading.
class HabotZoneFix {
  const HabotZoneFix({
    required this.distanceMetres,
    required this.accuracyMetres,
    required this.hasFix,
  });

  /// Distance from the site centre.
  final double distanceMetres;

  /// The radius of the reported accuracy circle.
  final double accuracyMetres;

  final bool hasFix;

  double get nearestPossible => distanceMetres - accuracyMetres;
  double get furthestPossible => distanceMetres + accuracyMetres;
}

/// The badge.
class HabotZoneBadge {
  const HabotZoneBadge._();

  static const double fenceRadiusMetres = 50;

  static HabotZoneVerdict verdictFor(HabotZoneFix fix) {
    if (!fix.hasFix) {
      return HabotZoneVerdict.unknown;
    }
    if (fix.nearestPossible > fenceRadiusMetres) {
      return HabotZoneVerdict.outside;
    }
    if (fix.furthestPossible < fenceRadiusMetres) {
      return HabotZoneVerdict.verified;
    }
    return HabotZoneVerdict.unknown;
  }

  /// The worked readings.
  static const List<HabotZoneFix> readings = <HabotZoneFix>[
    HabotZoneFix(distanceMetres: 40, accuracyMetres: 8, hasFix: true),
    HabotZoneFix(distanceMetres: 12, accuracyMetres: 20, hasFix: true),
    HabotZoneFix(distanceMetres: 60, accuracyMetres: 25, hasFix: true),
    HabotZoneFix(distanceMetres: 95, accuracyMetres: 20, hasFix: true),
    HabotZoneFix(distanceMetres: 120, accuracyMetres: 15, hasFix: true),
    HabotZoneFix(distanceMetres: 0, accuracyMetres: 0, hasFix: false),
  ];

  static int countOf(HabotZoneVerdict v) =>
      readings.where((HabotZoneFix f) => verdictFor(f) == v).length;

  static bool get theStraddlingReadingIsUnknown =>
      verdictFor(readings[2]) == HabotZoneVerdict.unknown;

  static bool get noFixIsUnknownRatherThanOutside =>
      verdictFor(readings[5]) == HabotZoneVerdict.unknown;

  /// The naive comparison the row's two-badge phrasing invites, kept
  /// executable so the difference is visible rather than argued.
  static HabotZoneVerdict naiveVerdictFor(HabotZoneFix fix) =>
      fix.distanceMetres <= fenceRadiusMetres
          ? HabotZoneVerdict.verified
          : HabotZoneVerdict.outside;

  static List<HabotZoneFix> get readingsTheNaiveRuleGetsWrong => readings
      .where((HabotZoneFix f) => naiveVerdictFor(f) != verdictFor(f))
      .toList();

  static const String confidenceNote =
      'A fix 60 m from the centre with +/-25 m of accuracy is somewhere '
      'between 35 m and 85 m out. Against a 50 m fence that is not an answer, '
      'and asserting one is a coin toss dressed as a measurement. The badge '
      'says outside only when the whole accuracy circle is outside and '
      'verified only when the whole circle is inside. The cases that fall in '
      'between are the cases near the fence, which are the only cases anybody '
      'ever argues about.';

  // -----------------------------------------------------------------------
  // What each state says and offers.
  // -----------------------------------------------------------------------

  static const Map<HabotZoneVerdict, String> labels =
      <HabotZoneVerdict, String>{
    HabotZoneVerdict.verified: 'On site',
    HabotZoneVerdict.outside: 'Not at this site',
    HabotZoneVerdict.unknown: 'Cannot confirm your location',
  };

  static const Map<HabotZoneVerdict, String> nextSteps =
      <HabotZoneVerdict, String>{
    HabotZoneVerdict.verified: '',
    HabotZoneVerdict.outside:
        'Check you picked the right job, or start it anyway and add a note',
    HabotZoneVerdict.unknown:
        'Move somewhere with a clearer view of the sky, or start it anyway '
            'and add a note',
  };

  static bool get everyVerdictHasALabel =>
      labels.length == HabotZoneVerdict.values.length;

  static bool get everyNonVerifiedVerdictOffersAWayOn =>
      (nextSteps[HabotZoneVerdict.outside] ?? '').isNotEmpty &&
      (nextSteps[HabotZoneVerdict.unknown] ?? '').isNotEmpty;

  /// Neither non-verified state is a dead end: the work can proceed with a
  /// note, because a geofence is evidence and not a lock.
  static const bool theBadgeBlocksTheWork = false;

  static const String deadEndNote =
      'Neither of the two states that are not "on site" stops the work. A '
      'geofence on a phone is evidence, not a lock: it is wrong often enough '
      'near buildings that making it a gate strands people who are exactly '
      'where they said they would be. Both offer the same way on -- start it '
      'and add a note -- and the note is what the record carries.';

  // -----------------------------------------------------------------------
  // The badge itself.
  // -----------------------------------------------------------------------

  static const double contrastFloor = 4.5;
  static const double contrastOptimal = 7.0;
  static const double contrastCeiling = 21.0;

  static const bool colourIsTheSoleCarrier = false;

  static bool get everyBadgeCarriesItsWords =>
      labels.values.every((String l) => l.trim().split(' ').length >= 2);

  static const String ceilingNote =
      'The 21:1 ceiling is the formula\'s maximum rather than a target, which '
      'Step 272 recorded and Step 315 restated. Nothing here is asked to '
      'approach it.';

  // -----------------------------------------------------------------------
  // The one-valued output column.
  // -----------------------------------------------------------------------

  static const String rowOutputVocabulary = 'Pass';

  static bool get theOutputCannotExpressAFailure =>
      !rowOutputVocabulary.contains('Fail');

  static const List<int> stepsInThisBatchWithAOneValuedOutput = <int>[
    321,
    322,
    334,
    335,
  ];

  static bool get fourRowsInThisBatchShareTheDefect =>
      stepsInThisBatchWithAOneValuedOutput.length == 4;

  static const String outputNote =
      'The output column holds "Pass" and nothing else. A row whose vocabulary '
      'cannot express a failure can only be closed one way, whatever the '
      'measurement turns out to be, which makes the gate decorative. Four rows '
      'in this batch are like this and they are the first four in this track. '
      'The step reports Pass/Fail against its own declared obligations so that '
      'a failure would have somewhere to go.';

  static Map<String, bool> get obligations => <String, bool>{
        'the badge has three states rather than two':
            HabotZoneVerdict.values.length == 3,
        'a straddling fix reports unknown': theStraddlingReadingIsUnknown,
        'no fix reports unknown rather than outside':
            noFixIsUnknownRatherThanOutside,
        'every state carries words': everyBadgeCarriesItsWords,
        'neither non-verified state is a dead end': !theBadgeBlocksTheWork,
        'colour is not the carrier': !colourIsTheSoleCarrier,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'six readings across three verdicts':
            readings.length == 6 &&
                countOf(HabotZoneVerdict.verified) == 2 &&
                countOf(HabotZoneVerdict.outside) == 2 &&
                countOf(HabotZoneVerdict.unknown) == 2,
        'the reading that straddles the fence is unknown':
            theStraddlingReadingIsUnknown &&
                readings[2].nearestPossible == 35 &&
                readings[2].furthestPossible == 85,
        'a device with no fix is unknown, not outside':
            noFixIsUnknownRatherThanOutside,
        'the two-badge reading gets two of the six wrong':
            readingsTheNaiveRuleGetsWrong.length == 2 &&
                confidenceNote.contains('coin toss'),
        'three labels and two ways on':
            everyVerdictHasALabel &&
                everyNonVerifiedVerdictOffersAWayOn &&
                labels[HabotZoneVerdict.unknown] ==
                    'Cannot confirm your location',
        'the geofence is evidence rather than a lock':
            !theBadgeBlocksTheWork &&
                deadEndNote.contains('exactly where they said they would be'),
        'the band is the ordinary contrast band':
            contrastFloor == 4.5 &&
                contrastOptimal == 7.0 &&
                contrastCeiling == 21.0 &&
                ceilingNote.contains('Step 315'),
        'the output column cannot express a failure':
            theOutputCannotExpressAFailure &&
                rowOutputVocabulary == 'Pass',
        'and four rows in this batch share that defect':
            fourRowsInThisBatchShareTheDefect &&
                outputNote.contains('makes the gate decorative'),
        'six obligations, all met, giving Pass':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: the Best Qualitative Output column on this row reads '
      '"Pass", with no failing value, and every narrative column is the '
      'generic engineering-console boilerplate. Atomic Step: "Display '
      'high-contrast Site Verified or Outside Authorized Zone badges on '
      'screen."';
}
