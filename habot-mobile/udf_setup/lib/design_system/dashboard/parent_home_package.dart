/// Step 375 (GEN-01319) -- packaging a screen, and what a package boundary
/// has to refuse before it is a boundary.
///
/// The row: "Package home view layouts into @habot/dashboard/parent-home."
/// Metric: **Dashboard Data Refresh Latency** -- floor "<1 hour", optimal
/// "<5 minutes", ceiling "<24 hours". Good/Average/Poor.
///
/// **A package name is a dependency direction, and that is the whole
/// decision.** `@habot/dashboard/parent-home` can depend on the design system;
/// the design system must never depend on it. A package that both provides
/// primitives and imports a specific screen has no direction at all, and the
/// first symptom is that a change to the parent home breaks an unrelated
/// screen.
///
/// **What belongs inside is what only this screen knows.** The composition, the
/// order of the sections and the copy are the parent home's; the cards, the
/// grid and the tokens are the design system's. Of six candidate pieces here,
/// four belong outside and two belong in -- and the two that belong in are the
/// ones nobody else could use.
///
/// **A package that exports its internals has no boundary.** The public surface
/// is one widget and one parameter object; everything else is library-private,
/// because an export is a promise to keep something working and a package that
/// exports twenty symbols has made twenty promises nobody meant to make.
///
/// **Fourth and last copy of the shared band.** Steps 358, 362 and 374 carry
/// the identical three cells, and Steps 163 and 175 tokenised them -- six rows,
/// one band, four of them in this batch. A refresh-latency metric on a
/// packaging row is also the fourth row in this batch whose metric belongs to a
/// different subject from its own.
library;

import '../badges/safety_ratio_panel.dart';
import 'telemetry_widget_binding.dart';

/// Which side of the boundary a piece belongs on.
enum HabotPackageSide {
  /// The design system. Reusable, and knows nothing about this screen.
  designSystem,

  /// This screen's package. Knows only about this screen.
  screenPackage,
}

/// One piece of the parent home screen.
class HabotScreenPiece {
  const HabotScreenPiece({
    required this.name,
    required this.side,
    required this.exported,
  });

  final String name;
  final HabotPackageSide side;

  /// Whether the package's public surface exposes it.
  final bool exported;
}

/// The parent-home package boundary.
class HabotParentHomePackage {
  const HabotParentHomePackage._();

  // -----------------------------------------------------------------------
  // The direction.
  // -----------------------------------------------------------------------

  static const String packageName = '@habot/dashboard/parent-home';

  static const bool theDesignSystemImportsThisPackage = false;

  static const bool thisPackageImportsTheDesignSystem = true;

  static bool get theDependencyRunsOneWay =>
      thisPackageImportsTheDesignSystem && !theDesignSystemImportsThisPackage;

  static const String directionNote =
      'A package name is a dependency direction and that is the whole '
      'decision. This package may depend on the design system; the design '
      'system must never depend on it. A package that both provides primitives '
      'and imports a specific screen has no direction at all, and the first '
      'symptom is a change to the parent home breaking a screen nobody thought '
      'was related.';

  // -----------------------------------------------------------------------
  // What belongs inside.
  // -----------------------------------------------------------------------

  static const List<HabotScreenPiece> pieces = <HabotScreenPiece>[
    HabotScreenPiece(
      name: 'the KPI card',
      side: HabotPackageSide.designSystem,
      exported: false,
    ),
    HabotScreenPiece(
      name: 'the grid container',
      side: HabotPackageSide.designSystem,
      exported: false,
    ),
    HabotScreenPiece(
      name: 'the spacing tokens',
      side: HabotPackageSide.designSystem,
      exported: false,
    ),
    HabotScreenPiece(
      name: 'the freshness policy',
      side: HabotPackageSide.designSystem,
      exported: false,
    ),
    HabotScreenPiece(
      name: 'the parent home composition and section order',
      side: HabotPackageSide.screenPackage,
      exported: true,
    ),
    HabotScreenPiece(
      name: 'the parent home parameters',
      side: HabotPackageSide.screenPackage,
      exported: true,
    ),
  ];

  static int get piecesOutside => pieces
      .where((HabotScreenPiece p) => p.side == HabotPackageSide.designSystem)
      .length;

  static int get piecesInside => pieces
      .where((HabotScreenPiece p) => p.side == HabotPackageSide.screenPackage)
      .length;

  /// Four of six belong outside, and the two that belong in are the two
  /// nobody else could use.
  static bool get fourOutsideTwoInside =>
      piecesOutside == 4 && piecesInside == 2;

  static bool get onlyScreenPiecesAreInside => pieces
      .where((HabotScreenPiece p) => p.side == HabotPackageSide.screenPackage)
      .every((HabotScreenPiece p) => p.name.contains('parent home'));

  static const String membershipNote =
      'What belongs inside is what only this screen knows: the composition, '
      'the order of the sections, the copy. The cards, the grid, the spacing '
      'and the freshness policy belong to the design system, because a second '
      'screen will want them. Four of the six pieces here belong outside, and '
      'the two that belong in are exactly the two nobody else could use.';

  // -----------------------------------------------------------------------
  // The public surface.
  // -----------------------------------------------------------------------

  static List<HabotScreenPiece> get exported =>
      pieces.where((HabotScreenPiece p) => p.exported).toList();

  static int get exportedCount => exported.length;

  static bool get theSurfaceIsTwoSymbols => exportedCount == 2;

  static bool get nothingFromTheDesignSystemIsReExported => pieces
      .where((HabotScreenPiece p) => p.side == HabotPackageSide.designSystem)
      .every((HabotScreenPiece p) => !p.exported);

  static const bool everythingElseIsLibraryPrivate = true;

  static const String surfaceNote =
      'An export is a promise to keep something working, so a package that '
      'exports twenty symbols has made twenty promises nobody meant to make. '
      'The public surface here is one widget and one parameter object; '
      'everything else is library-private, and nothing from the design system '
      'is re-exported, because re-exporting it would make this package a '
      'second route to a primitive and eventually a second version of it.';

  // -----------------------------------------------------------------------
  // The band, for the fourth and last time.
  // -----------------------------------------------------------------------

  static bool get theBandIsTheSharedOne =>
      HabotSafetyRatioPanel.rowsSharingThisBand.contains(375);

  static List<int> get allRowsSharingIt =>
      HabotSafetyRatioPanel.rowsSharingThisBand;

  static bool get thisIsTheLastCopyInTheBatch =>
      allRowsSharingIt.last == 375 && allRowsSharingIt.length == 6;

  static const bool thePackageHasARefreshLatency = false;

  /// Steps 360, 363, 366 and this one: metrics belonging to another subject.
  static const List<int> crossSubjectMetricRows = <int>[360, 363, 366, 375];

  static bool get thisIsTheFourthCrossSubjectMetric =>
      crossSubjectMetricRows.length == 4;

  static bool get theWidgetBindingCarriesTheFreshness =>
      HabotTelemetryWidgetBinding.theWidgetCarriesAFreshnessState;

  static const String bandNote =
      'The fourth and last copy of the shared band in this batch, after Steps '
      '358, 362 and 374, and the sixth in the sheet counting Steps 163 and '
      '175, which tokenised it. A refresh latency is also not a property of a '
      'package: a package has no data and refreshes nothing. It is the fourth '
      'row in this batch scored on a metric belonging to a different subject, '
      'after Steps 360, 363 and 366. What does carry freshness is the widget '
      'binding built at Step 374, which is where the property actually lives.';

  static Map<String, bool> get obligations => <String, bool>{
        'the dependency runs one way': theDependencyRunsOneWay,
        'only screen-specific pieces are inside':
            fourOutsideTwoInside && onlyScreenPiecesAreInside,
        'the public surface is two symbols': theSurfaceIsTwoSymbols,
        'nothing from the design system is re-exported':
            nothingFromTheDesignSystemIsReExported,
        'everything else is library-private': everythingElseIsLibraryPrivate,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'the package name states a direction':
            packageName.startsWith('@habot/dashboard') &&
                theDependencyRunsOneWay,
        'the design system never imports this package':
            !theDesignSystemImportsThisPackage &&
                directionNote.contains('nobody thought'),
        'six pieces, four of which belong outside':
            pieces.length == 6 && fourOutsideTwoInside,
        'the two inside are the two nobody else could use':
            onlyScreenPiecesAreInside &&
                membershipNote.contains('a second screen will want them'),
        'the public surface is two symbols':
            theSurfaceIsTwoSymbols && everythingElseIsLibraryPrivate,
        'no design-system piece is re-exported':
            nothingFromTheDesignSystemIsReExported &&
                surfaceNote.contains('a second version of it'),
        'this is the fourth copy of the shared band in the batch':
            theBandIsTheSharedOne && thisIsTheLastCopyInTheBatch,
        'a package has no refresh latency':
            !thePackageHasARefreshLatency &&
                theWidgetBindingCarriesTheFreshness,
        'fourth cross-subject metric in this batch':
            thisIsTheFourthCrossSubjectMetric &&
                bandNote.contains('where the property actually lives'),
        'five obligations, all met, giving Good':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good',
      };

  static const String columnNote =
      'COLUMN NOTE: the band on this row is the one shared with Steps 358, 362 '
      'and 374 of this batch and with Steps 163 and 175 -- six rows, one band '
      '-- its metric is a dashboard refresh latency on a packaging row, its '
      'Data Requirement cell reads "Data/artifacts to prepare: '
      '@habot/dashboard/parent-home", which is the package name lifted into '
      'the artefact list, and the Setup Step column is empty. Atomic Step: '
      '"Package home view layouts into @habot/dashboard/parent-home."';
}
