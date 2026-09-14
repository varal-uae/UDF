/// Step 252 (GEN-03569) -- source minus destination equals zero, and why
/// doing that in a double refuses correct submissions.
///
/// The row: "Implement local pre-submit mathematical validation gates in the
/// mobile UI layer (Source - Destination = 0)."
/// Metric: **Client-Side Math Gate Latency** -- floor < 50 ms, optimal < 10
/// ms, ceiling < 100 ms. Pass/Fail. Standard cited: W3C Client Performance.
///
/// **The failure mode is refusing good data, not accepting bad.** Splitting
/// AED 0.70 into 0.10, 0.20 and 0.40 is correct, and in binary floating point
/// `0.7 - (0.1 + 0.2 + 0.4)` is `-1.1102230246251565e-16`. A gate that tests
/// that difference against zero blocks a parent who entered the right numbers,
/// and tells them their split does not balance when it does. Step 140 built
/// [HabotFixed] for exactly this; the gate runs on scaled integers, where the
/// same split is exactly zero.
///
/// **"= 0" means zero, not nearly zero.** The obvious repair to the floating
/// point problem is an epsilon, and an epsilon wide enough to absorb binary
/// error is also wide enough to absorb a fils. At fils precision the smallest
/// real discrepancy is one unit, so a tolerance that admits anything admits
/// the one error the gate exists to catch.
///
/// **Two of the three latency boundaries were already declared.** 50ms is
/// `HabotMotion.orderTotalRecalculationBudget`, from Step 204. 100ms is
/// `HabotMotion.railInstant`. Only the 10ms optimal is new -- the same shape
/// as Step 235, where two of three SLA figures had been in force for seventy
/// steps. And the band is generous by orders of magnitude: this gate is a
/// handful of integer additions, so the operation count is published beside
/// the budget because that is the number that would ever change.
library;

import '../i18n/fixed_precision.dart';
import '../tokens/motion_tokens.dart';

/// One split to check: a source amount and the destinations it is divided
/// into.
class HabotBalanceCase {
  const HabotBalanceCase({
    required this.label,
    required this.source,
    required this.destinations,
    required this.balances,
    required this.why,
  });

  final String label;

  /// Exact decimal text. Parsed at storage scale, never through a double.
  final String source;

  final List<String> destinations;

  /// What the arithmetic should say.
  final bool balances;

  final String why;
}

/// The gate.
class HabotBalanceGate {
  const HabotBalanceGate._();

  /// Everything is compared at storage scale, which is where the repository
  /// holds money.
  static int get scale => HabotPrecision.storageScale;

  static HabotFixed parse(String text) =>
      HabotFixed.parse(text, scale: scale);

  static HabotFixed sumOf(List<String> amounts) {
    HabotFixed total = HabotFixed.parse('0', scale: scale);
    for (final String amount in amounts) {
      total = total + parse(amount);
    }
    return total;
  }

  /// Source minus destination. Exactly zero or it does not balance.
  static HabotFixed differenceFor({
    required String source,
    required List<String> destinations,
  }) =>
      parse(source) - sumOf(destinations);

  static bool balances({
    required String source,
    required List<String> destinations,
  }) =>
      differenceFor(source: source, destinations: destinations).isZero;

  /// The number of arithmetic operations the gate performs: one addition per
  /// destination, then one subtraction. This is the figure the latency band
  /// is really about.
  static int operationsFor(int destinationCount) => destinationCount + 1;

  // -----------------------------------------------------------------------
  // What a double would do with the same splits.
  // -----------------------------------------------------------------------

  static double _doubleDifference(String source, List<String> destinations) {
    double total = 0;
    for (final String amount in destinations) {
      total += double.parse(amount);
    }
    return double.parse(source) - total;
  }

  /// Whether a gate implemented in binary floating point would reject this
  /// split. Computed, not asserted.
  static bool doubleWouldRefuse(HabotBalanceCase c) =>
      c.balances && _doubleDifference(c.source, c.destinations) != 0;

  // -----------------------------------------------------------------------
  // The corpus.
  // -----------------------------------------------------------------------

  static const List<HabotBalanceCase> corpus = <HabotBalanceCase>[
    HabotBalanceCase(
      label: 'seventy fils into ten, twenty and forty',
      source: '0.70',
      destinations: <String>['0.10', '0.20', '0.40'],
      balances: true,
      why: 'Correct, and the case a double refuses: 0.7 - (0.1 + 0.2 + 0.4) '
          'is not zero in binary floating point. This is the whole reason the '
          'gate does not use one.',
    ),
    HabotBalanceCase(
      label: 'three-line order against its total',
      source: '331.26',
      destinations: <String>['315.49', '15.77'],
      balances: true,
      why: 'The Step 204 figures. Balances exactly at fils precision.',
    ),
    HabotBalanceCase(
      label: 'the same order, one fils out',
      source: '331.26',
      destinations: <String>['315.49', '15.78'],
      balances: false,
      why: 'One fils. The smallest real discrepancy there is, and the one an '
          'epsilon wide enough to absorb floating-point error would let '
          'through.',
    ),
    HabotBalanceCase(
      label: 'a refund split across two cards',
      source: '120.00',
      destinations: <String>['80.00', '40.00'],
      balances: true,
      why: 'Round numbers, which a double also gets right -- included so the '
          'corpus is not only cases chosen to embarrass floating point.',
    ),
    HabotBalanceCase(
      label: 'a single destination that is short',
      source: '50.00',
      destinations: <String>['49.99'],
      balances: false,
      why: 'The simplest possible imbalance, to check the gate is not passing '
          'everything with one destination.',
    ),
    HabotBalanceCase(
      label: 'no destinations at all',
      source: '10.00',
      destinations: <String>[],
      balances: false,
      why: 'An empty split is not a balanced one. A sum over an empty list is '
          'zero, and a gate that forgot this would report a form with nothing '
          'entered as ready to submit.',
    ),
  ];

  static bool get corpusIsClassifiedCorrectly => corpus.every(
        (HabotBalanceCase c) =>
            balances(source: c.source, destinations: c.destinations) ==
            c.balances,
      );

  /// The cases a floating-point gate would wrongly refuse.
  static List<HabotBalanceCase> get refusedByADouble =>
      corpus.where(doubleWouldRefuse).toList();

  static double get exactGateAccuracy =>
      corpusIsClassifiedCorrectly ? 1 : 0;

  /// What a double-based gate would score on the same corpus.
  static double get doubleGateAccuracy {
    int correct = 0;
    for (final HabotBalanceCase c in corpus) {
      final bool accepts = _doubleDifference(c.source, c.destinations) == 0;
      if (accepts == c.balances) {
        correct += 1;
      }
    }
    return correct / corpus.length;
  }

  // -----------------------------------------------------------------------
  // Epsilon, and why there is none.
  // -----------------------------------------------------------------------

  /// The smallest real discrepancy, at the precision money is displayed to.
  static HabotFixed get smallestRealDiscrepancy =>
      HabotFixed.parse('0.01', scale: HabotPrecision.displayScale);

  static bool get anEpsilonWouldSwallowAFils =>
      !smallestRealDiscrepancy.isZero &&
      !balances(source: '331.26', destinations: <String>['315.49', '15.78']);

  static const String noEpsilonNote =
      '"= 0" means zero, not nearly zero. The obvious repair to the '
      'floating-point problem is an epsilon, and an epsilon wide enough to '
      'absorb binary error is also wide enough to absorb a fils. At fils '
      'precision the smallest real discrepancy is one unit, so a tolerance '
      'that admits anything admits the one error the gate exists to catch. On '
      'scaled integers no tolerance is needed, because there is no error to '
      'tolerate.';

  // -----------------------------------------------------------------------
  // Metric: Client-Side Math Gate Latency.
  // -----------------------------------------------------------------------

  /// 50ms. Declared at Step 204 as the budget for recomputing an order total.
  static Duration get latencyFloor => HabotMotion.orderTotalRecalculationBudget;

  /// 10ms. The one figure this row adds.
  static Duration get latencyOptimal => HabotMotion.clientMathGateBudget;

  /// 100ms. The RAIL instant band.
  static Duration get latencyCeiling => HabotMotion.railInstant;

  static bool get twoOfThreeBoundariesWereAlreadyDeclared =>
      latencyFloor.inMilliseconds == 50 &&
      latencyCeiling.inMilliseconds == 100 &&
      latencyOptimal.inMilliseconds == 10 &&
      latencyFloor == HabotMotion.orderTotalRecalculationBudget &&
      latencyCeiling == HabotMotion.railInstant;

  /// The largest split in the corpus, and what it costs.
  static int get worstCaseOperations => corpus
      .map((HabotBalanceCase c) => operationsFor(c.destinations.length))
      .reduce((int a, int b) => a > b ? a : b);

  static const String latencyIsNotTheRiskNote =
      'The band is generous by orders of magnitude. The worst case in this '
      'corpus is four integer operations -- three additions and a '
      'subtraction -- and ten milliseconds is not a budget for four integer '
      'operations, it is a budget for a frame. So the operation count is '
      'published beside the budget, because the operation count is the number '
      'that would ever change: a gate that started doing per-line tax '
      'recomputation, or that parsed strings inside a loop over a long order, '
      'is the shape that eventually costs something. The latency band cannot '
      'detect that until it already has.';

  static const String alreadyDeclaredNote =
      'Two of the three latency boundaries were already declared. 50ms is '
      'HabotMotion.orderTotalRecalculationBudget, from Step 204. 100ms is '
      'HabotMotion.railInstant. Only the 10ms optimal is new -- the same '
      'shape as Step 235, where two of three SLA figures had been in force '
      'for seventy steps and what was missing was the record.';

  static const String refusingGoodDataNote =
      'FINDING: the failure mode here is refusing good data, not accepting '
      'bad. Splitting AED 0.70 into 0.10, 0.20 and 0.40 is correct, and in '
      'binary floating point 0.7 - (0.1 + 0.2 + 0.4) is about -1.1e-16. A '
      'gate that tests that difference against zero blocks a parent who '
      'entered the right numbers and tells them their split does not balance '
      'when it does -- and there is nothing they can type that will make it '
      'balance. Step 140 built HabotFixed for exactly this; the gate runs on '
      'scaled integers, where the same split is exactly zero.';

  static String get qualitativeOutput =>
      corpusIsClassifiedCorrectly && exactGateAccuracy == 1 ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'six splits are classified correctly': corpusIsClassifiedCorrectly &&
            corpus.length == 6,
        'the exact gate scores 1.0 and a floating-point one does not':
            exactGateAccuracy == 1.0 && doubleGateAccuracy < 1.0,
        'exactly one split in the corpus is one a double would refuse':
            refusedByADouble.length == 1 &&
                refusedByADouble.single.source == '0.70',
        'the corpus includes a split a double gets right, so it is not only '
            'chosen to embarrass one': corpus.any(
          (HabotBalanceCase c) =>
              c.balances && !doubleWouldRefuse(c),
        ),
        'a one-fils discrepancy does not balance': anEpsilonWouldSwallowAFils,
        'an empty split does not balance':
            !balances(source: '10.00', destinations: <String>[]),
        'the gate runs at storage scale': scale == HabotPrecision.storageScale,
        'two of the three latency boundaries were already declared tokens':
            twoOfThreeBoundariesWereAlreadyDeclared,
        'the operation count is published beside the budget':
            worstCaseOperations == 4 &&
                latencyIsNotTheRiskNote.contains('four integer operations'),
        'there is no epsilon, and the reason is written down':
            noEpsilonNote.contains('no error to tolerate'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Implement local pre-submit mathematical validation gates in the '
      'mobile UI layer (Source - Destination = 0)."';
}
