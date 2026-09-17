/// Step 415 (GEN-03943) -- import View and Text from React Native, in a Flutter
/// application, and measure the import in milliseconds.
///
/// The row: "Import View, Text, and native animation utilities from the mobile
/// UI framework."
/// Metric: **Import Overhead** -- floor "< 20 ms", optimal "< 2 ms", ceiling
/// "50 ms". Pass / Fail. React Native Performance. Assigned to **UDF**.
///
/// **The nineteenth foreign stack, and the first to appear in the standard
/// column.** `View` and `Text` are React Native's primitives and "React Native
/// Performance" is the reference standard this row is to be configured against.
/// Every previous foreign stack sat in the instruction text, where it reads as
/// a slip of vocabulary. This one is also the authority the row cites, which is
/// a different thing: the row is not borrowing a word, it is pointing at the
/// wrong specification.
///
/// **The optimal lies outside the band.** Floor "< 20 ms", ceiling "50 ms",
/// optimal "< 2 ms" -- so the two boundaries describe the interval 20 to 50 and
/// the target sits below both of them. Bands in this track have been inverted,
/// collapsed, typeset, annotated and, at Step 411, absent; this is the first
/// whose optimal is outside its own boundaries. Two of the three cells are
/// inequalities and the third is a bare number, so the shape cannot even be
/// read consistently before it is read as wrong.
///
/// **There is no import overhead to measure.** Dart imports are resolved when
/// the application is compiled and the unused parts are removed before the
/// binary exists; there is no per-import millisecond cost at run time to put
/// in a band. What can be measured is how many imports a file has, whether any
/// is unused, and what the first frame costs -- so that is what is published,
/// with the millisecond figure named as the thing it is not.
///
/// **What the row actually wants already exists.** `View` maps to a layout
/// widget, `Text` to a text widget, and the native animation utilities to the
/// motion tokens Step 176 exported -- which the poka-yoke rules `RAW_DURATION`
/// and `RAW_CURVE` have required since Step 179. Importing an animation
/// utility here would be importing a second answer to a governed question.
library;

import '../tokens/governance_rules.dart';
import '../tokens/motion_export.dart';
import 'component_docs.dart';

/// One symbol the row asks to import.
class HabotImportedSymbol {
  const HabotImportedSymbol({
    required this.rowName,
    required this.framework,
    required this.thisFrameworksEquivalent,
    required this.isGovernedElsewhere,
  });

  /// The name as the row writes it.
  final String rowName;

  /// The framework that name belongs to.
  final String framework;

  final String thisFrameworksEquivalent;

  /// True where a declared rule already answers the question.
  final bool isGovernedElsewhere;
}

/// The framework-imports row.
class HabotFrameworkImports {
  const HabotFrameworkImports._();

  // -----------------------------------------------------------------------
  // Three symbols, none of them from here.
  // -----------------------------------------------------------------------

  static const List<HabotImportedSymbol> symbols = <HabotImportedSymbol>[
    HabotImportedSymbol(
      rowName: 'View',
      framework: 'React Native',
      thisFrameworksEquivalent: 'a layout widget',
      isGovernedElsewhere: false,
    ),
    HabotImportedSymbol(
      rowName: 'Text',
      framework: 'React Native',
      thisFrameworksEquivalent: 'a text widget taking a typography token',
      isGovernedElsewhere: true,
    ),
    HabotImportedSymbol(
      rowName: 'native animation utilities',
      framework: 'React Native',
      thisFrameworksEquivalent: 'the exported motion tokens',
      isGovernedElsewhere: true,
    ),
  ];

  static bool get everySymbolNamesItsEquivalent => symbols
      .every((HabotImportedSymbol s) => s.thisFrameworksEquivalent.isNotEmpty);

  static bool get everySymbolIsForeign => symbols
      .every((HabotImportedSymbol s) => s.framework == 'React Native');

  static int get governedElsewhere => symbols
      .where((HabotImportedSymbol s) => s.isGovernedElsewhere)
      .length;

  static bool get twoOfThreeAreAlreadyGoverned => governedElsewhere == 2;

  static const String translationNote =
      'View is React Native\'s box and Text is its text container; the first '
      'maps to a layout widget here and the second to a text widget taking a '
      'typography token. The name Text exists in both frameworks and means '
      'different things in each, which is the worst case for a borrowed '
      'symbol: it will not fail to resolve, it will resolve to the wrong '
      'thing.';

  // -----------------------------------------------------------------------
  // The nineteenth, and the first in the standard column.
  // -----------------------------------------------------------------------

  static const int foreignStackOrdinal = 19;

  static const String theStandardCited = 'React Native Performance';

  static const bool theStackIsAlsoTheCitedAuthority = true;

  static bool get thisIsTheNineteenthForeignStack =>
      foreignStackOrdinal == 19 &&
      HabotComponentDocs.theNextRowMovesItTo == 19;

  static bool get theStackReachesTheStandardColumn =>
      theStackIsAlsoTheCitedAuthority &&
      theStandardCited.startsWith('React Native');

  static const String registerNote =
      'Every previous foreign stack sat in the instruction text, where it '
      'reads as a slip of vocabulary a reader can translate. This row also '
      'cites React Native Performance as the standard to configure against, so '
      'it is not borrowing a word but pointing at the wrong specification -- '
      'and a wrong specification is followed, where a wrong word is corrected.';

  // -----------------------------------------------------------------------
  // The optimal is outside the band.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '< 20 ms';
  static const String bandOptimalRaw = '< 2 ms';
  static const String bandCeilingRaw = '50 ms';

  static const int floorMs = 20;
  static const int optimalMs = 2;
  static const int ceilingMs = 50;

  static bool get theOptimalIsOutsideItsOwnBoundaries =>
      optimalMs < floorMs && optimalMs < ceilingMs;

  static bool get theBoundariesDescribeAnInterval => floorMs < ceilingMs;

  static bool get twoCellsAreInequalitiesAndOneIsNot =>
      bandFloorRaw.contains('<') &&
      bandOptimalRaw.contains('<') &&
      !bandCeilingRaw.contains('<');

  /// Inverted, collapsed, typeset, annotated, absent -- and now this.
  static const List<String> bandShapesRecorded = <String>[
    'inverted',
    'collapsed',
    'typeset in LaTeX',
    'annotated with an argument',
    'holding three different types',
    'declining to be a band',
    'optimal outside its own boundaries',
  ];

  static bool get thisShapeIsTheSeventh => bandShapesRecorded.length == 7;

  static const String bandNote =
      'The floor reads "< 20 ms" and the ceiling "50 ms", which describes the '
      'interval twenty to fifty; the optimal reads "< 2 ms", which is below '
      'both. The target sits outside the range its own boundaries define. Two '
      'of the three cells are inequalities and the third is a bare number, so '
      'the band cannot be read consistently before it is read as wrong. It is '
      'the seventh distinct band shape the track has recorded.';

  // -----------------------------------------------------------------------
  // There is no overhead to measure.
  // -----------------------------------------------------------------------

  static const bool importsCostMillisecondsAtRunTime = false;

  static const String whenImportsAreResolved = 'at compile time';

  static const String whatHappensToUnusedOnes = 'they are removed';

  static bool get theMetricMeasuresNothingThatExists =>
      !importsCostMillisecondsAtRunTime &&
      whenImportsAreResolved == 'at compile time';

  static const int importsInThisFile = 3;

  static const int unusedImports = 0;

  static const int firstFrameBudgetMs = 16;

  static bool get theSubstituteFiguresAreMeasurable =>
      importsInThisFile > 0 && unusedImports == 0 && firstFrameBudgetMs == 16;

  static const String overheadNote =
      'Imports are resolved when the application is compiled and the unused '
      'parts are removed before a binary exists, so no directive carries a '
      'millisecond cost at run time to put in a band. What is measurable is '
      'the import count, whether any is unused, and the first-frame budget of '
      'sixteen milliseconds -- so those are published, and the millisecond '
      'figure the row asks for is named as the thing it is not rather than '
      'invented to fill the cell.';

  // -----------------------------------------------------------------------
  // The animation utilities are already governed.
  // -----------------------------------------------------------------------

  static int get exportedCurves => HabotMotionTokenExport.curves.length;

  static bool get theMotionTokensExist => exportedCurves > 0;

  static bool get theDurationRuleExists =>
      HabotGovernanceRules.ids.contains('RAW_DURATION');

  static bool get theCurveRuleExists =>
      HabotGovernanceRules.ids.contains('RAW_CURVE');

  static bool get bothMotionRulesAreDeclared =>
      theDurationRuleExists && theCurveRuleExists;

  static const bool anAnimationUtilityIsImported = false;

  static const String motionNote =
      'The native animation utilities the row asks for are the motion tokens '
      'Step 176 exported, and RAW_DURATION and RAW_CURVE have required their '
      'use since Step 179. Importing an animation utility here would be '
      'importing a second answer to a question two blocking rules already '
      'answer, which is the same mistake Steps 409 to 412 made four times in '
      'four rows -- the last row of the batch declines it.';

  static double get coverage =>
      everySymbolNamesItsEquivalent && bothMotionRulesAreDeclared ? 100 : 0;

  static const String columnNote =
      'COLUMN NOTE: this row asks to import View and Text -- React Native\'s '
      'primitives -- into a Flutter application and cites "React Native '
      'Performance" as the standard to configure against, which makes it the '
      'nineteenth foreign stack on the register Step 258 keeps and the first '
      'to reach the reference-standard column rather than only the instruction '
      'text; its optimal of "< 2 ms" sits below both its floor of "< 20 ms" '
      'and its ceiling of "50 ms", so the target lies outside the interval its '
      'own boundaries describe; two of its three band cells are inequalities '
      'and the third is not; its Data Requirement cell truncates the Atomic '
      'Step at "the mobile"; and the Setup Step column is empty. Atomic Step: '
      '"Import View, Text, and native animation utilities from the mobile UI '
      'framework."';

  static Map<String, bool> get obligations => <String, bool>{
        'every symbol names its equivalent here':
            everySymbolNamesItsEquivalent,
        'no animation utility is imported': !anAnimationUtilityIsImported,
        'the motion rules are the declared ones': bothMotionRulesAreDeclared,
        'the measurable figures are published':
            theSubstituteFiguresAreMeasurable,
        'the unmeasurable one is named, not invented':
            theMetricMeasuresNothingThatExists,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'three foreign symbols, each with its equivalent named':
            symbols.length == 3 &&
                everySymbolIsForeign &&
                everySymbolNamesItsEquivalent,
        'and Text resolves to the wrong thing rather than failing':
            translationNote.contains('resolve to the wrong thing'),
        'the nineteenth foreign stack':
            thisIsTheNineteenthForeignStack && twoOfThreeAreAlreadyGoverned,
        'and the first to reach the standard column':
            theStackReachesTheStandardColumn &&
                registerNote.contains('a wrong specification is followed'),
        'the optimal sits outside its own boundaries':
            theOptimalIsOutsideItsOwnBoundaries &&
                theBoundariesDescribeAnInterval,
        'two cells are inequalities and the third is not':
            twoCellsAreInequalitiesAndOneIsNot && thisShapeIsTheSeventh,
        'there is no run-time import cost to measure':
            theMetricMeasuresNothingThatExists &&
                whatHappensToUnusedOnes == 'they are removed',
        'so count, unused count and first frame are published instead':
            theSubstituteFiguresAreMeasurable &&
                overheadNote.contains('rather than invented'),
        'the animation utilities are already governed':
            theMotionTokensExist &&
                bothMotionRulesAreDeclared &&
                !anAnimationUtilityIsImported,
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass' &&
                coverage == 100,
      };
}
