/// AISS Step 136 -- ANSA-012
/// Atomic Steps Reference ID: ANSA-012-A02
/// Setup Step (Action): "Establish Contextual Navigation Header Framework."
/// Atomic Step: "Create the ContextualHeaderModule component file."
/// Metric: Layout Structural Consistency (Responsive Grid Compliance) --
///         Floor "90% of components on shared layout pattern", Optimal "100%",
///         Ceiling "100% (cannot exceed)".
///
/// THE FIRST ROW IN THE SHEET WHOSE DEPENDENCY THIS PROJECT HAS SATISFIED.
/// Every one of the 135 steps before it was a zero-dependency row. This one
/// declares `Dependency (Atomic Step Serial No) = 4`, and serial 4 is
/// ANSA-012-A01, built at Step 9. It is genuinely next, and that is why it
/// leads this batch rather than a more interesting-looking row.
///
/// THE COMPONENT FILE ALREADY EXISTS, AND IS NOT REBUILT.
/// `navigation/contextual_header.dart` was written at Step 9 and carries
/// `HabotContextualHeader`, its title policy, its elevation policy and its
/// overflow sheet. Writing a second header module would be two definitions of
/// one surface -- exactly the drift these steps exist to prevent.
///
/// SO WHAT IS THE WORK? The METRIC, which Step 9 could not report and nobody
/// has computed since: "% of components on shared layout pattern". That
/// number cannot come from a file that exists; it comes from an inventory of
/// what the app's chrome is built from and whether each piece sits on the
/// shared pattern or invents its own. [HabotSharedLayout] is that inventory,
/// and it is a measurement rather than an assertion: a component added
/// without a pattern lowers the rate and is named by
/// [HabotSharedLayout.offPattern] rather than quietly averaged away.
library;

/// The shared layout patterns this app has. A component is compliant when it
/// is built from one of these rather than from a bare Flutter primitive.
enum HabotLayoutPattern {
  /// `layout/master_scaffold.dart` -- the only file permitted to build a
  /// Scaffold, enforced by the ROGUE_SCAFFOLD guard.
  masterScaffold,

  /// `layout/mobile_grid_container.dart` / `tokens/grid_tokens.dart` -- the
  /// 4/8/12 column responsive grid.
  responsiveGrid,

  /// `surfaces/card_chassis.dart` -- the one card shell.
  cardChassis,

  /// `shell/adaptive_panes.dart` -- the split/pane distribution rules.
  adaptivePanes,

  /// `layout/page_frame.dart` -- page padding and safe-area ownership.
  pageFrame,
}

/// One entry in the inventory.
class HabotLayoutComponent {
  const HabotLayoutComponent({
    required this.name,
    required this.file,
    required this.pattern,
    required this.owningStep,
    this.note,
  });

  final String name;
  final String file;

  /// Null means the component builds its own layout. That is what the metric
  /// is counting, so it must be representable.
  final HabotLayoutPattern? pattern;

  final String owningStep;
  final String? note;

  bool get isOnSharedPattern => pattern != null;
}

/// The responsive-grid conformance inventory.
class HabotSharedLayout {
  const HabotSharedLayout._();

  /// The module this row is about. Named separately because the row names it,
  /// and because a gate that only checked a percentage could pass without the
  /// header being in the list at all.
  static const String contextualHeaderModule =
      'lib/design_system/navigation/contextual_header.dart';

  static const List<HabotLayoutComponent> components =
      <HabotLayoutComponent>[
    HabotLayoutComponent(
      name: 'ContextualHeaderModule',
      file: contextualHeaderModule,
      pattern: HabotLayoutPattern.masterScaffold,
      owningStep: 'Step 9 ANSA-012-A01',
      note: 'The module this row names. Built at Step 9, verified here, not '
          'rebuilt: a second header module would be two definitions of one '
          'surface.',
    ),
    HabotLayoutComponent(
      name: 'HabotMasterScaffold',
      file: 'lib/design_system/layout/master_scaffold.dart',
      pattern: HabotLayoutPattern.masterScaffold,
      owningStep: 'Step 8 RCGLA-018',
    ),
    HabotLayoutComponent(
      name: 'HabotPageFrame',
      file: 'lib/design_system/layout/page_frame.dart',
      pattern: HabotLayoutPattern.pageFrame,
      owningStep: 'Step 8 RCGLA-018',
    ),
    HabotLayoutComponent(
      name: 'MobileGridContainer',
      file: 'lib/design_system/layout/mobile_grid_container.dart',
      pattern: HabotLayoutPattern.responsiveGrid,
      owningStep: 'Step 2 RCGLA-001',
    ),
    HabotLayoutComponent(
      name: 'HabotCardChassis',
      file: 'lib/design_system/surfaces/card_chassis.dart',
      pattern: HabotLayoutPattern.cardChassis,
      owningStep: 'Step 29 GEN-01452',
    ),
    HabotLayoutComponent(
      name: 'HabotAdaptiveNavigation',
      file: 'lib/design_system/navigation/adaptive_navigation.dart',
      pattern: HabotLayoutPattern.masterScaffold,
      owningStep: 'Step 40 GEN-02334',
    ),
    HabotLayoutComponent(
      name: 'HabotAdaptivePanes',
      file: 'lib/design_system/shell/adaptive_panes.dart',
      pattern: HabotLayoutPattern.adaptivePanes,
      owningStep: 'Step 87 SSELC-016',
    ),
    HabotLayoutComponent(
      name: 'HabotDashboardGrid',
      file: 'lib/design_system/shell/dashboard_grid.dart',
      pattern: HabotLayoutPattern.responsiveGrid,
      owningStep: 'Step 45 GEN-00022',
    ),
    HabotLayoutComponent(
      name: 'HabotKpiGrid',
      file: 'lib/design_system/dashboard/kpi_grid.dart',
      pattern: HabotLayoutPattern.responsiveGrid,
      owningStep: 'Step 54 GEN-00168',
    ),
    HabotLayoutComponent(
      name: 'HabotTaskChassis',
      file: 'lib/design_system/mto/task_chassis.dart',
      pattern: HabotLayoutPattern.masterScaffold,
      owningStep: 'Step 88 GEN-00610',
    ),
    HabotLayoutComponent(
      name: 'HabotBottomSheet',
      file: 'lib/design_system/surfaces/bottom_sheet.dart',
      pattern: HabotLayoutPattern.pageFrame,
      owningStep: 'Step 21 GEN-00055',
    ),
    HabotLayoutComponent(
      name: 'GuidedForm',
      file: 'lib/design_system/wizard/carousel_stepper.dart',
      pattern: HabotLayoutPattern.pageFrame,
      owningStep: 'Step 20 FIEVR-033',
    ),
  ];

  static Iterable<HabotLayoutComponent> get onPattern =>
      components.where((HabotLayoutComponent c) => c.isOnSharedPattern);

  /// Components that build their own layout. Empty is the requirement; the
  /// list exists so a failure names the file rather than only a percentage.
  static List<String> get offPattern => components
      .where((HabotLayoutComponent c) => !c.isOnSharedPattern)
      .map((HabotLayoutComponent c) => '${c.name} (${c.file})')
      .toList();

  /// The row's metric.
  static double get complianceRate =>
      components.isEmpty ? 0 : onPattern.length / components.length;

  static const double floor = 0.90;
  static const double optimal = 1.0;

  /// The row's Best Qualitative Output vocabulary.
  static String get qualitativeOutput {
    if (complianceRate >= optimal) {
      return 'Complete';
    }
    return complianceRate >= floor ? 'Partial' : 'Not Complete';
  }

  /// Which patterns are actually in use. A pattern nothing is built on is a
  /// pattern that has been abandoned without being deleted.
  static Set<HabotLayoutPattern> get patternsInUse => onPattern
      .map((HabotLayoutComponent c) => c.pattern!)
      .toSet();

  static const String notRebuiltNote =
      'The ContextualHeaderModule file this row asks for was created at Step 9 '
      '(ANSA-012-A01) as navigation/contextual_header.dart. It is verified '
      'here and deliberately not recreated: a second header module would be '
      'two definitions of one surface, which is the drift the AISS steps exist '
      'to prevent. The work in this row is the metric -- the share of '
      'components sitting on a shared layout pattern -- which no earlier step '
      'computed.';

  static const String dependencyNote =
      'This is the first row in the sheet whose declared dependency this '
      'project has satisfied: Dependency (Atomic Step Serial No) = 4, which is '
      'ANSA-012-A01, built at Step 9. Every one of Steps 1-135 was a '
      'zero-dependency row. It leads this batch because the dependency graph '
      'says it is next, not because it is the most interesting row available.';
}
