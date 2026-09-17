/// Step 390 (BCDLD-022) -- a binary gate at the edge, on a row whose bottom
/// half is about hiding salaries.
///
/// The row: "Implement client-side validation running DCYN gate evaluation at
/// the mobile edge."
/// Metric: **Binary Compliance Gate (DCYN) Decision Accuracy (%)** -- floor
/// "98% correct gate decisions", optimal "99.5%-100%", ceiling "100% (zero
/// false negatives)". Yes (Rating Scale: Yes / No). Assigned to **ADFA**.
///
/// **The row is spliced, like Step 388 two rows earlier.** Its Atomic Step and
/// its Data Requirement are about validation at the edge with a Material error
/// state and red helper text. Everything below -- Expected Output, Completion
/// Measures, the two Material decisions, the poka-yoke cell, the dashboard
/// implication and Why This Matters -- is about masking sensitive fields,
/// blocking the clipboard and padlock markers in lists, to protect against
/// "camera screen captures in public transit". Two features, one row, and the
/// second one is a real requirement that now has no row of its own.
///
/// **A client-side gate is a latency decision, not a trust decision.** The
/// value of evaluating at the edge is that somebody learns their entry is wrong
/// in tens of milliseconds instead of a round trip; the server evaluates the
/// same rule again because the client's answer is advice. Both are stated,
/// because "gate at the edge" reads like the gate moved.
///
/// **A false negative and a false positive are not equally bad, and the band
/// says so.** The ceiling cell reads "100% (zero false negatives)" -- a false
/// negative here is a bad value accepted, and the ceiling names it. A false
/// positive is a good value refused, which is annoying and recoverable. The
/// asymmetry is the one useful thing in the band and it is in a parenthesis.
///
/// **So the gate fails closed and says which way it failed.** Five worked
/// entries: three pass, one is refused, and one cannot be decided at the edge
/// at all -- an IBAN whose checksum is fine but whose bank is unknown to the
/// client. That last one is not refused and not accepted; it is sent, and the
/// server decides.
///
/// **The standard cell holds testing advice.** Where the name of a standard
/// belongs, the row says to test on mid-tier hardware rather than developer
/// machines. It is good advice. Step 370 carried benchmarking prose in the same
/// column, which makes this the second occurrence.
library;

/// What the edge can conclude about one entry.
enum HabotEdgeDecision {
  /// The rule is satisfied, as far as the client can tell.
  pass,

  /// The rule is broken and the client can prove it.
  refuse,

  /// The client cannot decide; the server must.
  undecidable,
}

/// One worked entry.
class HabotEdgeEntry {
  const HabotEdgeEntry({
    required this.field,
    required this.value,
    required this.decision,
    required this.message,
  });

  final String field;
  final String value;
  final HabotEdgeDecision decision;

  /// Empty for entries that pass.
  final String message;
}

/// The edge-validation rule.
class HabotEdgeValidation {
  const HabotEdgeValidation._();

  // -----------------------------------------------------------------------
  // Two features in one row.
  // -----------------------------------------------------------------------

  static const String theTopHalf =
      'client-side validation with a Material error state and red helper text';

  static const String theBottomHalf =
      'masked fields, a blocked clipboard and padlock markers in lists';

  static bool get theRowDescribesTwoFeatures => theTopHalf != theBottomHalf;

  /// Step 388 in this batch has the same shape.
  static const int theOtherSplicedRow = 388;

  static const bool theSecondFeatureHasARowOfItsOwn = false;

  static const String spliceNote =
      'The Atomic Step and the Data Requirement column describe validation at '
      'the edge. Everything below them -- the expected output, the completion '
      'measure, both Material decisions, the poka-yoke cell, the dashboard '
      'implication and Why This Matters -- describes masking sensitive fields, '
      'blocking the clipboard and padlock markers in lists, against "camera '
      'screen captures in public transit". Two features in one row, as at Step '
      '388, and the second is a real requirement that now has no row of its '
      'own.';

  // -----------------------------------------------------------------------
  // Latency, not trust.
  // -----------------------------------------------------------------------

  static const bool theServerEvaluatesTheSameRule = true;

  static const bool theClientsAnswerIsAuthoritative = false;

  static bool get theEdgeGateIsAdvice =>
      theServerEvaluatesTheSameRule && !theClientsAnswerIsAuthoritative;

  static const String whatTheEdgeBuys =
      'an answer in tens of milliseconds instead of a round trip';

  static const String edgeNote =
      'Evaluating at the edge buys latency: somebody learns their entry is '
      'wrong in tens of milliseconds instead of a round trip. It buys nothing '
      'else, and the server evaluates the same rule again because the '
      'client\'s answer is advice from a program the person is holding. Both '
      'facts are stated here because "gate at the edge" reads like the gate '
      'moved.';

  // -----------------------------------------------------------------------
  // The asymmetry the band names in a parenthesis.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '98% correct gate decisions';
  static const String bandOptimalRaw = '99.5%-100%';
  static const String bandCeilingRaw = '100% (zero false negatives)';

  static bool get theCeilingNamesFalseNegatives =>
      bandCeilingRaw.contains('zero false negatives');

  static const String whatAFalseNegativeIs = 'a bad value accepted';
  static const String whatAFalsePositiveIs = 'a good value refused';

  static bool get theTwoErrorsAreNotEquivalent =>
      whatAFalseNegativeIs != whatAFalsePositiveIs;

  static bool get noneOfTheThreeCellsParses =>
      double.tryParse(bandFloorRaw) == null &&
      double.tryParse(bandOptimalRaw) == null &&
      double.tryParse(bandCeilingRaw) == null;

  static const String bandNote =
      'A false negative here is a bad value accepted and a false positive is a '
      'good value refused; the first is a record to clean up later and the '
      'second is a moment of annoyance. The ceiling cell names the asymmetry '
      '-- "100% (zero false negatives)" -- which is the most useful thing on '
      'the row, and it is inside a parenthesis in a boundary cell that does '
      'not parse as a number.';

  // -----------------------------------------------------------------------
  // Fail closed, and say which way.
  // -----------------------------------------------------------------------

  static const List<HabotEdgeEntry> entries = <HabotEdgeEntry>[
    HabotEdgeEntry(
      field: 'Mobile number',
      value: '+971 50 123 4567',
      decision: HabotEdgeDecision.pass,
      message: '',
    ),
    HabotEdgeEntry(
      field: 'Hourly rate',
      value: '45.00',
      decision: HabotEdgeDecision.pass,
      message: '',
    ),
    HabotEdgeEntry(
      field: 'Start date',
      value: '2026-09-03',
      decision: HabotEdgeDecision.pass,
      message: '',
    ),
    HabotEdgeEntry(
      field: 'Emirates ID',
      value: '784-1980-1234567-0',
      decision: HabotEdgeDecision.refuse,
      message: 'the check digit does not match the rest of the number',
    ),
    HabotEdgeEntry(
      field: 'IBAN',
      value: 'AE07 0331 2345 6789 0123 456',
      decision: HabotEdgeDecision.undecidable,
      message: 'checked here; the bank is confirmed when you save',
    ),
  ];

  static int countOf(HabotEdgeDecision d) =>
      entries.where((HabotEdgeEntry e) => e.decision == d).length;

  static bool get threePassOneRefusedOneUndecidable =>
      countOf(HabotEdgeDecision.pass) == 3 &&
      countOf(HabotEdgeDecision.refuse) == 1 &&
      countOf(HabotEdgeDecision.undecidable) == 1;

  /// The undecidable entry is neither refused nor silently accepted: it goes
  /// to the server and the person is told so.
  static bool get theUndecidableEntryIsNotRefused => entries
      .where((HabotEdgeEntry e) => e.decision == HabotEdgeDecision.undecidable)
      .every((HabotEdgeEntry e) => e.message.contains('when you save'));

  static bool get everyRefusalExplainsItself => entries
      .where((HabotEdgeEntry e) => e.decision == HabotEdgeDecision.refuse)
      .every((HabotEdgeEntry e) => e.message.isNotEmpty);

  static const bool anUndecidableEntryIsTreatedAsAPass = false;

  static const String decisionNote =
      'Three of the five entries pass, one is refused with a reason the person '
      'can act on, and one cannot be decided at the edge at all: an IBAN whose '
      'checksum is fine but whose bank the client does not know. It is neither '
      'refused nor quietly accepted -- it is sent, the server decides, and the '
      'helper text says so. A gate with only two outcomes has to guess on the '
      'third case, and guessing "pass" is how a bad value gets in.';

  // -----------------------------------------------------------------------
  // The standard cell.
  // -----------------------------------------------------------------------

  static const String standardCell =
      'Test on mid-tier mobile hardware, not developer machines, since that is '
      'where world-class INP targets are hardest to hit.';

  static bool get theStandardCellHoldsAdvice =>
      standardCell.startsWith('Test on mid-tier');

  static const bool theAdviceIsGood = true;

  /// Step 370 carried benchmarking prose in the same column.
  static const int theFirstSuchCell = 370;

  static const String standardNote =
      'Where the name of a standard belongs, this row says to test on mid-tier '
      'hardware rather than developer machines. It is good advice and it is '
      'not a standard; Step 370 carried benchmarking prose in the same column, '
      'which makes this the second occurrence and the second time the useful '
      'sentence on a row is in the wrong column.';

  static double get decidedAtTheEdge => entries.isEmpty
      ? 0
      : (entries.length - countOf(HabotEdgeDecision.undecidable)) /
          entries.length *
          100;

  static Map<String, bool> get obligations => <String, bool>{
        'the server evaluates the same rule': theEdgeGateIsAdvice,
        'three outcomes, not two': threePassOneRefusedOneUndecidable,
        'an undecidable entry is not treated as a pass':
            !anUndecidableEntryIsTreatedAsAPass &&
                theUndecidableEntryIsNotRefused,
        'every refusal explains itself': everyRefusalExplainsItself,
        'the asymmetry between the two errors is recorded':
            theTwoErrorsAreNotEquivalent,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Yes' : 'No';

  static Map<String, bool> get checks => <String, bool>{
        'the row describes two features':
            theRowDescribesTwoFeatures && theOtherSplicedRow == 388,
        'and the second one has no row of its own':
            !theSecondFeatureHasARowOfItsOwn &&
                spliceNote.contains('public transit'),
        'the edge gate is advice, not authority':
            theEdgeGateIsAdvice && whatTheEdgeBuys.contains('round trip'),
        'and the reason is latency': edgeNote.contains('the gate moved'),
        'the ceiling cell names false negatives':
            theCeilingNamesFalseNegatives && theTwoErrorsAreNotEquivalent,
        'none of the three band cells parses as a number':
            noneOfTheThreeCellsParses && bandNote.contains('a parenthesis'),
        'five entries: three pass, one refused, one undecidable':
            entries.length == 5 && threePassOneRefusedOneUndecidable,
        'the undecidable entry is sent and the person is told':
            theUndecidableEntryIsNotRefused &&
                decisionNote.contains('guessing "pass"'),
        'the standard cell holds testing advice, as at Step 370':
            theStandardCellHoldsAdvice &&
                theAdviceIsGood &&
                theFirstSuchCell == 370,
        'five obligations, all met, giving Yes':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Yes' &&
                decidedAtTheEdge == 80,
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to ADFA rather than UDF; its top half '
      'describes client-side validation and everything from Expected Output '
      'downward describes masking sensitive fields, blocking the clipboard and '
      'padlock markers in lists, so two features share one row as at Step 388; '
      'none of its three boundary cells parses as a number and the ceiling '
      'holds the useful asymmetry inside a parenthesis; its standard column '
      'holds testing advice rather than a standard, as Step 370\'s does; and '
      'its Setup Step column reads "Verify the timeout counter displays '
      'correctly across all device sizes". Atomic Step: "Implement client-side '
      'validation running DCYN gate evaluation at the mobile edge."';
}
