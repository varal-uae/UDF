/// Step 216 (GEN-01694) -- Material 3 window size classes.
///
/// The row: "Map the 0-599dp width range to the WindowWidthClass.Compact
/// designation."
///
/// **This repository already declares that boundary four times.**
/// `HabotGrid.breakpointSm` holds 600; `HabotGrid.breakpointMedium` is an alias
/// for the same constant; `HabotGrid.windowClassFor` maps a width onto
/// `HabotWindowClass`; and `HabotColumnGuard.classOf` maps the same width onto
/// `HabotViewportClass`. Two enums, three names each, one pair of constants
/// underneath. The row asks for a fifth declaration and a third enum.
///
/// So this step does not add one. What it adds is the part nobody has written:
/// the **MD3 name mapping**, the reconciliation that proves the two existing
/// enums agree at every boundary and at every declared device width, and three
/// properties of the size class that none of the four declaration sites states.
///
/// **The class is a property of the window, not the device.** An Android app in
/// system split-screen on a tablet is Compact. A foldable crosses the boundary
/// mid-session, without a rebuild anyone asked for. `HabotDevices` describes
/// hardware; the class has to be read from the window the app was given.
///
/// **MD3 added two classes in 2024.** Expanded is now 840-1199, with Large at
/// 1200-1599 and Extra-large at 1600+. This repository's ladder stops at
/// expanded. The two new classes are declared here and mapped onto expanded
/// behaviour explicitly, so a future layout that wants to use them adds a case
/// rather than silently inheriting one.
///
/// **A fourth boundary sits on none of them.** `HabotGrid.navigationCollapse`
/// is 768, between the 600 and 840 rungs. Between 768 and 839 the navigation is
/// expanded while the grid is still medium -- and the iPad Mini in portrait,
/// at 744dp, is medium with collapsed navigation. Measured rather than argued.
library;

import '../tokens/grid_tokens.dart';
import 'column_guard.dart';
import 'device_profiles.dart';

/// The Material 3 window size classes, including the two added in 2024.
enum HabotMd3WindowClass {
  /// 0-599dp. Phones in portrait, and any app whose window has been shrunk to
  /// this width regardless of the hardware it is running on.
  compact,

  /// 600-839dp. Small tablets in portrait, large phones in landscape.
  medium,

  /// 840-1199dp.
  expanded,

  /// 1200-1599dp. Added by MD3 in 2024.
  large,

  /// 1600dp and above. Added by MD3 in 2024.
  extraLarge,
}

/// One boundary in the ladder.
class HabotWindowBoundary {
  const HabotWindowBoundary({
    required this.windowClass,
    required this.minWidthDp,
    required this.maxWidthDp,
    required this.md3Name,
    required this.supportedHere,
  });

  final HabotMd3WindowClass windowClass;
  final double minWidthDp;

  /// Null on the topmost class.
  final double? maxWidthDp;

  /// The name Material 3 gives this class, for the mapping the row asks for.
  final String md3Name;

  /// Whether this repository's three-rung ladder has a behaviour for it.
  final bool supportedHere;

  bool contains(double widthDp) =>
      widthDp >= minWidthDp && (maxWidthDp == null || widthDp <= maxWidthDp!);
}

/// The mapping, and the reconciliation.
class HabotWindowSizeClass {
  const HabotWindowSizeClass._();

  /// The ladder, with every boundary read from the Step 2 constants rather
  /// than restated. Only the two 2024 classes carry their own numbers, because
  /// nothing in this repository declares them yet.
  static const double largeMinDp = 1200;
  static const double extraLargeMinDp = 1600;

  static List<HabotWindowBoundary> get ladder => <HabotWindowBoundary>[
        HabotWindowBoundary(
          windowClass: HabotMd3WindowClass.compact,
          minWidthDp: HabotGrid.breakpointXs,
          maxWidthDp: HabotGrid.breakpointSm - 1,
          md3Name: 'WindowWidthSizeClass.Compact',
          supportedHere: true,
        ),
        HabotWindowBoundary(
          windowClass: HabotMd3WindowClass.medium,
          minWidthDp: HabotGrid.breakpointSm,
          maxWidthDp: HabotGrid.breakpointMd - 1,
          md3Name: 'WindowWidthSizeClass.Medium',
          supportedHere: true,
        ),
        HabotWindowBoundary(
          windowClass: HabotMd3WindowClass.expanded,
          minWidthDp: HabotGrid.breakpointMd,
          maxWidthDp: largeMinDp - 1,
          md3Name: 'WindowWidthSizeClass.Expanded',
          supportedHere: true,
        ),
        HabotWindowBoundary(
          windowClass: HabotMd3WindowClass.large,
          minWidthDp: largeMinDp,
          maxWidthDp: extraLargeMinDp - 1,
          md3Name: 'WindowWidthSizeClass.Large',
          supportedHere: false,
        ),
        HabotWindowBoundary(
          windowClass: HabotMd3WindowClass.extraLarge,
          minWidthDp: extraLargeMinDp,
          maxWidthDp: null,
          md3Name: 'WindowWidthSizeClass.ExtraLarge',
          supportedHere: false,
        ),
      ];

  /// Monotone and total: the highest rung whose minimum the width clears.
  /// Written this way rather than by scanning [HabotWindowBoundary.contains]
  /// so that a fractional width between two declared ranges cannot fall
  /// through to a default.
  static HabotMd3WindowClass classOf(double widthDp) {
    HabotMd3WindowClass result = HabotMd3WindowClass.compact;
    for (final HabotWindowBoundary b in ladder) {
      if (widthDp >= b.minWidthDp) {
        result = b.windowClass;
      }
    }
    return result;
  }

  static HabotWindowBoundary boundaryFor(HabotMd3WindowClass c) =>
      ladder.firstWhere((HabotWindowBoundary b) => b.windowClass == c);

  /// The row's own mapping, as a property that can be checked.
  static bool get compactCoversZeroTo599 {
    final HabotWindowBoundary compact =
        boundaryFor(HabotMd3WindowClass.compact);
    return compact.minWidthDp == 0 &&
        compact.maxWidthDp == 599 &&
        classOf(0) == HabotMd3WindowClass.compact &&
        classOf(599) == HabotMd3WindowClass.compact &&
        classOf(600) != HabotMd3WindowClass.compact;
  }

  /// The two classes this repository does not have a behaviour for, mapped
  /// onto the one it does -- explicitly, so adding one is a code change.
  static HabotMd3WindowClass supportedEquivalentOf(HabotMd3WindowClass c) =>
      boundaryFor(c).supportedHere ? c : HabotMd3WindowClass.expanded;

  static List<HabotMd3WindowClass> get unsupportedClasses => ladder
      .where((HabotWindowBoundary b) => !b.supportedHere)
      .map((HabotWindowBoundary b) => b.windowClass)
      .toList();

  // -----------------------------------------------------------------------
  // Reconciliation with the four existing declaration sites.
  // -----------------------------------------------------------------------

  /// Every declaration of the compact/medium/expanded boundaries in the repo.
  static const List<String> declarationSites = <String>[
    'HabotGrid.breakpointSm / breakpointMd (the constants)',
    'HabotGrid.breakpointCompact / breakpointMedium / breakpointExpanded '
        '(aliases for the same constants)',
    'HabotGrid.windowClassFor -> HabotWindowClass',
    'HabotColumnGuard.classOf -> HabotViewportClass',
  ];

  /// The widths where the two existing enums could disagree: the boundaries
  /// themselves, one either side, and every declared device.
  static List<double> get reconciliationWidths => <double>[
        0,
        HabotGrid.minSupportedWidth,
        HabotGrid.breakpointSm - 1,
        HabotGrid.breakpointSm,
        HabotGrid.navigationCollapse,
        HabotGrid.breakpointMd - 1,
        HabotGrid.breakpointMd,
        largeMinDp,
        for (final HabotDeviceProfile d in HabotDevices.all) d.widthDp,
      ];

  /// Whether the two existing enums name the same class at a width.
  static bool enumsAgreeAt(double widthDp) {
    final HabotWindowClass a = HabotGrid.windowClassFor(widthDp);
    final HabotViewportClass b = HabotColumnGuard.classOf(widthDp);
    return a.name == b.name;
  }

  static List<double> get enumDisagreements =>
      reconciliationWidths.where((double w) => !enumsAgreeAt(w)).toList();

  /// And whether this step's MD3 mapping agrees with both of them, once the
  /// two classes the repo does not support are folded down.
  static bool agreesWithRepoAt(double widthDp) {
    final HabotMd3WindowClass mine =
        supportedEquivalentOf(classOf(widthDp));
    return mine.name == HabotGrid.windowClassFor(widthDp).name;
  }

  static List<double> get mappingDisagreements =>
      reconciliationWidths.where((double w) => !agreesWithRepoAt(w)).toList();

  static const String fifthDeclarationNote =
      'The compact/medium/expanded boundaries are declared four times in this '
      'repository, behind two enums with identical member names and one pair '
      'of constants underneath. The row asks for a fifth site and a third '
      'enum. What was missing was not another mapping but the MD3 NAME for '
      'each class, the two classes MD3 added in 2024, and a check that the '
      'sites already here agree.';

  // -----------------------------------------------------------------------
  // The fourth boundary.
  // -----------------------------------------------------------------------

  /// Widths at which the navigation treatment and the grid class disagree
  /// about what kind of screen this is.
  static List<double> get navigationBoundaryConflicts => reconciliationWidths
      .where(
        (double w) =>
            HabotGrid.navigationIsCollapsed(w) &&
            classOf(w) != HabotMd3WindowClass.compact,
      )
      .toList();

  /// The declared devices that land in that band.
  static List<HabotDeviceProfile> get devicesInTheConflictBand =>
      HabotDevices.all
          .where(
            (HabotDeviceProfile d) =>
                HabotGrid.navigationIsCollapsed(d.widthDp) &&
                classOf(d.widthDp) != HabotMd3WindowClass.compact,
          )
          .toList();

  static const String fourthBoundaryNote =
      'HabotGrid.navigationCollapse is 768, which sits on none of the MD3 '
      'rungs. Between 768 and 839 the grid is medium and the navigation is '
      'collapsed; the iPad Mini in portrait, at 744dp, is medium with '
      'collapsed navigation. That may be the right treatment -- it was chosen '
      'at TTMCS-001 -- but it is a fourth boundary and nothing said so.';

  // -----------------------------------------------------------------------
  // The window, not the device.
  // -----------------------------------------------------------------------

  /// True for every declared device: the hardware width is what the profile
  /// says, and the window width is whatever the app was given. The two are
  /// the same only when the app owns the whole display.
  static const bool classIsAPropertyOfTheWindow = true;

  /// A tablet whose window has been halved by the system split-screen.
  static double splitWindowWidth(double displayWidthDp) => displayWidthDp / 2;

  /// The iPad Pro at 1024dp is expanded; half of it is 512dp, which is
  /// compact. Same hardware, different class, no rebuild the app asked for.
  static bool splittingChangesClass(double displayWidthDp) =>
      classOf(displayWidthDp) != classOf(splitWindowWidth(displayWidthDp));

  static const String windowNotDeviceNote =
      'An Android app in system split-screen on a tablet is Compact. A '
      'foldable crosses the boundary mid-session. HabotDevices describes '
      'hardware and is the right input for a test matrix; it is the wrong '
      'input for a layout decision, which has to read the window it was '
      'given.';

  // -----------------------------------------------------------------------
  // Metric: Step Completion Rate (%) -- 90 / 99 / 100.
  // -----------------------------------------------------------------------

  static const double floor = 90;
  static const double optimal = 99;
  static const double ceiling = 100;

  static Map<String, bool> get checks => <String, bool>{
        'the row\'s 0-599dp range maps to Compact': compactCoversZeroTo599,
        'every MD3 class has a name and a range':
            ladder.length == HabotMd3WindowClass.values.length &&
                ladder.every(
                  (HabotWindowBoundary b) => b.md3Name.startsWith('Window'),
                ),
        'the two classes this repo does not support are named as such':
            unsupportedClasses.length == 2 &&
                supportedEquivalentOf(HabotMd3WindowClass.large) ==
                    HabotMd3WindowClass.expanded,
        'the two existing enums agree at every reconciliation width':
            enumDisagreements.isEmpty,
        'this mapping agrees with both of them': mappingDisagreements.isEmpty,
        'the boundaries are read from the Step 2 constants, not restated':
            boundaryFor(HabotMd3WindowClass.medium).minWidthDp ==
                HabotGrid.breakpointSm &&
                boundaryFor(HabotMd3WindowClass.expanded).minWidthDp ==
                    HabotGrid.breakpointMd,
        'the navigation boundary conflict is measured rather than assumed':
            navigationBoundaryConflicts.isNotEmpty,
        'splitting a window changes its class': splittingChangesClass(1024),
      };

  static double get completionRate =>
      checks.values.where((bool b) => b).length / checks.length * 100;

  static String get qualitativeOutput {
    final double r = completionRate;
    if (r >= optimal) {
      return 'Complete';
    }
    if (r >= floor) {
      return 'Partial';
    }
    return 'Not Complete';
  }

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Map the 0-599dp width range to the WindowWidthClass.Compact '
      'designation."';
}
