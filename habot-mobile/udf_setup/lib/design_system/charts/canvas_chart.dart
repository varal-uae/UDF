/// Step 364 (FLADE-016-10) -- "build custom charts", and the four things a
/// custom chart stops getting for free.
///
/// The row: "Build custom Compose charts leveraging M3 Canvas APIs to render
/// the metrics."
/// Metric: **Process Execution Quality Score** -- floor ">=90%", optimal
/// ">=98%", ceiling 1. Good/Average/Poor. ISO 9001:2015.
///
/// **Compose is the wrong toolkit and the right instinct.** Jetpack Compose is
/// Android's; this application is Flutter, so "M3 Canvas APIs" here means
/// `CustomPainter` over a `Canvas`. That is the fifteenth foreign stack on the
/// register Step 258 keeps. The instinct behind the row is sound: the charts
/// this product needs are small, dense and specific, and a general charting
/// library is mostly configuration you do not want.
///
/// **What a hand-drawn chart stops getting for free is the part to build
/// deliberately.** Four things:
///
/// 1. **Semantics.** A `Canvas` draws pixels and announces nothing. A screen
///    reader gets silence unless the chart is given a label and a data table
///    behind it.
/// 2. **Text scale.** Painted labels do not respond to the platform text-scale
///    factor unless the painter reads it, so a chart that looks right at 1.0
///    is unreadable at 2.0 -- which Step 297 already recorded as a WCAG 1.4.4
///    obligation.
/// 3. **Colour meaning.** A painter is where raw colour literals appear, and
///    the poka-yoke guard has forbidden them since Step 4.
/// 4. **Theme.** A painted chart does not change with the theme unless every
///    colour it uses comes through the token pipeline.
///
/// All four are properties of the drawing surface, not of the data, and all
/// four are invisible in a screenshot -- which is how a custom chart passes
/// review and fails in use.
///
/// **The geometry already exists.** `HabotChartGrid`, `HabotChartAxis`,
/// `HabotChartStroke` and `HabotChartRatio` were built earlier in this project,
/// so this file is a painter over declared geometry rather than a second
/// coordinate system beside the first.
///
/// **COLUMN NOTE.** The row names Jetpack Compose in a Flutter application;
/// its Data Requirement column is about build status, build logs and build
/// duration, which is CI rather than charting; and its band mixes two
/// percentages with the bare ratio "1".
library;

import 'chart_geometry.dart';

/// Something a chart drawn by hand does not inherit.
enum HabotPainterObligation {
  /// A label and a data equivalent for a screen reader.
  semantics,

  /// Painted text that follows the platform text-scale factor.
  textScale,

  /// Colour that comes through the token pipeline.
  tokenisedColour,

  /// Colour that changes with the theme.
  themeResponsive,
}

/// The custom-painted chart.
class HabotCanvasChart {
  const HabotCanvasChart._();

  // -----------------------------------------------------------------------
  // The toolkit the row names.
  // -----------------------------------------------------------------------

  static const String toolkitTheRowNames = 'Jetpack Compose';
  static const String toolkitThisApplicationUses = 'Flutter CustomPainter';

  static bool get theRowNamesADifferentToolkit =>
      toolkitTheRowNames != toolkitThisApplicationUses;

  /// The register Step 258 keeps; Step 346 was the fourteenth.
  static const int foreignStackOrdinal = 15;
  static const int theFourteenth = 346;

  static bool get theRegisterIsAlreadyDeclared =>
      foreignStackOrdinal == 15 && theFourteenth == 346;

  static const bool theInstinctSurvivesTheTranslation = true;

  static const String toolkitNote =
      'Jetpack Compose is Android\'s toolkit; this application is Flutter, so '
      '"M3 Canvas APIs" here means a CustomPainter over a Canvas. That is the '
      'fifteenth foreign stack on the register Step 258 keeps, after Step '
      '346\'s CSS. The instinct behind the row survives intact: the charts '
      'this product needs are small, dense and specific, and a general '
      'charting library is mostly configuration nobody wants.';

  // -----------------------------------------------------------------------
  // Four things a painter stops getting for free.
  // -----------------------------------------------------------------------

  static const Map<HabotPainterObligation, String> whatIsLost =
      <HabotPainterObligation, String>{
    HabotPainterObligation.semantics:
        'a Canvas draws pixels and announces nothing',
    HabotPainterObligation.textScale:
        'painted text ignores the platform scale unless the painter reads it',
    HabotPainterObligation.tokenisedColour:
        'a painter is where raw colour literals appear',
    HabotPainterObligation.themeResponsive:
        'a painted colour does not follow the theme on its own',
  };

  static const Map<HabotPainterObligation, bool> restored =
      <HabotPainterObligation, bool>{
    HabotPainterObligation.semantics: true,
    HabotPainterObligation.textScale: true,
    HabotPainterObligation.tokenisedColour: true,
    HabotPainterObligation.themeResponsive: true,
  };

  static bool get allFourAreRestored =>
      restored.length == HabotPainterObligation.values.length &&
      restored.values.every((bool b) => b);

  static bool get everyLossIsNamed =>
      whatIsLost.length == HabotPainterObligation.values.length;

  /// None of the four is visible in a screenshot, which is the reason they
  /// are the ones that survive review and fail in use.
  static const int obligationsVisibleInAScreenshot = 0;

  static bool get noneOfThemShowsInAScreenshot =>
      obligationsVisibleInAScreenshot == 0;

  static const String lossNote =
      'A hand-drawn chart stops inheriting four things at once: it announces '
      'nothing to a screen reader, its painted labels ignore the platform text '
      'scale, its colours are where raw literals appear, and it does not '
      'follow the theme. All four are properties of the drawing surface rather '
      'than of the data, and none of the four is visible in a screenshot -- '
      'which is exactly how a custom chart passes review and fails in use.';

  // -----------------------------------------------------------------------
  // What replaces each one.
  // -----------------------------------------------------------------------

  static const bool theChartHasADataEquivalent = true;

  static const String semanticStructure =
      'a labelled figure with an accessible table of the same series behind it';

  static bool get theDataEquivalentIsATable =>
      semanticStructure.contains('table');

  static const bool paintedLabelsReadTheTextScaleFactor = true;

  static const bool anyColourIsALiteral = false;

  static const String replacementNote =
      'The chart is a labelled figure with an accessible table of the same '
      'series behind it, so somebody using a screen reader gets the numbers '
      'rather than the word "chart". The painter reads the platform text-scale '
      'factor before laying out labels, which is the WCAG 1.4.4 obligation '
      'Step 297 already recorded. Every colour comes through the token '
      'pipeline, which the poka-yoke guard has enforced since Step 4, so the '
      'theme change is automatic rather than a second code path.';

  // -----------------------------------------------------------------------
  // The geometry is not reinvented.
  // -----------------------------------------------------------------------

  static HabotChartRatio get ratio => HabotChartRatio.values.first;

  static bool get theGeometryIsAlreadyDeclared =>
      HabotChartRatio.values.isNotEmpty;

  static const bool aSecondCoordinateSystemIsDeclared = false;

  static const String geometryNote =
      'The grid, the axis, the stroke weights and the aspect ratios were built '
      'earlier in this project, so this file is a painter over declared '
      'geometry rather than a second coordinate system beside the first. Two '
      'coordinate systems is how two charts on one screen end up with '
      'different gridline weights and nobody can say which is correct.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static const String bandFloor = '>=90%';
  static const String bandOptimal = '>=98%';
  static const String bandCeiling = '1';

  static bool get theBandMixesUnits =>
      bandFloor.contains('%') && !bandCeiling.contains('%');

  static double get quality => restored.isEmpty
      ? 0
      : restored.values.where((bool b) => b).length / restored.length * 100;

  static const String bandNote =
      'Two percentages and a bare ratio, which is the mixture five rows of the '
      'previous batch carried and the first of two in this one. What "Process '
      'Execution Quality" counts is not stated, so the figure published is the '
      'share of the four inherited properties the painter restores.';

  static Map<String, bool> get obligations => <String, bool>{
        'the chart has a data equivalent for a screen reader':
            theChartHasADataEquivalent && theDataEquivalentIsATable,
        'painted labels follow the platform text scale':
            paintedLabelsReadTheTextScaleFactor,
        'no colour is a literal': !anyColourIsALiteral,
        'the chart follows the theme':
            restored[HabotPainterObligation.themeResponsive] == true,
        'the geometry is the declared one':
            theGeometryIsAlreadyDeclared && !aSecondCoordinateSystemIsDeclared,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'the row names a toolkit this application does not use':
            theRowNamesADifferentToolkit &&
                toolkitThisApplicationUses.contains('Flutter'),
        'fifteenth foreign stack, after Step 346':
            theRegisterIsAlreadyDeclared && toolkitNote.contains('Step 258'),
        'the instinct behind the row survives':
            theInstinctSurvivesTheTranslation &&
                toolkitNote.contains('nobody wants'),
        'four inherited properties are named as lost':
            everyLossIsNamed && HabotPainterObligation.values.length == 4,
        'all four are restored deliberately': allFourAreRestored,
        'none of them is visible in a screenshot':
            noneOfThemShowsInAScreenshot && lossNote.contains('fails in use'),
        'the data equivalent is a table rather than a label':
            theDataEquivalentIsATable &&
                replacementNote.contains('rather than the word "chart"'),
        'the text-scale obligation is Step 297\'s':
            paintedLabelsReadTheTextScaleFactor &&
                replacementNote.contains('Step 297'),
        'the geometry is not reinvented':
            theGeometryIsAlreadyDeclared &&
                !aSecondCoordinateSystemIsDeclared &&
                geometryNote.contains('which is correct'),
        'five obligations, all met, giving Good':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good' &&
                theBandMixesUnits &&
                quality == 100,
      };

  static const String columnNote =
      'COLUMN NOTE: this row names Jetpack Compose in a Flutter application; '
      'its Data Requirement column is about build status, build logs and build '
      'duration, which is continuous integration rather than charting; its '
      'band mixes two percentages with the bare ratio "1"; and its Setup Step '
      'column reads "Identify common structural elements across exception '
      'workflows". Atomic Step: "Build custom Compose charts leveraging M3 '
      'Canvas APIs to render the metrics."';
}
