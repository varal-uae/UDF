/// AISS Step 176 -- GEN-03182
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Initialize a new NPM package directory named
///               @habot/design-tokens."
/// Metric: Package Initialisation Speed -- Floor "< 5s", Optimal "< 1s",
///         Ceiling "10s". Complete.
/// Common Library to Store: "@habot/shared-library".
///
/// **THE ROW NAMES AN NPM PACKAGE, AND THIS IS A FLUTTER APP.** NPM is
/// JavaScript's registry; a Flutter app's package manager is pub and its unit
/// of distribution is a Dart package. There is also no network on this build
/// host, so nothing could be published from here even if the ecosystem
/// matched. What IS buildable, and is the part that actually matters, is the
/// **manifest**: what the token package contains, what its public surface is,
/// where each family may be declared, and the rule that a token declared
/// anywhere else is not part of the package.
///
/// **"PACKAGE INITIALISATION SPEED" MEASURED AS `npm init` IS A MEASUREMENT OF
/// A DISK WRITE.** It is under a second on every machine ever built and tells
/// nobody anything. The reading that carries weight on a phone is the one the
/// number is actually about: **what it costs to have the token set available
/// when the first frame is built.** A token set of compile-time constants costs
/// nothing -- the values are in the binary. A token set that has to be computed
/// at startup is spending the Step 165 cold-start budget before a pixel is
/// drawn.
///
/// **AND THAT IS WHERE THE FINDING IS.** Every token family in this repository
/// is `const` and therefore free. The THEME ADAPTER is not: `HabotTheme`
/// builds its `ColorScheme` with `ColorScheme.fromSeed`, which runs the MD3
/// tonal-palette algorithm on every construction, on the cold-start path, to
/// produce roles that are then overridden one by one with the exact brand
/// tokens. The computed values are discarded. That cost is recorded here with
/// what it buys ([seedFallbackRationale]) rather than reported as zero.
library;

/// One family of tokens, and the single file allowed to declare it.
class HabotTokenFamily {
  const HabotTokenFamily({
    required this.name,
    required this.declarationSite,
    required this.surface,
    required this.isConstDeclared,
    required this.purpose,
  });

  final String name;

  /// The one file where a value of this family may be written down. This is
  /// the same list the poka-yoke guard exempts -- deliberately, because two
  /// lists would drift and the guard's copy is the one that fails the build.
  final String declarationSite;

  /// The type callers reach for.
  final String surface;

  /// Whether every value in the family is a compile-time constant, and so
  /// costs nothing at startup.
  final bool isConstDeclared;

  final String purpose;
}

/// The token package, declared.
class HabotTokenPackage {
  const HabotTokenPackage._();

  /// What this would be called on pub. Not `@habot/design-tokens`: that is an
  /// NPM scope, and a Dart package name may not contain `@` or `/`.
  static const String packageName = 'habot_design_tokens';

  /// The name the row gives, kept so the substitution is traceable from either
  /// direction.
  static const String requestedName = '@habot/design-tokens';

  static const String ecosystem = 'pub (Dart), not npm (JavaScript)';

  /// Version of the token surface, not of the app. Bumped when a token is
  /// added, removed or re-valued -- because a consumer pinning this is pinning
  /// the look of the product.
  static const String version = '0.1.0';

  /// Where it lives today: inside the app, not beside it. Extracting it is a
  /// real step and is recorded as not done rather than implied.
  static const String currentLocation = 'lib/design_system/tokens';

  static const List<HabotTokenFamily> families = <HabotTokenFamily>[
    HabotTokenFamily(
      name: 'color',
      declarationSite: 'lib/design_system/tokens/color_tokens.dart',
      surface: 'HabotColors / HabotColorScheme',
      isConstDeclared: true,
      purpose: 'The 28 audited MD3 colour roles, per scheme.',
    ),
    HabotTokenFamily(
      name: 'color.highContrast',
      declarationSite: 'lib/design_system/tokens/high_contrast_tokens.dart',
      surface: 'HabotHighContrast',
      isConstDeclared: true,
      purpose: 'The same roles at the AAA floor, for the high-contrast '
          'schemes. A separate family because it is audited against a '
          'different threshold, not because it is a different kind of thing.',
    ),
    HabotTokenFamily(
      name: 'typography',
      declarationSite: 'lib/design_system/tokens/typography_tokens.dart',
      surface: 'HabotTypography / HabotTypeToken',
      isConstDeclared: true,
      purpose: 'The 15 MD3 type roles with size, line height, weight and '
          'tracking.',
    ),
    HabotTokenFamily(
      name: 'spacing',
      declarationSite: 'lib/design_system/tokens/spacing_tokens.dart',
      surface: 'HabotSpacing / HabotDensity',
      isConstDeclared: true,
      purpose: 'The spacing scale and the density figures derived from it.',
    ),
    HabotTokenFamily(
      name: 'shape',
      declarationSite: 'lib/design_system/tokens/shape_tokens.dart',
      surface: 'HabotShape',
      isConstDeclared: true,
      purpose: 'Corner radii and border widths.',
    ),
    HabotTokenFamily(
      name: 'elevation',
      declarationSite: 'lib/design_system/tokens/elevation_tokens.dart',
      surface: 'HabotElevation',
      isConstDeclared: true,
      purpose: 'The six MD3 elevation levels and the dark surface ladder they '
          'imply.',
    ),
    HabotTokenFamily(
      name: 'grid',
      declarationSite: 'lib/design_system/tokens/grid_tokens.dart',
      surface: 'HabotGrid',
      isConstDeclared: true,
      purpose: 'Breakpoints, column counts, margins and gutters.',
    ),
    HabotTokenFamily(
      name: 'motion',
      declarationSite: 'lib/design_system/tokens/motion_tokens.dart',
      surface: 'HabotMotion / HabotEasing',
      isConstDeclared: true,
      purpose: 'Durations, curves and the latency bands the metrics are '
          'banded against.',
    ),
  ];

  static HabotTokenFamily? familyNamed(String name) {
    for (final HabotTokenFamily f in families) {
      if (f.name == name) {
        return f;
      }
    }
    return null;
  }

  /// The files a token may be written down in. Anything outside this set is a
  /// value somebody typed into a widget.
  static Set<String> get declarationSites =>
      families.map((HabotTokenFamily f) => f.declarationSite).toSet();

  static bool isDeclarationSite(String path) =>
      declarationSites.contains(path);

  // ---- the row's metric, read ---------------------------------------------

  /// **The reading.** Not "how long does `npm init` take" -- that is a disk
  /// write -- but "what does having the token set available cost at startup".
  ///
  /// True when every family is const-declared, which makes the answer zero:
  /// the values are compiled into the binary and there is nothing to
  /// initialise.
  static bool get initialisesFree =>
      families.every((HabotTokenFamily f) => f.isConstDeclared);

  static int get constFamilies =>
      families.where((HabotTokenFamily f) => f.isConstDeclared).length;

  /// Work that DOES happen at startup, named. Empty would be the ideal; it is
  /// not empty, and the entry says what it costs and what it buys.
  static const Map<String, String> startupWork = <String, String>{
    'HabotTheme.ColorScheme.fromSeed':
        'The theme adapter runs the MD3 tonal-palette algorithm from '
            'HabotColors.seedPrimary on every ThemeData construction, then '
            'overrides all 28 audited roles with the exact brand tokens -- so '
            'the computed values are discarded. It runs on the cold-start '
            'path, inside the Step 165 budget. It is kept for the reason in '
            'seedFallbackRationale, and it is the only non-constant cost in '
            'the token path.',
  };

  static const String seedFallbackRationale =
      'fromSeed is kept because a role this project has NOT pinned still '
      'resolves to a valid Material value rather than to null or to a Material '
      'default nobody chose. The 28 pinned roles are what the contrast audit '
      'gates; the unpinned remainder is what fromSeed covers. Dropping it '
      'would save the startup cost and would make every unpinned role a '
      'silent framework default -- which is the defect Step 174 MISSING_ROLE '
      'exists to catch, moved somewhere nothing can see it.';

  static const String npmSubstitution =
      'The row names an NPM package. NPM is JavaScript\'s registry; a Flutter '
      'app\'s package manager is pub and its unit of distribution is a Dart '
      'package, which may not contain "@" or "/" in its name. There is also no '
      'network on this build host. What is built is the manifest -- what the '
      'package contains, what its public surface is, and where each family may '
      'be declared -- because that is the half that decides whether a token '
      'set is a package or a folder.';

  static const String speedReadingNote =
      '"Package Initialisation Speed" measured as npm init is a measurement of '
      'a disk write: under a second on every machine ever built, and it tells '
      'nobody anything. The reading that carries weight on a phone is what it '
      'costs to have the token set available when the first frame is built. '
      'Constants cost nothing. Anything computed at startup is spending the '
      'Step 165 cold-start budget before a pixel is drawn.';

  static const String notExtractedNote =
      'The package lives inside the app today rather than beside it. '
      'Extracting it into its own pub package is a real piece of work -- a '
      'second pubspec, a version policy, and a consumer that can lag -- and it '
      'is recorded as not done rather than implied by the existence of this '
      'manifest.';
}
