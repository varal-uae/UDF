/// AISS Step 180 -- GEN-03602
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Activate the self-chasing mechanism: Non-standard UI code
///               fails automated build checks, forcing developers to use
///               tokenized library components."
/// Metric: Developer Build Intercept Enforcement -- Floor 1, Optimal 1,
///         Ceiling 1. Pass / Fail.
///
/// **THIS HAS BEEN ACTIVE SINCE STEP 4, AND SAYING SO IS THE POINT.**
/// `tool/verify_aiss.sh` runs the poka-yoke guard at stage G-C, before the
/// test suite, and exits non-zero on the first violation. A raw hex, a raw
/// spacing value, a second `ThemeData`, a rogue `Scaffold` or FAB all stop the
/// build today. The row asks for the mechanism to be *activated*; it is. What
/// this step adds is the half that was never built: **the mechanism cannot
/// currently be measured.**
///
/// **AN INTERCEPT NOBODY MEASURES DEGRADES WITHOUT ANYONE DECIDING TO LET IT.**
/// Three questions have no answer in this repository today: how much of the
/// codebase is actually under the guard, how many exemptions the rule set is
/// carrying, and whether that number went up this month. Each exemption is
/// individually reasonable — that is what makes the aggregate the thing worth
/// watching. [HabotBuildIntercept.exemptionBudget] pins the count so an
/// addition shows up as a diff on a declared number rather than as one more
/// line in a set literal.
///
/// **"FORCING DEVELOPERS TO USE TOKENIZED LIBRARY COMPONENTS" IS A CLAIM ABOUT
/// WHAT HAPPENS AFTER THE BUILD STOPS.** A rule that only says *no* gets
/// worked around; a rule that names the component gets followed. Step 179's
/// catalogue carries an `instead` for every rule, and this step checks that
/// none of them is empty — because that field is the entire difference between
/// an intercept and an obstacle.
library;

import '../a11y/a11y_rules.dart';
import 'governance_rules.dart';

/// Where in the verification sequence the intercept sits.
class HabotInterceptStage {
  const HabotInterceptStage({
    required this.id,
    required this.name,
    required this.blocks,
  });

  final String id;
  final String name;

  /// Whether a failure here stops everything after it.
  final bool blocks;
}

/// The build intercept, measured.
class HabotBuildIntercept {
  const HabotBuildIntercept._();

  static const String script = 'tool/verify_aiss.sh';

  /// The stages, in order. The guard is third, and deliberately BEFORE the
  /// test suite: a codebase with raw hexes in it should not get as far as
  /// being told its tests pass.
  static const List<HabotInterceptStage> stages = <HabotInterceptStage>[
    HabotInterceptStage(id: 'G-A', name: 'format', blocks: true),
    HabotInterceptStage(id: 'G-B', name: 'analyze', blocks: true),
    HabotInterceptStage(id: 'G-C', name: 'poka-yoke guard', blocks: true),
    HabotInterceptStage(id: 'G-D', name: 'test suite', blocks: true),
    HabotInterceptStage(id: 'G-E', name: 'evidence roll-up', blocks: false),
  ];

  static HabotInterceptStage get guardStage =>
      stages.firstWhere((HabotInterceptStage s) => s.id == 'G-C');

  /// True when the guard runs before the tests, which is what makes it an
  /// intercept rather than a report.
  static bool get runsBeforeTests {
    final int guard = stages.indexWhere((HabotInterceptStage s) => s.id == 'G-C');
    final int tests = stages.indexWhere((HabotInterceptStage s) => s.id == 'G-D');
    return guard >= 0 && tests >= 0 && guard < tests;
  }

  static bool get isBlocking => guardStage.blocks;

  /// The tree the scanners walk.
  static const String scannedRoot = 'lib/';

  /// Directories deliberately outside the scan, with the reason. `test/` is
  /// the interesting one: a fixture is allowed a raw value precisely because
  /// a rule needs something to catch.
  static const Map<String, String> outsideScan = <String, String>{
    'test/': 'Guard fixtures have to be able to contain the constructs the '
        'rules forbid, or the rules could not be tested against planted '
        'violations. This is also why the scanners walk lib/ and live in '
        'test/ rather than the other way round.',
    'tool/': 'Shell, not Dart.',
    'web/, android/, ios/':
        'Platform shells. The zoom-lock decision recorded at RCGLA-012 lives '
        'in web/index.html and is a documented deferral rather than an '
        'unscanned file.',
  };

  // ---- what was not measurable before -------------------------------------

  static int get ruleCount => HabotGovernance.ruleCount;

  static int get blockingRuleCount =>
      HabotGovernanceRules.all
          .where((HabotGovernanceRule r) => r.isBlocking)
          .length +
      HabotA11yRules.all.length;

  /// Rules that admit no exemption anywhere. The strongest form a rule takes.
  static int get absoluteRuleCount =>
      HabotGovernanceRules.absolute.length +
      HabotA11yRules.all.where((HabotA11yRule r) => r.exemptPaths.isEmpty).length;

  /// Every (rule, path) exemption currently carried, across both families.
  static Map<String, String> get exemptions {
    final Map<String, String> out =
        Map<String, String>.from(HabotGovernanceRules.exemptions);
    for (final HabotA11yRule r in HabotA11yRules.all) {
      for (final String p in r.exemptPaths) {
        out['${r.id} @ $p'] = r.exemptionRationale ?? 'NO REASON RECORDED';
      }
    }
    return out;
  }

  /// **The number worth watching.**
  ///
  /// Pinned so that adding an exemption changes a declared figure and shows up
  /// in review, rather than adding a line to a set literal that nobody counts.
  /// Each individual exemption is reasonable; that is exactly what makes the
  /// aggregate the thing to watch.
  /// Seventeen poka-yoke (six of them the metric declaration sites for one
  /// rule) and four accessibility.
  static const int exemptionBudget = 21;

  static int get exemptionsCarried => exemptions.length;

  static bool get withinBudget => exemptionsCarried <= exemptionBudget;

  static List<String> get unexplainedExemptions => exemptions.entries
      .where((MapEntry<String, String> e) => e.value == 'NO REASON RECORDED')
      .map((MapEntry<String, String> e) => e.key)
      .toList();

  /// Rules that stop a developer without telling them what to use instead.
  /// Must be empty -- see the header.
  static List<String> get rulesWithoutAnAlternative => HabotGovernanceRules.all
      .where((HabotGovernanceRule r) => r.instead.trim().length < 10)
      .map((HabotGovernanceRule r) => r.id)
      .toList();

  // ---- the row's metric ---------------------------------------------------

  /// Developer Build Intercept Enforcement: 1 at every bound, so it is a
  /// conjunction rather than a rate.
  static Map<String, bool> get enforcementChecks => <String, bool>{
        'the guard is a blocking stage rather than a report':
            isBlocking,
        'it runs before the test suite, so a codebase with raw values in it '
                'never gets told its tests passed':
            runsBeforeTests,
        'every rule in the catalogue is blocking': blockingRuleCount == ruleCount,
        'every rule names the component to use instead':
            rulesWithoutAnAlternative.isEmpty,
        'every exemption carries a reason': unexplainedExemptions.isEmpty,
        'the exemption count is within its declared budget': withinBudget,
      };

  static bool get isEnforced =>
      enforcementChecks.values.every((bool b) => b);

  static const int floor = 1;
  static const int optimal = 1;
  static const int ceiling = 1;

  static String get qualitativeOutput => isEnforced ? 'Pass' : 'Fail';

  static const String alreadyActiveNote =
      'The intercept has been active since Step 4. verify_aiss.sh runs the '
      'guard at stage G-C, before the test suite, and exits non-zero on the '
      'first violation. The row asks for the mechanism to be activated; it '
      'is. What this step adds is the half that was never built: the '
      'mechanism could not be measured.';

  static const String exemptionDriftNote =
      'An intercept nobody measures degrades without anyone deciding to let '
      'it. Three questions had no answer here: how much of the codebase is '
      'under the guard, how many exemptions the rule set carries, and whether '
      'that number went up. Each exemption is individually reasonable -- which '
      'is exactly what makes the aggregate the thing to watch. The budget is '
      'declared so an addition is a diff on a number rather than one more line '
      'in a set literal.';

  static const String insteadNote =
      '"Forcing developers to use tokenized library components" is a claim '
      'about what happens after the build stops. A rule that only says no '
      'gets worked around; a rule that names the component gets followed. The '
      'instead field is the entire difference between an intercept and an '
      'obstacle.';

  static const String columnNote =
      'Setup Step (Action) is EMPTY on this row. The Atomic Step is the unit '
      'of work.';
}
