/// Step 453 (GEN-05364) -- review the objective of a suggestion portal, and
/// report Partial because the objective cannot be confirmed from here.
///
/// The row: "Review the step objective: deploy a touch-friendly employee
/// suggestion portal allowing team members to submit zero-cost process
/// improvement (ZII Kaizen) ideas, automatically routing them for fast review
/// and reward"
/// Metric: **Requirement/Objective Comprehension Completeness** -- floor
/// "Partial understanding; unresolved ambiguities", optimal "Objective fully
/// documented & stakeholder-confirmed", ceiling "1". Complete/Partial/Not
/// Complete. BABOK v3 -- Requirements Elicitation & Analysis. Assigned to
/// **PDG**.
///
/// **A review row, like Step 416, and this time the subject exists.** The
/// objective is in the row itself, so the review is a reading of it: what it
/// says, what it leaves open, and who has to decide. The honest output of a
/// review is the list of what it could not resolve, and four things are.
///
/// **Four ambiguities.** "ZII" is never expanded -- zero-investment
/// improvement, probably, but a guess is not a definition. "Fast review" has no
/// number. "Automatically routing" does not say to whom. And "reward" does not
/// say in what: Step 442 decided that peer thanks is worth zero points, and a
/// reward for an adopted improvement is a different decision that nobody has
/// taken. Each is written down with a proposed resolution and the person who
/// would have to confirm it.
///
/// **The optimal needs a stakeholder, so this row reports Partial.** "Objective
/// fully documented & stakeholder-confirmed": the documenting is done here, and
/// the confirming cannot be -- there is no stakeholder in this session to
/// confirm anything. Reporting Complete would claim a sign-off that did not
/// happen. The row reports **Partial**, because that is what its own band says
/// a documented but unconfirmed objective is.
///
/// **A suggestion box dies when ideas vanish into it.** Whatever the answers to
/// the four questions, one thing is fixed by the objective's own purpose: the
/// person who made a suggestion sees what happened to it -- adopted, trialled,
/// declined with a reason -- because a suggestion scheme whose ideas disappear
/// teaches people to stop suggesting within a quarter. Suggestions can be
/// made anonymously, and an anonymous suggester can still follow theirs by a
/// receipt code.
///
/// **The floor describes the failure** -- "Partial understanding; unresolved
/// ambiguities" -- the third floor in this batch to do so, after Steps 442 and
/// 450.
library;

import '../recognition/gratitude_policy.dart';

/// Where a suggestion ended up, as its author sees it.
enum HabotSuggestionOutcome {
  /// Received and waiting for review.
  received,

  /// Being tried somewhere.
  trialled,

  /// Adopted as the way things are done.
  adopted,

  /// Not taken forward, with the reason.
  declined,
}

/// One ambiguity the review could not resolve.
class HabotAmbiguity {
  const HabotAmbiguity({
    required this.phrase,
    required this.question,
    required this.proposal,
    required this.confirmer,
  });

  final String phrase;
  final String question;
  final String proposal;
  final String confirmer;
}

/// The suggestion portal objective review.
class HabotSuggestionPortal {
  const HabotSuggestionPortal._();

  // -----------------------------------------------------------------------
  // Four ambiguities.
  // -----------------------------------------------------------------------

  static const List<HabotAmbiguity> ambiguities = <HabotAmbiguity>[
    HabotAmbiguity(
      phrase: 'ZII',
      question: 'What does ZII stand for?',
      proposal: 'Zero-Investment Improvement',
      confirmer: 'Head of Operations',
    ),
    HabotAmbiguity(
      phrase: 'fast review',
      question: 'How fast?',
      proposal: 'A first response within five working days',
      confirmer: 'Head of Operations',
    ),
    HabotAmbiguity(
      phrase: 'automatically routing',
      question: 'Routed to whom?',
      proposal: 'The manager of the area the suggestion concerns',
      confirmer: 'Head of Operations',
    ),
    HabotAmbiguity(
      phrase: 'reward',
      question: 'Rewarded in what?',
      proposal: 'Recognition by name, if the author agrees; no points until '
          'the reward decision is taken',
      confirmer: 'Head of People Operations',
    ),
  ];

  static bool get fourAmbiguities => ambiguities.length == 4;

  static bool get everyAmbiguityHasAProposalAndAConfirmer => ambiguities.every(
      (HabotAmbiguity a) => a.proposal.isNotEmpty && a.confirmer.isNotEmpty);

  static bool get theRewardQuestionIsNotStep442s =>
      HabotGratitudePolicy.peerThanksPointValue == 0 &&
      ambiguities.last.phrase == 'reward';

  static const String ambiguityNote =
      'ZII is never expanded; fast review has no number; automatic routing '
      'does not say to whom; and reward does not say in what. Step 442 decided '
      'peer thanks is worth zero points, and a reward for an adopted '
      'improvement is a different decision nobody has taken. Each ambiguity is '
      'written down with a proposed resolution and the person who would have '
      'to confirm it.';

  // -----------------------------------------------------------------------
  // Documented, not confirmed.
  // -----------------------------------------------------------------------

  static const bool theObjectiveIsDocumented = true;

  static const bool aStakeholderHasConfirmed = false;

  static bool get theOptimalIsMet =>
      theObjectiveIsDocumented && aStakeholderHasConfirmed;

  static const bool aSignOffIsClaimed = false;

  static const String partialNote =
      'The optimal is "objective fully documented and stakeholder-confirmed". '
      'The documenting is done here and the confirming cannot be: there is no '
      'stakeholder in this session to confirm anything. Reporting Complete '
      'would claim a sign-off that did not happen, so the row reports Partial, '
      'which is what its own band says a documented but unconfirmed objective '
      'is.';

  // -----------------------------------------------------------------------
  // Closing the loop.
  // -----------------------------------------------------------------------

  static bool get theAuthorSeesEveryOutcome =>
      HabotSuggestionOutcome.values.length == 4;

  static const bool aDeclineCarriesAReason = true;

  static const bool anonymousSuggestionsAreAllowed = true;

  static const bool anAnonymousAuthorCanFollowByReceipt = true;

  static bool get theLoopIsClosed =>
      theAuthorSeesEveryOutcome &&
      aDeclineCarriesAReason &&
      anonymousSuggestionsAreAllowed &&
      anAnonymousAuthorCanFollowByReceipt;

  static const String loopNote =
      'A suggestion scheme whose ideas disappear teaches people to stop '
      'suggesting within a quarter. The author sees every outcome -- received, '
      'trialled, adopted, or declined with a reason -- and somebody who '
      'suggested anonymously can still follow theirs by a receipt code.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw =
      'Partial understanding; unresolved ambiguities';

  static bool get theFloorDescribesTheFailure =>
      bandFloorRaw.contains('unresolved');

  static double get comprehension => theOptimalIsMet ? 1 : 0.5;

  static String get qualitativeOutput {
    if (theOptimalIsMet) {
      return 'Complete';
    }
    return theObjectiveIsDocumented ? 'Partial' : 'Not Complete';
  }

  static const String columnNote =
      'COLUMN NOTE: this is a review row whose subject is in the row itself, '
      'so the review documents the objective and its four unresolved '
      'ambiguities -- ZII unexpanded, fast review unnumbered, routing '
      'unaddressed, and reward undefined -- each with a proposal and a named '
      'confirmer; its optimal requires stakeholder confirmation, which cannot '
      'happen in this session, so it reports Partial rather than claim a '
      'sign-off; its floor describes the failure, the third in this batch; and '
      'its ceiling is a bare 1 beneath two prose cells. Atomic Step: "Review '
      'the step objective: deploy a touch-friendly employee suggestion portal '
      'allowing team members to submit zero-cost process improvement (ZII '
      'Kaizen) ideas, automatically routing them for fast review and reward"';

  static Map<String, bool> get obligations => <String, bool>{
        'the objective is documented': theObjectiveIsDocumented,
        'every ambiguity has a proposal and a confirmer':
            everyAmbiguityHasAProposalAndAConfirmer,
        'no sign-off is claimed': !aSignOffIsClaimed,
        'the author sees every outcome': theLoopIsClosed,
        'the reward question is left for its owner':
            theRewardQuestionIsNotStep442s,
      };

  static Map<String, bool> get checks => <String, bool>{
        'four ambiguities, each with a proposal and a confirmer':
            fourAmbiguities && everyAmbiguityHasAProposalAndAConfirmer,
        'ZII is never expanded':
            ambiguities.first.phrase == 'ZII' &&
                ambiguities.first.proposal.contains('Zero'),
        'and reward is a different decision from Step 442\'s':
            theRewardQuestionIsNotStep442s &&
                ambiguityNote.contains('nobody has taken'),
        'the objective is documented and not confirmed':
            theObjectiveIsDocumented && !aStakeholderHasConfirmed,
        'so no sign-off is claimed':
            !aSignOffIsClaimed && partialNote.contains('did not happen'),
        'four outcomes, a decline carries its reason':
            theAuthorSeesEveryOutcome && aDeclineCarriesAReason,
        'anonymous authors follow theirs by receipt':
            anonymousSuggestionsAreAllowed &&
                anAnonymousAuthorCanFollowByReceipt &&
                loopNote.contains('stop suggesting'),
        'the floor describes the failure': theFloorDescribesTheFailure,
        'comprehension is half, not whole': comprehension == 0.5,
        'five obligations met, and the row reports Partial':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Partial',
      };
}
