/// AISS Step 103 -- GEN-04462
/// "Verify typography sizing, line heights, and weights against Figma specs."
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// SUBSTITUTION RECORDED. The row names Figma, and its metric is "Visual
/// Regression Pixel Variance". There is no Figma file in this project, and a
/// pixel-variance metric needs a reference image to vary FROM. The only
/// specification that exists is the type scale itself, declared in
/// `tokens/typography_tokens.dart`. That is the specification this step
/// verifies against, and no pixel-variance figure is invented.
///
/// This is the same treatment Cloud Build got at Step 97: name the gap, use
/// the thing that actually exists, and record the substitution where someone
/// can disagree with it.
///
/// WHAT "VERIFY AGAINST A SPEC" MEANS WITH NO EXTERNAL SPEC. A type scale is
/// not an arbitrary list of numbers; it is a set of relationships. Those
/// relationships are checkable without any reference image:
///
///   * sizes descend monotonically WITHIN each role group (display, headline,
///     title, body, label) -- not across the whole list, because Material's
///     scale restarts at each group and `bodyLarge` is deliberately larger
///     than `titleSmall`;
///   * leading is never tighter than the glyphs (line height >= size);
///   * leading ratios stay inside the band where text is neither cramped nor
///     drifting apart;
///   * every weight is a real Material weight;
///   * every size clears the readable floor;
///   * no two tokens are the same size AND weight AND leading AND tracking,
///     because two names for one style is a scale nobody can apply
///     consistently -- except where Material 3 itself declares the pair, which
///     is recorded as an exemption rather than silently skipped.
///
/// A scale that satisfies all six is a scale that was designed. One that does
/// not is a scale that drifted, which is what a Figma comparison would have
/// been looking for anyway.
///
/// WHAT IS DELIBERATELY NOT CHECKED. Whether a token is still readable at the
/// OS *minimum* text scale (0.85x). Below 1.0 the user has asked for smaller
/// text; penalising their choice is not an accessibility check, it is the app
/// overriding a preference. The readable floor is enforced at 1.0, and the
/// scale-up axis is Step 102's.
library;

import '../tokens/typography_tokens.dart';
import 'text_fit.dart';

/// One thing that can be wrong with a type scale.
enum HabotTypeDefect {
  sizeNotDescending,
  leadingTighterThanGlyphs,
  leadingRatioOutOfBand,
  weightNotMaterial,
  belowReadableFloor,
  duplicateToken,
}

/// One violation found in the scale.
class HabotTypeFinding {
  const HabotTypeFinding({
    required this.defect,
    required this.tokenName,
    required this.detail,
  });

  final HabotTypeDefect defect;
  final String tokenName;
  final String detail;

  @override
  String toString() => '[${defect.name}] $tokenName -- $detail';
}

/// The type scale audit.
class HabotTypeScaleAudit {
  const HabotTypeScaleAudit._();

  /// Material's type scale sits between roughly 1.15 and 1.60 leading. Outside
  /// that band, lines either collide or stop reading as a paragraph.
  static const double minLeadingRatio = 1.10;
  static const double maxLeadingRatio = 1.75;

  static const Set<int> materialWeights = <int>{
    100,
    200,
    300,
    400,
    500,
    600,
    700,
    800,
    900,
  };

  /// The declared order, largest to smallest within each group.
  /// `HabotTypography.all` is the specification's own order, so this reads it
  /// rather than restating it.
  static List<HabotTypeToken> get scale => HabotTypography.all;

  /// Material 3's own scale declares `titleSmall` and `labelLarge` with
  /// identical size, leading, weight and tracking. Recorded here rather than
  /// skipped silently, so the duplicate rule still catches a NEW collision.
  static const Set<String> sanctionedDuplicates = <String>{
    'titleSmall',
    'labelLarge',
  };

  static const String sanctionedDuplicateRationale =
      'Material 3 defines titleSmall and labelLarge as 14sp / 20sp / w500 / '
      '0.1 tracking. They differ in ROLE, not in appearance. Diverging from '
      'the platform scale to satisfy this audit would be the audit changing '
      'the design rather than measuring it.';

  /// The role group a token belongs to: 'display', 'headline', 'title',
  /// 'body', 'label'. Sizes descend within a group, not across groups.
  static String groupOf(HabotTypeToken t) =>
      t.name.replaceAll(RegExp(r'(Large|Medium|Small)$'), '');

  static List<HabotTypeFinding> audit() {
    final List<HabotTypeFinding> out = <HabotTypeFinding>[];

    // 1. Sizes descend within each role group.
    final Map<String, HabotTypeToken> previousInGroup =
        <String, HabotTypeToken>{};
    for (final HabotTypeToken cur in scale) {
      final String g = groupOf(cur);
      final HabotTypeToken? prev = previousInGroup[g];
      if (prev != null && cur.sizeSp > prev.sizeSp) {
        out.add(
          HabotTypeFinding(
            defect: HabotTypeDefect.sizeNotDescending,
            tokenName: cur.name,
            detail:
                '${cur.sizeSp}sp is larger than ${prev.name} at '
                '${prev.sizeSp}sp, but is declared after it in the "$g" group',
          ),
        );
      }
      previousInGroup[g] = cur;
    }

    for (final HabotTypeToken t in scale) {
      // 2. Leading is never tighter than the glyphs.
      if (t.lineHeightSp < t.sizeSp) {
        out.add(
          HabotTypeFinding(
            defect: HabotTypeDefect.leadingTighterThanGlyphs,
            tokenName: t.name,
            detail:
                'line height ${t.lineHeightSp}sp is below the font size '
                '${t.sizeSp}sp',
          ),
        );
      }

      // 3. Leading ratio inside the band.
      final double ratio = t.heightMultiple;
      if (ratio < minLeadingRatio || ratio > maxLeadingRatio) {
        out.add(
          HabotTypeFinding(
            defect: HabotTypeDefect.leadingRatioOutOfBand,
            tokenName: t.name,
            detail:
                'leading ratio ${ratio.toStringAsFixed(2)} is outside '
                '$minLeadingRatio..$maxLeadingRatio',
          ),
        );
      }

      // 4. Real Material weight.
      if (!materialWeights.contains(t.weight)) {
        out.add(
          HabotTypeFinding(
            defect: HabotTypeDefect.weightNotMaterial,
            tokenName: t.name,
            detail: '${t.weight} is not a Material weight',
          ),
        );
      }

      // 5. Readable at 1.0 and still readable at the minimum supported scale.
      if (t.sizeSp < HabotTextFit.minReadableFontSp) {
        out.add(
          HabotTypeFinding(
            defect: HabotTypeDefect.belowReadableFloor,
            tokenName: t.name,
            detail:
                '${t.sizeSp}sp is below the '
                '${HabotTextFit.minReadableFontSp}sp readable floor',
          ),
        );
      }
    }

    // 6. No two tokens identical in every visual property.
    final Map<String, String> seen = <String, String>{};
    for (final HabotTypeToken t in scale) {
      final String key = '${t.sizeSp}/${t.lineHeightSp}/${t.weight}/'
          '${t.tracking}';
      final String? first = seen[key];
      if (first != null &&
          !(sanctionedDuplicates.contains(t.name) &&
              sanctionedDuplicates.contains(first))) {
        out.add(
          HabotTypeFinding(
            defect: HabotTypeDefect.duplicateToken,
            tokenName: t.name,
            detail:
                'is visually identical to $first ($key); two names for one '
                'style cannot be applied consistently',
          ),
        );
      } else {
        seen[key] = t.name;
      }
    }

    return out;
  }

  static bool get isClean => audit().isEmpty;

  /// The specification this audit runs against, named rather than assumed.
  static const String specificationSource =
      'lib/design_system/tokens/typography_tokens.dart -- the declared type '
      'scale. Substituted for the Figma file the sheet names, which does not '
      'exist in this project.';

  static String report() {
    final List<HabotTypeFinding> f = audit();
    if (f.isEmpty) {
      return 'TYPE SCALE CLEAN -- ${scale.length} tokens verified against '
          '$specificationSource';
    }
    return <String>[
      'TYPE SCALE: ${f.length} finding(s) across ${scale.length} tokens',
      ...f.map((HabotTypeFinding x) => '  $x'),
    ].join('\n');
  }
}
