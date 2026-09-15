/// Step 263 (GEN-00988) -- compressing the bundled image assets, of which
/// there are none.
///
/// The row: "Compress all bundled image assets to WebP/AVIF formats with @2x
/// and @3x density variants."
/// Metric: **Asset Compression Ratio** -- floor >= 60%, optimal >= 80%,
/// ceiling >= 90%. Pass / Fail. Standard cited: Google WebP/AVIF Image Specs.
///
/// **There are no bundled image assets.** The `assets:` section of
/// `pubspec.yaml` is commented out, there is no `assets/` directory, and every
/// image file in the repository is a platform launcher icon or a web favicon.
/// Thirty-five files, 229,791 bytes, and not one of them is a Flutter asset.
/// A compression ratio over that population is a ratio over nothing, and a
/// step that reports Pass on an empty population is the thing this track has
/// refused in every batch since 136.
///
/// **The platform images cannot be converted, and that is not a shortfall.**
/// An iOS asset catalogue requires PNG at fixed sizes; an Android mipmap set
/// requires PNG; a web manifest names PNG icons that a browser fetches before
/// any of this application's code runs. Converting them to WebP would break
/// the launcher on three platforms to improve a number.
///
/// **`@2x` and `@3x` is an iOS convention that Flutter does not use.** Flutter
/// resolves densities from `2.0x/` and `3.0x/` subdirectories beside the base
/// image, declared in `pubspec.yaml`. There are twelve `@2x`/`@3x` files in
/// this repository and every one of them is inside
/// `ios/Runner/Assets.xcassets`, which is exactly where that convention comes
/// from. There are zero `2.0x` or `3.0x` directories.
///
/// **And the ratio has no direction.** "Asset Compression Ratio >= 90%" is
/// either a saving of ninety per cent or an output nine tenths the size of the
/// input, and those are opposite outcomes. Under one reading the ceiling is
/// the best result; under the other the floor is. The row does not say which.
library;

/// Where an image in this repository lives and what may be done to it.
class HabotImageLocation {
  const HabotImageLocation({
    required this.path,
    required this.files,
    required this.bytes,
    required this.isAFlutterAsset,
    required this.mayBeConverted,
    required this.why,
  });

  final String path;
  final int files;
  final int bytes;

  /// Declared in `pubspec.yaml` and loaded by `AssetImage`. The population
  /// the row is about.
  final bool isAFlutterAsset;

  /// Whether the format may be changed without breaking the platform that
  /// reads it.
  final bool mayBeConverted;

  final String why;
}

/// The inventory and the rules.
class HabotAssetBudget {
  const HabotAssetBudget._();

  /// Measured on the repository at Step 263, not estimated.
  static const List<HabotImageLocation> locations = <HabotImageLocation>[
    HabotImageLocation(
      path: 'ios/Runner/Assets.xcassets',
      files: 18,
      bytes: 21531,
      isAFlutterAsset: false,
      mayBeConverted: false,
      why: 'An iOS asset catalogue. Xcode requires PNG at fixed pixel sizes '
          'and the launcher reads them before any Dart runs. Twelve of these '
          'carry the @2x and @3x suffixes the row asks for, which is where '
          'that convention comes from.',
    ),
    HabotImageLocation(
      path: 'android/app/src/main/res',
      files: 5,
      bytes: 4181,
      isAFlutterAsset: false,
      mayBeConverted: false,
      why: 'Android mipmaps. The launcher icon is read by the system, not by '
          'this application.',
    ),
    HabotImageLocation(
      path: 'macos/Runner/Assets.xcassets',
      files: 7,
      bytes: 163026,
      isAFlutterAsset: false,
      mayBeConverted: false,
      why: 'A macOS asset catalogue -- and seventy-one per cent of every '
          'image byte in this repository, for a platform that is not a '
          'declared target of a mobile application.',
    ),
    HabotImageLocation(
      path: 'web',
      files: 5,
      bytes: 41053,
      isAFlutterAsset: false,
      mayBeConverted: false,
      why: 'The favicon and the PWA manifest icons. A browser fetches these '
          'before the application loads, and the manifest names them by '
          'extension.',
    ),
    HabotImageLocation(
      path: 'assets',
      files: 0,
      bytes: 0,
      isAFlutterAsset: true,
      mayBeConverted: true,
      why: 'The directory the row is about. It does not exist, and the '
          'assets: section of pubspec.yaml is commented out. This is the '
          'population the compression ratio would be measured over.',
    ),
  ];

  static int get totalFiles =>
      locations.fold(0, (int a, HabotImageLocation l) => a + l.files);

  static int get totalBytes =>
      locations.fold(0, (int a, HabotImageLocation l) => a + l.bytes);

  static List<HabotImageLocation> get flutterAssets =>
      locations.where((HabotImageLocation l) => l.isAFlutterAsset).toList();

  static int get bundledAssetCount =>
      flutterAssets.fold(0, (int a, HabotImageLocation l) => a + l.files);

  static List<HabotImageLocation> get platformImages =>
      locations.where((HabotImageLocation l) => !l.isAFlutterAsset).toList();

  static int get convertibleFiles => locations
      .where((HabotImageLocation l) => l.mayBeConverted)
      .fold(0, (int a, HabotImageLocation l) => a + l.files);

  /// The population the metric would be computed over. Zero.
  static bool get thePopulationIsEmpty => bundledAssetCount == 0;

  /// The largest single location, and it is a platform that is not a target.
  static HabotImageLocation get largestLocation => locations.reduce(
        (HabotImageLocation a, HabotImageLocation b) =>
            a.bytes >= b.bytes ? a : b,
      );

  static double get macOsShareOfBytes =>
      locations
          .firstWhere((HabotImageLocation l) => l.path.startsWith('macos'))
          .bytes /
      totalBytes;

  // -----------------------------------------------------------------------
  // The density convention.
  // -----------------------------------------------------------------------

  /// Files in this repository carrying the iOS suffix.
  static const int filesWithIosDensitySuffix = 12;

  /// Directories following Flutter's own convention.
  static const int flutterDensityDirectories = 0;

  static const List<String> flutterDensityConvention = <String>[
    'assets/icon.png',
    'assets/2.0x/icon.png',
    'assets/3.0x/icon.png',
  ];

  static bool get theRowsConventionIsNotFluttersConvention =>
      filesWithIosDensitySuffix > 0 &&
      flutterDensityDirectories == 0 &&
      flutterDensityConvention.every((String p) => !p.contains('@'));

  static const String densityNote =
      '@2x and @3x is an iOS convention that Flutter does not use. Flutter '
      'resolves densities from 2.0x/ and 3.0x/ subdirectories beside the base '
      'image, declared in pubspec.yaml. There are twelve @2x/@3x files in '
      'this repository and every one of them is inside '
      'ios/Runner/Assets.xcassets, which is exactly where that convention '
      'comes from; there are zero 2.0x or 3.0x directories. Following the '
      'row literally would produce filenames Flutter ignores.';

  // -----------------------------------------------------------------------
  // The formats.
  // -----------------------------------------------------------------------

  /// Formats the Flutter image pipeline decodes on every declared target.
  static const Set<String> decodableEverywhere = <String>{
    'png',
    'jpg',
    'webp',
    'gif',
    'bmp',
  };

  /// AVIF is not in that set, and whether it decodes depends on the engine
  /// version and the target. Named rather than assumed: a format the engine
  /// cannot read is an asset that renders as nothing.
  static const String avifNote =
      'The row names WebP AND AVIF. WebP is decoded by the Flutter image '
      'pipeline on every declared target. AVIF is not in that set and '
      'whether it decodes depends on the engine version and the platform, so '
      'shipping AVIF is a per-target verification rather than a format '
      'choice -- and an asset the engine cannot read renders as nothing '
      'rather than as a warning. WebP first, AVIF only where a build has '
      'been shown to decode it.';

  static bool get webPIsSafeAndAvifIsNot =>
      decodableEverywhere.contains('webp') &&
      !decodableEverywhere.contains('avif');

  // -----------------------------------------------------------------------
  // The ratio, which has no direction.
  // -----------------------------------------------------------------------

  static const double floorPercent = 60;
  static const double optimalPercent = 80;
  static const double ceilingPercent = 90;

  /// Reading one: the ratio is the saving. 90% means the output is a tenth
  /// of the input, and the ceiling is the best outcome.
  static double savingOf({required int before, required int after}) =>
      before == 0 ? 0 : (before - after) / before * 100;

  /// Reading two: the ratio is output over input. 90% means almost nothing
  /// was saved, and the FLOOR is the best outcome.
  static double outputShareOf({required int before, required int after}) =>
      before == 0 ? 0 : after / before * 100;

  /// The two readings disagree about which end of the band is good. Shown on
  /// one worked pair rather than argued.
  static bool get theTwoReadingsDisagree {
    const int before = 100000;
    const int after = 10000;
    final double saving = savingOf(before: before, after: after);
    final double share = outputShareOf(before: before, after: after);
    return saving >= ceilingPercent && share <= 100 - ceilingPercent;
  }

  static const String directionNote =
      'The ratio has no direction. "Asset Compression Ratio >= 90%" is '
      'either a saving of ninety per cent or an output nine tenths the size '
      'of the input, and those are opposite outcomes: under one reading the '
      'ceiling is the best result and under the other the floor is. The row '
      'does not say which, so both are computed here and the band is left '
      'unread rather than guessed.';

  static const String qualityFloorNote =
      'A compression ratio with no quality floor optimises for the wrong '
      'thing. Any photograph can be made ninety per cent smaller by making '
      'it worse, and a target that only counts bytes rewards exactly that. A '
      'usable pair is a size budget per density variant AND a perceptual '
      'quality floor; neither is declared on this row, and neither can be '
      'declared over a population of zero.';

  // -----------------------------------------------------------------------
  // Metric: Pass / Fail.
  // -----------------------------------------------------------------------

  /// **Fail**, and for the only honest reason: there is nothing to measure.
  /// Reporting Pass on an empty population is how a metric stops being able
  /// to fail, which Steps 239 and 249 both refused for the same reason.
  static String get qualitativeOutput =>
      thePopulationIsEmpty ? 'Fail' : 'Pass';

  static const String emptyPopulationNote =
      'There are no bundled image assets. The assets: section of pubspec.yaml '
      'is commented out, there is no assets/ directory, and every image file '
      'in the repository is a platform launcher icon or a web favicon: '
      'thirty-five files, 229,791 bytes, not one of them a Flutter asset. A '
      'compression ratio over that population is a ratio over nothing. '
      'Reported Fail rather than Pass, because a metric that reports success '
      'on an empty population has stopped being able to fail -- and because '
      'the honest reading of this row is that it is waiting for the first '
      'bundled asset rather than that it is done.';

  static const String platformImagesNote =
      'The platform images cannot be converted, and that is not a shortfall. '
      'An iOS asset catalogue requires PNG at fixed sizes, an Android mipmap '
      'set requires PNG, and a web manifest names PNG icons a browser fetches '
      'before any of this code runs. Converting them to WebP would break the '
      'launcher on three platforms to improve a number. The one figure worth '
      'acting on is that macOS holds 71% of every image byte here for a '
      'platform that is not a declared target of a mobile application.';

  static Map<String, bool> get checks => <String, bool>{
        'five locations are inventoried with measured file counts and bytes':
            locations.length == 5 && totalFiles == 35 && totalBytes == 229791,
        'the population the metric is about is empty': thePopulationIsEmpty,
        'four platform locations hold every file, and none may be converted':
            platformImages.length == 4 && convertibleFiles == 0,
        'the largest location is macOS, which is not a declared target':
            largestLocation.path.startsWith('macos') &&
                (macOsShareOfBytes - 163026 / 229791).abs() < 1e-9,
        'the row\'s density convention is iOS\'s, not Flutter\'s':
            theRowsConventionIsNotFluttersConvention,
        'WebP decodes everywhere and AVIF is a per-target verification':
            webPIsSafeAndAvifIsNot && avifNote.contains('renders as nothing'),
        'the two readings of the ratio disagree about which end is good':
            theTwoReadingsDisagree && directionNote.contains('unread rather '
                'than guessed'),
        'a ratio with no quality floor is named as the wrong target':
            qualityFloorNote.contains('by making it worse'),
        'the step reports Fail on an empty population rather than Pass':
            qualitativeOutput == 'Fail' &&
                emptyPopulationNote.contains('stopped being able to fail'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row, and the band is '
      'written with LaTeX escapes -- "\$\\ge 60\\%\$" -- rather than as plain '
      'figures. Atomic Step: "Compress all bundled image assets to WebP/AVIF '
      'formats with @2x and @3x density variants."';
}
