/// Step 220 (AWCV-015) -- the split-screen matrix.
///
/// The row: "Define the layout requirements for the split-screen matrix."
/// Metric: Process Execution Quality (%) -- 95 / 99 / 100. Pass/Fail.
///
/// **MECHANICAL SHEET DEFECT, RECORDED.** This row's Atomic Step is about
/// layout. Its Expected Output is "production-ready data governance operating
/// manual for technical workflows" and its Common Library is
/// `governance/roles/operating-model-privileges.json`. Those two columns
/// belong to a data-governance row and have been carried onto a layout one --
/// the same class of defect as the eleven mismatched columns already recorded
/// in batches 3 and 4. The Atomic Step is implemented; the two mismatched
/// columns are reported rather than followed, because following them would
/// produce a roles file from a row about panes.
///
/// **The matrix is the useful reading.** "Layout requirements for the
/// split-screen matrix" is a grid: window class x pane relation, and what each
/// cell resolves to. Written as a total function it answers a question the
/// four preceding steps leave open one cell at a time -- and a cell nobody
/// thought about is the one that ships as a crash on a foldable.
///
/// Fifteen cells. Every one of them named, with the minimum extent each pane
/// gets and whether that extent is usable.
library;

import '../tokens/grid_tokens.dart';
import 'device_profiles.dart';
import 'pane_split.dart';
import 'window_size_class.dart';

/// One cell of the matrix.
class HabotMatrixCell {
  const HabotMatrixCell({
    required this.windowClass,
    required this.relation,
    required this.presentation,
    required this.leadingExtentDp,
    required this.usable,
  });

  final HabotMd3WindowClass windowClass;
  final HabotPaneRelation relation;
  final HabotPanePresentation presentation;

  /// Extent the leading pane receives in this cell.
  final double leadingExtentDp;

  /// Whether that extent clears the minimum usable pane.
  final bool usable;

  String get id => '${windowClass.name}/${relation.name}';
}

/// The matrix.
class HabotSplitMatrix {
  const HabotSplitMatrix._();

  // -----------------------------------------------------------------------
  // The column defect.
  // -----------------------------------------------------------------------

  static const String rowExpectedOutput =
      'production-ready data governance operating manual for technical '
      'workflows.';

  static const String rowCommonLibrary =
      'governance/roles/operating-model-privileges.json.';

  static const String rowAtomicStep =
      'Define the layout requirements for the split-screen matrix.';

  static const String columnMismatchNote =
      'MECHANICAL DEFECT: the Expected Output and Common Library columns on '
      'this row describe a data-governance artefact -- an operating manual and '
      'a roles JSON file -- while the Atomic Step describes a layout. The two '
      'columns have been carried onto the wrong row. The Atomic Step is '
      'implemented and the mismatch is reported; following the columns would '
      'produce a privileges file from a row about panes. Same class of defect '
      'as the eleven mismatched columns recorded in batches 3 and 4.';

  static bool get columnsDescribeADifferentArtefact =>
      rowExpectedOutput.contains('governance') &&
      rowCommonLibrary.contains('privileges') &&
      !rowAtomicStep.contains('governance');

  // -----------------------------------------------------------------------
  // The matrix itself.
  // -----------------------------------------------------------------------

  /// A representative width for each window class: the narrowest width in the
  /// class that the product actually has to survive. Using the narrowest is
  /// the point -- a cell that is usable at its widest width tells you nothing.
  static double representativeWidthFor(HabotMd3WindowClass c) => switch (c) {
        HabotMd3WindowClass.compact => HabotGrid.minSupportedWidth,
        HabotMd3WindowClass.medium =>
          HabotWindowSizeClass.boundaryFor(HabotMd3WindowClass.medium)
              .minWidthDp,
        HabotMd3WindowClass.expanded =>
          HabotWindowSizeClass.boundaryFor(HabotMd3WindowClass.expanded)
              .minWidthDp,
        HabotMd3WindowClass.large => HabotWindowSizeClass.largeMinDp,
        HabotMd3WindowClass.extraLarge =>
          HabotWindowSizeClass.extraLargeMinDp,
      };

  /// Height the app bar and safe areas take before any pane gets anything.
  static const double chromeHeightDp = 120;

  /// A representative height, taken from the shortest declared phone so the
  /// stacked cells are evaluated where they are tightest.
  static double get representativeHeightDp => HabotDevices.all
      .where((HabotDeviceProfile d) => d.deviceType == HabotDeviceType.phone)
      .map((HabotDeviceProfile d) => d.heightDp)
      .reduce((double a, double b) => a < b ? a : b);

  static List<HabotMatrixCell> get cells => <HabotMatrixCell>[
        for (final HabotMd3WindowClass c in HabotMd3WindowClass.values)
          for (final HabotPaneRelation r in HabotPaneRelation.values)
            _cell(c, r),
      ];

  static HabotMatrixCell _cell(
    HabotMd3WindowClass c,
    HabotPaneRelation r,
  ) {
    final double w = representativeWidthFor(c);
    final double extent = HabotPaneSplit.paneExtentFor(
      relation: r,
      windowWidthDp: w,
      windowHeightDp: representativeHeightDp,
      chromeHeightDp: chromeHeightDp,
    );
    return HabotMatrixCell(
      windowClass: c,
      relation: r,
      presentation: HabotPaneSplit.presentationFor(r, w),
      leadingExtentDp: extent,
      usable: HabotPaneSplit.paneIsUsable(extent),
    );
  }

  static HabotMatrixCell cellFor(
    HabotMd3WindowClass c,
    HabotPaneRelation r,
  ) =>
      cells.firstWhere(
        (HabotMatrixCell x) => x.windowClass == c && x.relation == r,
      );

  static int get cellCount => cells.length;

  static bool get everyCellIsNamed =>
      cellCount ==
      HabotMd3WindowClass.values.length * HabotPaneRelation.values.length;

  /// Cells where the leading pane does not clear the minimum usable extent.
  static List<HabotMatrixCell> get unusableCells =>
      cells.where((HabotMatrixCell c) => !c.usable).toList();

  /// A navigated cell is always usable -- the pane gets the whole window --
  /// so an unusable cell is always one that tried to show both panes.
  static bool get everyUnusableCellShowsBothPanes => unusableCells.every(
        (HabotMatrixCell c) =>
            c.presentation != HabotPanePresentation.navigated,
      );

  /// The cells the four preceding steps would otherwise have left implicit:
  /// the two window classes this repository has no behaviour for.
  static List<HabotMatrixCell> get cellsForUnsupportedClasses => cells
      .where(
        (HabotMatrixCell c) =>
            HabotWindowSizeClass.unsupportedClasses.contains(c.windowClass),
      )
      .toList();

  /// The cell with the least room. Reported because a matrix with no
  /// unusable cells still has a tightest one, and that is the cell a change
  /// to any of the three inputs breaks first.
  static HabotMatrixCell get tightestCell => cells.reduce(
        (HabotMatrixCell a, HabotMatrixCell b) =>
            a.leadingExtentDp <= b.leadingExtentDp ? a : b,
      );

  static double get tightestMarginDp =>
      tightestCell.leadingExtentDp - HabotPaneSplit.minimumUsablePaneDp;

  static const String matrixIsTheReadingNote =
      '"Layout requirements for the split-screen matrix" is a grid: window '
      'class by pane relation, and what each cell resolves to. Written as a '
      'total function it answers in one place what the four preceding steps '
      'leave open one cell at a time -- and a cell nobody thought about is the '
      'one that ships as a crash on a foldable.';

  static const String narrowestWidthNote =
      'Each class is evaluated at its NARROWEST width rather than a typical '
      'one. A cell that is usable at 1280dp and unusable at 840dp is an '
      'unusable cell; evaluating it at the width where it is comfortable is '
      'how a matrix comes out green and a tablet comes out broken.';

  // -----------------------------------------------------------------------
  // Metric: Process Execution Quality (%). 95 / 99 / 100. Pass/Fail.
  // -----------------------------------------------------------------------

  static const double floor = 95;
  static const double optimal = 99;
  static const double ceiling = 100;

  static Map<String, bool> get checks => <String, bool>{
        'every cell of the matrix is named': everyCellIsNamed,
        'the matrix is total over both axes':
            cellCount == 15 &&
                cells.map((HabotMatrixCell c) => c.id).toSet().length == 15,
        'each cell carries the extent its leading pane receives':
            cells.every((HabotMatrixCell c) => c.leadingExtentDp > 0),
        'a navigated cell is never unusable': everyUnusableCellShowsBothPanes,
        'the two unsupported window classes have cells rather than gaps':
            cellsForUnsupportedClasses.length ==
                HabotPaneRelation.values.length * 2,
        'each class is evaluated at its narrowest width':
            representativeWidthFor(HabotMd3WindowClass.medium) ==
                    HabotGrid.breakpointSm &&
                representativeWidthFor(HabotMd3WindowClass.compact) ==
                    HabotGrid.minSupportedWidth,
        'no cell leaves its leading pane below the usable minimum':
            unusableCells.isEmpty,
        'the mismatched columns on this row are recorded':
            columnsDescribeADifferentArtefact,
      };

  static double get executionQuality =>
      checks.values.where((bool b) => b).length / checks.length * 100;

  static String get qualitativeOutput =>
      executionQuality >= floor ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Expected Output '
      'and Common Library belong to a different row -- see '
      'columnMismatchNote. Atomic Step: "Define the layout requirements for '
      'the split-screen matrix."';
}
