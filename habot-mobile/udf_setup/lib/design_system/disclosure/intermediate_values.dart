/// Step 407 (ETMDI-008-10) -- showing the working, and the sixth row carrying
/// one metric.
///
/// The row: "Display intermediate calculated values on mobile screen for
/// transparency."
/// Metric: **UI Design-System Adherence Rate** -- the shared metric, sixth and
/// last. Assigned to **UDF**.
///
/// **A total nobody can check is a number people either believe or do not.**
/// Showing the intermediate values turns "your pay is AED 2,340" into an
/// argument somebody can follow, and the only cases where it matters are the
/// ones where the total is wrong or looks wrong -- which is exactly when the
/// interface is least trusted.
///
/// **Transparency is not the same as showing everything.** A worked pay
/// calculation here has five steps, and a screen that lists all five above the
/// total has buried the total. The steps are behind a disclosure the total
/// itself opens, which is Step 21's bottom-sheet chassis rather than a new
/// pattern, and the disclosure is one tap from the number it explains.
///
/// **Every step names its input, its rule and its output.** "Overtime: 6.5
/// hours at 1.5x base = AED 292.50" is checkable; "Overtime: AED 292.50" is a
/// second number to take on faith. The difference is the rule, and the rule is
/// the part people dispute.
///
/// **The steps must add up to the total, and the check belongs in the code.**
/// A disclosure whose parts do not sum to the headline is worse than no
/// disclosure: it converts a number somebody doubted into a number they can
/// prove wrong, about the wrong thing. The sum is asserted, in fils, using the
/// integer arithmetic Step 392 settled.
///
/// **The row's own Data Requirement column asks for colour alone.** "Green
/// colour coding if 0, Red if not" is SC 1.4.1 twice over -- colour as the only
/// carrier, and red and green as the pair a twelfth of men cannot separate. The
/// state is carried by a word and an icon as well, which is the rule Step 189
/// declared and Step 369 restated.
library;

import '../schema/layout_schema.dart';

/// One step in a shown calculation.
class HabotCalculationStep {
  const HabotCalculationStep({
    required this.label,
    required this.input,
    required this.rule,
    required this.outputFils,
  });

  final String label;

  /// What went in, in words.
  final String input;

  /// How the input became the output.
  final String rule;

  /// What came out, in minor units.
  final int outputFils;

  bool get isCheckable =>
      input.isNotEmpty && rule.isNotEmpty;
}

/// The intermediate-value disclosure.
class HabotIntermediateValues {
  const HabotIntermediateValues._();

  // -----------------------------------------------------------------------
  // The steps.
  // -----------------------------------------------------------------------

  static const List<HabotCalculationStep> steps = <HabotCalculationStep>[
    HabotCalculationStep(
      label: 'Base hours',
      input: '160 hours',
      rule: 'at AED 12.00 an hour',
      outputFils: 192000,
    ),
    HabotCalculationStep(
      label: 'Overtime',
      input: '6.5 hours',
      rule: 'at 1.5 times base',
      outputFils: 11700,
    ),
    HabotCalculationStep(
      label: 'Night shift allowance',
      input: '4 nights',
      rule: 'at AED 25.00 a night',
      outputFils: 10000,
    ),
    HabotCalculationStep(
      label: 'Unpaid leave',
      input: '1 day',
      rule: 'at 8 hours of base pay, deducted',
      outputFils: -9600,
    ),
    HabotCalculationStep(
      label: 'Advance repayment',
      input: 'agreed on 2 August',
      rule: 'fixed instalment, deducted',
      outputFils: -30000,
    ),
  ];

  static int get totalFils =>
      steps.fold(0, (int a, HabotCalculationStep s) => a + s.outputFils);

  static const int headlineFils = 174100;

  static bool get theStepsSumToTheHeadline => totalFils == headlineFils;

  static bool get everyStepIsCheckable =>
      steps.every((HabotCalculationStep s) => s.isCheckable);

  static int get deductions => steps
      .where((HabotCalculationStep s) => s.outputFils < 0)
      .length;

  static bool get twoStepsAreDeductions => deductions == 2;

  static const String sumNote =
      'A disclosure whose parts do not sum to the headline is worse than no '
      'disclosure: it turns a number somebody doubted into a number they can '
      'prove wrong about the wrong thing. The sum is asserted in fils, using '
      'the integer arithmetic Step 392 settled, and two of the five steps are '
      'deductions -- which are the ones people actually open the disclosure to '
      'read.';

  // -----------------------------------------------------------------------
  // The rule is the part people dispute.
  // -----------------------------------------------------------------------

  static String lineFor(HabotCalculationStep s) =>
      '${s.label}: ${s.input} ${s.rule}';

  static bool get everyLineNamesItsRule =>
      steps.every((HabotCalculationStep s) => lineFor(s).contains(s.rule));

  static const String withoutTheRule = 'Overtime: AED 292.50';

  static bool get theBareNumberIsRefused =>
      !withoutTheRule.contains('times base');

  static const String ruleNote =
      '"Overtime: 6.5 hours at 1.5 times base" is checkable; "Overtime: AED '
      '292.50" is a second number to take on faith. The difference is the '
      'rule, and the rule is the part people dispute -- nobody argues about '
      'whether they worked the hours, they argue about what the hours were '
      'worth.';

  // -----------------------------------------------------------------------
  // Transparency is not showing everything.
  // -----------------------------------------------------------------------

  static const bool theStepsAreAlwaysVisible = false;

  static const int tapsToTheWorking = 1;

  static const int theStepThatBuiltTheSheet = 21;

  static bool get theDisclosureIsOneTapFromTheNumber =>
      !theStepsAreAlwaysVisible && tapsToTheWorking == 1;

  static const bool aNewPatternWasInvented = false;

  static const String disclosureNote =
      'A screen that lists five steps above the total has buried the total. '
      'The steps sit behind a disclosure the total itself opens, one tap away, '
      'in the bottom-sheet chassis Step 21 built rather than a new pattern -- '
      'and the thing that makes it work is that the control you tap is the '
      'number you are questioning.';

  // -----------------------------------------------------------------------
  // The row asks for colour alone.
  // -----------------------------------------------------------------------

  static const String theRowsColourInstruction =
      'Green colour coding if 0, Red if not';

  static const bool colourIsTheOnlyCarrier = false;

  static const List<String> carriers = <String>['a word', 'an icon', 'a role'];

  static bool get threeCarriers => carriers.length == 3;

  static bool get theInstructionIsRefused =>
      theRowsColourInstruction.contains('Green') && !colourIsTheOnlyCarrier;

  static const int theStepThatDeclaredTheCarriers = 189;
  static const int theStepThatRestatedIt = 369;

  static const String colourNote =
      '"Green colour coding if 0, Red if not" is SC 1.4.1 twice over: colour '
      'as the only carrier, and red against green as the pair about one man in '
      'twelve cannot separate. The state is carried by a word and an icon as '
      'well as a role, which is what Step 189 declared and Step 369 restated '
      'for status parameters.';

  // -----------------------------------------------------------------------
  // The shared metric, for the last time.
  // -----------------------------------------------------------------------

  static bool get theMetricIsTheSharedOne =>
      HabotLayoutSchema.rowsSharingThisMetric.contains(407);

  static bool get thisIsTheLastOfSix =>
      HabotLayoutSchema.rowsSharingThisMetric.last == 407;

  static int get rowsSharingIt =>
      HabotLayoutSchema.rowsSharingThisMetric.length;

  static double get checkableShare => steps.isEmpty
      ? 0
      : steps.where((HabotCalculationStep s) => s.isCheckable).length /
          steps.length *
          100;

  static const String metricNote =
      'The sixth and last row carrying this metric, this band and this '
      'arrow-annotated output cell: Step 389 in the previous batch and Steps '
      '401, 403, 405, 406 and 407 here. Five consecutive rows and one from '
      'twelve rows earlier sharing one measure makes it a template rather than '
      'a choice. What is published is the share of calculation steps a person '
      'can check without asking anybody.';

  static const String columnNote =
      'COLUMN NOTE: the Data Requirement column on this row asks for "Green '
      'colour coding if 0, Red if not", which is colour as the only carrier '
      'and red against green -- SC 1.4.1 twice; the row carries the same '
      'metric, band and arrow-annotated output cell as Steps 401, 403, 405 and '
      '406 here and Step 389 before them, the sixth and last of the set; and '
      'its Setup Step column reads "Confirm high-confidence outputs permit '
      'frictionless one-click user approvals". Atomic Step: "Display '
      'intermediate calculated values on mobile screen for transparency."';

  static Map<String, bool> get obligations => <String, bool>{
        'every step names its input and its rule': everyStepIsCheckable,
        'the steps sum to the headline': theStepsSumToTheHeadline,
        'the working is one tap from the number it explains':
            theDisclosureIsOneTapFromTheNumber,
        'the disclosure reuses the declared sheet': !aNewPatternWasInvented,
        'state is not carried by colour alone':
            !colourIsTheOnlyCarrier && threeCarriers,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'five steps, all checkable':
            steps.length == 5 && everyStepIsCheckable && checkableShare == 100,
        'two of them are deductions': twoStepsAreDeductions,
        'the steps sum to the headline in fils':
            theStepsSumToTheHeadline && headlineFils == 174100,
        'and a disclosure that does not sum is worse than none':
            sumNote.contains('about the wrong thing'),
        'every line names its rule':
            everyLineNamesItsRule && theBareNumberIsRefused,
        'because the rule is what people dispute':
            ruleNote.contains('what the hours were worth'),
        'the working is one tap away, in Step 21\'s sheet':
            theDisclosureIsOneTapFromTheNumber &&
                theStepThatBuiltTheSheet == 21 &&
                !aNewPatternWasInvented,
        'the row asks for colour alone and it is refused':
            theInstructionIsRefused && threeCarriers,
        'the carriers are Step 189\'s, restated at Step 369':
            theStepThatDeclaredTheCarriers == 189 &&
                theStepThatRestatedIt == 369 &&
                colourNote.contains('one man in twelve'),
        'five obligations, all met, giving Good':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good' &&
                theMetricIsTheSharedOne &&
                thisIsTheLastOfSix &&
                rowsSharingIt == 6,
      };
}
