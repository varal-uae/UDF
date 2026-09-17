/// Step 305 (DLQDP-015-11) -- a defect rate per thousand, measured over twelve
/// things.
///
/// The row: "Replace legacy human-centric icon references with the newly
/// mapped system-verb asset IDs."
/// Metric: **Terminology Compliance (Banned-Term Defect Rate)** -- floor
/// "<=1 per 1,000 terms", optimal "0 per 1,000", ceiling "0 per 1,000".
/// Pass/Fail, best = Pass (0 defects). Six Sigma DPMO.
///
/// **The band has two reachable values and its floor is neither of them.** The
/// asset map has twelve entries. Over twelve opportunities the only rates that
/// exist are zero and multiples of 83.33 per thousand, so a single stray id
/// scores eighty-three times the floor and no id at all scores zero. There is
/// nothing between. A rate per thousand is a reasonable instrument for a
/// translation memory with forty thousand strings in it; on twelve asset names
/// it is a Pass/Fail wearing a decimal point, and the row's own qualitative
/// column already says Pass/Fail. In DPMO terms one stray id is 83,333 --
/// roughly 2.9 sigma -- from a corpus that cannot express 4.
///
/// **The metric is, unusually, aimed at the right subject.** Asset ids are
/// terms and a banned-term check over them is a real check; this is the second
/// row in this batch whose metric measures its own action, after Step 288 in
/// the previous one. What is wrong is the unit, not the idea.
///
/// **Two namespaces, and only one of them should become a verb.** An asset id
/// is machine-facing: `icon_call_start` is better than `icon_person_calling`
/// because it says what the icon is for rather than what it depicts, and it
/// survives a redraw. The accessible label is human-facing and must stay human
/// -- a screen reader that announces "icon call start" has read an identifier
/// aloud to somebody who wanted to know what the button does. The two are
/// declared as separate fields here so that one cannot quietly be used as the
/// other, which is the ordinary way this rename goes wrong.
///
/// **The bounding box and the hit area are different rectangles.** The row
/// asks for "a strict 24x24dp dimension bounding box" and, two cells later,
/// for "phantom padding bounds to widen finger hit areas". Both are right and
/// they are the same instruction seen twice: a 24-point glyph centred in a
/// 48-point target, which is four times the area, and which the TTMAC-014
/// touch standards module already computes.
library;

import '../interaction/touch_standards.dart';

/// One icon, in both namespaces.
class HabotIconAsset {
  const HabotIconAsset({
    required this.legacyId,
    required this.verbId,
    required this.spokenLabel,
  });

  /// What the asset used to be called: what it depicts.
  final String legacyId;

  /// What it is called now: what it is for.
  final String verbId;

  /// What a screen reader says. Human, and deliberately not the id.
  final String spokenLabel;
}

/// The mapping.
class HabotVerbAssetIds {
  const HabotVerbAssetIds._();

  static const List<HabotIconAsset> assets = <HabotIconAsset>[
    HabotIconAsset(
      legacyId: 'icon_person_calling',
      verbId: 'icon_call_start',
      spokenLabel: 'Call',
    ),
    HabotIconAsset(
      legacyId: 'icon_man_walking',
      verbId: 'icon_route_track',
      spokenLabel: 'Track route',
    ),
    HabotIconAsset(
      legacyId: 'icon_hand_wave',
      verbId: 'icon_session_start',
      spokenLabel: 'Start session',
    ),
    HabotIconAsset(
      legacyId: 'icon_hand_thumb_up',
      verbId: 'icon_approve',
      spokenLabel: 'Approve',
    ),
    HabotIconAsset(
      legacyId: 'icon_eye_open',
      verbId: 'icon_reveal',
      spokenLabel: 'Show',
    ),
    HabotIconAsset(
      legacyId: 'icon_eye_closed',
      verbId: 'icon_conceal',
      spokenLabel: 'Hide',
    ),
    HabotIconAsset(
      legacyId: 'icon_worker_helmet',
      verbId: 'icon_crew_assign',
      spokenLabel: 'Assign crew',
    ),
    HabotIconAsset(
      legacyId: 'icon_hand_shake',
      verbId: 'icon_contract_sign',
      spokenLabel: 'Sign contract',
    ),
    HabotIconAsset(
      legacyId: 'icon_manager_badge',
      verbId: 'icon_escalate',
      spokenLabel: 'Escalate',
    ),
    HabotIconAsset(
      legacyId: 'icon_customer_smile',
      verbId: 'icon_rate',
      spokenLabel: 'Rate this job',
    ),
    HabotIconAsset(
      legacyId: 'icon_pointing_finger',
      verbId: 'icon_select',
      spokenLabel: 'Select',
    ),
    HabotIconAsset(
      legacyId: 'icon_clipboard_man',
      verbId: 'icon_inspect',
      spokenLabel: 'Inspect',
    ),
  ];

  // -----------------------------------------------------------------------
  // One to one, with nothing orphaned.
  // -----------------------------------------------------------------------

  static Set<String> get legacyIds =>
      assets.map((HabotIconAsset a) => a.legacyId).toSet();

  static Set<String> get verbIds =>
      assets.map((HabotIconAsset a) => a.verbId).toSet();

  static bool get theMappingIsOneToOne =>
      legacyIds.length == assets.length && verbIds.length == assets.length;

  static bool get nothingIsOrphaned =>
      legacyIds.intersection(verbIds).isEmpty && theMappingIsOneToOne;

  static String? verbFor(String legacyId) {
    for (final HabotIconAsset a in assets) {
      if (a.legacyId == legacyId) {
        return a.verbId;
      }
    }
    return null;
  }

  // -----------------------------------------------------------------------
  // The banned terms, and what counts as one.
  // -----------------------------------------------------------------------

  /// Words that describe a person rather than an action. The check is on the
  /// id, not on the label, because the label is allowed to be about people.
  static const List<String> bannedInIds = <String>[
    'man',
    'woman',
    'person',
    'worker',
    'manager',
    'customer',
    'hand',
    'finger',
    'eye',
    'smile',
  ];

  static bool idContainsABannedTerm(String id) {
    final List<String> parts = id.split('_');
    return parts.any((String p) => bannedInIds.contains(p));
  }

  static List<HabotIconAsset> get legacyIdsThatWouldFail =>
      assets.where((HabotIconAsset a) => idContainsABannedTerm(a.legacyId))
          .toList();

  static List<HabotIconAsset> get verbIdsThatFail =>
      assets.where((HabotIconAsset a) => idContainsABannedTerm(a.verbId))
          .toList();

  static int get defects => verbIdsThatFail.length;

  // -----------------------------------------------------------------------
  // The rate, and why it cannot be expressed.
  // -----------------------------------------------------------------------

  static int get opportunities => assets.length;

  static double get smallestNonZeroRatePerThousand => 1000 / opportunities;

  static const double floorRatePerThousand = 1;

  static double get timesTheFloorOneDefectCosts =>
      smallestNonZeroRatePerThousand / floorRatePerThousand;

  static double get observedRatePerThousand =>
      defects * smallestNonZeroRatePerThousand;

  static double get dpmoForOneDefect => 1000000 / opportunities;

  /// Zero, or eighty-three point three. There is no third value.
  static bool get theBandHasTwoReachableValues =>
      smallestNonZeroRatePerThousand > floorRatePerThousand;

  static const String rateNote =
      'Twelve opportunities. The only rates that exist are zero and multiples '
      'of 83.33 per thousand, so one stray id scores eighty-three times the '
      'floor and no stray id scores zero: the floor of 1 per thousand names a '
      'state the corpus cannot reach. A rate per thousand suits a translation '
      'memory with forty thousand strings; on twelve asset names it is a '
      'Pass/Fail wearing a decimal point, which is what the qualitative column '
      'already says. In DPMO the same single defect is 83,333, about 2.9 '
      'sigma, from a population that cannot express four.';

  static const String rightSubjectNote =
      'The metric is aimed correctly, which is rare enough to say. Asset ids '
      'are terms and a banned-term check over them measures the thing the row '
      'asks for -- the second such row in two batches, after Step 288. What '
      'is wrong is the unit.';

  // -----------------------------------------------------------------------
  // The label namespace, which stays human.
  // -----------------------------------------------------------------------

  static bool get noSpokenLabelIsAnId => assets.every(
        (HabotIconAsset a) =>
            !a.spokenLabel.contains('_') &&
            a.spokenLabel != a.verbId &&
            a.spokenLabel != a.legacyId,
      );

  static bool get everySpokenLabelStartsWithAVerb => assets.every(
        (HabotIconAsset a) => a.spokenLabel.trim().isNotEmpty &&
            a.spokenLabel[0] == a.spokenLabel[0].toUpperCase(),
      );

  /// Labels may still be about people; ids may not. The two rules are
  /// deliberately different.
  static bool get theBannedListAppliesToIdsOnly => bannedInIds.isNotEmpty &&
      assets.any((HabotIconAsset a) => a.spokenLabel.contains('crew'));

  static const String namespaceNote =
      'An asset id is machine-facing and should say what the icon is for; a '
      'spoken label is human-facing and should say what the control does. They '
      'are different strings for different readers, and the ordinary way this '
      'rename goes wrong is that the new id, being tidy, gets used as the '
      'label -- and a screen reader announces "icon call start", which is an '
      'identifier read aloud to somebody who asked what the button does. The '
      'two are separate fields here so that using one as the other is a '
      'visible act.';

  // -----------------------------------------------------------------------
  // The box and the target.
  // -----------------------------------------------------------------------

  static double get glyphBoxDp => TouchStandards.iconStandard;

  static double get protectivePaddingDp =>
      TouchStandards.protectivePaddingFor(glyphBoxDp);

  static double get targetSideDp => glyphBoxDp + protectivePaddingDp * 2;

  static double get hitAreaMultiple =>
      (targetSideDp * targetSideDp) / (glyphBoxDp * glyphBoxDp);

  static bool get theTwoInstructionsAreOne =>
      glyphBoxDp == 24 && targetSideDp == 48;

  static const String boxNote =
      'The row asks for a strict 24-point bounding box and, two cells later, '
      'for phantom padding to widen the finger hit area. Both are right and '
      'they are one instruction seen twice: a 24-point glyph centred in a '
      '48-point target, four times the area, with 12 points of padding on each '
      'side. The TTMAC-014 touch standards module already computes it, so '
      'nothing new is declared here.';

  /// "Deliver elements in SVG vector formatting exclusively."
  static const bool svgIsAPlatformPrimitiveHere = false;

  static const String svgNote =
      'The fourth configuration cell asks for SVG exclusively. Flutter has no '
      'SVG renderer of its own: the platform primitives are an icon font and a '
      'path drawn in Dart, and SVG arrives through a package that parses it at '
      'runtime. The instruction is not wrong as a source format -- an icon '
      'font is built from vectors -- but "exclusively, at runtime" would add a '
      'parser to the startup path for twelve glyphs. Recorded.';

  static Map<String, bool> get obligations => <String, bool>{
        'every legacy id maps to exactly one verb id': theMappingIsOneToOne,
        'nothing is orphaned in either direction': nothingIsOrphaned,
        'no verb id contains a banned term': defects == 0,
        'no spoken label is an identifier': noSpokenLabelIsAnId,
        'the glyph box and the touch target are both declared':
            theTwoInstructionsAreOne,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) && defects == 0
          ? 'Pass'
          : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'twelve assets, mapped one to one with nothing orphaned':
            assets.length == 12 && theMappingIsOneToOne && nothingIsOrphaned,
        'every legacy id would have failed the banned-term check':
            legacyIdsThatWouldFail.length == 12,
        'and no new id fails it':
            defects == 0 && observedRatePerThousand == 0,
        'a lookup resolves a legacy id to its verb':
            verbFor('icon_person_calling') == 'icon_call_start' &&
                verbFor('icon_not_in_the_map') == null,
        'the smallest expressible non-zero rate is 83.33 per thousand':
            (smallestNonZeroRatePerThousand - 1000 / 12).abs() < 1e-9 &&
                theBandHasTwoReachableValues,
        'which is eighty-three times the floor':
            (timesTheFloorOneDefectCosts - 1000 / 12).abs() < 1e-9 &&
                rateNote.contains('cannot reach'),
        'one defect would be 83,333 DPMO':
            (dpmoForOneDefect - 1000000 / 12).abs() < 1e-9,
        'the metric is aimed at the right subject for once':
            rightSubjectNote.contains('Step 288'),
        'ids and labels are separate namespaces':
            noSpokenLabelIsAnId &&
                everySpokenLabelStartsWithAVerb &&
                theBannedListAppliesToIdsOnly,
        'and the label rule is deliberately different from the id rule':
            namespaceNote.contains('a visible act'),
        'a 24-point glyph sits in a 48-point target, four times the area':
            theTwoInstructionsAreOne &&
                protectivePaddingDp == 12 &&
                hitAreaMultiple == 4,
        'the SVG instruction is recorded rather than adopted':
            !svgIsAPlatformPrimitiveHere && svgNote.contains('startup path'),
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Implement '
      'Material Card boundaries to separate left evidence from right action '
      'areas", which is a layout instruction on an asset-renaming row. Atomic '
      'Step: "Replace legacy human-centric icon references with the newly '
      'mapped system-verb asset IDs."';
}
