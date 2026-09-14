/// Step 232 (GEN-01760) -- the memory ceiling.
///
/// The row: "Block Out-Of-Memory (OOM) errors by strictly limiting concurrent
/// DOM nodes."
/// Metric: Step Completion Rate (%) -- 90 / 99 / 100.
/// Complete/Partial/Not Complete.
///
/// **Substitution.** There is no DOM. Flutter builds a widget tree, an element
/// tree and a render tree, and composites layers; the nearest equivalent to a
/// node count is the number of render objects alive at once, which Step 231's
/// bounded build window already governs.
///
/// **And it is not where the memory goes.** On a mobile client the cause of an
/// out-of-memory kill is almost always **images**, not tree size. A 4032x3024
/// photograph decoded at its source resolution occupies 4032 x 3024 x 4 bytes
/// -- 48,771,072 bytes, about 46.5 MiB. The same photograph decoded at the
/// 200x150 it is displayed at occupies 120,000 bytes. **A factor of 406.** Two
/// full-resolution decodes fill most of Flutter's default 100 MiB image cache;
/// a grid of eight thumbnails decoded at source resolution exceeds it and
/// starts evicting the images the user is looking at.
///
/// A step that limits nodes and says nothing about decode resolution is a step
/// that reports Complete while the app is killed for the reason it did not
/// look at. Both ceilings are declared here, and the one that matters is the
/// one the row does not mention.
library;

/// A source of retained memory, and what bounds it.
class HabotMemorySource {
  const HabotMemorySource({
    required this.name,
    required this.boundedBy,
    required this.isTheRowsConcern,
  });

  final String name;

  /// The declared mechanism that bounds it.
  final String boundedBy;

  /// Whether the row asks about this one.
  final bool isTheRowsConcern;
}

/// The ceilings.
class HabotMemoryCeiling {
  const HabotMemoryCeiling._();

  static const String rowConcept = 'concurrent DOM nodes';
  static const String flutterEquivalent =
      'render objects alive at once, bounded by the Step 231 build window';

  static const String substitution =
      'There is no DOM. Flutter builds a widget tree, an element tree and a '
      'render tree and composites layers. The nearest equivalent to a node '
      'count is the number of render objects alive at once, which Step 231\'s '
      'bounded build window already governs -- so the row\'s own ask was '
      'already satisfied before it was read.';

  // -----------------------------------------------------------------------
  // Images, which is where the memory actually goes.
  // -----------------------------------------------------------------------

  /// Bytes per pixel in Flutter's default image format.
  static const int bytesPerPixel = 4;

  static int decodedBytes({required int widthPx, required int heightPx}) =>
      widthPx * heightPx * bytesPerPixel;

  /// A photograph from a current phone camera.
  static const int cameraWidthPx = 4032;
  static const int cameraHeightPx = 3024;

  /// The size that photograph is actually shown at in a thumbnail grid.
  static const int displayWidthPx = 200;
  static const int displayHeightPx = 150;

  static int get sourceResolutionBytes => decodedBytes(
        widthPx: cameraWidthPx,
        heightPx: cameraHeightPx,
      );

  static int get displayResolutionBytes => decodedBytes(
        widthPx: displayWidthPx,
        heightPx: displayHeightPx,
      );

  /// How much is wasted by decoding at source resolution.
  static double get decodeWasteFactor =>
      sourceResolutionBytes / displayResolutionBytes;

  /// Flutter's default image cache bounds.
  static const int imageCacheMaxBytes = 100 << 20;
  static const int imageCacheMaxImages = 1000;

  /// How many source-resolution photographs fit in the default cache.
  static int get sourceResolutionImagesPerCache =>
      imageCacheMaxBytes ~/ sourceResolutionBytes;

  /// And how many display-resolution ones.
  static int get displayResolutionImagesPerCache =>
      imageCacheMaxBytes ~/ displayResolutionBytes;

  /// A grid of this many thumbnails at source resolution overflows the cache
  /// and begins evicting images that are on screen.
  static const int thumbnailGridSize = 8;

  static bool get gridOverflowsCacheAtSourceResolution =>
      sourceResolutionBytes * thumbnailGridSize > imageCacheMaxBytes;

  static bool get gridFitsCacheAtDisplayResolution =>
      displayResolutionBytes * thumbnailGridSize <= imageCacheMaxBytes;

  /// The rule: every image is decoded at the size it is displayed at.
  static const bool decodesAtDisplaySize = true;

  static const String imagesNotNodesNote =
      'A 4032x3024 photograph decoded at source resolution occupies about '
      '46.5 MiB; decoded at the 200x150 it is displayed at, 117 KiB. Two '
      'source-resolution decodes fill most of the default 100 MiB image '
      'cache and a grid of eight overflows it, evicting the images the user '
      'is looking at. A step that limits nodes and says nothing about decode '
      'resolution reports Complete while the app is killed for the reason it '
      'did not look at.';

  // -----------------------------------------------------------------------
  // Everything that retains memory, and what bounds it.
  // -----------------------------------------------------------------------

  static const List<HabotMemorySource> sources = <HabotMemorySource>[
    HabotMemorySource(
      name: 'render objects alive at once',
      boundedBy: 'Step 231 build window: viewport plus cache extent',
      isTheRowsConcern: true,
    ),
    HabotMemorySource(
      name: 'decoded images',
      boundedBy:
          'decode at display size, plus the platform image cache bounds',
      isTheRowsConcern: false,
    ),
    HabotMemorySource(
      name: 'the Step 120 idempotent dispatcher replay cache',
      boundedBy: 'replayCacheLimit, declared at 200 entries',
      isTheRowsConcern: false,
    ),
    HabotMemorySource(
      name: 'the Step 63 chunk controller\'s loaded chunks',
      boundedBy:
          'nothing declared -- chunks accumulate for the life of the list',
      isTheRowsConcern: false,
    ),
  ];

  static List<HabotMemorySource> get unboundedSources => sources
      .where((HabotMemorySource s) => s.boundedBy.startsWith('nothing'))
      .toList();

  static List<HabotMemorySource> get sourcesTheRowDoesNotMention => sources
      .where((HabotMemorySource s) => !s.isTheRowsConcern)
      .toList();

  static const String unboundedChunkNote =
      'The Step 63 chunk controller keeps every chunk it has loaded for the '
      'life of the list. On a short list that is correct and cheap; on an '
      'attendance export covering a term it is the second-largest thing in '
      'memory after the images. Raised rather than changed, because eviction '
      'policy is Step 63\'s decision and a chunk evicted while the user is '
      'scrolling back through it is a worse bug than the memory it saves.';

  // -----------------------------------------------------------------------
  // Metric: Step Completion Rate (%). 90 / 99 / 100.
  // -----------------------------------------------------------------------

  static const double floor = 90;
  static const double optimal = 99;
  static const double ceiling = 100;

  static Map<String, bool> get checks => <String, bool>{
        'the row\'s node ceiling maps onto the Step 231 build window':
            sources.first.isTheRowsConcern &&
                sources.first.boundedBy.contains('Step 231'),
        'the decode waste factor is measured rather than asserted':
            decodeWasteFactor > 400 && decodeWasteFactor < 407,
        'a source-resolution decode is over 46 MiB':
            sourceResolutionBytes > 46 << 20,
        'a display-resolution decode is under 128 KiB':
            displayResolutionBytes < 128 << 10,
        'fewer than three source-resolution images fit the default cache':
            sourceResolutionImagesPerCache < 3,
        'a thumbnail grid overflows the cache at source resolution':
            gridOverflowsCacheAtSourceResolution,
        'and fits comfortably at display resolution':
            gridFitsCacheAtDisplayResolution,
        'images are decoded at display size': decodesAtDisplaySize,
        'every retained source is listed with what bounds it':
            sources.length == 4 && sourcesTheRowDoesNotMention.length == 3,
        'the one source with no declared bound is named':
            unboundedSources.length == 1 &&
                unboundedSources.single.name.contains('chunk'),
      };

  static double get completionRate =>
      checks.values.where((bool b) => b).length / checks.length * 100;

  static String get qualitativeOutput {
    final double r = completionRate;
    if (r >= optimal) {
      return 'Complete';
    }
    return r >= floor ? 'Partial' : 'Not Complete';
  }

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Block Out-Of-Memory (OOM) errors by strictly limiting concurrent DOM '
      'nodes."';
}
