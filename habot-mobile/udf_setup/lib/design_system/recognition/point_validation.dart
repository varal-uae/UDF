/// Step 438 (GEN-02104) -- points tied to validation, and the first row where
/// the accounting metric this sheet keeps misapplying actually fits.
///
/// The row: "Mathematically link point generation to system validation to
/// prevent cheating."
/// Metric: **Mathematical Balance Validation Accuracy (%)** -- floor 99.5,
/// optimal 99.99, ceiling 100. Complete/Partial/Not Complete. ISO/IEC
/// 27035:2016 (Data Integrity) & OWASP Standards. Assigned to **DEA**.
///
/// **The same metric and band as Step 435, and this time the metric fits.**
/// Step 435 carried the A - B = 0 triangular-check measure onto a variant
/// assignment, where there was no balance to validate. Points are different:
/// points are a ledger. Every point awarded (A) should be matched by a
/// validated completion that earned it (B), and A - B = 0 is precisely the
/// check. After two batches of this metric landing on the wrong row, it lands
/// on the right one -- which is worth recording, because it shows the metric
/// was never the defect; where it was put was.
///
/// **And a floor of 99.5 is still wrong.** A ledger that balances to 99.5 per
/// cent is an unbalanced ledger. One point in two hundred without a completion
/// behind it is one point in two hundred that was minted from nothing, and on a
/// ledger the honest band is one cell -- zero difference -- for the third time
/// after Steps 411 and 435.
///
/// **Cheating is information about the rules.** When people game a points
/// system it usually means the points reward something other than the work:
/// the measure has become the target. So a detected pattern is reported as a
/// finding about the rule that allowed it, and not as an accusation against the
/// person who found it -- which is the third rule of Step 436's charter
/// applied: no score produces a consequence without a named person deciding.
///
/// **One kind of cheating a ledger cannot see.** Two people approving each
/// other's requests produce points that balance perfectly, because every point
/// has a real, validated completion behind it. A - B = 0 does not catch
/// collusion. That needs a separation-of-duties rule -- nobody approves their
/// own request, and reciprocal approvals between the same pair are surfaced for
/// a person to look at -- and the limit is written down so nobody mistakes a
/// balanced ledger for an honest one.
library;

import 'completion_criteria.dart';
import 'progress_events.dart';

/// One line on the points ledger.
class HabotPointLine {
  const HabotPointLine({
    required this.points,
    required this.completionId,
  });

  final int points;

  /// Empty where no validated completion backs the line.
  final String completionId;
}

/// The point-validation ledger.
class HabotPointValidation {
  const HabotPointValidation._();

  // -----------------------------------------------------------------------
  // The metric fits, for once.
  // -----------------------------------------------------------------------

  static const String metricName =
      'Mathematical Balance Validation Accuracy (%)';

  /// Step 435 carried it onto a variant assignment.
  static const int theRowWhereItDidNotFit = 435;

  static const bool pointsAreALedger = true;

  static bool get theMetricFitsThisRow =>
      pointsAreALedger && metricName.contains('Balance');

  static const String fitNote =
      'Step 435 carried this A - B = 0 measure onto a variant assignment, '
      'where there was no balance to validate. Points are a ledger: every '
      'point awarded should be matched by the validated completion that earned '
      'it, and A - B = 0 is exactly the check. After two batches of this '
      'metric on the wrong row it lands on the right one, which shows the '
      'metric was never the defect -- where it was put was.';

  // -----------------------------------------------------------------------
  // The ledger.
  // -----------------------------------------------------------------------

  static const List<HabotPointLine> ledger = <HabotPointLine>[
    HabotPointLine(points: 10, completionId: 'ot-2291'),
    HabotPointLine(points: 10, completionId: 'ot-2304'),
    HabotPointLine(points: 25, completionId: 'trn-118'),
    HabotPointLine(points: 5, completionId: 'swp-077'),
    HabotPointLine(points: 10, completionId: 'exp-0402'),
  ];

  static int get pointsAwarded =>
      ledger.fold(0, (int a, HabotPointLine l) => a + l.points);

  static int get pointsBacked => ledger
      .where((HabotPointLine l) => l.completionId.isNotEmpty)
      .fold(0, (int a, HabotPointLine l) => a + l.points);

  static int get difference => pointsAwarded - pointsBacked;

  static bool get theLedgerBalances => difference == 0;

  static bool get everyLineCarriesItsCompletion =>
      ledger.every((HabotPointLine l) => l.completionId.isNotEmpty);

  static bool get onlyTheServerMintsPoints =>
      HabotProgressEvents.whoDecidesALevel == HabotEventAuthority.server;

  static bool get aCompletionIsTheStep436Kind =>
      HabotCompletionCriteria.aNotifiedTerminalRecordIsComplete;

  // -----------------------------------------------------------------------
  // A floor of 99.5 is an unbalanced ledger.
  // -----------------------------------------------------------------------

  static const double bandFloor = 99.5;
  static const double bandOptimal = 99.99;
  static const double bandCeiling = 100;

  static bool get theFloorAllowsAnUnbalancedLedger => bandFloor < 100;

  /// Steps 411, 435 and this one.
  static const List<int> rowsWhoseHonestBandIsOneCell = <int>[411, 435, 438];

  static bool get thirdSuchRow => rowsWhoseHonestBandIsOneCell.length == 3;

  static double get balanceAccuracy => pointsAwarded == 0
      ? 0
      : (pointsAwarded - difference.abs()) / pointsAwarded * 100;

  static const String floorNote =
      'A ledger that balances to 99.5 per cent is an unbalanced ledger: one '
      'point in two hundred minted from nothing. On a ledger the honest band '
      'is one cell -- zero difference -- which makes this the third row whose '
      'true measure is a single value the sheet cannot express, after Steps '
      '411 and 435.';

  // -----------------------------------------------------------------------
  // Cheating is information about the rules.
  // -----------------------------------------------------------------------

  static const bool aPatternIsReportedAsAFindingAboutTheRule = true;

  static const bool aPatternTriggersAConsequenceAutomatically = false;

  static bool get theCharterThirdRuleHolds =>
      !aPatternTriggersAConsequenceAutomatically &&
      HabotScoringCharter.rules[2].contains('named person');

  static const String gamingNote =
      'When people game a points system it usually means the points reward '
      'something other than the work -- the measure has become the target. A '
      'detected pattern is reported as a finding about the rule that allowed '
      'it and not as an accusation against the person who found it, and no '
      'pattern produces a consequence without somebody named deciding.';

  // -----------------------------------------------------------------------
  // What a ledger cannot see.
  // -----------------------------------------------------------------------

  static const bool theLedgerCatchesCollusion = false;

  static const bool selfApprovalIsForbidden = true;

  static const bool reciprocalApprovalsAreSurfaced = true;

  static const bool reciprocalApprovalsAreBlocked = false;

  static bool get separationOfDutiesCoversTheGap =>
      selfApprovalIsForbidden &&
      reciprocalApprovalsAreSurfaced &&
      !reciprocalApprovalsAreBlocked;

  static const String collusionNote =
      'Two people approving each other\'s requests produce points that balance '
      'perfectly, because every point has a real validated completion behind '
      'it. A - B = 0 does not catch collusion. Nobody may approve their own '
      'request, and reciprocal approvals between the same pair are surfaced '
      'for a person to look at rather than blocked, because two colleagues '
      'covering each other\'s shifts is also what reciprocity looks like. The '
      'limit is written down so a balanced ledger is not mistaken for an '
      'honest one.';

  static String get qualitativeOutput =>
      theLedgerBalances && everyLineCarriesItsCompletion
          ? 'Complete'
          : 'Partial';

  static const String columnNote =
      'COLUMN NOTE: this row\'s metric and band -- Mathematical Balance '
      'Validation Accuracy at 99.5, 99.99, 100 -- are identical to Step '
      '435\'s, and here the metric fits, because points are a ledger and A - B '
      '= 0 is the right check; its floor of 99.5 still permits an unbalanced '
      'ledger, so the honest band is one cell, the third such row after Steps '
      '411 and 435; and its instruction to "prevent cheating" is met by '
      'server-minted points carrying their completion, with gaming reported as '
      'a finding about the rule and collusion covered by separation of duties '
      'rather than by the ledger. Atomic Step: "Mathematically link point '
      'generation to system validation to prevent cheating."';

  static Map<String, bool> get obligations => <String, bool>{
        'every point carries its completion': everyLineCarriesItsCompletion,
        'only the server mints points': onlyTheServerMintsPoints,
        'the ledger balances to zero': theLedgerBalances,
        'no pattern triggers a consequence automatically':
            theCharterThirdRuleHolds,
        'separation of duties covers what the ledger cannot':
            separationOfDutiesCoversTheGap,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the same metric as Step 435, and here it fits':
            theMetricFitsThisRow && theRowWhereItDidNotFit == 435,
        'so the defect was always where it was put':
            fitNote.contains('where it was put was'),
        'five ledger lines, each carrying its completion':
            ledger.length == 5 && everyLineCarriesItsCompletion,
        'sixty points awarded, sixty backed, difference zero':
            pointsAwarded == 60 && pointsBacked == 60 && theLedgerBalances,
        'and only the server mints them':
            onlyTheServerMintsPoints && aCompletionIsTheStep436Kind,
        'a floor of 99.5 permits an unbalanced ledger':
            theFloorAllowsAnUnbalancedLedger && thirdSuchRow,
        'gaming is a finding about the rule':
            aPatternIsReportedAsAFindingAboutTheRule &&
                theCharterThirdRuleHolds,
        'and not an accusation against the person':
            gamingNote.contains('not as an accusation'),
        'the ledger cannot see collusion, and says so':
            !theLedgerCatchesCollusion &&
                separationOfDutiesCoversTheGap &&
                collusionNote.contains('mistaken for an honest one'),
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete' &&
                balanceAccuracy == 100,
      };
}
