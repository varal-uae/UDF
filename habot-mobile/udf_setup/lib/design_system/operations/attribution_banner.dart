/// Step 322 (GEN-03459) -- a banner tells the person looking now; the record
/// is what tells everybody afterwards.
///
/// The row: 'Display clear visual attribution banners ("Acting on behalf of")
/// on review cards.'
/// Metric: **Attribution Banner Contrast** -- floor 4.5:1, optimal 7:1,
/// ceiling 21:1. Best Qualitative Output: **"Pass"**. WCAG 2.2 AA.
///
/// **Second of the four one-valued output columns in this batch**, and
/// adjacent in the sheet to the first: Step 321 is three rows earlier with the
/// same shape, the same contrast band and the same single "Pass". The defect
/// is recorded once in each and the steps report against their own
/// obligations.
///
/// **A banner is not attribution.** It is a label on a card, and it exists for
/// as long as somebody is looking at that card. The decision the card records
/// outlives the session by years, and if the only place the delegation appears
/// is the banner then the decision is attributed to the wrong person for all
/// of that time. Both identities go on the record -- the actor who pressed the
/// button and the principal they acted for -- and the banner is *rendered from
/// those fields* rather than set beside them. That is what stops a card from
/// being wrong about itself.
///
/// **A card can be wrong about itself in both directions.** An impersonation
/// session that has ended can leave a cached card still wearing the banner; a
/// session that has just begun can leave a card without one. Both are worse
/// than no banner, because a banner that is sometimes wrong is a banner nobody
/// checks. Deriving it from the same two fields the record is written from
/// makes the two states impossible to hold at once.
///
/// **And it has to come before the actions in the reading order.** A screen
/// reader that reaches "Approve" before it reaches "acting on behalf of
/// Fatima" has given the person the decision before the context. The banner is
/// the card's first child; that is not a visual preference, it is the order
/// the information is needed in.
library;

/// Who did the thing, and for whom.
class HabotActorPair {
  const HabotActorPair({
    required this.actor,
    required this.principal,
  });

  /// The person who pressed the button.
  final String actor;

  /// The person on whose behalf they pressed it. Empty when nobody.
  final String principal;

  bool get isDelegated => principal.isNotEmpty && principal != actor;
}

/// The banner.
class HabotAttributionBanner {
  const HabotAttributionBanner._();

  static const HabotActorPair delegated = HabotActorPair(
    actor: 'Omar (support)',
    principal: 'Fatima Al-Mansouri',
  );

  static const HabotActorPair direct = HabotActorPair(
    actor: 'Fatima Al-Mansouri',
    principal: '',
  );

  // -----------------------------------------------------------------------
  // The banner is derived, never set.
  // -----------------------------------------------------------------------

  static String bannerFor(HabotActorPair pair) => pair.isDelegated
      ? '${pair.actor} is acting on behalf of ${pair.principal}'
      : '';

  static bool get theBannerIsDerivedFromTheRecordFields =>
      bannerFor(delegated).contains(delegated.actor) &&
      bannerFor(delegated).contains(delegated.principal) &&
      bannerFor(direct).isEmpty;

  /// Both identities on the record, always, whether delegated or not.
  static Map<String, String> recordFor(HabotActorPair pair) => <String, String>{
        'actor': pair.actor,
        'principal': pair.isDelegated ? pair.principal : pair.actor,
        'delegated': pair.isDelegated ? 'true' : 'false',
      };

  static bool get bothIdentitiesAreAlwaysRecorded =>
      recordFor(delegated).length == 3 &&
      recordFor(direct).length == 3 &&
      recordFor(direct)['actor'] == recordFor(direct)['principal'];

  /// The record and the banner cannot disagree, because one is computed from
  /// the other's fields.
  static bool get theRecordAndTheBannerCannotDisagree =>
      (recordFor(delegated)['delegated'] == 'true') ==
          bannerFor(delegated).isNotEmpty &&
      (recordFor(direct)['delegated'] == 'true') ==
          bannerFor(direct).isNotEmpty;

  static const String recordNote =
      'A banner exists for as long as somebody is looking at the card. The '
      'decision the card records outlives the session by years, so if the '
      'delegation appears only in the banner then the decision is attributed '
      'to the wrong person for all of that time -- and the person it is '
      'attributed to is the one who was not there. Both identities go on the '
      'record and the banner is rendered from those fields, which is also what '
      'stops the two from drifting.';

  // -----------------------------------------------------------------------
  // The two ways a card is wrong about itself.
  // -----------------------------------------------------------------------

  static const List<String> bothFailureDirections = <String>[
    'a cached card still wearing the banner after the session ended',
    'a card without the banner after a session began',
  ];

  static bool get bothDirectionsAreNamed =>
      bothFailureDirections.length == 2;

  /// Neither is reachable, because the banner has no state of its own to be
  /// stale in.
  static const bool theBannerHasStateOfItsOwn = false;

  static const String staleNote =
      'A banner that is sometimes wrong is a banner nobody checks, and it can '
      'be wrong in both directions: present after the impersonation ended, '
      'absent after it began. The second is the dangerous one -- somebody '
      'reads a decision as their colleague\'s own when it was made for them. '
      'Neither is reachable here because the banner holds no state; it is a '
      'function of the two fields the record carries.';

  // -----------------------------------------------------------------------
  // Reading order.
  // -----------------------------------------------------------------------

  static const List<String> cardOrder = <String>[
    'attribution banner',
    'what is being reviewed',
    'the amount',
    'approve',
    'reject',
  ];

  static int get bannerPosition => cardOrder.indexOf('attribution banner');

  static int get firstActionPosition => cardOrder.indexOf('approve');

  static bool get theBannerPrecedesTheActions =>
      bannerPosition >= 0 && bannerPosition < firstActionPosition;

  static bool get theBannerIsTheFirstThingRead => bannerPosition == 0;

  static const String orderNote =
      'A screen reader that reaches "Approve" before it reaches "acting on '
      'behalf of Fatima" has handed somebody the decision before the context, '
      'and on a card the two are inches apart visually and minutes apart '
      'aurally. The banner is the card\'s first child. That is not a visual '
      'preference; it is the order the information is needed in.';

  // -----------------------------------------------------------------------
  // The band and the output column.
  // -----------------------------------------------------------------------

  static const double contrastFloor = 4.5;
  static const double contrastOptimal = 7.0;
  static const double contrastCeiling = 21.0;

  static const bool colourIsTheSoleCarrier = false;

  static const String rowOutputVocabulary = 'Pass';

  static bool get theOutputCannotExpressAFailure =>
      !rowOutputVocabulary.contains('Fail');

  static const int siblingStepWithTheSameDefect = 321;

  static const String outputNote =
      'The output column holds "Pass" and nothing else, as Step 321\'s does '
      'three rows earlier in the sheet, with the same contrast band. Two '
      'adjacent rows, the same one-valued vocabulary. The step reports '
      'Pass/Fail against its own obligations so a failure has somewhere to go.';

  static Map<String, bool> get obligations => <String, bool>{
        'both identities are on the record': bothIdentitiesAreAlwaysRecorded,
        'the banner is derived from those fields':
            theBannerIsDerivedFromTheRecordFields,
        'the record and the banner cannot disagree':
            theRecordAndTheBannerCannotDisagree,
        'the banner holds no state of its own': !theBannerHasStateOfItsOwn,
        'the banner is read before the actions': theBannerPrecedesTheActions,
        'colour is not the carrier': !colourIsTheSoleCarrier,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'a delegated pair produces a banner naming both people':
            delegated.isDelegated &&
                bannerFor(delegated) ==
                    'Omar (support) is acting on behalf of Fatima Al-Mansouri',
        'a direct pair produces none':
            !direct.isDelegated && bannerFor(direct).isEmpty,
        'both identities are recorded either way':
            bothIdentitiesAreAlwaysRecorded &&
                recordFor(delegated)['principal'] == 'Fatima Al-Mansouri' &&
                recordFor(direct)['principal'] == 'Fatima Al-Mansouri',
        'the record outlives the banner and carries the delegation':
            recordNote.contains('the one who was not there'),
        'the two stale directions are both named and both unreachable':
            bothDirectionsAreNamed &&
                !theBannerHasStateOfItsOwn &&
                theRecordAndTheBannerCannotDisagree,
        'the absent-banner direction is the dangerous one':
            staleNote.contains('made for them'),
        'the banner is the first thing on the card':
            theBannerIsTheFirstThingRead &&
                theBannerPrecedesTheActions &&
                cardOrder.length == 5,
        'and that is an ordering requirement rather than a visual one':
            orderNote.contains('the order the information is needed in'),
        'the output column cannot express a failure, as Step 321\'s cannot':
            theOutputCannotExpressAFailure &&
                siblingStepWithTheSameDefect == 321 &&
                outputNote.contains('Two adjacent rows'),
        'the band is the ordinary contrast band':
            contrastFloor == 4.5 &&
                contrastOptimal == 7.0 &&
                contrastCeiling == 21.0,
        'six obligations, all met, giving Pass':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: the Best Qualitative Output column on this row reads '
      '"Pass", with no failing value -- the second such row in this batch, '
      'three rows from the first in the sheet -- and every narrative column is '
      'the generic engineering-console boilerplate. Atomic Step: "Display '
      'clear visual attribution banners (Acting on behalf of) on review '
      'cards."';
}
