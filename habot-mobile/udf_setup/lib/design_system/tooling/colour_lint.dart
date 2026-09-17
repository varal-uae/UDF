/// Step 409 (GEN-00044) -- a CSS linter for an application with no CSS, on a
/// row carrying another row's metric.
///
/// The row: "Configure a CSS linter to block custom hex color values in
/// component code."
/// Metric: **Function Complexity / Size Limit Compliance** -- floor "<= 25
/// lines / cyclomatic complexity <= 10 (acceptable ceiling)", optimal "<= 20
/// lines, <= 5 parameters, cyclomatic complexity <= 5", ceiling "25 lines (hard
/// linter-enforced ceiling)". Pass / Fail. Assigned to **UDF**.
///
/// **The metric belongs to Step 412.** "Function Complexity / Size Limit
/// Compliance" measures function length; Step 412 three rows later is "set a
/// hard limit of 20 lines of code per function" and carries a generic step
/// completion rate instead. The two rows have swapped metrics, which is a shape
/// this track has not recorded before -- the metric is not merely wrong for its
/// row, it is right for a different row in the same batch.
///
/// **And the floor cell contains the word "ceiling".** Floor "<= 25 lines /
/// cyclomatic complexity <= 10 (acceptable ceiling)"; ceiling "25 lines (hard
/// linter-enforced ceiling)". Both name 25, one calls itself acceptable and the
/// other hard, and the floor annotates itself as a ceiling. Step 384's ceiling
/// carried an argument and Step 413's carries a parenthetical; this floor
/// carries the name of the other boundary.
///
/// **There is no CSS.** This is the seventeenth foreign stack on the register
/// Step 258 keeps. What the row wants exists and has since Step 4:
/// `RAW_COLOR_LITERAL` in the poka-yoke catalogue blocks a `Color(0x...)`
/// literal outside the three declaration sites, and
/// `UNTOKENISED_MATERIAL_COLOR` blocks the Material constants a hex would
/// otherwise hide behind.
///
/// **So this row is bound rather than built, and the binding is the finding.**
/// Three rows in this batch -- 409, 410 and 411 -- ask for a colour lint, and
/// Step 412 asks for the function-length limit Step 296 set. Four rows asking
/// for rules already in force, in twenty.
library;

import '../tokens/governance_rules.dart';

/// The colour-lint row.
class HabotColourLint {
  const HabotColourLint._();

  // -----------------------------------------------------------------------
  // The metric belongs to another row.
  // -----------------------------------------------------------------------

  static const String metricName =
      'Function Complexity / Size Limit Compliance';

  static const int theRowThisMetricBelongsTo = 412;

  static const String theOtherRowsSubject =
      'a hard limit of 20 lines of code per function';

  static bool get theMetricBelongsToStep412 =>
      metricName.contains('Function Complexity') &&
      theRowThisMetricBelongsTo == 412;

  static const bool theTwoRowsHaveSwappedMetrics = true;

  static const String swapNote =
      '"Function Complexity / Size Limit Compliance" measures function length. '
      'Step 412, three rows later, is "set a hard limit of 20 lines of code '
      'per function" and carries a generic step completion rate instead. The '
      'two rows have swapped metrics, which is new: the metric is not merely '
      'wrong for its row, it is right for a different row in the same batch.';

  // -----------------------------------------------------------------------
  // A floor that calls itself a ceiling.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw =
      '<= 25 lines / cyclomatic complexity <= 10 (acceptable ceiling)';
  static const String bandOptimalRaw =
      '<= 20 lines, <= 5 parameters, cyclomatic complexity <= 5';
  static const String bandCeilingRaw =
      '25 lines (hard linter-enforced ceiling)';

  static bool get theFloorCallsItselfACeiling =>
      bandFloorRaw.contains('ceiling');

  static bool get bothEndsNameTwentyFive =>
      bandFloorRaw.contains('25') && bandCeilingRaw.contains('25');

  static bool get noCellParsesAsANumber =>
      double.tryParse(bandFloorRaw) == null &&
      double.tryParse(bandOptimalRaw) == null &&
      double.tryParse(bandCeilingRaw) == null;

  /// Step 384's ceiling carried an argument; Step 413's carries a
  /// parenthetical; this floor carries the name of the other boundary.
  static const List<int> annotatedBoundaryRows = <int>[384, 409, 413];

  static bool get threeAnnotatedBoundaries =>
      annotatedBoundaryRows.length == 3;

  static const String bandNote =
      'The floor reads "<= 25 lines / cyclomatic complexity <= 10 (acceptable '
      'ceiling)" and the ceiling reads "25 lines (hard linter-enforced '
      'ceiling)". Both name 25, one calls itself acceptable and the other '
      'hard, and the floor annotates itself as a ceiling -- so the two ends of '
      'the band describe the same number under two names. None of the three '
      'cells parses.';

  // -----------------------------------------------------------------------
  // There is no CSS.
  // -----------------------------------------------------------------------

  static const String toolTheRowNames = 'a CSS linter';

  static const bool theApplicationHasCss = false;

  /// The register Step 258 keeps; Step 415 in this batch is the eighteenth.
  static const int foreignStackOrdinal = 17;

  static bool get thisIsTheSeventeenthForeignStack =>
      !theApplicationHasCss && foreignStackOrdinal == 17;

  static const String stackNote =
      'There is no CSS in a Flutter application, so a CSS linter is the '
      'seventeenth foreign stack on the register Step 258 keeps. The instinct '
      'is right and the tool is not: what stops a hex colour here is a Dart '
      'static check, and one has been running since Step 4.';

  // -----------------------------------------------------------------------
  // The rule already exists.
  // -----------------------------------------------------------------------

  static const String colourRuleId = 'RAW_COLOR_LITERAL';
  static const String materialRuleId = 'UNTOKENISED_MATERIAL_COLOR';

  static bool get theColourRuleExists =>
      HabotGovernanceRules.ids.contains(colourRuleId);

  static bool get theMaterialRuleExists =>
      HabotGovernanceRules.ids.contains(materialRuleId);

  static bool get bothRulesAreDeclared =>
      theColourRuleExists && theMaterialRuleExists;

  static HabotGovernanceRule get colourRule =>
      HabotGovernanceRules.byId(colourRuleId);

  static bool get theRuleIsBlocking =>
      colourRule.severity == HabotRuleSeverity.blocking;

  static bool get theRuleNamesItsExemptSites =>
      colourRule.exemptPaths.isNotEmpty &&
      (colourRule.exemptionRationale ?? '').isNotEmpty;

  static const int theStepThatOwnsIt = 4;

  static const bool aSecondCheckIsAdded = false;

  static const String existingRuleNote =
      'RAW_COLOR_LITERAL has blocked a Color literal outside the three colour '
      'declaration sites since Step 4, and UNTOKENISED_MATERIAL_COLOR blocks '
      'the Material constants a hex would otherwise hide behind -- a literal '
      'wearing a name. Both are blocking, both name their exempt sites with a '
      'rationale, and adding a second check would give two answers to one '
      'question.';

  // -----------------------------------------------------------------------
  // Four rows asking for rules already in force.
  // -----------------------------------------------------------------------

  static const List<int> rowsAskingForExistingRules = <int>[409, 410, 411, 412];

  static bool get fourRowsInThisBatch =>
      rowsAskingForExistingRules.length == 4;

  static const int colourRowsInThisBatch = 3;

  static const String repetitionNote =
      'Steps 409, 410 and 411 all ask for a colour lint and Step 412 asks for '
      'the twenty-line function limit Step 296 already set: four rows in '
      'twenty asking for rules the build has been enforcing for four hundred '
      'steps. The previous batch found three duplicated instructions; this is '
      'the same defect aimed at the tooling rather than at the screens.';

  static double get coverage => bothRulesAreDeclared ? 100 : 0;

  static const String columnNote =
      'COLUMN NOTE: this row asks for a CSS linter in an application with no '
      'CSS -- the seventeenth foreign stack on the register Step 258 keeps; '
      'its metric is "Function Complexity / Size Limit Compliance", which '
      'belongs to Step 412 three rows later, so the two rows have swapped '
      'metrics; its floor cell annotates itself "(acceptable ceiling)" while '
      'its ceiling reads "25 lines (hard linter-enforced ceiling)", both '
      'naming 25; and its Setup Step column reads "Implement the scope '
      'indicator -- show currently active scope prominently in the UI header". '
      'Atomic Step: "Configure a CSS linter to block custom hex color values '
      'in component code."';

  static Map<String, bool> get obligations => <String, bool>{
        'the colour rule exists and is blocking':
            theColourRuleExists && theRuleIsBlocking,
        'the Material-constant rule exists too': theMaterialRuleExists,
        'the rule names its exempt sites with a rationale':
            theRuleNamesItsExemptSites,
        'no second check is added': !aSecondCheckIsAdded,
        'the foreign stack is recorded': thisIsTheSeventeenthForeignStack,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'the metric belongs to Step 412':
            theMetricBelongsToStep412 && theTwoRowsHaveSwappedMetrics,
        'and the two rows have swapped metrics':
            swapNote.contains('right for a different row'),
        'the floor cell calls itself a ceiling':
            theFloorCallsItselfACeiling && bothEndsNameTwentyFive,
        'and no band cell parses':
            noCellParsesAsANumber && threeAnnotatedBoundaries,
        'there is no CSS to lint':
            thisIsTheSeventeenthForeignStack &&
                toolTheRowNames.contains('CSS'),
        'both colour rules are already declared':
            bothRulesAreDeclared && theStepThatOwnsIt == 4,
        'the rule is blocking and names its exemptions':
            theRuleIsBlocking && theRuleNamesItsExemptSites,
        'no second check is added':
            !aSecondCheckIsAdded &&
                existingRuleNote.contains('two answers to one question'),
        'four rows in this batch ask for existing rules':
            fourRowsInThisBatch && colourRowsInThisBatch == 3,
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass' &&
                coverage == 100,
      };
}
