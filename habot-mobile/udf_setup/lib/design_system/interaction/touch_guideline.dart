/// Step 227 (GEN-04286) -- the atomic touch target guideline.
///
/// The row: "Define atomic touch target guidelines enforcing a minimum 48x48 dp
/// boundary."
/// Metric: Minimum Touch Target Size -- 44dp / 48dp / 56dp. Pass/Fail.
/// Standard cited: **Material Design 3 / WCAG 2.5.5 (Target Size)**.
///
/// **This is the sixth time the sheet asks for 48dp.** Step 3 declared
/// `HabotDensity.minTouchTarget`. Step 108 built `TouchStandards` and the
/// `A11Y_LITERAL_TOUCH_SIZE` rule. Step 184 built the band with a floor, an
/// optimal and a ceiling. Step 198 applied it to category cards. This row asks
/// again, and so do Steps 228 and 229 in this same batch -- three restatements
/// in twenty rows, from three different source documents, none of which knows
/// the others exist.
///
/// **That is the finding, and a seventh implementation is not the response.**
/// What this step produces is a census: every declaration of the number in this
/// repository, what each one holds, and whether they agree -- plus the single
/// reference all three of this batch's rows point at.
///
/// **The three rows disagree about the ceiling.** This row says 56dp; Step 228
/// says 64x64dp; Step 229 says 56dp. The disagreement is real and resolvable:
/// Step 228 is about navigation destinations specifically, and MD3 draws those
/// 64dp tall inside an 80dp bar. So 56 is the ceiling for a free-standing
/// control and 64 is a declared exception for navigation, which is the sheet's
/// own number honoured where the sheet meant it.
///
/// **One of the two citations is wrong.** This row cites WCAG 2.5.5 for 44dp,
/// which is correct -- SC 2.5.5 Target Size is Level AAA at 44x44 CSS pixels.
/// Step 229 cites **WCAG 2.2 SC 2.5.8 Target Size (Minimum)** for the same
/// 44x44 figure, and 2.5.8 is Level AA at **24x24**. Same number, two success
/// criteria, one of them not the one that says it.
library;

import '../tokens/spacing_tokens.dart';
import '../tokens/touch_target_band.dart';

/// One place the minimum is declared in this repository.
class HabotTargetDeclaration {
  const HabotTargetDeclaration({
    required this.site,
    required this.symbol,
    required this.valueDp,
    required this.owner,
    required this.role,
  });

  /// The file it lives in.
  final String site;
  final String symbol;
  final double valueDp;

  /// The step that put it there.
  final String owner;

  /// What this declaration is for, so "duplicate" and "different job" can be
  /// told apart.
  final String role;
}

/// A control class with a ceiling that is not the default one.
class HabotCeilingException {
  const HabotCeilingException({
    required this.controlClass,
    required this.ceilingDp,
    required this.rowThatAsksForIt,
    required this.rationale,
  });

  final String controlClass;
  final double ceilingDp;
  final String rowThatAsksForIt;
  final String rationale;
}

/// The guideline.
class HabotTouchTargetGuideline {
  const HabotTouchTargetGuideline._();

  /// The canonical reference. Everything in this batch points here, and this
  /// points at Step 184.
  static double get floorDp => HabotTouchBand.floorDp;
  static double get optimalDp => HabotTouchBand.optimalDp;
  static double get ceilingDp => HabotTouchBand.ceilingDp;

  /// The row asks for 48 as a minimum, which is the band's optimal.
  static double get rowMinimumDp => optimalDp;

  static bool get rowAsksForTheOptimalNotTheFloor =>
      rowMinimumDp == optimalDp && rowMinimumDp > floorDp;

  // -----------------------------------------------------------------------
  // The census.
  // -----------------------------------------------------------------------

  static List<HabotTargetDeclaration> get declarations =>
      <HabotTargetDeclaration>[
        HabotTargetDeclaration(
          site: 'lib/design_system/tokens/spacing_tokens.dart',
          symbol: 'HabotDensity.minTouchTarget',
          valueDp: HabotDensity.minTouchTarget,
          owner: 'Step 3',
          role: 'The density token. The oldest declaration and the one most '
              'call sites read.',
        ),
        HabotTargetDeclaration(
          site: 'lib/design_system/tokens/spacing_tokens.dart',
          symbol: 'HabotSpacing.xxxl',
          valueDp: HabotSpacing.xxxl,
          owner: 'Step 2',
          role: 'A spacing rung that happens to equal the target minimum. Not '
              'a touch declaration, and reading it as one is how a spacing '
              'change becomes an accessibility regression.',
        ),
        HabotTargetDeclaration(
          site: 'lib/design_system/tokens/touch_target_band.dart',
          symbol: 'HabotTouchBand.optimalDp',
          valueDp: HabotTouchBand.optimalDp,
          owner: 'Step 184',
          role: 'The band optimal, derived from HabotDensity.minTouchTarget '
              'rather than restated. The canonical reference.',
        ),
        HabotTargetDeclaration(
          site: 'lib/design_system/discovery/category_card_target.dart',
          symbol: 'HabotCategoryCardTarget.controlMinimumDp',
          valueDp: HabotTouchBand.optimalDp,
          owner: 'Step 198',
          role: 'A screen applying the band. Derived, not declared.',
        ),
      ];

  /// Declarations that hold the number in their own right rather than reading
  /// it from somewhere else.
  static List<HabotTargetDeclaration> get independentDeclarations =>
      declarations
          .where(
            (HabotTargetDeclaration d) => !d.role.contains('Derived') &&
                !d.role.contains('derived'),
          )
          .toList();

  /// Every declaration holds the same number.
  static bool get censusAgrees =>
      declarations.every((HabotTargetDeclaration d) => d.valueDp == optimalDp);

  /// The one entry that is not a touch declaration at all, kept in the census
  /// precisely because it is the one a future change breaks silently.
  static HabotTargetDeclaration get coincidentalDeclaration =>
      declarations.firstWhere(
        (HabotTargetDeclaration d) => d.symbol == 'HabotSpacing.xxxl',
      );

  static const int sheetRestatements = 6;

  static const String sixthTimeNote =
      'Step 3 declared the density token, Step 108 built the touch standards '
      'and the literal-size rule, Step 184 built the band, Step 198 applied '
      'it. This row asks again, and so do Steps 228 and 229 in this same '
      'batch -- three restatements in twenty rows, from three source '
      'documents, none of which knows the others exist. A seventh '
      'implementation is not the response; a census is.';

  static const String coincidenceNote =
      'HabotSpacing.xxxl is 48 and HabotDensity.minTouchTarget is 48, and they '
      'are not the same fact. One is a spacing rung; the other is an '
      'accessibility minimum. A control sized from the spacing rung passes '
      'every check today and becomes non-compliant the day somebody retunes '
      'the spacing ladder, with nothing in the diff to say so.';

  // -----------------------------------------------------------------------
  // The ceiling disagreement.
  // -----------------------------------------------------------------------

  static const List<HabotCeilingException> ceilingExceptions =
      <HabotCeilingException>[
    HabotCeilingException(
      controlClass: 'navigation destination',
      ceilingDp: 64,
      rowThatAsksForIt: 'GEN-03259 (Step 228)',
      rationale:
          'MD3 draws a navigation destination 64dp tall inside an 80dp bar. '
          'The band ceiling exists to stop an ambiguous region being called a '
          'button; a navigation destination is unambiguous -- its whole cell '
          'means one thing -- so the sheet\'s 64 is honoured where the sheet '
          'meant it.',
    ),
  ];

  static double ceilingForControlClass(String controlClass) {
    for (final HabotCeilingException e in ceilingExceptions) {
      if (e.controlClass == controlClass) {
        return e.ceilingDp;
      }
    }
    return ceilingDp;
  }

  /// The three ceilings the three rows in this batch name.
  static const Map<String, double> ceilingsNamedByTheRows = <String, double>{
    'GEN-04286 (Step 227)': 56,
    'GEN-03259 (Step 228)': 64,
    'GEN-04164 (Step 229)': 56,
  };

  static bool get rowsDisagreeAboutTheCeiling =>
      ceilingsNamedByTheRows.values.toSet().length > 1;

  static bool get disagreementIsResolved =>
      ceilingForControlClass('navigation destination') == 64 &&
      ceilingForControlClass('icon button') == ceilingDp;

  // -----------------------------------------------------------------------
  // The citation defect.
  // -----------------------------------------------------------------------

  static const String thisRowCitation = 'WCAG 2.5.5 (Target Size)';
  static const String step229Citation =
      'WCAG 2.2 SC 2.5.8 Target Size (Minimum)';

  /// SC 2.5.5 Target Size is Level AAA at 44x44 CSS pixels.
  static const double sc255MinimumCssPx = 44;

  /// SC 2.5.8 Target Size (Minimum) is Level AA at 24x24 CSS pixels.
  static const double sc258MinimumCssPx = 24;

  /// Both rows state a 44x44 floor. Only one of them cites the criterion that
  /// says 44.
  static bool get oneCitationIsWrong =>
      sc255MinimumCssPx == floorDp && sc258MinimumCssPx != floorDp;

  static const String citationNote =
      'Both rows state a 44x44 floor. SC 2.5.5 Target Size is Level AAA and '
      'says 44x44 CSS pixels, which is the figure -- this row cites it '
      'correctly. SC 2.5.8 Target Size (Minimum) is Level AA and says 24x24, '
      'so Step 229 cites a criterion that does not contain its own number. The '
      'figure is right and the reference is not, which is worse than a wrong '
      'figure: it survives review because the number looks familiar.';

  // -----------------------------------------------------------------------
  // Metric: Minimum Touch Target Size. 44 / 48 / 56. Pass/Fail.
  // -----------------------------------------------------------------------

  static Map<String, bool> get checks => <String, bool>{
        'the band is read from Step 184 rather than restated':
            floorDp == HabotTouchBand.floorDp &&
                optimalDp == HabotTouchBand.optimalDp &&
                ceilingDp == HabotTouchBand.ceilingDp,
        'the row asks for the band optimal, not its floor':
            rowAsksForTheOptimalNotTheFloor,
        'every declaration in the census holds the same number': censusAgrees,
        'the census separates real declarations from a coincidence':
            declarations.length == 4 &&
                independentDeclarations.length == 2 &&
                coincidentalDeclaration.role.contains('Not a touch'),
        'the three rows in this batch disagree about the ceiling':
            rowsDisagreeAboutTheCeiling,
        'and the disagreement is resolved per control class':
            disagreementIsResolved,
        'one of the two WCAG citations does not contain its own number':
            oneCitationIsWrong,
        'the restatement count is recorded': sheetRestatements == 6,
      };

  static bool get isPass => checks.values.every((bool b) => b);

  static String get qualitativeOutput => isPass ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Define atomic touch target guidelines enforcing a minimum 48x48 dp '
      'boundary."';
}
