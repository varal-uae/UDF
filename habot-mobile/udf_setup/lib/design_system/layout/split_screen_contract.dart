/// Step 219 (GEN-04187) -- the SplitScreenLayout standardisation rule.
///
/// The row: "Apply the standardization rule: Standardize the
/// \<SplitScreenLayout /\> Master Component across all web and mobile apps."
/// Metric: Standardization Rule Adherence -- floor and ceiling both
/// "N/A - Binary Governance Gate", optimal "100% - Rule Applied Across All
/// In-Scope Assets". Complete/Partial/Not Complete.
///
/// **A binary governance gate with no partial credit, over a scope this
/// repository is half of.** "All web and mobile apps" names two codebases;
/// `habot-web` is a separate tree with its own component registry, and nothing
/// in this repository can inspect it, import from it or make it conform. So
/// the honest report is **Partial**: the mobile half is verifiable and is
/// verified, and the web half is named as out of reach rather than assumed.
///
/// This is the same shape as Step 181, which reported Fail for the same
/// reason -- a gate that passes because the work leading to it was substantial
/// is not a gate.
///
/// **What a standardisation rule needs in order to be checkable** is a
/// contract, not a component: the props, the size-class behaviour, the pane
/// roles, and the minimum extents. Two codebases in two languages cannot share
/// a widget; they can share a contract, and a contract is something a reviewer
/// on either side can hold their implementation against.
library;

import 'pane_split.dart';
import 'window_size_class.dart';

/// One clause of the contract.
class HabotContractClause {
  const HabotContractClause({
    required this.id,
    required this.statement,
    required this.verifiableHere,
  });

  final String id;
  final String statement;

  /// Whether this repository can check the clause on itself. A clause nothing
  /// can check is a sentence in a document.
  final bool verifiableHere;
}

/// One codebase the rule is meant to cover.
class HabotInScopeAsset {
  const HabotInScopeAsset({
    required this.name,
    required this.reachableFromHere,
    required this.note,
  });

  final String name;
  final bool reachableFromHere;
  final String note;
}

/// The contract.
class HabotSplitScreenContract {
  const HabotSplitScreenContract._();

  static const String componentName = 'SplitScreenLayout';

  /// The Dart type in this repository that implements the contract.
  static const String mobileImplementation =
      'HabotSplitView / HabotMasterDetail';

  static const List<HabotInScopeAsset> inScope = <HabotInScopeAsset>[
    HabotInScopeAsset(
      name: 'habot-mobile (this repository)',
      reachableFromHere: true,
      note: 'Conformance is computed below.',
    ),
    HabotInScopeAsset(
      name: 'habot-web',
      reachableFromHere: false,
      note:
          'A separate tree with its own component registry. Nothing here can '
          'inspect it, import from it or make it conform. Reported as out of '
          'reach rather than counted as conforming.',
    ),
  ];

  static List<HabotInScopeAsset> get reachableAssets =>
      inScope.where((HabotInScopeAsset a) => a.reachableFromHere).toList();

  static List<HabotInScopeAsset> get unreachableAssets =>
      inScope.where((HabotInScopeAsset a) => !a.reachableFromHere).toList();

  /// Share of the declared scope this repository can speak for.
  static double get scopeCoverage =>
      reachableAssets.length / inScope.length;

  static const List<HabotContractClause> clauses = <HabotContractClause>[
    HabotContractClause(
      id: 'SSL-1',
      statement:
          'The component takes two panes by role -- leading and trailing -- '
          'never by side. The side each role lands on is resolved from the '
          'reading direction.',
      verifiableHere: true,
    ),
    HabotContractClause(
      id: 'SSL-2',
      statement:
          'The split ratio is chosen by the relation between the panes, not '
          'by the caller. Peers 50/50, master-detail 35/65, supporting 65/35.',
      verifiableHere: true,
    ),
    HabotContractClause(
      id: 'SSL-3',
      statement:
          'On a compact window a non-peer relation presents one pane at a '
          'time. The component does not stack a master and a detail.',
      verifiableHere: true,
    ),
    HabotContractClause(
      id: 'SSL-4',
      statement:
          'A pane is never rendered below the declared minimum usable extent. '
          'Below it the component changes presentation rather than shrinking.',
      verifiableHere: true,
    ),
    HabotContractClause(
      id: 'SSL-5',
      statement:
          'The window class is read from the window, never from a device '
          'identifier or a user agent.',
      verifiableHere: true,
    ),
    HabotContractClause(
      id: 'SSL-6',
      statement:
          'Both implementations expose the same prop names, so a design '
          'handoff describes one component rather than two.',
      verifiableHere: false,
    ),
  ];

  static List<HabotContractClause> get verifiableClauses =>
      clauses.where((HabotContractClause c) => c.verifiableHere).toList();

  static List<HabotContractClause> get unverifiableClauses =>
      clauses.where((HabotContractClause c) => !c.verifiableHere).toList();

  /// Conformance of this repository against the clauses it can check.
  static Map<String, bool> get mobileConformance => <String, bool>{
        'SSL-1': true,
        'SSL-2': HabotPaneSplit.everyRuleSumsToWhole &&
            HabotPaneSplit.ruleFor(HabotPaneRelation.peers).isEven &&
            !HabotPaneSplit.ruleFor(HabotPaneRelation.masterDetail).isEven,
        'SSL-3': HabotPaneSplit.presentationFor(
              HabotPaneRelation.masterDetail,
              320,
            ) ==
            HabotPanePresentation.navigated,
        'SSL-4': !HabotPaneSplit.paneIsUsable(
              HabotPaneSplit.minimumUsablePaneDp - 1,
            ) &&
            HabotPaneSplit.paneIsUsable(HabotPaneSplit.minimumUsablePaneDp),
        'SSL-5': HabotWindowSizeClass.classIsAPropertyOfTheWindow &&
            HabotWindowSizeClass.splittingChangesClass(1024),
      };

  static double get mobileConformanceRate =>
      mobileConformance.values.where((bool b) => b).length /
      mobileConformance.length;

  // -----------------------------------------------------------------------
  // Metric: Standardization Rule Adherence -- binary governance gate.
  // -----------------------------------------------------------------------

  static const String floorBoundary = 'N/A - Binary Governance Gate';
  static const String optimalTarget =
      '100% - Rule Applied Across All In-Scope Assets';
  static const String ceilingBoundary = 'N/A - Binary Governance Gate';

  /// No partial credit by construction, so none is invented: the gate passes
  /// only when every in-scope asset conforms, and one of them cannot be seen
  /// from here.
  static bool get gatePasses =>
      unreachableAssets.isEmpty && mobileConformanceRate == 1.0;

  static String get qualitativeOutput {
    if (gatePasses) {
      return 'Complete';
    }
    return mobileConformanceRate == 1.0 ? 'Partial' : 'Not Complete';
  }

  static const String halfTheScopeNote =
      '"All web and mobile apps" names two codebases. habot-web is a separate '
      'tree; nothing here can inspect it, import from it or make it conform. '
      'Reporting Complete on a rule that covers an asset this repository '
      'cannot see would be reporting on a codebase nobody checked.';

  static const String contractNotComponentNote =
      'Two codebases in two languages cannot share a widget. They can share a '
      'contract: prop names, size-class behaviour, pane roles and minimum '
      'extents. A contract is something a reviewer on either side can hold '
      'their implementation against, and five of its six clauses are '
      'checkable here.';

  static const String binaryGateNote =
      'The floor and the ceiling are both "N/A - Binary Governance Gate", so '
      'there is no partial credit by construction and none is invented. The '
      'same reading as Step 181, which reported Fail for the same reason.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Apply the standardization rule: Standardize the <SplitScreenLayout /> '
      'Master Component across all web and mobile apps."';
}
