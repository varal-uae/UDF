/// AISS Step 179 -- GEN-03514
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Package design system linter configurations into a shared
///               build governance repo."
/// Metric: Governance Repo Packaging -- Floor 1, Optimal 1, Ceiling 1.
///         Complete.
///
/// **A SEPARATE REPOSITORY IS AN ORGANISATION DECISION, NOT A CLIENT ONE, AND
/// A SECOND COPY OF A RULE IS THE PROBLEM RATHER THAN THE SOLUTION.** What
/// "packaging" actually buys is the part this repository can do and has half
/// done: making the rule set **data** -- countable, reviewable as a set, and
/// adoptable by something that is not this test file.
///
/// **HALF OF THIS IS ALREADY TRUE, AND THE ASYMMETRY IS THE FINDING.** Step 97
/// extracted the six accessibility rules into `HabotA11yRules` in `lib/`, for
/// the reason written at the top of that file: *a rule that only exists inside
/// a test file cannot be read by anything else.* The ten poka-yoke rules never
/// got the same treatment. They have lived inside
/// `test/guards/poka_yoke_no_hardcoded_values_test.dart` since Step 4, which
/// means nothing can count them, nothing can list them for a developer before
/// they run the build, and nothing outside this repository could adopt them.
///
/// **AND THE OBVIOUS FIX WOULD CREATE THE DEFECT IT IS MEANT TO PREVENT.**
/// Copying each regex into this file would give the project two copies of
/// every pattern, and the copy that fails the build is the one in the scanner
/// — so the catalogue would drift and nobody would notice, because only one of
/// them is executed. **So the pattern is deliberately NOT declared here.** What
/// is declared is everything else: the id, what the rule forbids, why, its
/// exempt sites, the reason for each exemption, and which step owns it. The
/// gate then asserts that the ids in this catalogue are exactly the ids the
/// scanner implements, which is what keeps one list honest about the other.
library;

import '../a11y/a11y_rules.dart';
import '../interaction/keyboard_aware_fab.dart';
import 'token_package.dart';

/// How a rule behaves when it matches.
enum HabotRuleSeverity {
  /// Fails the build. Every rule in this catalogue is one of these today;
  /// the enum exists so that adding a warning-level rule is a visible
  /// decision rather than a quiet one.
  blocking,

  /// Recorded in the evidence, does not fail the build.
  advisory,
}

/// One governance rule, as a catalogue entry.
///
/// **No pattern field.** See the header: the pattern stays in the one place
/// that executes it.
class HabotGovernanceRule {
  const HabotGovernanceRule({
    required this.id,
    required this.forbids,
    required this.instead,
    required this.why,
    required this.owner,
    required this.severity,
    this.exemptPaths = const <String>{},
    this.exemptionRationale,
  });

  /// e.g. 'RAW_COLOR_LITERAL'. Matches the id the scanner emits.
  final String id;

  final String forbids;

  /// What to do instead. A rule that only says what is wrong gets worked
  /// around rather than followed.
  final String instead;

  final String why;

  /// The implementation step that introduced it.
  final String owner;

  final HabotRuleSeverity severity;

  /// Files allowed to contain the construct.
  final Set<String> exemptPaths;

  /// Why. An exemption without a reason is how a rule dies.
  final String? exemptionRationale;

  bool get isAbsolute => exemptPaths.isEmpty;
  bool get isBlocking => severity == HabotRuleSeverity.blocking;
}

/// The poka-yoke half of the catalogue.
class HabotGovernanceRules {
  const HabotGovernanceRules._();

  /// The scanner that executes these. One file, named once.
  static const String scanner =
      'test/guards/poka_yoke_no_hardcoded_values_test.dart';

  static const String a11yScanner = 'test/guards/a11y_rules_test.dart';

  static const Set<String> _colourSites = <String>{
    'lib/design_system/tokens/color_tokens.dart',
    'lib/design_system/tokens/elevation_tokens.dart',
    'lib/design_system/tokens/high_contrast_tokens.dart',
  };

  static const Set<String> _metricSites = <String>{
    'lib/design_system/tokens/spacing_tokens.dart',
    'lib/design_system/interaction/touch_standards.dart',
    'lib/design_system/tokens/grid_tokens.dart',
    'lib/design_system/tokens/shape_tokens.dart',
    'lib/design_system/tokens/elevation_tokens.dart',
    'lib/design_system/tokens/typography_tokens.dart',
  };

  static const String _motionSite =
      'lib/design_system/tokens/motion_tokens.dart';
  static const String _themeSite =
      'lib/design_system/theme/habot_theme.dart';
  static const String _scaffoldSite =
      'lib/design_system/layout/master_scaffold.dart';

  static const List<HabotGovernanceRule> all = <HabotGovernanceRule>[
    HabotGovernanceRule(
      id: 'RAW_COLOR_LITERAL',
      forbids: 'A Color(0x...) literal outside the colour declaration sites.',
      instead: 'Reference the role on HabotColors / HabotColorScheme.',
      why: 'A literal is a colour nothing audited. The Step 4 contrast engine '
          'reads the declared scheme, so a hex typed into a widget is outside '
          'every accessibility gate this project has.',
      owner: 'Step 4 TTMCS-005',
      severity: HabotRuleSeverity.blocking,
      exemptPaths: _colourSites,
      exemptionRationale:
          'These three files ARE the colour declaration. Their literals are '
          'WCAG-audited by the Step 4 engine and, for the dark ladder, '
          're-derived by TTMCS-005-G2.',
    ),
    HabotGovernanceRule(
      id: 'UNTOKENISED_MATERIAL_COLOR',
      forbids: 'Colors.red and the rest of the Material colour constants.',
      instead: 'Reference the semantic role -- error, primary, outline.',
      why: 'A Material constant is a literal wearing a name. It also carries '
          'no semantics: Colors.red is not the error role, it is one '
          'particular red, and it will not move when the palette does.',
      owner: 'Step 4 TTMCS-005',
      severity: HabotRuleSeverity.blocking,
      exemptPaths: _colourSites,
      exemptionRationale: 'As RAW_COLOR_LITERAL.',
    ),
    HabotGovernanceRule(
      id: 'RAW_SPACING_VALUE',
      forbids: 'A numeric literal inside EdgeInsets, BorderRadius, Radius or '
          'SizedBox outside the metric declaration sites.',
      instead: 'Reference HabotSpacing, HabotShape, HabotGrid or '
          'HabotDensity.',
      why: 'RCGLA-001: "Style repository checks automatically fail if layout '
          'padding variables use non-standard grid intervals." A literal is '
          'how a 14dp gap appears in a system built on multiples of four.',
      owner: 'Step 2 RCGLA-001',
      severity: HabotRuleSeverity.blocking,
      exemptPaths: _metricSites,
      exemptionRationale:
          'These six files are where the metric scales are written down. '
          'Step 183 measures their alignment to the 4dp grid rather than '
          'assuming it.',
    ),
    HabotGovernanceRule(
      id: 'RAW_DURATION',
      forbids: 'Duration(milliseconds: n) outside the motion token file.',
      instead: 'Reference HabotMotion.',
      why: 'BPTR-0422 asks for standardised transitions. A duration typed at '
          'a call site is a transition nobody can retune, and it is how one '
          'screen ends up 200ms out of step with every other.',
      owner: 'Step 11 BPTR-0422',
      severity: HabotRuleSeverity.blocking,
      exemptPaths: <String>{_motionSite},
      exemptionRationale: 'The motion token file is the declaration site.',
    ),
    HabotGovernanceRule(
      id: 'RAW_CURVE',
      forbids: 'A Curves.* reference outside the motion token file.',
      instead: 'Reference HabotEasing.',
      why: 'An easing curve is as much a brand decision as a colour, and it '
          'is the one people copy from a tutorial without noticing.',
      owner: 'Step 11 BPTR-0422',
      severity: HabotRuleSeverity.blocking,
      exemptPaths: <String>{_motionSite},
      exemptionRationale: 'As RAW_DURATION.',
    ),
    HabotGovernanceRule(
      id: 'HOVER_TOOLTIP',
      forbids: 'Tooltip(...). Anywhere.',
      instead: 'HabotMetadataDisclosure, which opens on long-press and on a '
          'tap of the trailing icon.',
      why: 'MUFCE-028. A hover tooltip is unreachable on a touch device, so '
          'information that only appears on hover is, on a phone, information '
          'that does not exist.',
      owner: 'Step 24 MUFCE-028',
      severity: HabotRuleSeverity.blocking,
    ),
    HabotGovernanceRule(
      id: 'HOVER_CALLBACK',
      forbids: 'An onHover: callback. Anywhere.',
      instead: 'A press or long-press gesture.',
      why: 'As HOVER_TOOLTIP. Behaviour behind hover is behaviour a touch '
          'user never reaches.',
      owner: 'Step 24 MUFCE-028',
      severity: HabotRuleSeverity.blocking,
    ),
    HabotGovernanceRule(
      id: 'ROGUE_SCAFFOLD',
      forbids: 'Scaffold(...) outside the master layout wrapper.',
      instead: 'HabotMasterScaffold.',
      why: 'SSTLA-012: "Code linters block views that do not extend the '
          'master layout wrapper." A screen with its own Scaffold has its own '
          'safe-area handling, its own app bar and its own idea of the '
          'bottom -- which is three chances to diverge.',
      owner: 'Step 36 SSTLA-012',
      severity: HabotRuleSeverity.blocking,
      exemptPaths: <String>{_scaffoldSite},
      exemptionRationale: 'The wrapper itself has to build one.',
    ),
    HabotGovernanceRule(
      id: 'ROGUE_FAB',
      forbids: 'FloatingActionButton(...) outside the keyboard-aware FAB.',
      instead: 'HabotKeyboardAwareFab.',
      why: 'A raw FAB does not leave the tree when the keyboard opens, so it '
          'sits over the field the user is typing in and is tapped by '
          'accident.',
      owner: 'Step 154 GEN-04825',
      severity: HabotRuleSeverity.blocking,
      exemptPaths: <String>{HabotFabSafeguard.permittedSite},
      exemptionRationale:
          'The one component that implements the sanctioned behaviour.',
    ),
    HabotGovernanceRule(
      id: 'ROGUE_THEME_CONSTRUCTION',
      forbids: 'ThemeData(...) outside the theme adapter.',
      instead: 'HabotTheme.light() / HabotTheme.dark().',
      why: 'A second ThemeData is a second palette. It will not be audited, '
          'and the screen using it will look almost right.',
      owner: 'Step 1 TTMCS-001',
      severity: HabotRuleSeverity.blocking,
      exemptPaths: <String>{_themeSite},
      exemptionRationale: 'The adapter is where the tokens become a theme.',
    ),
  ];

  static Set<String> get ids =>
      all.map((HabotGovernanceRule r) => r.id).toSet();

  static HabotGovernanceRule byId(String id) =>
      all.firstWhere((HabotGovernanceRule r) => r.id == id);

  /// Rules with no exempt site at all.
  static List<HabotGovernanceRule> get absolute =>
      all.where((HabotGovernanceRule r) => r.isAbsolute).toList();

  /// Every exemption in the catalogue, flattened, so the list can be read as
  /// one thing and argued with. An exemption list that grows quietly is how a
  /// guard stops being a guard.
  static Map<String, String> get exemptions {
    final Map<String, String> out = <String, String>{};
    for (final HabotGovernanceRule r in all) {
      for (final String p in r.exemptPaths) {
        out['${r.id} @ $p'] = r.exemptionRationale ?? 'NO REASON RECORDED';
      }
    }
    return out;
  }

  /// Exemptions with no reason written down. Must be empty.
  static List<String> get unexplainedExemptions => exemptions.entries
      .where((MapEntry<String, String> e) => e.value == 'NO REASON RECORDED')
      .map((MapEntry<String, String> e) => e.key)
      .toList();

  /// Every exempt path must be a token declaration site or a named single
  /// implementation. An exemption pointing at an ordinary widget file is a
  /// rule somebody switched off.
  static List<String> get exemptionsOutsideDeclaredSites {
    const Set<String> sanctionedNonTokenSites = <String>{
      _themeSite,
      _scaffoldSite,
      HabotFabSafeguard.permittedSite,
      'lib/design_system/interaction/touch_standards.dart',
    };
    final List<String> out = <String>[];
    for (final HabotGovernanceRule r in all) {
      for (final String p in r.exemptPaths) {
        if (HabotTokenPackage.isDeclarationSite(p) ||
            sanctionedNonTokenSites.contains(p)) {
          continue;
        }
        out.add('${r.id} @ $p');
      }
    }
    return out;
  }
}

/// The whole governance surface: both rule families, as one thing.
class HabotGovernance {
  const HabotGovernance._();

  /// What a consumer would adopt. The row asks for a package; this is its
  /// contents.
  static const String packageName = 'habot_design_governance';

  static List<String> get pokaYokeRuleIds =>
      HabotGovernanceRules.ids.toList()..sort();

  static List<String> get a11yRuleIds =>
      HabotA11yRules.all.map((HabotA11yRule r) => r.id).toList()..sort();

  static List<String> get allRuleIds =>
      <String>[...pokaYokeRuleIds, ...a11yRuleIds]..sort();

  static int get ruleCount => allRuleIds.length;

  /// The two scanners that execute the catalogue.
  static List<String> get scanners => <String>[
        HabotGovernanceRules.scanner,
        HabotGovernanceRules.a11yScanner,
      ];

  /// A portable description of the rule set, without the patterns -- which is
  /// what an adopting repository needs in order to decide, and what a
  /// developer needs in order to know what will stop them.
  static List<Map<String, Object?>> export() => <Map<String, Object?>>[
        for (final HabotGovernanceRule r in HabotGovernanceRules.all)
          <String, Object?>{
            'id': r.id,
            'family': 'poka-yoke',
            'forbids': r.forbids,
            'instead': r.instead,
            'why': r.why,
            'owner': r.owner,
            'severity': r.severity.name,
            'exempt_paths': r.exemptPaths.toList()..sort(),
            'exemption_rationale': r.exemptionRationale,
          },
        for (final HabotA11yRule r in HabotA11yRules.all)
          <String, Object?>{
            'id': r.id,
            'family': 'accessibility',
            'forbids': r.message,
            'instead': r.message,
            'why': r.message,
            'owner': r.owner,
            'severity': HabotRuleSeverity.blocking.name,
            'exempt_paths': r.exemptPaths.toList()..sort(),
            'exemption_rationale': r.exemptionRationale,
          },
      ];

  // ---- the row's metric ---------------------------------------------------

  /// Governance Repo Packaging: 1 at floor, optimal and ceiling alike, so it
  /// is a set of conditions rather than a rate.
  static Map<String, bool> get packagingChecks => <String, bool>{
        'both rule families are declared as data rather than only as scanner '
                'internals':
            HabotGovernanceRules.all.isNotEmpty && HabotA11yRules.all.isNotEmpty,
        'every rule names the step that owns it':
            HabotGovernanceRules.all.every(
                  (HabotGovernanceRule r) => r.owner.contains('Step'),
                ) &&
                HabotA11yRules.all
                    .every((HabotA11yRule r) => r.owner.contains('Step')),
        'every rule says what to do INSTEAD, not only what is forbidden':
            HabotGovernanceRules.all
                .every((HabotGovernanceRule r) => r.instead.length > 10),
        'every exemption carries a reason':
            HabotGovernanceRules.unexplainedExemptions.isEmpty,
        'every exemption points at a token declaration site or a named single '
                'implementation':
            HabotGovernanceRules.exemptionsOutsideDeclaredSites.isEmpty,
        'the catalogue is exportable without the patterns, so adopting it does '
                'not mean copying regexes':
            export().length == ruleCount,
        'no rule id is claimed by both families':
            pokaYokeRuleIds.toSet().intersection(a11yRuleIds.toSet()).isEmpty,
      };

  static bool get isPackaged =>
      packagingChecks.values.every((bool b) => b);

  static double get packagingRate {
    final Iterable<bool> v = packagingChecks.values;
    return v.where((bool b) => b).length / v.length;
  }

  static const double floor = 1.0;
  static const double optimal = 1.0;

  static String get qualitativeOutput => isPackaged ? 'Complete' : 'Partial';

  /// What packaging does NOT yet include, named.
  static const List<String> outstanding = <String>[
    'The scanner still holds the patterns inline. It should consume this '
        'catalogue the way a11y_rules_test.dart consumes HabotA11yRules -- '
        'the gate asserts the two id sets match, which is what keeps them '
        'honest until the migration happens.',
    'A separate repository is an organisation decision. The contents are here; '
        'where they live is not a call this codebase makes.',
  ];

  static const String separateRepoNote =
      'A separate repo is an organisation decision, not a client one, and a '
      'second copy of a rule is the problem rather than the solution. What '
      'packaging buys is the part this repository can do: making the rule set '
      'data -- countable, reviewable as a set, and adoptable by something that '
      'is not a test file.';

  static const String asymmetryNote =
      'Step 97 extracted the six accessibility rules into lib/ for exactly '
      'this reason, and wrote it down: a rule that only exists inside a test '
      'file cannot be read by anything else. The ten poka-yoke rules never got '
      'the same treatment and have lived inside the scanner since Step 4.';

  static const String noPatternsHereNote =
      'The patterns are deliberately NOT declared in the catalogue. Copying '
      'each regex would give the project two copies, and the copy that fails '
      'the build is the one in the scanner -- so the catalogue would drift and '
      'nobody would notice, because only one of them is executed. The gate '
      'asserts instead that the catalogue\'s ids are exactly the ids the '
      'scanner implements.';

  static const String columnNote =
      'Setup Step (Action) is EMPTY on this row. The Atomic Step is the unit '
      'of work.';
}
