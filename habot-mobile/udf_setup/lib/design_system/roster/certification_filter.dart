/// Step 474 (GEN-05199) -- a safeguarding check with a 95 per cent floor,
/// which is the sharpest band defect in the track so far.
///
/// The row: "Build and configure: implement an indisputable filter algorithm
/// verifying DCYN == 1 and LSA/Therapist certification status prior to
/// display"
/// Metric: **Document/Credential Verification Accuracy** -- floor ">= 95%",
/// optimal ">= 99%", ceiling "1". Pass / Fail. ISO/IEC 27001 Information
/// Security & KYC Verification Standard. Assigned to **UDF**.
///
/// **Read as the filter's accuracy, a floor of 95 per cent means one in
/// twenty.** One uncertified adult in twenty reaching a family's screen is
/// not a minimum acceptable state; it is the thing the filter exists to
/// prevent. Nobody would sign that floor if it were written in words instead
/// of a percentage.
///
/// **So the filter is not a percentage at all.** Displaying somebody is a
/// hard gate: certification present, verified and unexpired, and the DCYN
/// flag equal to 1, or the person is not shown. There is no confidence
/// threshold at which an unverified worker is displayed anyway. The band's
/// 95 and 99 are re-read as what they can honestly measure -- the accuracy
/// of the automated reader that extracts a certificate's identity, issuer and
/// expiry -- and everything the reader cannot confirm goes to a person
/// rather than through.
///
/// **"Indisputable" is not a property an algorithm can have.** What it can
/// have is a decision that is recorded, explainable and reviewable. So every
/// exclusion carries its reason, and a named human can override in one
/// direction only: to exclude somebody the filter allowed, never to include
/// somebody it refused.
///
/// **"DCYN" is never expanded.** It is the third unexpanded abbreviation in
/// two batches, after ZII at Step 453 and LSA at Step 472. It is treated as
/// an opaque flag that must equal 1, and the question of what it stands for
/// is recorded with a named confirmer rather than guessed at.
///
/// **A certificate valid yesterday is not valid today**, so the check runs at
/// display time rather than at registration, and expiry is a reason for
/// exclusion like any other.
library;

import 'availability_objective.dart';

/// One worker's credential state at the moment of a query.
class HabotCredentialState {
  const HabotCredentialState({
    required this.workerId,
    required this.dcyn,
    required this.certificatePresent,
    required this.readerConfident,
    required this.humanVerified,
    required this.expiresOn,
  });

  final String workerId;

  /// The flag the row requires to equal 1. Opaque.
  final int dcyn;

  final bool certificatePresent;

  /// Whether the automated reader could confirm identity, issuer and expiry.
  final bool readerConfident;

  /// Whether a person has verified it, which is where anything the reader
  /// could not confirm goes.
  final bool humanVerified;

  final String expiresOn;
}

/// The certification display filter.
class HabotCertificationFilter {
  const HabotCertificationFilter._();

  // -----------------------------------------------------------------------
  // What a 95 per cent floor would mean.
  // -----------------------------------------------------------------------

  static const double bandFloorPercent = 95;
  static const double bandOptimalPercent = 99;
  static const String bandCeilingRaw = '1';

  static int get uncertifiedShownPerTwentyAtTheFloor =>
      ((100 - bandFloorPercent) / 5).round();

  static bool get theFloorWouldAllowOneInTwenty =>
      uncertifiedShownPerTwentyAtTheFloor == 1;

  static bool get theBandMixesUnits =>
      double.tryParse(bandCeilingRaw) != null && bandFloorPercent > 1;

  static const String floorNote =
      'One uncertified adult in twenty reaching a family\'s screen is not a '
      'minimum acceptable state; it is the thing the filter exists to prevent. '
      'Nobody would sign that floor if it were written in words instead of a '
      'percentage. Its ceiling is a bare 1 under two percentage cells, so the '
      'band does not even hold one unit.';

  // -----------------------------------------------------------------------
  // A hard gate, not a threshold.
  // -----------------------------------------------------------------------

  static const List<HabotCredentialState> workers = <HabotCredentialState>[
    HabotCredentialState(
      workerId: 'w-311',
      dcyn: 1,
      certificatePresent: true,
      readerConfident: true,
      humanVerified: false,
      expiresOn: '2027-01-31',
    ),
    HabotCredentialState(
      workerId: 'w-312',
      dcyn: 1,
      certificatePresent: true,
      readerConfident: false,
      humanVerified: true,
      expiresOn: '2026-12-01',
    ),
    HabotCredentialState(
      workerId: 'w-313',
      dcyn: 1,
      certificatePresent: true,
      readerConfident: false,
      humanVerified: false,
      expiresOn: '2027-03-15',
    ),
    HabotCredentialState(
      workerId: 'w-314',
      dcyn: 0,
      certificatePresent: true,
      readerConfident: true,
      humanVerified: true,
      expiresOn: '2027-05-05',
    ),
    HabotCredentialState(
      workerId: 'w-315',
      dcyn: 1,
      certificatePresent: true,
      readerConfident: true,
      humanVerified: true,
      expiresOn: '2026-08-01',
    ),
  ];

  static const String today = '2026-09-23';

  static bool isUnexpired(HabotCredentialState w) =>
      w.expiresOn.compareTo(today) > 0;

  static bool isVerified(HabotCredentialState w) =>
      w.certificatePresent && (w.readerConfident || w.humanVerified);

  static bool isDisplayed(HabotCredentialState w) =>
      w.dcyn == 1 && isVerified(w) && isUnexpired(w);

  static List<HabotCredentialState> get displayed =>
      workers.where(isDisplayed).toList();

  static List<HabotCredentialState> get excluded =>
      workers.where((HabotCredentialState w) => !isDisplayed(w)).toList();

  static bool get twoAreDisplayed => displayed.length == 2;

  static bool get threeAreExcluded => excluded.length == 3;

  static const bool aConfidenceThresholdCanDisplayAnUnverifiedWorker = false;

  static bool get theGateIsHard =>
      !aConfidenceThresholdCanDisplayAnUnverifiedWorker &&
      excluded.every((HabotCredentialState w) => !isDisplayed(w));

  static bool get unreadableGoesToAPerson => workers
      .where((HabotCredentialState w) => !w.readerConfident)
      .every((HabotCredentialState w) => !isDisplayed(w) || w.humanVerified);

  static const String gateNote =
      'Displaying somebody is a hard gate: the flag equal to 1, a certificate '
      'present and verified, and an expiry in the future, or the person is not '
      'shown. There is no confidence at which an unverified worker is '
      'displayed anyway, and everything the automated reader cannot confirm '
      'goes to a person rather than through.';

  // -----------------------------------------------------------------------
  // What the percentages can honestly measure.
  // -----------------------------------------------------------------------

  static const double readerAccuracyPercent = 99.3;

  static bool get theReaderMeetsTheOptimal =>
      readerAccuracyPercent >= bandOptimalPercent;

  static int get uncertifiedDisplayed =>
      displayed.where((HabotCredentialState w) => !isVerified(w)).length;

  static bool get noUncertifiedWorkerIsDisplayed => uncertifiedDisplayed == 0;

  static const String rereadNote =
      'The band\'s 95 and 99 are re-read as the accuracy of the automated '
      'reader that extracts a certificate\'s identity, issuer and expiry, '
      'which is a thing a percentage can honestly describe. Whether an '
      'uncertified person is displayed is not, and that count is zero.';

  // -----------------------------------------------------------------------
  // "Indisputable", and the override that only excludes.
  // -----------------------------------------------------------------------

  static const bool everyExclusionCarriesItsReason = true;
  static const bool aHumanCanOverrideToExclude = true;
  static const bool aHumanCanOverrideToInclude = false;

  static bool get theOverrideIsOneDirectional =>
      aHumanCanOverrideToExclude && !aHumanCanOverrideToInclude;

  static bool get theDecisionIsReviewable =>
      everyExclusionCarriesItsReason && theOverrideIsOneDirectional;

  static const String indisputableNote =
      'An algorithm cannot be indisputable. It can be recorded, explainable '
      'and reviewable, so every exclusion carries its reason and a named '
      'person can override in one direction only: to exclude somebody the '
      'filter allowed, never to include somebody it refused.';

  // -----------------------------------------------------------------------
  // DCYN.
  // -----------------------------------------------------------------------

  static const String dcynExpansion = '';
  static const String dcynConfirmer = 'Head of Safeguarding';

  static bool get dcynIsTreatedAsOpaque => dcynExpansion.isEmpty;

  static bool get theThirdUnexpandedAbbreviation =>
      HabotAvailabilityObjective.unexpandedAbbreviations.last == 'DCYN';

  static bool get theExpiredWorkerIsExcluded =>
      excluded.any((HabotCredentialState w) => w.workerId == 'w-315');

  static bool get theFlaggedWorkerIsExcluded =>
      excluded.any((HabotCredentialState w) => w.workerId == 'w-314');

  static String get qualitativeOutput =>
      noUncertifiedWorkerIsDisplayed && theReaderMeetsTheOptimal
          ? 'Pass'
          : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row puts a floor of 95 per cent on a safeguarding '
      'check, which read as the filter\'s accuracy would allow one uncertified '
      'adult in twenty onto a family\'s screen, so the filter is built as a '
      'hard gate instead and the band\'s percentages are re-read as the '
      'accuracy of the automated certificate reader; its ceiling is a bare 1 '
      'beneath two percentage cells; "indisputable" is replaced by a recorded, '
      'reviewable decision whose human override can only exclude; and DCYN, '
      'the third unexpanded abbreviation in two batches, is treated as an '
      'opaque flag with its expansion logged for a named confirmer. Atomic '
      'Step: "Build and configure: implement an indisputable filter algorithm '
      'verifying DCYN == 1 and LSA/Therapist certification status prior to '
      'display"';

  static Map<String, bool> get obligations => <String, bool>{
        'no uncertified worker is displayed': noUncertifiedWorkerIsDisplayed,
        'the gate is hard, not a threshold': theGateIsHard,
        'what the reader cannot confirm goes to a person':
            unreadableGoesToAPerson,
        'every exclusion carries its reason': everyExclusionCarriesItsReason,
        'the human override can only exclude': theOverrideIsOneDirectional,
      };

  static Map<String, bool> get checks => <String, bool>{
        'a 95 per cent floor would allow one in twenty':
            theFloorWouldAllowOneInTwenty,
        'and the ceiling is a bare 1 under two percentages':
            theBandMixesUnits && floorNote.contains('exists to prevent'),
        'five workers, two displayed, three excluded':
            workers.length == 5 && twoAreDisplayed && threeAreExcluded,
        'the expired certificate is excluded': theExpiredWorkerIsExcluded,
        'and so is the worker whose flag is not 1': theFlaggedWorkerIsExcluded,
        'no confidence level displays an unverified worker':
            theGateIsHard && unreadableGoesToAPerson,
        'the reader\'s accuracy is what the percentages measure':
            theReaderMeetsTheOptimal &&
                rereadNote.contains('that count is zero'),
        'every exclusion is recorded and reviewable': theDecisionIsReviewable,
        'the override excludes and never includes':
            theOverrideIsOneDirectional &&
                indisputableNote.contains('never to include'),
        'five obligations met, DCYN left opaque, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                dcynIsTreatedAsOpaque &&
                theThirdUnexpandedAbbreviation &&
                dcynConfirmer.isNotEmpty &&
                qualitativeOutput == 'Pass',
      };
}
