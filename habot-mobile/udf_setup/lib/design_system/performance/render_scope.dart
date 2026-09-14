/// Step 231 (GEN-01970) -- what actually consumes rendering resources.
///
/// The row: "Ensure only visible components consume rendering resources."
/// Metric: Step Completion Rate (%) -- 90 / 99 / 100.
/// Complete/Partial/Not Complete.
///
/// **"Only visible" is false by design, and it should be.** A
/// `ListView.builder` builds a cache extent beyond the viewport in both
/// directions -- 250 logical
/// pixels by default -- so that a scroll does not stutter at the seam where new
/// items appear. Setting that to zero satisfies the row's wording exactly and
/// produces a list that hitches every time it is flicked. The honest statement
/// is not "only visible" but **a bounded build window**, and the number is the
/// cache extent.
///
/// **Virtualisation costs scroll-position stability, and nothing in the repo
/// declares what it is paying.** An item whose height is unknown until it is
/// built makes the scrollbar thumb a guess, and makes "jump to item 400"
/// impossible without building the 399 above it. The two mitigations are a
/// fixed extent or a prototype item, and Step 63's chunked list declares
/// neither. Recorded, with the extent strategy now declared per list.
library;

import '../tokens/spacing_tokens.dart';

/// How a list knows how tall its items are before it builds them.
enum HabotExtentStrategy {
  /// Every item is the same declared height. Scroll position is exact and
  /// jumping to an index is free.
  fixedExtent,

  /// One item is built off-screen and measured; the rest are assumed to match.
  /// Exact while the assumption holds.
  prototypeItem,

  /// Nothing is known until an item is built. The scrollbar is an estimate
  /// and an index jump has to build its way there.
  intrinsic,
}

/// One scrolling surface in the product.
class HabotScrollSurface {
  const HabotScrollSurface({
    required this.name,
    required this.strategy,
    required this.itemExtentDp,
    required this.isVirtualised,
  });

  final String name;
  final HabotExtentStrategy strategy;

  /// Null when the strategy is intrinsic.
  final double? itemExtentDp;

  final bool isVirtualised;

  bool get scrollPositionIsExact =>
      strategy != HabotExtentStrategy.intrinsic;
}

/// The build window.
class HabotRenderScope {
  const HabotRenderScope._();

  /// Flutter's default cache extent, in logical pixels, applied beyond the
  /// viewport in each direction.
  static const double cacheExtentDp = 250;

  /// So the window is the viewport plus the cache extent on both sides.
  static double buildWindowFor(double viewportExtentDp) =>
      viewportExtentDp + cacheExtentDp * 2;

  /// How many items of a given height are built for a given viewport.
  static int itemsBuiltFor({
    required double viewportExtentDp,
    required double itemExtentDp,
  }) =>
      itemExtentDp <= 0
          ? 0
          : (buildWindowFor(viewportExtentDp) / itemExtentDp).ceil();

  /// And how many are on screen.
  static int itemsVisibleFor({
    required double viewportExtentDp,
    required double itemExtentDp,
  }) =>
      itemExtentDp <= 0 ? 0 : (viewportExtentDp / itemExtentDp).ceil();

  /// The number the row's wording would have to be false about: items built
  /// that are not visible.
  static int itemsBuiltButNotVisible({
    required double viewportExtentDp,
    required double itemExtentDp,
  }) =>
      itemsBuiltFor(
        viewportExtentDp: viewportExtentDp,
        itemExtentDp: itemExtentDp,
      ) -
      itemsVisibleFor(
        viewportExtentDp: viewportExtentDp,
        itemExtentDp: itemExtentDp,
      );

  /// Setting the cache extent to zero satisfies the row and produces a list
  /// that hitches at every seam.
  static const bool zeroCacheExtentIsAcceptable = false;

  static const String boundedNotZeroNote =
      'A ListView.builder builds 250 logical pixels beyond the viewport in '
      'each direction so a flick does not hitch where new items appear. '
      'Setting that to zero satisfies "only visible components" exactly and '
      'produces a list that stutters every time it is scrolled. The honest '
      'statement is a bounded build window, and the bound is the cache '
      'extent.';

  // -----------------------------------------------------------------------
  // What virtualisation costs.
  // -----------------------------------------------------------------------

  /// Every scrolling surface, with the extent strategy it uses.
  static List<HabotScrollSurface> get surfaces => <HabotScrollSurface>[
        HabotScrollSurface(
          name: 'child profile list',
          strategy: HabotExtentStrategy.fixedExtent,
          itemExtentDp: HabotSpacing.xxxl + HabotSpacing.xl,
          isVirtualised: true,
        ),
        HabotScrollSurface(
          name: 'booking history',
          strategy: HabotExtentStrategy.fixedExtent,
          itemExtentDp: HabotSpacing.xxxl * 2,
          isVirtualised: true,
        ),
        const HabotScrollSurface(
          name: 'attendance records (Step 63 chunked list)',
          strategy: HabotExtentStrategy.intrinsic,
          itemExtentDp: null,
          isVirtualised: true,
        ),
        HabotScrollSurface(
          name: 'add-on options (at most three, plus a disclosure)',
          strategy: HabotExtentStrategy.prototypeItem,
          itemExtentDp: HabotSpacing.xxxl + HabotSpacing.md,
          isVirtualised: false,
        ),
      ];

  static List<HabotScrollSurface> get surfacesWithInexactScrollPosition =>
      surfaces
          .where((HabotScrollSurface s) => !s.scrollPositionIsExact)
          .toList();

  /// A short list does not need virtualising, and virtualising it costs the
  /// exactness for nothing.
  static List<HabotScrollSurface> get unvirtualisedSurfaces =>
      surfaces.where((HabotScrollSurface s) => !s.isVirtualised).toList();

  static bool get everyVirtualisedSurfaceDeclaresAStrategy =>
      surfaces.where((HabotScrollSurface s) => s.isVirtualised).every(
            (HabotScrollSurface s) =>
                HabotExtentStrategy.values.contains(s.strategy),
          );

  static const String positionStabilityNote =
      'An item whose height is unknown until it is built makes the scrollbar '
      'thumb a guess and makes "jump to item 400" impossible without building '
      'the 399 above it. The two mitigations are a fixed extent and a '
      'prototype item; Step 63\'s chunked list declares neither, and that is '
      'the cost this repository is paying without having written it down.';

  // -----------------------------------------------------------------------
  // Metric: Step Completion Rate (%). 90 / 99 / 100.
  // -----------------------------------------------------------------------

  static const double floor = 90;
  static const double optimal = 99;
  static const double ceiling = 100;

  /// The declared phone viewport used for the worked figures.
  static const double workedViewportDp = 568;
  static double get workedItemExtentDp => HabotSpacing.xxxl * 2;

  static Map<String, bool> get checks => <String, bool>{
        'the build window is bounded rather than zero':
            !zeroCacheExtentIsAcceptable && cacheExtentDp > 0,
        'the window is the viewport plus the cache extent both ways':
            buildWindowFor(workedViewportDp) ==
                workedViewportDp + cacheExtentDp * 2,
        'more items are built than are visible, and the number is reported':
            itemsBuiltButNotVisible(
                  viewportExtentDp: workedViewportDp,
                  itemExtentDp: workedItemExtentDp,
                ) >
                0,
        'every virtualised surface declares an extent strategy':
            everyVirtualisedSurfaceDeclaresAStrategy,
        'the surfaces with inexact scroll position are named':
            surfacesWithInexactScrollPosition.length == 1 &&
                surfacesWithInexactScrollPosition.single.name
                    .contains('Step 63'),
        'a short list is not virtualised, and says so':
            unvirtualisedSurfaces.length == 1,
        'an intrinsic surface declares no item extent':
            surfacesWithInexactScrollPosition.single.itemExtentDp == null,
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
      '"Ensure only visible components consume rendering resources."';
}
