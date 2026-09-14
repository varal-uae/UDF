/// AISS Step 182 -- GEN-00599
/// Setup Step (Action): "Create a token rule enforcer middleware or
///                       interceptor for the mobile API gateway."
/// Atomic Step: "Bind font family Inter to Body typography tokens
///               (normal 400)."
/// Metric: Body Font Alignment -- Floor "Inter 400", Optimal "Inter 400",
///         Ceiling "Inter 400". Complete / Not Complete.
///
/// **THIS STEP REPORTS NOT COMPLETE, AND THE REASON IS THE WHOLE VALUE OF THE
/// STEP.** The row asks for Inter. This project's body tokens are bound to
/// Roboto, declared at Step 3 and recorded there as the platform-bundled
/// Material type face with no asset to ship. Those two facts are in direct
/// conflict, and the conflict is worth surfacing rather than resolving by
/// editing one string.
///
/// **BECAUSE EDITING THE STRING IS THE DANGEROUS OPTION.** Inter is not a
/// platform font on either Android or iOS. Changing `fontName` to `'Inter'`
/// without shipping the font files does not produce Inter — Flutter falls back
/// to the platform default, which is Roboto on Android, San Francisco on iOS,
/// and something else again on a manufacturer skin. The app would then render
/// in a font that *varies by device*, while every measurement taken against a
/// known type face silently stops being true.
///
/// **AND THIS PROJECT HAS TAKEN A LOT OF THOSE MEASUREMENTS.** Step 102 audits
/// text fit at 200% scaling, Step 138 carries a 30% expansion factor for Welsh,
/// Step 144 rejected two language labels against a 12-character button budget,
/// and Step 167 sizes frozen table columns against label widths. Every one of
/// those numbers is a claim about how wide a string is *in a specific type
/// face*. A silent per-device font substitution invalidates them without
/// failing anything.
///
/// **SO THE BINDING IS BUILT, AND IT IS BUILT WITH A PRECONDITION.** The font
/// a body token resolves to is declared data with an asset requirement
/// attached; [HabotBodyFont.canBind] is false while the asset is absent, and
/// the metric reports Not Complete with the outstanding work named. What is
/// NOT done is the thing that would look like progress and would be a
/// regression.
///
/// **COLUMN NOTE, RECORDED.** The Setup Step names an API-gateway middleware.
/// A font binding is a client-side typography concern with no gateway
/// involvement; the Atomic Step is the unit of work and is what is built.
library;

import 'typography_tokens.dart';

/// A font family the body tokens could be bound to.
class HabotFontFamily {
  const HabotFontFamily({
    required this.name,
    required this.isPlatformBundled,
    required this.assetPath,
    required this.licence,
  });

  final String name;

  /// True when the platform already ships it, so there is no asset and no
  /// fallback risk.
  final bool isPlatformBundled;

  /// Null when nothing has to be shipped.
  final String? assetPath;

  final String licence;

  /// A family can be bound only if the glyphs will actually be present.
  /// Naming a family the build does not ship produces a silent per-device
  /// substitution, which is worse than not changing it.
  bool get isAvailable => isPlatformBundled || assetPath != null;
}

/// What the body tokens are bound to, what the row asks for, and the gap.
class HabotBodyFont {
  const HabotBodyFont._();

  /// The family the row specifies.
  static const HabotFontFamily requested = HabotFontFamily(
    name: 'Inter',
    isPlatformBundled: false,
    // Nothing is vendored. This build host has no network, so the files
    // cannot be fetched here either; that is a fact about the environment
    // rather than a decision.
    assetPath: null,
    licence: 'SIL Open Font License 1.1',
  );

  /// The family the body tokens actually resolve to today.
  static const HabotFontFamily bound = HabotFontFamily(
    name: HabotTypography.fontName,
    isPlatformBundled: true,
    assetPath: null,
    licence: 'Apache 2.0, bundled by the platform',
  );

  /// The weight the row specifies, and the weight the tokens carry.
  static const int requestedWeight = 400;

  /// The three roles this row is about. Display, headline, title and label
  /// roles are out of its scope and are deliberately not touched: a row that
  /// says "Body" is not a licence to restyle the whole scale.
  static List<HabotTypeToken> get bodyTokens => <HabotTypeToken>[
        HabotTypography.bodyLarge,
        HabotTypography.bodyMedium,
        HabotTypography.bodySmall,
      ];

  /// The weight half of the requirement, which IS met.
  static bool get weightMatches =>
      bodyTokens.every((HabotTypeToken t) => t.weight == requestedWeight);

  /// The family half, which is not.
  static bool get familyMatches => bound.name == requested.name;

  /// Whether the requested family could be bound at all right now.
  ///
  /// **The precondition.** False while no asset is vendored -- binding a name
  /// with no glyphs behind it is a silent fallback, not a binding.
  static bool get canBind => requested.isAvailable;

  /// What would have to be true before the swap is safe. Named, because "add
  /// the font" is only the first of four.
  static const List<String> preconditions = <String>[
    'The Inter font files are vendored into the repository and declared in '
        'pubspec.yaml under a fonts: entry. Until then the family name '
        'resolves to a per-device platform default rather than to Inter.',
    'The Step 102 text-fit audit is re-run: every fit result in it was '
        'measured against Roboto metrics, and Inter is not metrically '
        'compatible with it.',
    'The Step 144 language-label budget is re-checked. Two labels were '
        'rejected against a 12-character button at Roboto widths; the '
        'accepted ones were accepted at those widths too.',
    'The Step 167 frozen-column widths are re-derived, since they are sized '
        'against label widths in the shipped type face.',
  ];

  /// The whole scale, for the record: the row is about body, and these are the
  /// roles a family change would ALSO move, none of which this row authorises.
  static List<String> get rolesOutsideThisRow => HabotTypography.all
      .map((HabotTypeToken t) => t.name)
      .where((String n) => !n.startsWith('body'))
      .toList();

  // ---- the row's metric ---------------------------------------------------

  /// Body Font Alignment. Floor, optimal and ceiling are all the same literal
  /// string, so this is a match or it is nothing.
  static String get observed => '${bound.name} $requestedWeight';

  static const String target = 'Inter 400';

  static bool get isAligned => familyMatches && weightMatches;

  static String get qualitativeOutput =>
      isAligned ? 'Complete' : 'Not Complete';

  /// The part of the requirement that IS satisfied, so the report is a
  /// measurement rather than a flat refusal.
  static Map<String, bool> get requirementParts => <String, bool>{
        'body tokens carry weight 400': weightMatches,
        'body tokens are bound to a family that will actually render':
            bound.isAvailable,
        'body tokens are bound to Inter': familyMatches,
        'the requested family is available to bind': canBind,
      };

  static double get alignmentRate {
    final Iterable<bool> v = requirementParts.values;
    return v.where((bool b) => b).length / v.length;
  }

  static const String conflictNote =
      'The row asks for Inter. Step 3 bound the body tokens to Roboto and '
      'recorded it as the platform-bundled Material type face with no asset '
      'to ship. The two are in direct conflict, and the conflict is the value '
      'of this step rather than something to resolve by editing one string.';

  static const String silentFallbackNote =
      'Inter is not a platform font on Android or iOS. Setting the family '
      'name without shipping the files does not produce Inter -- Flutter falls '
      'back to the platform default, which is Roboto on Android, San Francisco '
      'on iOS and something else on a manufacturer skin. The app would render '
      'in a font that varies by device, and nothing would fail.';

  static const String invalidatedMeasurementsNote =
      'Step 102 audits text fit at 200% scaling, Step 138 carries a 30% '
      'expansion factor for Welsh, Step 144 rejected two language labels '
      'against a 12-character button budget, and Step 167 sizes frozen '
      'columns against label widths. Every one of those is a claim about how '
      'wide a string is in a specific type face. A silent per-device '
      'substitution invalidates them all without failing anything.';

  static const String scopeNote =
      'The row says Body. Display, headline, title and label roles are '
      'deliberately untouched: a row about one part of the scale is not a '
      'licence to restyle the whole of it, and a half-migrated type scale is '
      'worse than either end of the migration.';

  static const String columnNote =
      'The Setup Step on this row names an API-gateway middleware. A font '
      'binding is a client-side typography concern with no gateway '
      'involvement. The Atomic Step is the unit of work.';
}
