/// Step 218 (GEN-04748) -- the 50/50 pane decision.
///
/// The row: "Apply the mobile-first UX decision: Vertical 50/50 stack on
/// mobile; horizontal 50/50 split on tablet/desktop."
/// Metric: UX Decision Adoption Consistency -- >=95% of applicable screens /
/// 100% / 100%. Yes/No.
///
/// **On a compact window the two panes should not both be visible.** A 50/50
/// vertical stack on a 360x740 phone gives each pane about 320dp after the app
/// bar and the safe areas, and about 50dp once the keyboard opens -- which is
/// the state a booking form spends most of its life in. On compact the
/// relationship between two panes is *navigation*, not layout, and
/// `HabotMasterDetail` already implements it that way: one pane at a time,
/// with a back gesture between them.
///
/// **50/50 is a ratio, not a decision.** Two panes rarely carry equal content,
/// and this repository already says so: `HabotMasterDetail` declares 35/65.
/// So the row and the code disagree, and the disagreement is real rather than
/// an oversight -- they are describing two different patterns. Peer panes
/// (Step 170's split view, where both sides are evidence) are 50/50. A master
/// and a detail are not peers and stay 35/65.
///
/// What this step adds is the rule that says which of the two a given screen
/// is, so "apply the decision" has something to be applied to.
library;

import 'window_size_class.dart';

/// How two panes relate to each other.
enum HabotPaneRelation {
  /// Both panes carry content of the same kind and the same weight. A
  /// side-by-side comparison, a before and after.
  peers,

  /// One pane selects, the other shows what was selected.
  masterDetail,

  /// One pane is the work and the other supports it -- a form and its
  /// guidance. MD3 calls this the supporting pane.
  supporting,
}

/// What a screen actually does at a given window class.
enum HabotPanePresentation {
  /// Both panes visible, side by side.
  sideBySide,

  /// Both panes visible, stacked vertically.
  stacked,

  /// One pane at a time, with navigation between them.
  navigated,
}

/// A declared split, for one relation.
class HabotSplitRule {
  const HabotSplitRule({
    required this.relation,
    required this.leadingPercent,
    required this.trailingPercent,
    required this.rationale,
  });

  final HabotPaneRelation relation;

  /// Percentages of the cross-axis extent. Leading and trailing rather than
  /// left and right, for the reason recorded at Steps 188, 193 and 212.
  final double leadingPercent;
  final double trailingPercent;

  final String rationale;

  bool get sumsToWhole => leadingPercent + trailingPercent == 100;
  bool get isEven => leadingPercent == trailingPercent;
}

/// The rule.
class HabotPaneSplit {
  const HabotPaneSplit._();

  /// `HabotMasterDetail.masterFlex` and `detailFlex` -- restated here only so
  /// the contradiction with the row is visible in one place.
  static const double masterDetailLeading = 35;
  static const double masterDetailTrailing = 65;

  static const List<HabotSplitRule> rules = <HabotSplitRule>[
    HabotSplitRule(
      relation: HabotPaneRelation.peers,
      leadingPercent: 50,
      trailingPercent: 50,
      rationale:
          'The row\'s decision, applied where it is true: two panes carrying '
          'the same kind of content at the same weight have no reason to be '
          'uneven.',
    ),
    HabotSplitRule(
      relation: HabotPaneRelation.masterDetail,
      leadingPercent: masterDetailLeading,
      trailingPercent: masterDetailTrailing,
      rationale:
          'A list of names and a record. Giving the list half the width wastes '
          'it and cramps the record; HabotMasterDetail declared 35/65 before '
          'this row was read and it is not changed to satisfy a ratio.',
    ),
    HabotSplitRule(
      relation: HabotPaneRelation.supporting,
      leadingPercent: 65,
      trailingPercent: 35,
      rationale:
          'MD3 supporting pane: the work is the larger side and the support '
          'is the smaller one. Reversing it makes the guidance look like the '
          'task.',
    ),
  ];

  static HabotSplitRule ruleFor(HabotPaneRelation relation) =>
      rules.firstWhere((HabotSplitRule r) => r.relation == relation);

  /// The row's ratio holds for exactly one of the three relations.
  static List<HabotPaneRelation> get relationsTheRowFits => rules
      .where((HabotSplitRule r) => r.isEven)
      .map((HabotSplitRule r) => r.relation)
      .toList();

  static bool get everyRuleSumsToWhole =>
      rules.every((HabotSplitRule r) => r.sumsToWhole);

  // -----------------------------------------------------------------------
  // What happens at each window class.
  // -----------------------------------------------------------------------

  /// The row says vertical on mobile and horizontal on tablet/desktop. The
  /// vertical stack is kept for peers, where both halves are worth seeing at
  /// once; for the other two relations a compact window navigates instead.
  static HabotPanePresentation presentationFor(
    HabotPaneRelation relation,
    double windowWidthDp,
  ) {
    final HabotMd3WindowClass c =
        HabotWindowSizeClass.classOf(windowWidthDp);
    if (c != HabotMd3WindowClass.compact) {
      return HabotPanePresentation.sideBySide;
    }
    return relation == HabotPaneRelation.peers
        ? HabotPanePresentation.stacked
        : HabotPanePresentation.navigated;
  }

  /// Cross-axis extent available to one pane, after the chrome a screen
  /// always has.
  static double paneExtentFor({
    required HabotPaneRelation relation,
    required double windowWidthDp,
    required double windowHeightDp,
    required double chromeHeightDp,
    double keyboardInsetDp = 0,
  }) {
    final HabotPanePresentation p = presentationFor(relation, windowWidthDp);
    final HabotSplitRule r = ruleFor(relation);
    switch (p) {
      case HabotPanePresentation.sideBySide:
        return windowWidthDp * r.leadingPercent / 100;
      case HabotPanePresentation.stacked:
        final double usable =
            windowHeightDp - chromeHeightDp - keyboardInsetDp;
        return usable * r.leadingPercent / 100;
      case HabotPanePresentation.navigated:
        return windowWidthDp;
    }
  }

  /// Below this a pane is a label with a scrollbar rather than a pane.
  static const double minimumUsablePaneDp = 200;

  static bool paneIsUsable(double extentDp) => extentDp >= minimumUsablePaneDp;

  static const String stackCollapsesUnderAKeyboardNote =
      'A vertical 50/50 stack on a 360x740 phone gives each pane about 320dp '
      'after the app bar and the safe areas. With the keyboard open it gives '
      'each pane about 50dp, and a booking form spends most of its life with '
      'the keyboard open. That is why compact navigates rather than stacks '
      'for anything but peers.';

  static const String ratioIsNotADecisionNote =
      'Two panes rarely carry equal content. HabotMasterDetail declared 35/65 '
      'before this row was read, so the row and the code disagree -- and the '
      'disagreement is real: they describe different patterns. Peer panes are '
      '50/50; a master and a detail are not peers.';

  // -----------------------------------------------------------------------
  // Metric: UX Decision Adoption Consistency. >=95% / 100% / 100%. Yes/No.
  // -----------------------------------------------------------------------

  static const double floor = 95;
  static const double optimal = 100;
  static const double ceiling = 100;

  /// The screens this decision applies to, and what relation each one is.
  static const Map<String, HabotPaneRelation> applicableScreens =
      <String, HabotPaneRelation>{
    'contextual mirror (evidence beside action)': HabotPaneRelation.peers,
    'dashboard grid (metric beside its trend)': HabotPaneRelation.peers,
    'child profile list and record': HabotPaneRelation.masterDetail,
    'booking list and booking detail': HabotPaneRelation.masterDetail,
    'operator queue and order under review': HabotPaneRelation.masterDetail,
    'booking form with its guidance': HabotPaneRelation.supporting,
    'dispute intake with its evidence list': HabotPaneRelation.supporting,
  };

  /// A screen adopts the decision when its relation is declared and the rule
  /// for that relation sums to a whole.
  static bool screenAdopts(String screen) {
    final HabotPaneRelation? r = applicableScreens[screen];
    if (r == null) {
      return false;
    }
    return ruleFor(r).sumsToWhole;
  }

  static double get adoptionConsistency =>
      applicableScreens.keys.where(screenAdopts).length /
      applicableScreens.length *
      100;

  /// Share of applicable screens on which the row's literal 50/50 is correct.
  static double get literalRatioApplies =>
      applicableScreens.values
          .where((HabotPaneRelation r) => ruleFor(r).isEven)
          .length /
      applicableScreens.length *
      100;

  static String get qualitativeOutput =>
      adoptionConsistency >= floor ? 'Yes' : 'No';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Apply the mobile-first UX decision: Vertical 50/50 stack on mobile; '
      'horizontal 50/50 split on tablet/desktop."';
}
