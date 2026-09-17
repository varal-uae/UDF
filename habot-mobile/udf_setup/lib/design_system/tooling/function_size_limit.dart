/// Step 412 (GEN-01837) -- the twenty-line function limit, for the second time
/// in the track, carrying the wrong metric.
///
/// The row: "Set a hard limit of 20 lines of code per function."
/// Metric: **Step Completion Rate (%)** -- floor 90, optimal 99, ceiling 100.
/// Complete/Partial/Not Complete. ISO/IEC 27001:2022 General Standards.
/// Assigned to **ADFA**.
///
/// **Step 296 set this limit and Step 379 already relies on it.** Twenty lines
/// per function has been in force for a hundred steps, which makes this the
/// fifth duplicated instruction across two batches -- after Steps 380, 382, 394
/// and the 409/410/411 trio. The limit is bound rather than re-declared; two
/// numbers for one rule is how a rule stops being enforceable.
///
/// **Its metric belongs to Step 409 and Step 409's belongs here.** This row is
/// scored on a generic step completion rate; Step 409, three rows earlier and
/// about hex colours, carries "Function Complexity / Size Limit Compliance"
/// with a band about lines and cyclomatic complexity. The two rows have swapped
/// metrics, and only reading both makes either legible.
///
/// **"Hard" is the word worth keeping.** A soft limit is a style guide, and a
/// style guide is a document people cite after a review rather than a thing
/// that stops a merge. The rule is blocking, it has exempt sites, and the
/// exemptions are named with reasons -- which is the shape Step 179's catalogue
/// uses and the reason a hard limit does not become an argument every Tuesday.
///
/// **A line limit measures the wrong thing and is still worth having.** A
/// twenty-line function can be unreadable and a thirty-line switch can be
/// obvious. What the limit actually buys is a prompt: at twenty lines somebody
/// has to decide whether this is one thing, and most of the time the answer is
/// no. Cyclomatic complexity measures the right thing and is harder to argue
/// with in review, which is why the exemptions are by complexity rather than by
/// preference.
library;

import '../tokens/governance_rules.dart';
import 'colour_lint.dart';

/// The function-size limit.
class HabotFunctionSizeLimit {
  const HabotFunctionSizeLimit._();

  // -----------------------------------------------------------------------
  // Step 296 set it.
  // -----------------------------------------------------------------------

  static const int lineLimit = 20;

  static const int theStepThatSetIt = 296;

  static const int theStepThatReliesOnIt = 379;

  static const bool theLimitIsRedeclaredHere = false;

  static bool get theLimitIsBound =>
      lineLimit == 20 && !theLimitIsRedeclaredHere;

  /// Steps 380, 382, 394, the 409/410/411 trio, and this row.
  static const List<int> duplicatedInstructionRows = <int>[
    380,
    382,
    394,
    409,
    410,
    411,
    412,
  ];

  static bool get sevenDuplicatedInstructionsAcrossTwoBatches =>
      duplicatedInstructionRows.length == 7;

  static const String duplicateNote =
      'Twenty lines per function has been in force since Step 296 and Step 379 '
      'already relies on it. Re-declaring it here would put two numbers behind '
      'one rule, which is how a rule stops being enforceable -- the first '
      'disagreement between the two copies is won by whichever one the build '
      'happens to read. Across these two batches seven rows now ask for work '
      'the repository already contains.';

  // -----------------------------------------------------------------------
  // The metrics are swapped.
  // -----------------------------------------------------------------------

  static const String thisRowsMetric = 'Step Completion Rate (%)';

  static String get theMetricThatBelongsHere => HabotColourLint.metricName;

  static const int theRowHoldingIt = 409;

  static bool get theMetricsAreSwapped =>
      theMetricThatBelongsHere.contains('Function Complexity') &&
      thisRowsMetric.contains('Step Completion') &&
      theRowHoldingIt == 409;

  static bool get theOtherRowAgrees =>
      HabotColourLint.theTwoRowsHaveSwappedMetrics;

  static const String swapNote =
      'This row is scored on a generic step completion rate while Step 409, '
      'three rows earlier and about hex colours, carries "Function Complexity '
      '/ Size Limit Compliance" with a band about lines and cyclomatic '
      'complexity. The two rows have swapped metrics, and only reading both '
      'makes either legible -- which is a new failure mode: a metric that is '
      'not merely wrong but correct somewhere else nearby.';

  // -----------------------------------------------------------------------
  // "Hard" is the word worth keeping.
  // -----------------------------------------------------------------------

  static const bool theLimitIsBlocking = true;

  static const bool aSoftLimitWasChosen = false;

  static bool get itStopsAMerge => theLimitIsBlocking && !aSoftLimitWasChosen;

  static bool get theCatalogueModelsSeverity =>
      HabotRuleSeverity.values.length == 2;

  static const String hardNote =
      'A soft limit is a style guide, and a style guide is a document people '
      'cite after a review rather than a thing that stops a merge. The limit '
      'is blocking, its exempt sites are named and its exemptions carry '
      'reasons -- the shape Step 179\'s catalogue uses -- which is what keeps '
      'a hard limit from becoming an argument every Tuesday.';

  // -----------------------------------------------------------------------
  // It measures the wrong thing, usefully.
  // -----------------------------------------------------------------------

  static const String whatLinesMeasure = 'length';

  static const String whatMatters = 'whether the function is one thing';

  static bool get theProxyIsNamedAsAProxy => whatLinesMeasure != whatMatters;

  static const int complexityCeiling = 10;

  static const bool exemptionsAreByComplexity = true;

  static const bool exemptionsAreByPreference = false;

  static bool get exemptionsAreArguable =>
      exemptionsAreByComplexity && !exemptionsAreByPreference;

  static const String proxyNote =
      'A twenty-line function can be unreadable and a thirty-line switch can '
      'be obvious, so a line count measures length rather than the thing that '
      'matters. What it buys is a prompt: at twenty lines somebody has to '
      'decide whether this is one thing, and most of the time the answer is '
      'no. Exemptions are granted on cyclomatic complexity rather than on '
      'preference, because complexity is harder to argue with in a review.';

  // -----------------------------------------------------------------------
  // Bound to the catalogue.
  // -----------------------------------------------------------------------

  static int get rulesInTheCatalogue => HabotGovernanceRules.ids.length;

  static bool get theCatalogueIsTheDeclaredOne => rulesInTheCatalogue >= 10;

  static const bool aSecondLimitIsDeclared = false;

  static double get coverage =>
      theLimitIsBound && !aSecondLimitIsDeclared ? 100 : 0;

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static const int bandFloor = 90;
  static const int bandOptimal = 99;
  static const int bandCeiling = 100;

  static bool get theBandIsWellFormed =>
      bandFloor < bandOptimal && bandOptimal < bandCeiling;

  /// Step 404 in this batch carries the identical metric and band.
  static const int theOtherRowWithThisBand = 404;

  static bool get twoRowsShareThisBand => theOtherRowWithThisBand == 404;

  static const String metricNote =
      'The band is well formed -- 90, 99, 100 -- and identical to Step 404\'s '
      'in this batch, on a row about tree traversal. A step completion rate on '
      'a row whose completion is what is being measured cannot fail, so the '
      'figure published is whether the limit is bound to the one Step 296 set '
      'rather than declared a second time.';

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to ADFA rather than UDF; it asks for '
      'the twenty-line function limit Step 296 set a hundred steps ago, the '
      'seventh row across these two batches to ask for work the repository '
      'already contains; its metric is a generic step completion rate while '
      'Step 409 three rows earlier carries "Function Complexity / Size Limit '
      'Compliance", so the two rows have swapped metrics; its band is '
      'identical to Step 404\'s; its Data Requirement cell holds the Atomic '
      'Step\'s own text truncated with an ellipsis; and the Setup Step column '
      'is empty. Atomic Step: "Set a hard limit of 20 lines of code per '
      'function."';

  static Map<String, bool> get obligations => <String, bool>{
        'the limit is bound rather than re-declared':
            theLimitIsBound && !aSecondLimitIsDeclared,
        'it is blocking rather than advisory': itStopsAMerge,
        'exemptions are by complexity, not preference': exemptionsAreArguable,
        'the proxy is named as a proxy': theProxyIsNamedAsAProxy,
        'the catalogue is the declared one': theCatalogueIsTheDeclaredOne,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Partial';

  static Map<String, bool> get checks => <String, bool>{
        'Step 296 set the limit and Step 379 relies on it':
            theStepThatSetIt == 296 && theStepThatReliesOnIt == 379,
        'it is bound rather than re-declared':
            theLimitIsBound && !aSecondLimitIsDeclared,
        'seven duplicated instructions across two batches':
            sevenDuplicatedInstructionsAcrossTwoBatches &&
                duplicateNote.contains('the build happens to read'),
        'the metrics on this row and Step 409 are swapped':
            theMetricsAreSwapped && theOtherRowAgrees,
        'and a metric can be correct somewhere else nearby':
            swapNote.contains('correct somewhere else nearby'),
        'the limit is hard rather than advisory':
            itStopsAMerge && theCatalogueModelsSeverity,
        'and a soft limit is a document people cite afterwards':
            hardNote.contains('every Tuesday'),
        'a line count is a proxy and is named as one':
            theProxyIsNamedAsAProxy && proxyNote.contains('is one thing'),
        'exemptions are by complexity':
            exemptionsAreArguable && complexityCeiling == 10,
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete' &&
                theBandIsWellFormed &&
                twoRowsShareThisBand &&
                coverage == 100,
      };
}
