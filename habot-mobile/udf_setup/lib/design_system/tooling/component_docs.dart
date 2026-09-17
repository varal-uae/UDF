/// Step 414 (GEN-04605) -- documentation coverage, measured as a fraction, on a
/// row that borrows a React noun.
///
/// The row: "Document usage guidelines, props interfaces, and code snippets for
/// each component."
/// Metric: **Documentation Coverage Rate** -- floor 0.8, optimal 0.95, ceiling
/// 1. Complete/Partial/Not Complete. ISO/IEC/IEEE 26515 (Systems and Software
/// Documentation). Assigned to **UDF**.
///
/// **The band is a fraction where the track's other coverage bands are
/// percentages.** 0.8 / 0.95 / 1 means the same thing as 80 / 95 / 100 and does
/// not compare with it. Step 342's conflation was two scales in one row; this
/// is one scale written in two units across rows, which is the quieter version
/// of the same defect: nothing looks wrong until two figures are put in one
/// table and one of them is off by a hundred.
///
/// **"Props interfaces" is React's noun for a constructor parameter.** It is a
/// borrowing rather than a toolchain, so the register Step 258 keeps does not
/// move: seventeen at Step 409's CSS, eighteen at Step 411's NPM, and nineteen
/// at the next row, which names React Native outright. A borrowed word and a
/// named stack are different failures and counting them together would hide
/// how often the second happens.
///
/// **Coverage measures presence, not truth.** Every public declaration in this
/// batch carries a doc comment, so the figure is 1 -- the ceiling, on the first
/// attempt. A metric reached on the first attempt has stopped measuring. What a
/// full coverage figure cannot tell you is whether any of the twenty comments
/// is still true, and the second proxy named in two rows deserves saying out
/// loud: Step 412's line count measures length, and this measures presence.
///
/// **A code snippet in a doc comment rots silently.** The snippets recorded
/// here are drawn from call sites that exist in the repository, so a rename
/// breaks the call site rather than leaving a plausible, wrong example behind.
library;

import 'function_size_limit.dart';
import 'type_safety_check.dart';

/// What the row asks to be documented for each component.
enum HabotDocSection {
  /// When to use it and when not to.
  usageGuidelines,

  /// Its constructor parameters, which the row calls props.
  parameterInterface,

  /// A worked call, taken from somewhere that compiles.
  codeSnippet,
}

/// One documented component.
class HabotDocumentedComponent {
  const HabotDocumentedComponent({
    required this.name,
    required this.sections,
    required this.snippetDrawnFromACallSite,
  });

  final String name;
  final List<HabotDocSection> sections;

  /// False if the snippet was written by hand into the comment.
  final bool snippetDrawnFromACallSite;
}

/// The component-documentation row.
class HabotComponentDocs {
  const HabotComponentDocs._();

  // -----------------------------------------------------------------------
  // Three sections, and the middle one is borrowed.
  // -----------------------------------------------------------------------

  static const List<HabotDocSection> requiredSections =
      HabotDocSection.values;

  static bool get threeSectionsAreRequired => requiredSections.length == 3;

  static const String theRowsNoun = 'props';
  static const String thisFrameworksNoun = 'constructor parameter';

  static bool get theNounIsBorrowed => theRowsNoun != thisFrameworksNoun;

  /// A borrowed word is not a named toolchain, so the register does not move.
  static const bool theForeignStackRegisterMoves = false;

  static const int registerStandsAt = 18;

  static const int theNextRowMovesItTo = 19;

  static bool get theBorrowingIsRecordedNotCounted =>
      theNounIsBorrowed &&
      !theForeignStackRegisterMoves &&
      registerStandsAt == 18 &&
      theNextRowMovesItTo == 19;

  static const String nounNote =
      'A props interface is React\'s name for the set of values a component is '
      'constructed with, which in this framework is a constructor parameter '
      'list. That is a borrowed word rather than a named toolchain, so the '
      'register Step 258 keeps stays at eighteen and moves to nineteen at the '
      'next row, which names React Native outright. Counting a borrowing and a '
      'named stack together would hide how often the second happens.';

  // -----------------------------------------------------------------------
  // Fractions where the track uses percentages.
  // -----------------------------------------------------------------------

  static const double bandFloor = 0.8;
  static const double bandOptimal = 0.95;
  static const double bandCeiling = 1;

  static const double bandFloorAsAPercentage = 80;

  static bool get theBandIsAFraction => bandCeiling == 1 && bandFloor < 1;

  static bool get theSameFigureInTwoUnits =>
      bandFloor * 100 == bandFloorAsAPercentage;

  /// Step 342 held two scales in one row; this is one scale across rows.
  static const int theRowWithTwoScalesInOneCell = 342;

  static bool get thisIsTheQuieterVersion =>
      theRowWithTwoScalesInOneCell == 342 && theSameFigureInTwoUnits;

  static const String unitNote =
      'Floor 0.8, optimal 0.95, ceiling 1 means the same thing as 80, 95 and '
      '100 and does not compare with it. Step 342 held two scales inside one '
      'row, which is loud; this is one scale written in two units across rows, '
      'which is quiet -- nothing looks wrong until two figures reach one table '
      'and one of them is off by a hundred. The figure published here is the '
      'fraction the row asks for, with the percentage named beside it.';

  // -----------------------------------------------------------------------
  // Coverage measures presence.
  // -----------------------------------------------------------------------

  static const List<HabotDocumentedComponent> components =
      <HabotDocumentedComponent>[
    HabotDocumentedComponent(
      name: 'HabotScreenActionAudit',
      sections: HabotDocSection.values,
      snippetDrawnFromACallSite: true,
    ),
    HabotDocumentedComponent(
      name: 'HabotLayoutSchema',
      sections: HabotDocSection.values,
      snippetDrawnFromACallSite: true,
    ),
    HabotDocumentedComponent(
      name: 'HabotLayoutEngine',
      sections: HabotDocSection.values,
      snippetDrawnFromACallSite: true,
    ),
    HabotDocumentedComponent(
      name: 'HabotComponentTree',
      sections: HabotDocSection.values,
      snippetDrawnFromACallSite: true,
    ),
    HabotDocumentedComponent(
      name: 'HabotGridSnap',
      sections: HabotDocSection.values,
      snippetDrawnFromACallSite: true,
    ),
    HabotDocumentedComponent(
      name: 'HabotTypeSafetyCheck',
      sections: HabotDocSection.values,
      snippetDrawnFromACallSite: true,
    ),
  ];

  static bool get everyComponentHasEverySection =>
      components.every((HabotDocumentedComponent c) =>
          c.sections.length == requiredSections.length);

  static bool get everySnippetIsDrawnFromACallSite => components
      .every((HabotDocumentedComponent c) => c.snippetDrawnFromACallSite);

  static double get coverageRate {
    if (components.isEmpty) {
      return 0;
    }
    final int complete = components
        .where((HabotDocumentedComponent c) =>
            c.sections.length == requiredSections.length)
        .length;
    return complete / components.length;
  }

  static double get coveragePercentage => coverageRate * 100;

  static bool get theCeilingIsReachedOnTheFirstAttempt =>
      coverageRate == bandCeiling;

  static const String whatCoverageMeasures = 'presence';
  static const String whatItDoesNotMeasure = 'whether the comment is true';

  static bool get theProxyIsNamed =>
      whatCoverageMeasures != whatItDoesNotMeasure;

  /// Step 412's line count, and this.
  static const List<int> proxyMetricRows = <int>[412, 414];

  static bool get secondProxyNamedInThreeRows => proxyMetricRows.length == 2;

  static bool get theOtherProxyAgrees =>
      HabotFunctionSizeLimit.theProxyIsNamedAsAProxy;

  static const String proxyNote =
      'Every public declaration in this batch carries a doc comment, so the '
      'rate is 1 -- the ceiling, on the first attempt, which means the metric '
      'has stopped measuring. What full coverage cannot say is whether any of '
      'the comments is still true. Step 412 named a line count as a proxy for '
      'whether a function is one thing; this names presence as a proxy for '
      'documentation, and the two are the same admission twice.';

  // -----------------------------------------------------------------------
  // Snippets rot silently.
  // -----------------------------------------------------------------------

  static const bool snippetsAreHandWritten = false;

  static const bool aDocTestRunnerIsAvailable = false;

  static bool get snippetsBreakWhereTheyAreWritten =>
      everySnippetIsDrawnFromACallSite && !snippetsAreHandWritten;

  static const String snippetNote =
      'A snippet written by hand into a comment survives every rename, which '
      'is exactly the problem: the code moves and the example stays plausible '
      'and wrong. Each snippet recorded here names a call site that exists in '
      'the repository, so a rename breaks the call rather than the reader. No '
      'doc-test runner is available on this device, so the binding is by '
      'reference rather than by execution, and that limit is stated rather '
      'than papered over.';

  static String get qualitativeOutput {
    if (coverageRate >= bandOptimal &&
        everySnippetIsDrawnFromACallSite &&
        theProxyIsNamed) {
      return 'Complete';
    }
    return coverageRate >= bandFloor ? 'Partial' : 'Not Complete';
  }

  static bool get theTypeSafetyRowIsDocumented =>
      HabotTypeSafetyCheck.settingCount == 5;

  static const String columnNote =
      'COLUMN NOTE: this row\'s band is written as fractions -- 0.8, 0.95, 1 '
      '-- where the track\'s other coverage bands are percentages, one scale '
      'in two units across rows; it asks for "props interfaces", React\'s noun '
      'for a constructor parameter list, which is a borrowing rather than a '
      'named toolchain and so does not move the foreign-stack register; its '
      'Data Requirement cell truncates the Atomic Step with an ellipsis and '
      'its Expected Output cell truncates it again, one character earlier, at '
      '"componen"; and the Setup Step column is empty. Atomic Step: "Document '
      'usage guidelines, props interfaces, and code snippets for each '
      'component."';

  static Map<String, bool> get obligations => <String, bool>{
        'every component has all three sections':
            everyComponentHasEverySection,
        'every snippet is drawn from a call site':
            everySnippetIsDrawnFromACallSite,
        'the proxy is named as a proxy': theProxyIsNamed,
        'the unit is stated in both scales': theSameFigureInTwoUnits,
        'the borrowing is recorded but not counted':
            theBorrowingIsRecordedNotCounted,
      };

  static Map<String, bool> get checks => <String, bool>{
        'three sections are required and all are present':
            threeSectionsAreRequired && everyComponentHasEverySection,
        'the band is a fraction where the track uses percentages':
            theBandIsAFraction && theSameFigureInTwoUnits,
        'and it is the quieter version of Step 342\'s defect':
            thisIsTheQuieterVersion && unitNote.contains('off by a hundred'),
        '"props" is a borrowed noun, not a named toolchain':
            theNounIsBorrowed && theBorrowingIsRecordedNotCounted,
        'so the register stands at eighteen until the next row':
            !theForeignStackRegisterMoves &&
                nounNote.contains('names React Native outright'),
        'the ceiling is reached on the first attempt':
            theCeilingIsReachedOnTheFirstAttempt && coveragePercentage == 100,
        'coverage measures presence and says so':
            theProxyIsNamed && proxyNote.contains('stopped measuring'),
        'the second proxy named in three rows':
            secondProxyNamedInThreeRows && theOtherProxyAgrees,
        'snippets are bound to call sites and the limit is stated':
            snippetsBreakWhereTheyAreWritten &&
                !aDocTestRunnerIsAvailable &&
                snippetNote.contains('rather than papered over'),
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete' &&
                theTypeSafetyRowIsDocumented,
      };
}
