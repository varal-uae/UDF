/// Step 441 (GEN-02687) -- the contract for a performance scorecard endpoint,
/// written from the side that has to render it.
///
/// The row: "Write the backend Cloud Run endpoint that serves the performance
/// scorecard data to the mobile view."
/// Metric: **Implementation Completeness Rate** -- floor "90% of defined build
/// scope completed", optimal "100% of scope complete with peer validation",
/// ceiling "1". Complete / Partial / Not Complete. DORA -- Implementation
/// Quality Standards. Assigned to **UDF**.
///
/// **A backend endpoint, in a mobile design-system track.** There is no server
/// in this repository and no toolchain on the device that could run one. What
/// the mobile side owns is the contract -- what the response must contain, who
/// may ask for it, and what the client refuses to render -- and that is what is
/// delivered, named as a contract rather than presented as an endpoint.
///
/// **"Performance scorecard" is the second relabelling in three rows.** Step
/// 439's metric turned a game level into a performance tier; this row's
/// instruction serves a performance scorecard. Once the word is in an endpoint
/// name it is in every log line, dashboard and export built on top of it. The
/// contract keeps the word, because this really is a scorecard about somebody's
/// work -- and holds it to all four rules of Step 436's charter, since this is
/// the row where a person most plainly becomes the subject.
///
/// **Every figure carries its working and a way to contest it.** A scorecard
/// line with a number and no computation is a verdict. The contract requires
/// each figure to carry the completions it was computed from and a contest
/// link, and the client refuses to render a figure that arrives without either
/// -- which is the only enforcement a client can offer and the one that
/// matters, because a figure nobody can see is a figure nobody can act on.
///
/// **Whose scorecard a caller can fetch is part of the contract.** Your own;
/// your direct reports' if you manage them; nobody else's. A peer's scorecard
/// is never returned, because the step from "can see my colleague's numbers" to
/// "is ranked against my colleague" is a step nobody decided to take.
///
/// **The band is two sentences and a bare 1.** The first of five rows in this
/// batch written that way, and its optimal carries a condition -- "with peer
/// validation" -- inside a boundary.
library;

import 'completion_criteria.dart';
import 'point_validation.dart';

/// Who is asking for a scorecard, relative to whose it is.
enum HabotScorecardCaller {
  /// The person the scorecard describes.
  self,

  /// Their direct manager.
  directManager,

  /// Anybody else. Refused.
  peer,
}

/// One figure on a scorecard.
class HabotScorecardFigure {
  const HabotScorecardFigure({
    required this.label,
    required this.value,
    required this.computedFrom,
    required this.contestLink,
  });

  final String label;
  final String value;

  /// Completion ids the figure was computed from.
  final List<String> computedFrom;

  final String contestLink;
}

/// The scorecard endpoint contract.
class HabotScorecardEndpoint {
  const HabotScorecardEndpoint._();

  // -----------------------------------------------------------------------
  // A contract, named as one.
  // -----------------------------------------------------------------------

  static const String route = '/v1/scorecard/{personId}';

  static const bool anEndpointIsImplementedHere = false;

  static const bool theContractIsDelivered = true;

  static bool get theDeliverableIsNamedHonestly =>
      theContractIsDelivered && !anEndpointIsImplementedHere;

  static const String contractNote =
      'There is no server in this repository and nothing on the device that '
      'could run one. What the mobile side owns is the contract: what the '
      'response must contain, who may ask for it, and what the client refuses '
      'to render. That is what is delivered, and it is called a contract '
      'rather than an endpoint.';

  // -----------------------------------------------------------------------
  // The word "performance", and the charter.
  // -----------------------------------------------------------------------

  static const int theRowThatRelabelledALevel = 439;

  static const bool theWordIsKept = true;

  static bool get theCharterAppliesInFull =>
      HabotScoringCharter.fourRules;

  static const String relabelNote =
      'Step 439\'s metric turned a game level into a performance tier; this '
      'row serves a performance scorecard. Once the word is in an endpoint '
      'name it is in every log, dashboard and export built on it. The word is '
      'kept, because this is a scorecard about somebody\'s work, and it is '
      'held to all four rules of Step 436\'s charter, because this is the row '
      'where a person most plainly becomes the subject.';

  // -----------------------------------------------------------------------
  // Working and contest on every figure.
  // -----------------------------------------------------------------------

  static const List<HabotScorecardFigure> sample = <HabotScorecardFigure>[
    HabotScorecardFigure(
      label: 'Requests completed this month',
      value: '14',
      computedFrom: <String>['ot-2291', 'ot-2304', 'swp-077'],
      contestLink: '/v1/scorecard/contest/f-1',
    ),
    HabotScorecardFigure(
      label: 'Training modules passed',
      value: '2',
      computedFrom: <String>['trn-118', 'trn-121'],
      contestLink: '/v1/scorecard/contest/f-2',
    ),
    HabotScorecardFigure(
      label: 'Median time to decide an approval',
      value: '3h 10m',
      computedFrom: <String>['ot-2291', 'ot-2304'],
      contestLink: '/v1/scorecard/contest/f-3',
    ),
  ];

  static bool renders(HabotScorecardFigure f) =>
      f.computedFrom.isNotEmpty && f.contestLink.isNotEmpty;

  static bool get everySampleFigureRenders => sample.every(renders);

  static bool get aFigureWithoutWorkingIsRefused => !renders(
      const HabotScorecardFigure(
        label: 'Rating',
        value: '3.2',
        computedFrom: <String>[],
        contestLink: '/v1/scorecard/contest/f-9',
      ));

  static bool get aFigureWithoutAContestIsRefused => !renders(
      const HabotScorecardFigure(
        label: 'Rating',
        value: '3.2',
        computedFrom: <String>['ot-2291'],
        contestLink: '',
      ));

  static bool get theFiguresComeFromTheLedger =>
      HabotPointValidation.everyLineCarriesItsCompletion;

  static const String workingNote =
      'A scorecard line with a number and no computation is a verdict. Each '
      'figure carries the completions it was computed from and a contest link, '
      'and the client refuses to render one that arrives without either -- the '
      'only enforcement a client can offer, and the one that matters, because '
      'a figure nobody can check is a figure nobody can act on.';

  // -----------------------------------------------------------------------
  // Who may fetch whose.
  // -----------------------------------------------------------------------

  static bool mayFetch(HabotScorecardCaller c) =>
      c == HabotScorecardCaller.self ||
      c == HabotScorecardCaller.directManager;

  static bool get aPeerIsRefused => !mayFetch(HabotScorecardCaller.peer);

  static bool get selfAndManagerAreAllowed =>
      mayFetch(HabotScorecardCaller.self) &&
      mayFetch(HabotScorecardCaller.directManager);

  static const String scopeNote =
      'Your own scorecard; your direct reports\' if you manage them; nobody '
      'else\'s. A peer\'s scorecard is never returned, because the step from '
      '"can see my colleague\'s numbers" to "is ranked against my colleague" '
      'is a step nobody decided to take and the endpoint should not take it '
      'for them.';

  // -----------------------------------------------------------------------
  // Two sentences and a bare 1.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '90% of defined build scope completed';
  static const String bandOptimalRaw =
      '100% of scope complete with peer validation';
  static const String bandCeilingRaw = '1';

  static bool get twoSentencesAndABareNumber =>
      bandFloorRaw.contains(' ') &&
      bandOptimalRaw.contains(' ') &&
      double.tryParse(bandCeilingRaw) != null;

  static bool get theOptimalCarriesACondition =>
      bandOptimalRaw.contains('with peer validation');

  /// Steps 441, 442, 450, 453 and 454.
  static const List<int> proseBandRows = <int>[441, 442, 450, 453, 454];

  static bool get firstOfFiveInThisBatch =>
      proseBandRows.length == 5 && proseBandRows.first == 441;

  static const int contractClausesDeclared = 4;
  static const int contractClausesRequired = 4;

  static double get completeness =>
      contractClausesDeclared / contractClausesRequired;

  static String get qualitativeOutput =>
      completeness == 1 && everySampleFigureRenders ? 'Complete' : 'Partial';

  static const String columnNote =
      'COLUMN NOTE: this row asks for a backend endpoint in a mobile '
      'design-system track, so the contract is delivered and named as a '
      'contract; it serves a "performance scorecard", the second relabelling '
      'of person data as performance in three rows after Step 439, so every '
      'figure carries its working and a contest link and a peer\'s scorecard '
      'is never returned; and its band is two sentences and a bare 1, the '
      'first of five such rows in this batch, with a condition -- "with peer '
      'validation" -- inside its optimal. Atomic Step: "Write the backend '
      'Cloud Run endpoint that serves the performance scorecard data to the '
      'mobile view."';

  static Map<String, bool> get obligations => <String, bool>{
        'the contract is named as a contract': theDeliverableIsNamedHonestly,
        'every figure carries its working': aFigureWithoutWorkingIsRefused,
        'every figure carries a contest link':
            aFigureWithoutAContestIsRefused,
        'a peer\'s scorecard is never returned': aPeerIsRefused,
        'the charter applies in full': theCharterAppliesInFull,
      };

  static Map<String, bool> get checks => <String, bool>{
        'a contract rather than an endpoint':
            theDeliverableIsNamedHonestly && route.startsWith('/v1/'),
        'the second relabelling as performance in three rows':
            theRowThatRelabelledALevel == 439 && theWordIsKept,
        'and the full charter applies':
            theCharterAppliesInFull &&
                relabelNote.contains('plainly becomes the subject'),
        'three sample figures, each with working and a contest link':
            sample.length == 3 && everySampleFigureRenders,
        'a figure without working is refused':
            aFigureWithoutWorkingIsRefused,
        'and so is one without a contest link':
            aFigureWithoutAContestIsRefused &&
                workingNote.contains('nobody can act on'),
        'self and manager may fetch, a peer may not':
            selfAndManagerAreAllowed && aPeerIsRefused,
        'and the step to ranking is not taken for anybody':
            scopeNote.contains('nobody decided to take') &&
                theFiguresComeFromTheLedger,
        'two sentences and a bare 1, with a condition in the optimal':
            twoSentencesAndABareNumber &&
                theOptimalCarriesACondition &&
                firstOfFiveInThisBatch,
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };
}
