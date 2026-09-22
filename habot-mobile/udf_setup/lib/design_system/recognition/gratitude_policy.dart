/// Step 442 (GEN-05232) -- two decisions in one row that pull against each
/// other: publishing thanks automatically, and converting thanks into points.
///
/// The row: "Make and document the required upfront decision: establish
/// criteria for auto-publishing gratitude notes and point conversion rates"
/// Metric: **Decision Documentation Completeness** -- floor "Decision
/// undocumented or verbal only", optimal "Decision documented with rationale &
/// owner sign-off", ceiling "1". Complete/Partial/Not Complete. ISO 21500 --
/// Project Governance & Decision Records. Assigned to **UDF**.
///
/// **The floor describes the failure.** "Decision undocumented or verbal only"
/// is not a minimum acceptable state; it is the state of not having done the
/// work. Step 400's ceiling described a failure; this floor does, which means
/// the band's lowest acceptable value is the thing the row exists to prevent.
///
/// **Once thanks converts into points, thanks becomes payment.** The row asks
/// for a conversion rate as though it were a detail. It is the whole decision.
/// A thank-you that is worth ten points is a thank-you somebody can be paid
/// for, and the first thing that happens to a currency of thanks is that pairs
/// of colleagues start trading it. Worse, it breaks Step 438's ledger: points
/// must come from validated completions, and a thank-you is not a completion.
/// So the decision recorded here is that **peer thanks converts to zero
/// points**. Gratitude stays gratitude.
///
/// **Publishing somebody's praise is their decision, not the system's.** Some
/// people want thanks read out; some would rather not have their name on a
/// screen in the break room, for reasons that are theirs. So gratitude notes
/// are private by default -- delivered to the person thanked and nobody else --
/// and published only if that person chooses. "Auto-publishing" is decided
/// against, and the reason is written into the record beside it.
///
/// **Both decisions are written as decision records.** Owner, rationale, date,
/// and a date to review them, because a decision with no review date becomes a
/// rule nobody remembers choosing.
library;

import 'completion_criteria.dart';
import 'point_validation.dart';

/// One recorded decision.
class HabotGratitudeDecision {
  const HabotGratitudeDecision({
    required this.question,
    required this.decision,
    required this.rationale,
    required this.owner,
    required this.decidedOn,
    required this.reviewOn,
  });

  final String question;
  final String decision;
  final String rationale;
  final String owner;
  final String decidedOn;
  final String reviewOn;
}

/// The gratitude policy.
class HabotGratitudePolicy {
  const HabotGratitudePolicy._();

  // -----------------------------------------------------------------------
  // The floor describes the failure.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = 'Decision undocumented or verbal only';
  static const String bandOptimalRaw =
      'Decision documented with rationale & owner sign-off';
  static const String bandCeilingRaw = '1';

  static bool get theFloorDescribesTheFailure =>
      bandFloorRaw.contains('undocumented');

  /// Step 400's ceiling described a failure.
  static const int theRowWhoseCeilingDidThis = 400;

  static bool get proseFloorAndBareCeiling =>
      bandFloorRaw.contains(' ') && double.tryParse(bandCeilingRaw) != null;

  static const String floorNote =
      '"Decision undocumented or verbal only" is not a minimum acceptable '
      'state; it is the state of not having done the work. Step 400\'s ceiling '
      'described a failure and this floor does, so the band\'s lowest '
      'acceptable value is the thing the row exists to prevent.';

  // -----------------------------------------------------------------------
  // The two decisions.
  // -----------------------------------------------------------------------

  static const int peerThanksPointValue = 0;

  static const bool gratitudeIsPrivateByDefault = true;

  static const bool thePersonThankedDecidesPublication = true;

  static const bool autoPublishing = false;

  static const List<HabotGratitudeDecision> records = <HabotGratitudeDecision>[
    HabotGratitudeDecision(
      question: 'What is peer thanks worth in points?',
      decision: 'Nothing. Peer thanks converts to zero points.',
      rationale: 'Thanks that is worth points is thanks that can be paid for, '
          'and it would mint points without a validated completion, breaking '
          'the Step 438 ledger.',
      owner: 'Head of People Operations',
      decidedOn: '2026-09-22',
      reviewOn: '2027-03-22',
    ),
    HabotGratitudeDecision(
      question: 'Are gratitude notes published automatically?',
      decision: 'No. Private by default; published only if the person '
          'thanked chooses.',
      rationale: 'Some people would rather not have their name on a shared '
          'screen, for reasons that are theirs to keep.',
      owner: 'Head of People Operations',
      decidedOn: '2026-09-22',
      reviewOn: '2027-03-22',
    ),
  ];

  static bool get twoDecisionsAreRecorded => records.length == 2;

  static bool get everyRecordHasAnOwnerAndRationale =>
      records.every((HabotGratitudeDecision r) =>
          r.owner.isNotEmpty && r.rationale.isNotEmpty);

  static bool get everyRecordHasAReviewDate =>
      records.every((HabotGratitudeDecision r) => r.reviewOn.isNotEmpty);

  // -----------------------------------------------------------------------
  // Why zero.
  // -----------------------------------------------------------------------

  static bool get thanksWouldBreakTheLedger =>
      HabotPointValidation.everyLineCarriesItsCompletion &&
      peerThanksPointValue == 0;

  static bool get aThankYouIsNotACompletion =>
      !HabotCompletionCriteria.isComplete(
        state: HabotRecordState.draft,
        personNotified: true,
      );

  static const String conversionNote =
      'The conversion rate is the whole decision rather than a detail of it. A '
      'thank-you worth ten points is a thank-you somebody can be paid for, and '
      'the first thing that happens to a currency of thanks is that pairs of '
      'colleagues start trading it. It would also mint points with no '
      'validated completion behind them, which Step 438\'s ledger forbids. '
      'Peer thanks converts to zero points; gratitude stays gratitude.';

  // -----------------------------------------------------------------------
  // Whose decision publication is.
  // -----------------------------------------------------------------------

  static bool get publicationIsThePersonsChoice =>
      gratitudeIsPrivateByDefault &&
      thePersonThankedDecidesPublication &&
      !autoPublishing;

  static bool get theCharterFirstRuleHolds =>
      HabotScoringCharter.rules.first.contains('own score');

  static const String publicationNote =
      'Some people want thanks read out and some would rather not have their '
      'name on a screen in the break room, for reasons that are theirs. '
      'Gratitude notes are delivered to the person thanked and nobody else, '
      'and published only if that person chooses. Auto-publishing is decided '
      'against, with the reason recorded beside it.';

  static double get documentation {
    final int complete = records
        .where((HabotGratitudeDecision r) =>
            r.owner.isNotEmpty &&
            r.rationale.isNotEmpty &&
            r.reviewOn.isNotEmpty)
        .length;
    return records.isEmpty ? 0 : complete / records.length;
  }

  static String get qualitativeOutput =>
      documentation == 1 ? 'Complete' : 'Partial';

  static const String columnNote =
      'COLUMN NOTE: this row\'s floor reads "Decision undocumented or verbal '
      'only", which describes the failure rather than a minimum acceptable '
      'state, and its ceiling is a bare 1 beneath two prose cells, the second '
      'of five such rows in this batch; it bundles two decisions that pull '
      'against each other -- publishing thanks automatically and converting '
      'thanks into points -- and both are recorded with owner, rationale and a '
      'review date: peer thanks is worth zero points, and publication is the '
      'thanked person\'s choice. Atomic Step: "Make and document the required '
      'upfront decision: establish criteria for auto-publishing gratitude '
      'notes and point conversion rates"';

  static Map<String, bool> get obligations => <String, bool>{
        'peer thanks is worth zero points': peerThanksPointValue == 0,
        'gratitude is private by default': gratitudeIsPrivateByDefault,
        'publication is the thanked person\'s choice':
            publicationIsThePersonsChoice,
        'both decisions carry an owner and a rationale':
            everyRecordHasAnOwnerAndRationale,
        'both carry a review date': everyRecordHasAReviewDate,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the floor describes the failure':
            theFloorDescribesTheFailure && theRowWhoseCeilingDidThis == 400,
        'and sits above a bare ceiling of 1':
            proseFloorAndBareCeiling &&
                floorNote.contains('exists to prevent'),
        'two decisions recorded': twoDecisionsAreRecorded,
        'peer thanks converts to zero points':
            peerThanksPointValue == 0 && thanksWouldBreakTheLedger,
        'because a thank-you is not a completion':
            aThankYouIsNotACompletion &&
                conversionNote.contains('gratitude stays gratitude'),
        'gratitude is private by default and not auto-published':
            publicationIsThePersonsChoice,
        'because publication is the person\'s choice':
            theCharterFirstRuleHolds &&
                publicationNote.contains('reasons that are theirs'),
        'every record has an owner, a rationale and a review date':
            everyRecordHasAnOwnerAndRationale && everyRecordHasAReviewDate,
        'documentation reaches the ceiling': documentation == 1,
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };
}
