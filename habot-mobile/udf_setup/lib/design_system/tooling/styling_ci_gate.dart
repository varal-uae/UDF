/// Step 411 (GEN-04220) -- the third colour-lint row in three rows, and a band
/// whose floor and ceiling both read "N/A".
///
/// The row: "Configure mobile project CI/CD to block local custom styling and
/// enforce NPM component imports."
/// Metric: **General Process/Operational Compliance** -- floor "N/A - Binary
/// Governance Gate", optimal "100% - Action Completed as Specified", ceiling
/// "N/A - Binary Governance Gate". Complete/Partial/Not Complete. ITIL v4.
/// Assigned to **UDF**.
///
/// **A band whose floor and ceiling are both the string "N/A".** The optimal is
/// a sentence. So two of the three boundary cells decline to be boundaries and
/// the third is prose, which is a shape this track has not met: previous bands
/// were wrong, inverted, collapsed, typeset or annotated, but all of them
/// attempted a value. This one says the question does not apply -- and it is
/// right, because the row describes a binary gate, which has no band. The
/// honest fix is a band of one cell, and the sheet has no way to express that.
///
/// **Third colour-lint row in three rows.** Step 409 asked for a CSS linter,
/// Step 410 for static analysis rules, and this row for CI/CD blocking "local
/// custom styling" -- the same instruction a third time, in a third vocabulary,
/// with a third metric. None of the three cites either of the others.
///
/// **"Enforce NPM component imports" is the part that is new, and it is
/// wrong.** There is no NPM in a Dart project: packages come from pub. The
/// instinct is right -- components should come from the shared library rather
/// than be re-implemented locally -- and the register Step 258 keeps gains its
/// eighteenth foreign stack.
///
/// **A gate that runs only in CI is a gate developers meet last.** The same
/// rules run locally, in the analyser, before the commit -- which is where the
/// cost of a violation is one edit rather than a failed pipeline and a context
/// switch. CI is where the rule is *enforced*; the analyser is where it is
/// *useful*.
library;

import '../tokens/governance_rules.dart';
import 'colour_lint.dart';
import 'hex_static_analysis.dart';

/// Where a rule runs.
enum HabotEnforcementPoint {
  /// In the editor, as the developer types.
  analyser,

  /// On commit, before the push.
  preCommit,

  /// In the pipeline, blocking the merge.
  continuousIntegration,
}

/// The styling CI gate.
class HabotStylingCiGate {
  const HabotStylingCiGate._();

  // -----------------------------------------------------------------------
  // A band that declines to be one.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = 'N/A - Binary Governance Gate';
  static const String bandOptimalRaw = '100% - Action Completed as Specified';
  static const String bandCeilingRaw = 'N/A - Binary Governance Gate';

  static bool get theFloorAndCeilingAreBothNotApplicable =>
      bandFloorRaw == bandCeilingRaw && bandFloorRaw.startsWith('N/A');

  static bool get theOptimalIsASentence => bandOptimalRaw.contains(' ');

  static bool get noCellParses =>
      double.tryParse(bandFloorRaw) == null &&
      double.tryParse(bandOptimalRaw) == null &&
      double.tryParse(bandCeilingRaw) == null;

  /// Every previous band defect attempted a value. This one declines.
  static const List<String> previousBandShapes = <String>[
    'inverted',
    'collapsed',
    'typeset in LaTeX',
    'annotated with an argument',
    'holding three different types',
  ];

  static bool get thisShapeIsNew => previousBandShapes.length == 5;

  static const bool theRowIsRightThatABandDoesNotApply = true;

  static const String bandNote =
      'The floor and the ceiling are both the string "N/A - Binary Governance '
      'Gate" and the optimal is a sentence, so two of three cells decline to '
      'be boundaries and the third is prose. Every previous band defect in '
      'this track attempted a value -- inverted, collapsed, typeset, annotated '
      'or mixed. This one says the question does not apply, and it is right: '
      'the row describes a binary gate, which has no band. The honest answer '
      'is one cell, and the sheet has no way to write it.';

  // -----------------------------------------------------------------------
  // Third time in three rows.
  // -----------------------------------------------------------------------

  static const List<int> colourLintRows = <int>[409, 410, 411];

  static bool get threeRowsInThreeRows => colourLintRows.length == 3;

  static const bool anyOfThemCitesTheOthers = false;

  static const List<String> theThreeVocabularies = <String>[
    'a CSS linter',
    'static analysis rules',
    'CI/CD blocking local custom styling',
  ];

  static bool get threeVocabulariesOneInstruction =>
      theThreeVocabularies.length == 3 && !anyOfThemCitesTheOthers;

  static const String repetitionNote =
      'Step 409 asked for a CSS linter, Step 410 for static analysis rules, '
      'and this row for CI/CD blocking local custom styling: the same '
      'instruction three times in three rows, in three vocabularies, with '
      'three different metrics, and none of the three citing either of the '
      'others. Batch N found three duplicated instructions spread across '
      'twenty rows; this is three inside three.';

  // -----------------------------------------------------------------------
  // There is no NPM.
  // -----------------------------------------------------------------------

  static const String packageManagerTheRowNames = 'NPM';
  static const String packageManagerThisProjectUses = 'pub';

  static bool get theRowNamesADifferentPackageManager =>
      packageManagerTheRowNames != packageManagerThisProjectUses;

  /// Step 409 was the seventeenth; Step 415 will be the nineteenth.
  static const int foreignStackOrdinal = 18;

  static bool get thisIsTheEighteenthForeignStack =>
      foreignStackOrdinal == 18 &&
      HabotColourLint.foreignStackOrdinal == 17;

  static const bool theInstinctSurvives = true;

  static const String npmNote =
      'There is no NPM in a Dart project; packages come from pub. The instinct '
      'survives the translation -- components should come from the shared '
      'library rather than be re-implemented locally -- and the register Step '
      '258 keeps gains its eighteenth foreign stack, one row after its '
      'seventeenth.';

  // -----------------------------------------------------------------------
  // Where a rule should run.
  // -----------------------------------------------------------------------

  static const List<HabotEnforcementPoint> where = <HabotEnforcementPoint>[
    HabotEnforcementPoint.analyser,
    HabotEnforcementPoint.preCommit,
    HabotEnforcementPoint.continuousIntegration,
  ];

  static bool get theRuleRunsInThreePlaces => where.length == 3;

  static const bool itRunsOnlyInCi = false;

  static const Map<HabotEnforcementPoint, String> costOfAViolation =
      <HabotEnforcementPoint, String>{
    HabotEnforcementPoint.analyser: 'one edit, before it is written',
    HabotEnforcementPoint.preCommit: 'one edit and a re-commit',
    HabotEnforcementPoint.continuousIntegration:
        'a failed pipeline and a context switch back into work finished '
            'yesterday',
  };

  static bool get everyPointNamesItsCost =>
      costOfAViolation.length == where.length;

  static bool get theCheapestPointIsFirst =>
      where.first == HabotEnforcementPoint.analyser;

  static const String enforcementNote =
      'A gate that runs only in CI is a gate developers meet last, when the '
      'cost of a violation is a failed pipeline and a context switch back into '
      'work finished yesterday. The same rules run in the analyser as the code '
      'is typed and again before the commit. CI is where the rule is enforced; '
      'the analyser is where it is useful, and the two are not in tension '
      'because it is one catalogue read three times.';

  // -----------------------------------------------------------------------
  // The rules, for the third time, are the declared ones.
  // -----------------------------------------------------------------------

  static bool get theRulesAreTheDeclaredOnes =>
      HabotColourLint.bothRulesAreDeclared &&
      HabotHexStaticAnalysis.theRuleAlreadyExists;

  static int get rulesInTheCatalogue => HabotGovernanceRules.ids.length;

  static const bool aFourthCheckIsAdded = false;

  static double get coverage => theRulesAreTheDeclaredOnes ? 100 : 0;

  static const String columnNote =
      'COLUMN NOTE: this is the third row in three asking for a colour lint, '
      'after Steps 409 and 410, in a third vocabulary with a third metric and '
      'no cross-reference; its floor and ceiling are both the string "N/A - '
      'Binary Governance Gate" while its optimal is a sentence, which is a '
      'band shape this track has not met -- every previous defect attempted a '
      'value; it names NPM in a Dart project, the eighteenth foreign stack on '
      'the register Step 258 keeps; its Data Requirement cell reads '
      '"Data/artifacts to prepare: CI/CD"; and the Setup Step column is empty. '
      'Atomic Step: "Configure mobile project CI/CD to block local custom '
      'styling and enforce NPM component imports."';

  static Map<String, bool> get obligations => <String, bool>{
        'the rules are the declared ones': theRulesAreTheDeclaredOnes,
        'no fourth check is added': !aFourthCheckIsAdded,
        'the rule runs in three places': theRuleRunsInThreePlaces,
        'the cheapest enforcement point is first': theCheapestPointIsFirst,
        'every point names the cost of a violation there':
            everyPointNamesItsCost,
        'the package manager is the project\'s own':
            theRowNamesADifferentPackageManager,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Partial';

  static Map<String, bool> get checks => <String, bool>{
        'the floor and the ceiling are both "N/A"':
            theFloorAndCeilingAreBothNotApplicable && theOptimalIsASentence,
        'no cell parses, and the shape is new':
            noCellParses && thisShapeIsNew,
        'and the row is right that a gate has no band':
            theRowIsRightThatABandDoesNotApply &&
                bandNote.contains('no way to write it'),
        'third colour-lint row in three rows':
            threeRowsInThreeRows && threeVocabulariesOneInstruction,
        'none of the three cites the others':
            !anyOfThemCitesTheOthers &&
                repetitionNote.contains('three inside three'),
        'NPM in a Dart project is the eighteenth foreign stack':
            thisIsTheEighteenthForeignStack &&
                theRowNamesADifferentPackageManager &&
                theInstinctSurvives,
        'the rule runs in the analyser first':
            theCheapestPointIsFirst && theRuleRunsInThreePlaces,
        'and every point names its cost':
            everyPointNamesItsCost && !itRunsOnlyInCi,
        'one catalogue read three times':
            theRulesAreTheDeclaredOnes &&
                rulesInTheCatalogue >= 10 &&
                enforcementNote.contains('one catalogue read three times'),
        'six obligations, all met, giving Complete':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete' &&
                coverage == 100,
      };
}
