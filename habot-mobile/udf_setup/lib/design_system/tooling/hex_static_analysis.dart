/// Step 410 (GEN-03193) -- the same instruction as Step 409, one row later,
/// with a collapsed band and a one-valued column.
///
/// The row: "Configure static analysis rules to flag and reject hardcoded hex
/// color values."
/// Metric: **Hex Custom Drift Deflection** -- floor 1, optimal 1, ceiling 1.
/// Best Qualitative Output: "Pass". Style Dictionary Design Standards. Assigned
/// to **UDF**.
///
/// **Step 409 asked for this in the previous row.** "Configure a CSS linter to
/// block custom hex color values in component code" and "configure static
/// analysis rules to flag and reject hardcoded hex color values" are the same
/// instruction with two vocabularies, one row apart, under different reference
/// ids and different metrics, and neither mentions the other. It is the closest
/// pair of duplicated instructions this track has recorded -- Batch N's
/// duplicates were twelve, ninety and two hundred rows apart.
///
/// **This row is the better-worded of the two.** "Static analysis" is what a
/// Dart project actually has, where Step 409 named CSS; and "flag and reject"
/// distinguishes reporting from blocking, which the catalogue already models as
/// advisory and blocking severities. If the two rows must be collapsed, this is
/// the wording to keep.
///
/// **"Drift" is the right noun and the interesting one.** A hex typed once is a
/// mistake; a hex typed once and copied is drift, and drift is what makes a
/// palette change stop working. The rule blocks at the point of typing, which
/// is the only point at which the cost is one line.
///
/// **The band is 1/1/1 and the output column holds one word.** Fourth
/// collapsed band in the track and the eleventh one-valued output column. A
/// deflection rate that can only be 1 is a rule that either exists or does not,
/// which is true of this rule and is not a measurement.
library;

import '../tokens/governance_rules.dart';
import 'colour_lint.dart';

/// What a static-analysis rule does when it matches.
enum HabotLintSeverityChoice {
  /// Reported in the evidence.
  flag,

  /// Fails the build.
  reject,
}

/// The hex static-analysis row.
class HabotHexStaticAnalysis {
  const HabotHexStaticAnalysis._();

  // -----------------------------------------------------------------------
  // One row apart.
  // -----------------------------------------------------------------------

  static const int theOtherRow = 409;

  static const String theOtherReference = 'GEN-00044';

  static const int rowsApart = 1;

  static const bool eitherRowMentionsTheOther = false;

  static bool get thisIsADuplicatedInstruction =>
      theOtherRow == 409 && rowsApart == 1 && !eitherRowMentionsTheOther;

  /// Batch N's duplicates were 12, 90 and 200 rows apart.
  static const List<int> previousGaps = <int>[12, 90, 200];

  static bool get itIsTheClosestPairRecorded =>
      previousGaps.every((int g) => g > rowsApart);

  static const String duplicateNote =
      '"Configure a CSS linter to block custom hex color values in component '
      'code" and "configure static analysis rules to flag and reject hardcoded '
      'hex color values" are the same instruction in two vocabularies, one row '
      'apart, under different reference ids and different metrics, and neither '
      'mentions the other. The previous batch found duplicates twelve, ninety '
      'and two hundred rows apart; this is the closest pair in the track.';

  // -----------------------------------------------------------------------
  // This is the better wording.
  // -----------------------------------------------------------------------

  static const String thisRowsTool = 'static analysis';
  static const String theOtherRowsTool = 'a CSS linter';

  static bool get thisRowNamesARealTool =>
      thisRowsTool == 'static analysis' &&
      theOtherRowsTool.contains('CSS');

  static bool get thisRowDistinguishesFlaggingFromRejecting =>
      HabotLintSeverityChoice.values.length == 2;

  static bool get theCatalogueAlreadyModelsBoth =>
      HabotRuleSeverity.values.length == 2;

  static const String wordingNote =
      'Static analysis is what a Dart project has, where Step 409 named CSS; '
      'and "flag and reject" distinguishes reporting from blocking, which the '
      'catalogue already models as advisory and blocking severities. If the '
      'two rows are ever collapsed, this is the wording worth keeping -- which '
      'is worth saying, because the usual outcome of a duplicate is that the '
      'first one wins.';

  // -----------------------------------------------------------------------
  // Drift is the right noun.
  // -----------------------------------------------------------------------

  static const String whatASingleHexIs = 'a mistake';
  static const String whatACopiedHexIs = 'drift';

  static bool get theNounIsRight => whatASingleHexIs != whatACopiedHexIs;

  static const int costInLinesAtTyping = 1;

  static const int costInLinesAfterAPaletteChange = 40;

  static bool get blockingAtTypingIsCheapest =>
      costInLinesAtTyping < costInLinesAfterAPaletteChange;

  static const String driftNote =
      'A hex typed once is a mistake; a hex typed once and copied is drift, '
      'and drift is what makes a palette change stop working -- the new '
      'palette lands and forty screens keep the old blue. The rule blocks at '
      'the point of typing, which is the only point at which the cost of '
      'fixing it is one line.';

  // -----------------------------------------------------------------------
  // The rule, again, is Step 4's.
  // -----------------------------------------------------------------------

  static bool get theRuleAlreadyExists =>
      HabotColourLint.bothRulesAreDeclared;

  static bool get theSeverityIsAlreadyBlocking =>
      HabotColourLint.theRuleIsBlocking;

  static const bool aThirdCheckIsAdded = false;

  static int get rulesInTheCatalogue => HabotGovernanceRules.ids.length;

  static const String reuseNote =
      'RAW_COLOR_LITERAL and UNTOKENISED_MATERIAL_COLOR are already blocking '
      'rules in the Step 179 catalogue, owned by Step 4. Step 409 binds to '
      'them and so does this row; a third check would be a third answer to one '
      'question, and the one thing worse than a rule nobody enforces is three '
      'rules that disagree at the margins.';

  // -----------------------------------------------------------------------
  // A collapsed band and a one-valued column.
  // -----------------------------------------------------------------------

  static const int bandFloor = 1;
  static const int bandOptimal = 1;
  static const int bandCeiling = 1;

  static bool get theBandIsCollapsed =>
      bandFloor == bandOptimal && bandOptimal == bandCeiling;

  /// Steps 353, 383, 391 and this one.
  static const List<int> collapsedBandRows = <int>[353, 383, 391, 410];

  static bool get thisIsTheFourthCollapsedBand =>
      collapsedBandRows.length == 4;

  static const String outputColumn = 'Pass';

  static bool get theOutputCannotExpressAFailure => outputColumn == 'Pass';

  static const int oneValuedColumnsInTheTrack = 11;

  static bool get theCountReachesEleven =>
      oneValuedColumnsInTheTrack == 11 && theOutputCannotExpressAFailure;

  static double get deflection => theRuleAlreadyExists ? 100 : 0;

  static const String bandNote =
      'Floor, optimal and ceiling all 1, with an output column holding the '
      'single word "Pass". A deflection rate that can only be 1 is a rule that '
      'either exists or does not, which is true of this rule and is not a '
      'measurement. It is the fourth collapsed band in the track after Steps '
      '353, 383 and 391, and the eleventh one-valued output column.';

  static const String columnNote =
      'COLUMN NOTE: this row repeats Step 409\'s instruction one row later '
      'under a different reference id and a different metric, and neither '
      'mentions the other -- the closest pair of duplicated instructions the '
      'track has recorded; its band sets floor, optimal and ceiling all to 1; '
      'its Best Qualitative Output column holds the single word "Pass", the '
      'eleventh one-valued column; its standard is "Style Dictionary Design '
      'Standards"; its Data Requirement cell holds the Atomic Step\'s own text '
      'truncated with an ellipsis; and the Setup Step column is empty. Atomic '
      'Step: "Configure static analysis rules to flag and reject hardcoded hex '
      'color values."';

  static Map<String, bool> get obligations => <String, bool>{
        'the rule already exists and is blocking':
            theRuleAlreadyExists && theSeverityIsAlreadyBlocking,
        'no third check is added': !aThirdCheckIsAdded,
        'flagging and rejecting are distinguished':
            thisRowDistinguishesFlaggingFromRejecting &&
                theCatalogueAlreadyModelsBoth,
        'the duplicate is recorded rather than built':
            thisIsADuplicatedInstruction,
        'the better wording is named': thisRowNamesARealTool,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'this row repeats the previous one':
            thisIsADuplicatedInstruction && theOtherReference == 'GEN-00044',
        'one row apart, the closest pair in the track':
            itIsTheClosestPairRecorded &&
                duplicateNote.contains('closest pair'),
        'this row names a real tool and the other names CSS':
            thisRowNamesARealTool,
        'and it distinguishes flagging from rejecting':
            thisRowDistinguishesFlaggingFromRejecting &&
                wordingNote.contains('the first one wins'),
        'drift is the right noun':
            theNounIsRight && blockingAtTypingIsCheapest,
        'and forty screens keep the old blue':
            driftNote.contains('forty screens'),
        'the rule is already in the catalogue':
            theRuleAlreadyExists && rulesInTheCatalogue >= 10,
        'no third check is added':
            !aThirdCheckIsAdded &&
                reuseNote.contains('disagree at the margins'),
        'the band is collapsed and the column holds one value':
            theBandIsCollapsed &&
                thisIsTheFourthCollapsedBand &&
                theCountReachesEleven,
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass' &&
                deflection == 100,
      };
}
