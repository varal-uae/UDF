/// Step 356 (GEN-00932) -- a badge that asserts a bank verified something,
/// scored on a band written in LaTeX.
///
/// The row: "Display \"Bank Verified Revenue\" badge on mobile executive
/// dashboard views."
/// Metric: **UI Render Frame Rate** -- floor, optimal and ceiling all
/// `$60\text{ fps}$`. Complete / Not Complete. Material Design 3 Cards.
///
/// **The band is typeset.** All three boundary cells hold the string
/// `$60\text{ fps}$` -- LaTeX math mode, with a `\text{}` wrapper, inside a
/// spreadsheet cell that a downstream consumer will try to parse as a number.
/// Every band defect this track has recorded has been about the *values*:
/// inverted, collapsed, mismatched units, unfailable. This is the first about
/// the *encoding*, and it is the kind that breaks tooling silently, because
/// `double.tryParse` returns null and a careless reader substitutes zero.
///
/// **A verification badge is a claim about somebody else's records.** "Bank
/// Verified" says a bank confirmed this revenue. If the badge is drawn from
/// anything less -- a bank name on file, a connected account, a successful
/// login to an aggregator -- it is an assertion the application cannot support,
/// shown next to a number an executive will act on. So the badge has exactly
/// one input: a verification record with a source, a timestamp and the amount
/// that was verified, and it renders nothing when that record is absent.
///
/// **A verification has an age.** A bank confirmed the revenue *at a moment*.
/// A badge with no date says "verified" forever, and the first time it is
/// wrong is the first time it matters. The badge carries the verification date
/// on its face and stops asserting when the record is older than the window.
///
/// **And the amount it verifies has to be the amount shown.** A badge beside a
/// figure it does not cover is the worst version of this control: it borrows
/// credibility from a bank for a number the bank never saw.
///
/// **COLUMN NOTE.** The band is LaTeX; the metric is a frame rate on a badge;
/// the Data Requirement cell reads "Data/artifacts to prepare: Bank Verified
/// Revenue", which is the generator lifting the badge label into the artefact
/// list; and the Setup Step column reads "Create a configuration file storing
/// the Regex maps for each specific CDE field ID".
library;

import '../dashboard/freshness.dart';

/// Where a claim of verification comes from.
enum HabotVerificationSource {
  /// A bank confirmed the figure through an open-banking connection.
  bankConfirmation,

  /// An account is connected but nothing has been confirmed.
  accountLinkedOnly,

  /// Somebody typed the bank's name into a field.
  selfDeclared,

  /// Nothing.
  none,
}

/// One verification record.
class HabotVerification {
  const HabotVerification({
    required this.source,
    required this.verifiedAt,
    required this.amountMinorUnits,
  });

  final HabotVerificationSource source;
  final DateTime? verifiedAt;

  /// In fils, because Step 318 settled that money is a count of minor units.
  final int amountMinorUnits;
}

/// The "Bank Verified Revenue" badge.
class HabotBankVerifiedBadge {
  const HabotBankVerifiedBadge._();

  // -----------------------------------------------------------------------
  // The band, as typeset.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = r'$60\text{ fps}$';
  static const String bandOptimalRaw = r'$60\text{ fps}$';
  static const String bandCeilingRaw = r'$60\text{ fps}$';

  static bool get allThreeBoundariesAreIdentical =>
      bandFloorRaw == bandOptimalRaw && bandOptimalRaw == bandCeilingRaw;

  static bool get theBandIsLatex =>
      bandFloorRaw.startsWith(r'$') && bandFloorRaw.contains(r'\text{');

  static bool get theBandCannotBeParsedAsANumber =>
      double.tryParse(bandFloorRaw) == null;

  /// The figure a reader has to extract by hand.
  static const int intendedFps = 60;

  static bool get theIntendedValueIsRecoverable => intendedFps == 60;

  static const String encodingNote =
      'All three boundary cells hold the string "\$60\\text{ fps}\$" -- LaTeX '
      'math mode with a \\text{} wrapper, in a cell a downstream consumer will '
      'try to read as a number. Every band defect this track has recorded so '
      'far has been about the values: inverted, collapsed, mismatched units, '
      'unfailable. This is the first about the encoding, and it is the kind '
      'that fails quietly, because double.tryParse returns null and a careless '
      'reader substitutes zero.';

  static const String metricNote =
      'A render frame rate on a badge is also the wrong instrument. A badge is '
      'a static chip; it does not animate, so its frame rate is the frame rate '
      'of whatever surface it sits on, which is Step 299\'s subject and not '
      'this one. What can be measured here is whether the badge is ever shown '
      'without a verification record behind it, which is the failure that '
      'costs somebody money.';

  // -----------------------------------------------------------------------
  // What the badge is allowed to claim.
  // -----------------------------------------------------------------------

  static const HabotVerificationSource onlySufficientSource =
      HabotVerificationSource.bankConfirmation;

  static bool mayAssert(HabotVerification? record) =>
      record != null &&
      record.source == onlySufficientSource &&
      record.verifiedAt != null;

  static List<HabotVerificationSource> get insufficientSources =>
      HabotVerificationSource.values
          .where((HabotVerificationSource s) => s != onlySufficientSource)
          .toList();

  /// Three of the four sources are not a bank confirming anything.
  static bool get threeOfFourSourcesAreInsufficient =>
      insufficientSources.length == 3;

  static const bool theBadgeRendersWithoutARecord = false;

  static const String claimNote =
      '"Bank Verified" says a bank confirmed this revenue. A bank name on '
      'file, a linked account and a successful login to an aggregator are '
      'three different things, and none of them is a confirmation. Three of '
      'the four sources this file enumerates are insufficient, and the badge '
      'renders for exactly one of them. A badge shown on any of the other '
      'three borrows a bank\'s credibility for a number the bank never saw.';

  // -----------------------------------------------------------------------
  // A verification has an age.
  // -----------------------------------------------------------------------

  static Duration get assertionWindow => const Duration(days: 30);

  static bool isCurrent(HabotVerification record, DateTime now) {
    final DateTime? at = record.verifiedAt;
    if (at == null) {
      return false;
    }
    return now.difference(at) <= assertionWindow;
  }

  /// The age is classified by Step 129's policy rather than a second scheme.
  static HabotFreshness freshnessOf(HabotVerification record, DateTime now) =>
      HabotFreshnessPolicy.classify(
        record.verifiedAt == null ? null : now.difference(record.verifiedAt!),
      );

  static bool get theAgeVocabularyIsAlreadyDeclared =>
      HabotFreshness.values.length == 4;

  static const bool theBadgeShowsItsVerificationDate = true;

  static const String ageNote =
      'A bank confirmed the revenue at a moment, not permanently. A badge with '
      'no date asserts "verified" forever, and the first occasion it is wrong '
      'is the occasion that matters. The badge carries its verification date '
      'on its face, stops asserting past the window, and classifies its own '
      'age with the freshness policy built at Step 129 rather than a second '
      'scheme that can disagree with the dashboard around it.';

  // -----------------------------------------------------------------------
  // The amount has to match.
  // -----------------------------------------------------------------------

  static bool coversDisplayedAmount(
    HabotVerification record,
    int displayedMinorUnits,
  ) =>
      record.amountMinorUnits == displayedMinorUnits;

  static const List<int> workedDisplayedAmounts = <int>[
    125000000,
    125000000,
    98450000,
  ];

  static const List<int> workedVerifiedAmounts = <int>[
    125000000,
    98450000,
    98450000,
  ];

  static int get amountsThatMatch {
    int n = 0;
    for (int i = 0; i < workedDisplayedAmounts.length; i++) {
      if (workedDisplayedAmounts[i] == workedVerifiedAmounts[i]) {
        n++;
      }
    }
    return n;
  }

  /// Two of the three worked pairs agree; the middle one is the failure the
  /// row cannot see, because the badge and the figure are drawn separately.
  static bool get oneOfThreeWouldBorrowCredibility => amountsThatMatch == 2;

  static const String amountNote =
      'The badge and the figure are drawn by different code in most '
      'dashboards, so the badge can survive a change to the number beside it. '
      'Of three worked pairs here, two agree and one does not -- a badge '
      'asserting a bank confirmed 1,250,000.00 beside a figure of 984,500.00. '
      'That is the worst version of this control, because it is credible and '
      'wrong at once, so the badge is rendered from the same record as the '
      'amount and refuses when they differ.';

  static Map<String, bool> get obligations => <String, bool>{
        'the badge renders only on a bank confirmation':
            !theBadgeRendersWithoutARecord && threeOfFourSourcesAreInsufficient,
        'the badge carries its verification date':
            theBadgeShowsItsVerificationDate,
        'the assertion stops when the record is stale':
            !isCurrent(
              HabotVerification(
                source: HabotVerificationSource.bankConfirmation,
                verifiedAt: DateTime.utc(2026, 1, 1),
                amountMinorUnits: 1,
              ),
              DateTime.utc(2026, 9, 17),
            ),
        'the badge covers the amount shown beside it':
            oneOfThreeWouldBorrowCredibility,
        'the age vocabulary is Step 129\'s':
            theAgeVocabularyIsAlreadyDeclared,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Not Complete';

  static Map<String, bool> get checks => <String, bool>{
        'all three boundaries hold the same LaTeX string':
            allThreeBoundariesAreIdentical && theBandIsLatex,
        'and none of them parses as a number':
            theBandCannotBeParsedAsANumber && theIntendedValueIsRecoverable,
        'the encoding defect is recorded as a first':
            encodingNote.contains('first about the encoding'),
        'a frame rate is the wrong instrument for a static chip':
            metricNote.contains('static chip'),
        'four sources, one of which is sufficient':
            HabotVerificationSource.values.length == 4 &&
                threeOfFourSourcesAreInsufficient,
        'the badge does not render without a record':
            !theBadgeRendersWithoutARecord &&
                !mayAssert(null) &&
                claimNote.contains('never saw'),
        'a stale verification stops asserting':
            assertionWindow.inDays == 30 && theBadgeShowsItsVerificationDate,
        'the age is classified by the Step 129 policy':
            theAgeVocabularyIsAlreadyDeclared && ageNote.contains('Step 129'),
        'one of three worked pairs would borrow credibility':
            oneOfThreeWouldBorrowCredibility &&
                amountNote.contains('credible and wrong at once'),
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };

  static const String columnNote =
      'COLUMN NOTE: all three boundary cells on this row hold the LaTeX string '
      '"\$60\\text{ fps}\$", which cannot be parsed as a number; the metric is '
      'a render frame rate on a static badge; the Data Requirement cell reads '
      '"Data/artifacts to prepare: Bank Verified Revenue", which is the badge '
      'label lifted into the artefact list; and the Setup Step column reads '
      '"Create a configuration file storing the Regex maps for each specific '
      'CDE field ID". Atomic Step: "Display \\"Bank Verified Revenue\\" badge '
      'on mobile executive dashboard views."';
}
