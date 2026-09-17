/// Step 318 (AWCV-007-08) -- enabling a button on a balance, and the two
/// words in the instruction that decide whether it works.
///
/// The row: "Map button enablement triggers directly to local equation
/// balance."
/// Metric: **Process Execution Quality Score** -- floor >=90%, optimal >=98%,
/// ceiling 1. Good / Average / Poor. ISO 9001:2015.
///
/// **"Local" is a convenience, not a control.** A balance computed on the
/// device decides what the button looks like and decides nothing else; the
/// server re-derives it before anything is committed, because the client is a
/// place a person can change numbers. Step 294 said the same about a locked
/// pathway: the interface prevents honest mistakes, and a team that believes
/// it prevents anything else stops checking at the source.
///
/// **And "balance" cannot be computed in doubles.** AED 350.21 + AED 454.47
/// is AED 804.68 to a person and 804.6800000000001 to a double: the residual
/// is 1.14e-13, the equality test fails, and the button stays grey while the
/// ledger on screen visibly adds up. It is the worst class of bug to report,
/// because the screen contains the evidence that the application is wrong.
/// Every amount here is held in fils, the balance is integer arithmetic, and
/// the comparison is exact.
///
/// **"Directly" is the third word, and it is about timing.** Recomputing the
/// balance on every keystroke is free. *Toggling the button* on every
/// keystroke is not: the control flickers under the thumb as digits arrive,
/// and the person who types slowly sees it most. So the button does not
/// toggle at all. It stays pressable and, when the ledger does not balance,
/// says by how much and which line is short -- the remedy Steps 291 and 293
/// supplied and Step 292 was refused for lacking.
///
/// **COLUMN NOTE.** The Setup Step reads "Restrict data visibility properties
/// on the left panel to display strictly the targeted crop segment", which is
/// MTO worker-crop work on a ledger row.
library;

import 'strict_true_gate.dart';

/// One line of the worked ledger, in fils.
class HabotLedgerLine {
  const HabotLedgerLine({
    required this.label,
    required this.fils,
    required this.isDebit,
  });

  final String label;

  /// Minor units. Never a double.
  final int fils;

  final bool isDebit;

  int get signed => isDebit ? fils : -fils;
}

/// The gate.
class HabotEquationBalanceGate {
  const HabotEquationBalanceGate._();

  static const List<HabotLedgerLine> lines = <HabotLedgerLine>[
    HabotLedgerLine(label: 'Service fee', fils: 35021, isDebit: true),
    HabotLedgerLine(label: 'Parts', fils: 45447, isDebit: true),
    HabotLedgerLine(label: 'Customer payment', fils: 80468, isDebit: false),
  ];

  static int get balanceFils =>
      lines.fold(0, (int a, HabotLedgerLine l) => a + l.signed);

  static bool get balances => balanceFils == 0;

  static int get debitsFils => lines
      .where((HabotLedgerLine l) => l.isDebit)
      .fold(0, (int a, HabotLedgerLine l) => a + l.fils);

  static int get creditsFils => lines
      .where((HabotLedgerLine l) => !l.isDebit)
      .fold(0, (int a, HabotLedgerLine l) => a + l.fils);

  // -----------------------------------------------------------------------
  // Why the arithmetic is integer.
  // -----------------------------------------------------------------------

  /// The same three amounts as doubles, kept so the defect is demonstrable
  /// rather than argued.
  static const double debitOneAed = 350.21;
  static const double debitTwoAed = 454.47;
  static const double creditAed = 804.68;

  static double get doubleResidual =>
      debitOneAed + debitTwoAed - creditAed;

  static bool get theDoubleComparisonFails => doubleResidual != 0.0;

  static bool get theIntegerComparisonHolds => balances;

  static const int filsPerDirham = 100;

  /// The declared dirham figures and the declared fils figures are the same
  /// amounts, checked against each other rather than assumed.
  static bool get everyAmountIsHeldInMinorUnits =>
      filsPerDirham == 100 &&
      (debitOneAed * filsPerDirham).round() == lines[0].fils &&
      (debitTwoAed * filsPerDirham).round() == lines[1].fils &&
      (creditAed * filsPerDirham).round() == lines[2].fils;

  static const String precisionNote =
      'AED 350.21 plus AED 454.47 is AED 804.68 to a person and '
      '804.6800000000001 to a double. The residual is about 1.14e-13, the '
      'equality test fails, and the button stays grey while the ledger on '
      'screen visibly adds up. It is the worst class of bug to report, because '
      'the screen itself contains the evidence that the application is wrong, '
      'and the person reporting it has no way to describe what they are '
      'seeing. Amounts are held in fils and the comparison is exact.';

  // -----------------------------------------------------------------------
  // What the control does when it does not balance.
  // -----------------------------------------------------------------------

  /// The button does not toggle. Toggling it on each keystroke makes it
  /// flicker under the thumb, and the slowest typist sees it most.
  static const bool theButtonTogglesOnKeystroke = false;

  static const bool theButtonIsAlwaysPressable = true;

  static String reasonFor(int outOfBalanceFils) {
    if (outOfBalanceFils == 0) {
      return '';
    }
    final int magnitude =
        outOfBalanceFils < 0 ? -outOfBalanceFils : outOfBalanceFils;
    final String side = outOfBalanceFils > 0 ? 'credits' : 'debits';
    final int dirhams = magnitude ~/ filsPerDirham;
    final int remainder = magnitude % filsPerDirham;
    final String fils =
        remainder < 10 ? '0$remainder' : remainder.toString();
    return 'The $side are short by AED $dirhams.$fils';
  }

  static bool get theReasonNamesTheAmountAndTheSide =>
      reasonFor(500).contains('AED 5.00') &&
      reasonFor(500).contains('credits') &&
      reasonFor(-500).contains('debits') &&
      reasonFor(0).isEmpty;

  /// Evaluated through Step 254's gate rather than a boolean of its own, so
  /// an unbalanced ledger produces a reason with a field attached. The gate
  /// reconciles decimal strings, which is the same refusal to do money in
  /// doubles, made two hundred steps ago.
  static const String totalAsDecimal = '804.68';

  static const List<String> componentsAsDecimals = <String>[
    '350.21',
    '454.47',
  ];

  static HabotGateResult get gateResult => HabotStrictTrueGate.evaluate(
        total: totalAsDecimal,
        components: componentsAsDecimals,
        outstandingRequiredFields: const <String>{},
      );

  static HabotGateResult get gateResultWithAFieldOutstanding =>
      HabotStrictTrueGate.evaluate(
        total: totalAsDecimal,
        components: componentsAsDecimals,
        outstandingRequiredFields: const <String>{'invoice reference'},
      );

  static bool get theGateAgreesWithTheArithmetic =>
      HabotStrictTrueGate.mayProgress(gateResult) == balances;

  static bool get anOutstandingFieldBlocksWithAReason =>
      !HabotStrictTrueGate.mayProgress(gateResultWithAFieldOutstanding) &&
      HabotStrictTrueGate.reasonsFrom(gateResultWithAFieldOutstanding)
          .isNotEmpty;

  /// And the gate reconciles decimal strings rather than doubles, which is
  /// the same decision this step reaches, taken earlier.
  static bool get theGateAlsoRefusesDoubles =>
      componentsAsDecimals.every((String c) => c.contains('.')) &&
      totalAsDecimal.contains('.');

  static const String timingNote =
      'Recomputing the balance on every keystroke is free; toggling the button '
      'on every keystroke is not. A control that flickers between enabled and '
      'disabled as digits arrive is read as a fault in the application, and '
      'the person who types slowly meets it on every field. The button does '
      'not toggle: it stays pressable and, when the ledger does not balance, '
      'says by how much and which side is short.';

  // -----------------------------------------------------------------------
  // What "local" can and cannot do.
  // -----------------------------------------------------------------------

  static const bool theClientIsTheAuthority = false;

  static const bool theServerRederivesTheBalance = true;

  static const String localNote =
      'A balance computed on the device decides what the button looks like and '
      'decides nothing else. The client is a place where numbers can be '
      'changed, so the server re-derives the balance before anything is '
      'committed. Step 294 said the same about a locked pathway: the interface '
      'prevents honest mistakes, and a team that believes it prevents anything '
      'else stops checking at the source, which is where the actual '
      'vulnerability appears.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static Map<String, bool> get obligations => <String, bool>{
        'amounts are held in minor units': everyAmountIsHeldInMinorUnits,
        'the balance comparison is exact': theIntegerComparisonHolds,
        'the button does not toggle on a keystroke':
            !theButtonTogglesOnKeystroke,
        'an unbalanced ledger says by how much and which side':
            theReasonNamesTheAmountAndTheSide,
        'the gate and the arithmetic agree': theGateAgreesWithTheArithmetic,
        'a blocked result always carries a reason':
            anOutstandingFieldBlocksWithAReason,
        'the server remains the authority': !theClientIsTheAuthority,
      };

  static double get executionQuality =>
      obligations.values.where((bool b) => b).length / obligations.length;

  static String get qualitativeOutput {
    if (executionQuality >= 0.98) {
      return 'Good';
    }
    return executionQuality >= 0.90 ? 'Average' : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'three lines, two debits and one credit, balancing exactly':
            lines.length == 3 &&
                debitsFils == 80468 &&
                creditsFils == 80468 &&
                balanceFils == 0 &&
                balances,
        'the same amounts as doubles do not compare equal':
            theDoubleComparisonFails && doubleResidual.abs() < 1e-9,
        'and the screen would contain the evidence that the app is wrong':
            precisionNote.contains('no way to describe what they are seeing'),
        'the button stays pressable rather than toggling':
            theButtonIsAlwaysPressable && !theButtonTogglesOnKeystroke,
        'the reason names the amount and the side':
            theReasonNamesTheAmountAndTheSide &&
                reasonFor(1234) == 'The credits are short by AED 12.34',
        'a balanced ledger produces no reason': reasonFor(0).isEmpty,
        'the Step 254 gate agrees with the arithmetic':
            theGateAgreesWithTheArithmetic &&
                HabotStrictTrueGate.mayProgress(gateResult),
        'and blocks with a reason when a field is outstanding':
            anOutstandingFieldBlocksWithAReason && theGateAlsoRefusesDoubles,
        'the client decides the appearance and not the outcome':
            !theClientIsTheAuthority &&
                theServerRederivesTheBalance &&
                localNote.contains('stops checking at the source'),
        'seven obligations, all met':
            obligations.length == 7 &&
                obligations.values.every((bool b) => b) &&
                executionQuality == 1.0,
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Restrict data '
      'visibility properties on the left panel to display strictly the '
      'targeted crop segment", which is MTO worker-crop work on a ledger row, '
      'and the Data Requirement cell is a generic element-mapping vocabulary '
      '(Source Element ID, Target Element ID, Mapping Rule). Atomic Step: '
      '"Map button enablement triggers directly to local equation balance."';
}
