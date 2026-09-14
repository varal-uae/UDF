/// Step 221 (DLQDP-029-11) -- MD3 canonical layouts.
///
/// The row: "Implement M3 Split Screen or supporting pane layout."
/// Metric: UI Design-System Adherence Rate -- >=85% / >=95% / 1.
/// Good/Average/Poor.
///
/// **"Split screen" is not a Material 3 layout.** MD3 names three canonical
/// layouts: list-detail, supporting pane, and feed. "Split screen" is the
/// *Android system* feature in which two different apps share the display --
/// and the row joins the two with an "or", as though they were alternatives.
///
/// They are not alternatives; they are opposites. System split-screen **shrinks
/// the app's window**, which moves it down the size-class ladder -- an app
/// given half of a 1024dp tablet is running at 512dp, which is Compact, which
/// is
/// exactly the class at which a supporting pane has to collapse. Implementing
/// "split screen" literally means implementing the thing that takes the
/// supporting pane away.
///
/// So the three canonical layouts are declared with the class at which each
/// collapses, and the system feature is declared separately as an input to the
/// window class rather than as a layout the app chooses.
library;

import 'pane_split.dart';
import 'window_size_class.dart';

/// The three layouts Material 3 actually names.
enum HabotCanonicalLayoutKind {
  /// A list of items beside the item that is open. MD3: list-detail.
  listDetail,

  /// The work, with a pane that supports it. MD3: supporting pane.
  supportingPane,

  /// A single scrolling surface of cards or tiles. MD3: feed.
  feed,
}

/// One canonical layout and how it behaves across the ladder.
class HabotCanonicalLayout {
  const HabotCanonicalLayout({
    required this.kind,
    required this.md3Name,
    required this.relation,
    required this.collapsesAtOrBelow,
    required this.compactBehaviour,
  });

  final HabotCanonicalLayoutKind kind;

  /// The name Material 3 uses, so a design conversation and a code review are
  /// about the same thing.
  final String md3Name;

  /// Which pane relation this layout is, in Step 218's terms.
  final HabotPaneRelation relation;

  /// The widest class at which this layout stops showing both panes.
  final HabotMd3WindowClass collapsesAtOrBelow;

  /// What it does once collapsed.
  final HabotPanePresentation compactBehaviour;
}

/// The set, and the conflation the row invites.
class HabotCanonicalLayouts {
  const HabotCanonicalLayouts._();

  static const List<HabotCanonicalLayout> all = <HabotCanonicalLayout>[
    HabotCanonicalLayout(
      kind: HabotCanonicalLayoutKind.listDetail,
      md3Name: 'List-detail',
      relation: HabotPaneRelation.masterDetail,
      collapsesAtOrBelow: HabotMd3WindowClass.compact,
      compactBehaviour: HabotPanePresentation.navigated,
    ),
    HabotCanonicalLayout(
      kind: HabotCanonicalLayoutKind.supportingPane,
      md3Name: 'Supporting pane',
      relation: HabotPaneRelation.supporting,
      collapsesAtOrBelow: HabotMd3WindowClass.compact,
      compactBehaviour: HabotPanePresentation.navigated,
    ),
    HabotCanonicalLayout(
      kind: HabotCanonicalLayoutKind.feed,
      md3Name: 'Feed',
      relation: HabotPaneRelation.peers,
      collapsesAtOrBelow: HabotMd3WindowClass.compact,
      compactBehaviour: HabotPanePresentation.stacked,
    ),
  ];

  static HabotCanonicalLayout of(HabotCanonicalLayoutKind kind) =>
      all.firstWhere((HabotCanonicalLayout l) => l.kind == kind);

  /// The name the row uses, which is not one of them.
  static const String nameInTheRow = 'Split Screen';

  static bool get rowNamesALayoutMd3DoesNotHave =>
      !all.any((HabotCanonicalLayout l) => l.md3Name == nameInTheRow);

  // -----------------------------------------------------------------------
  // The system feature, which is an input rather than a layout.
  // -----------------------------------------------------------------------

  /// The Android system feature: two apps sharing one display.
  static const String systemFeature =
      'Android system split-screen / iPadOS Split View';

  /// It is not something this app selects. It changes the width the app is
  /// given, and everything else follows from the class that width lands in.
  static const bool appChoosesIt = false;

  static double windowWidthUnderSystemSplit(double displayWidthDp) =>
      HabotWindowSizeClass.splitWindowWidth(displayWidthDp);

  /// A tablet at 1024dp runs a supporting pane. Halved, it is at 512dp, which
  /// is compact, which is where the supporting pane collapses. So the system
  /// feature the row names as an alternative is the thing that removes the
  /// layout it is offered as an alternative to.
  static bool systemSplitCollapsesLayout(
    HabotCanonicalLayoutKind kind,
    double displayWidthDp,
  ) {
    final HabotCanonicalLayout l = of(kind);
    final HabotPanePresentation before =
        HabotPaneSplit.presentationFor(l.relation, displayWidthDp);
    final HabotPanePresentation after = HabotPaneSplit.presentationFor(
      l.relation,
      windowWidthUnderSystemSplit(displayWidthDp),
    );
    return before != after && after == l.compactBehaviour;
  }

  static const String conflationNote =
      'The row offers "M3 Split Screen" and "supporting pane" as '
      'alternatives. Material 3 has no layout called Split Screen -- it names '
      'list-detail, supporting pane and feed. Split-screen is the Android '
      'system feature in which two apps share a display, and it is not an '
      'alternative to a supporting pane, it is the thing that takes one away: '
      'halving a 1024dp tablet window puts the app at 512dp, which is '
      'Compact, which is where the supporting pane collapses.';

  static const String systemFeatureIsAnInputNote =
      'The app does not choose system split-screen. It changes the width the '
      'app is given, and everything after that follows from the class that '
      'width lands in -- which is why Step 216 insists the class is read from '
      'the window rather than from the hardware.';

  // -----------------------------------------------------------------------
  // Metric: UI Design-System Adherence Rate. >=85% / >=95% / 1.
  // -----------------------------------------------------------------------

  static const double floor = 0.85;
  static const double optimal = 0.95;
  static const double ceiling = 1;

  static Map<String, bool> get adherenceChecks => <String, bool>{
        'all three MD3 canonical layouts are declared':
            all.length == 3 &&
                all.map((HabotCanonicalLayout l) => l.md3Name).toSet().length ==
                    3,
        'each carries the MD3 name a designer would use': all.every(
          (HabotCanonicalLayout l) => l.md3Name.isNotEmpty,
        ),
        'each maps onto a declared pane relation':
            all.map((HabotCanonicalLayout l) => l.relation).toSet().length == 3,
        'each declares the class at which it collapses': all.every(
          (HabotCanonicalLayout l) =>
              l.collapsesAtOrBelow == HabotMd3WindowClass.compact,
        ),
        'list-detail navigates on compact rather than stacking':
            of(HabotCanonicalLayoutKind.listDetail).compactBehaviour ==
                HabotPanePresentation.navigated,
        'a feed stacks, because both halves are the same kind of thing':
            of(HabotCanonicalLayoutKind.feed).compactBehaviour ==
                HabotPanePresentation.stacked,
        'the name the row uses is not one of them':
            rowNamesALayoutMd3DoesNotHave,
        'the system feature is an input, not a layout the app selects':
            !appChoosesIt &&
                systemSplitCollapsesLayout(
                  HabotCanonicalLayoutKind.supportingPane,
                  1024,
                ),
      };

  static double get adherenceRate =>
      adherenceChecks.values.where((bool b) => b).length /
      adherenceChecks.length;

  static String get qualitativeOutput {
    final double r = adherenceRate;
    if (r >= optimal) {
      return 'Good';
    }
    if (r >= floor) {
      return 'Average';
    }
    return 'Poor';
  }

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Implement M3 Split Screen or supporting pane layout."';
}
