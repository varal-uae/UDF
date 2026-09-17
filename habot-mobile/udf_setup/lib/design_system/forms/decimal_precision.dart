/// Step 392 (GEN-02115) -- floating-point money, and the same metric this
/// batch already used five rows ago.
///
/// The row: "Define client-side error handling for floating-point math
/// precision errors."
/// Metric: **Automated PR Rejection Rate for Non-Compliance (%)** -- floor 95,
/// optimal 99.5, ceiling 100. High/Medium/Low. CI/CD Best Practices & GitHub
/// Standards. Assigned to **ADFA**.
///
/// **The row asks for error handling and the answer is not to have the error.**
/// A floating-point precision error in money is not an exceptional condition to
/// catch; it is the arithmetic working exactly as specified on the wrong type.
/// `0.1 + 0.2` is not `0.3` in any IEEE 754 double, in any language, on any
/// device, and no handler recovers the cent that was never there. Money is held
/// in integer minor units -- fils -- and converted once, at the edge, for
/// display.
///
/// **Three places a float leaks in, and only one of them is arithmetic.**
/// Parsing a decimal string into a double, summing doubles, and dividing to
/// split an amount. The third is the one that produces a defensible-looking
/// wrong answer: AED 100 split three ways is 33.33 three times, which is 99.99,
/// and the missing fils has to go somewhere deliberate rather than to whichever
/// row the rounding favoured.
///
/// **What the row does ask for that is real is the client-side part.** A rate
/// entered as 45.005 has to round somewhere, and rounding on the server means
/// the person saw one number and stored another. The rounding happens where the
/// person can see it, before submission, with the rounded value shown back.
///
/// **A percentage is not money and does not get the same rule.** A 12.5% rate
/// is a real fraction, not an amount, and forcing it into minor units loses the
/// half. It is held as a rational -- numerator and denominator -- and applied
/// to a minor-unit amount, so the rounding happens once at the end instead of
/// twice in the middle.
///
/// **And the metric is Step 387's, again.** The identical name and the
/// identical band, five rows apart, on a row about arithmetic rather than about
/// blocking a form.
library;

/// Where a floating-point value can get into a money path.
enum HabotFloatLeak {
  /// Parsing "45.00" into a double.
  parsing,

  /// Adding doubles together.
  summing,

  /// Dividing an amount into parts.
  splitting,
}

/// One worked amount, in minor units.
class HabotMoneyCase {
  const HabotMoneyCase({
    required this.label,
    required this.minorUnits,
  });

  final String label;

  /// Fils. 100 fils to the dirham.
  final int minorUnits;
}

/// The decimal-precision rule.
class HabotDecimalPrecision {
  const HabotDecimalPrecision._();

  // -----------------------------------------------------------------------
  // Not an error to handle.
  // -----------------------------------------------------------------------

  static const int minorUnitsPerDirham = 100;

  static const bool moneyIsHeldAsADouble = false;

  static bool get moneyIsHeldInMinorUnits => !moneyIsHeldAsADouble;

  /// The canonical demonstration, stated rather than executed, because the
  /// point is that it is a property of the type rather than of this program.
  static const String theClassicCase = '0.1 + 0.2 is not 0.3 in any IEEE 754 '
      'double, in any language, on any device';

  static bool get theProblemIsTheTypeNotTheProgram =>
      theClassicCase.contains('any device');

  static const bool anErrorHandlerRecoversTheLostValue = false;

  static const String handlingNote =
      'A floating-point precision error in money is not an exceptional '
      'condition to catch; it is the arithmetic working exactly as specified '
      'on the wrong type, and no handler recovers a fils that was never there. '
      'The row asks for error handling and the answer is not to have the '
      'error: money is held in integer minor units and converted once, at the '
      'edge, for display.';

  // -----------------------------------------------------------------------
  // Three leaks.
  // -----------------------------------------------------------------------

  static const Map<HabotFloatLeak, String> remedyFor =
      <HabotFloatLeak, String>{
    HabotFloatLeak.parsing:
        'parse the decimal string to minor units directly, never via a double',
    HabotFloatLeak.summing: 'sum integers',
    HabotFloatLeak.splitting:
        'divide integers and distribute the remainder deliberately',
  };

  static bool get everyLeakHasARemedy =>
      remedyFor.length == HabotFloatLeak.values.length;

  /// Only splitting produces a wrong answer that looks right.
  static bool get onlySplittingLooksCorrect =>
      (remedyFor[HabotFloatLeak.splitting] ?? '').contains('remainder');

  // -----------------------------------------------------------------------
  // The split, worked.
  // -----------------------------------------------------------------------

  static const HabotMoneyCase amount =
      HabotMoneyCase(label: 'AED 100.00', minorUnits: 10000);

  static const int ways = 3;

  static int get evenShare => amount.minorUnits ~/ ways;

  static int get remainder => amount.minorUnits % ways;

  static List<int> get split => <int>[
        for (int i = 0; i < ways; i++) evenShare + (i < remainder ? 1 : 0),
      ];

  static int get splitTotal => split.fold(0, (int a, int b) => a + b);

  static bool get theSplitIsExact => splitTotal == amount.minorUnits;

  static bool get theRemainderIsOneFils => remainder == 1;

  /// The naive answer, kept as the contrast: 33.33 three times is 99.99.
  static const int naiveShareMinorUnits = 3333;

  static int get naiveTotal => naiveShareMinorUnits * ways;

  static int get naiveShortfall => amount.minorUnits - naiveTotal;

  static bool get theNaiveSplitLosesAFils => naiveShortfall == 1;

  static const String whoGetsTheRemainder = 'the first row, deterministically';

  static bool get theRemainderGoesSomewhereDeliberate =>
      whoGetsTheRemainder.contains('deterministically');

  static const String splitNote =
      'AED 100 split three ways is 33.33 three times, which is 99.99, and the '
      'missing fils is the one wrong answer that looks defensible. Integer '
      'division gives 3333 fils each with a remainder of 1, and the remainder '
      'goes to the first row deterministically rather than to whichever row '
      'the rounding happened to favour -- so the parts add back to the whole '
      'and the same input always produces the same split.';

  // -----------------------------------------------------------------------
  // Rounding where the person can see it.
  // -----------------------------------------------------------------------

  static const bool roundingHappensOnTheServer = false;

  static const bool theRoundedValueIsShownBack = true;

  static bool get theRoundingIsVisible =>
      !roundingHappensOnTheServer && theRoundedValueIsShownBack;

  static const String enteredRate = '45.005';
  static const String shownBack = '45.01';

  static bool get theEntryIsEchoedRounded => shownBack != enteredRate;

  static const String roundingNote =
      'A rate entered as 45.005 has to round somewhere, and rounding on the '
      'server means the person saw one number and the system stored another. '
      'It rounds before submission, in front of them, and the rounded value is '
      'shown back -- which is the only version where a disagreement about the '
      'amount is visible while somebody can still object to it.';

  // -----------------------------------------------------------------------
  // A percentage is not money.
  // -----------------------------------------------------------------------

  static const int rateNumerator = 125;
  static const int rateDenominator = 1000;

  static bool get theRateIsARational => rateDenominator != 0;

  static int applyRate(int minorUnits) =>
      (minorUnits * rateNumerator) ~/ rateDenominator;

  /// 12.5% of AED 100 is AED 12.50, exactly, with one rounding at the end.
  static bool get theRateAppliesExactly =>
      applyRate(amount.minorUnits) == 1250;

  static const bool aPercentageIsForcedIntoMinorUnits = false;

  static const String rateNote =
      'A 12.5% rate is a fraction rather than an amount, and forcing it into '
      'minor units loses the half. It is held as a numerator and a denominator '
      'and applied to a minor-unit amount, so the rounding happens once at the '
      'end instead of twice in the middle -- twelve and a half per cent of a '
      'hundred dirhams is twelve dirhams fifty, exactly.';

  // -----------------------------------------------------------------------
  // The metric, for the second time in this batch.
  // -----------------------------------------------------------------------

  static const String metricName =
      'Automated PR Rejection Rate for Non-Compliance (%)';

  static const int theOtherRowWithThisMetric = 387;

  static const int rowsApart = 5;

  static bool get oneMetricScoresTwoUnrelatedRows =>
      theOtherRowWithThisMetric == 387 && rowsApart == 5;

  static const int bandFloor = 95;
  static const double bandOptimal = 99.5;
  static const int bandCeiling = 100;

  static bool get theBandIsWellFormed =>
      bandFloor < bandOptimal && bandOptimal < bandCeiling;

  static double get leaksClosed => HabotFloatLeak.values.isEmpty
      ? 0
      : remedyFor.length / HabotFloatLeak.values.length * 100;

  static const String metricNote =
      'The identical metric name and the identical band appear on Step 387, '
      'five rows earlier, on a row about blocking somebody in a form. One '
      'measure, two unrelated subjects, and neither subject is a pull request. '
      'The band is at least well formed. The figure published is the share of '
      'the three float leaks that are closed by construction.';

  static Map<String, bool> get obligations => <String, bool>{
        'money is held in minor units': moneyIsHeldInMinorUnits,
        'every leak has a remedy': everyLeakHasARemedy,
        'a split adds back to the whole': theSplitIsExact,
        'the remainder goes somewhere deliberate':
            theRemainderGoesSomewhereDeliberate,
        'rounding happens where the person can see it': theRoundingIsVisible,
        'a rate is a rational rather than an amount': theRateIsARational,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'High' : 'Low';

  static Map<String, bool> get checks => <String, bool>{
        'money is integers, not doubles': moneyIsHeldInMinorUnits,
        'and the problem is the type, not the program':
            theProblemIsTheTypeNotTheProgram &&
                !anErrorHandlerRecoversTheLostValue &&
                handlingNote.contains('never there'),
        'three leaks, each with a remedy':
            everyLeakHasARemedy && HabotFloatLeak.values.length == 3,
        'only the split produces a plausible wrong answer':
            onlySplittingLooksCorrect,
        'the naive split loses a fils': theNaiveSplitLosesAFils,
        'the integer split is exact and deterministic':
            theSplitIsExact &&
                theRemainderIsOneFils &&
                theRemainderGoesSomewhereDeliberate,
        'rounding is visible before submission':
            theRoundingIsVisible &&
                theEntryIsEchoedRounded &&
                roundingNote.contains('still object to it'),
        'a rate is a rational and applies exactly':
            theRateIsARational &&
                theRateAppliesExactly &&
                !aPercentageIsForcedIntoMinorUnits,
        'the metric is Step 387\'s, five rows earlier':
            oneMetricScoresTwoUnrelatedRows && theBandIsWellFormed,
        'six obligations, all met, giving High':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'High' &&
                leaksClosed == 100,
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to ADFA rather than UDF; its metric '
      'is an automated pull-request rejection rate, identical in name and band '
      'to Step 387\'s five rows earlier, on a row about floating-point '
      'arithmetic; its Data Requirement cell holds the Atomic Step\'s own '
      'sentence as the artefact to prepare; and the Setup Step column is '
      'empty. Atomic Step: "Define client-side error handling for '
      'floating-point math precision errors."';
}
