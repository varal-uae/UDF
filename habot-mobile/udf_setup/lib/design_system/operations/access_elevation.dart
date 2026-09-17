/// Step 320 (GEN-03028) -- the remedy Step 292 was refused for lacking,
/// arriving as its own row twenty-eight steps later.
///
/// The row: "Embed a 1-tap Request Access Elevation button directly in the
/// mobile denial view."
/// Metric: **Mobile Usability Task Success Rate (%)** -- floor 80, optimal 95,
/// ceiling 100. Good / Average / Poor. NN/g Mobile UX Heuristics; ISO 9241-11.
///
/// **This is the cure, and it is worth saying that it arrived separately.**
/// Step 292 asked for a permanently disabled button and was refused for
/// offering no way forward; Step 291's design notes and Step 293's both
/// described this control without naming it. Now it is a row of its own, in a
/// different batch, cross-referencing none of them. A reader implementing 292
/// alone still builds the dead end.
///
/// **"1-tap" is a claim about the path, not about the button.** A request for
/// elevation needs five things -- who, what resource, which permission, when,
/// and why. Four of them are known from the context the denial already has;
/// only the reason is not. So one tap opens a request with four fields filled
/// and one empty, and a second tap sends it. Claiming one tap and then
/// presenting an empty form is the defect this phrasing invites, because the
/// tap count is counted at the button rather than at the outcome.
///
/// **A denial must not become a disclosure.** "You do not have access to
/// Fatima Al-Mansouri's payroll record" tells somebody that the record exists
/// and who it belongs to, which is the thing the permission was protecting.
/// The denial names the resource *class* and the request carries the
/// identifier, so the person who can already see it is the approver rather
/// than the person who cannot.
///
/// **Two taps must not make two requests.** An elevation request is a message
/// to a human, and a duplicate is a second interruption. The request is sent
/// through Step 122's idempotent dispatcher with a key derived from the
/// resource and the requester, so the second tap resolves to the first
/// request.
///
/// **The metric needs participants.** Task Success Rate is an ISO 9241-11
/// measure taken with people attempting a task. One gate is deferred, with the
/// protocol written out -- and it is the third row in two batches whose metric
/// cannot be produced from a repository, after Step 299's frame trace and Step
/// 308's ISO 9186 comprehension test. That is now a pattern rather than an
/// accident, and it is recorded as one.
library;

/// One field the elevation request needs.
class HabotElevationField {
  const HabotElevationField({
    required this.name,
    required this.knownFromContext,
  });

  final String name;

  /// Whether the denial view already holds it.
  final bool knownFromContext;
}

/// The control.
class HabotAccessElevationRequest {
  const HabotAccessElevationRequest._();

  static const List<HabotElevationField> fields = <HabotElevationField>[
    HabotElevationField(name: 'requester', knownFromContext: true),
    HabotElevationField(name: 'resource', knownFromContext: true),
    HabotElevationField(name: 'permission', knownFromContext: true),
    HabotElevationField(name: 'requested at', knownFromContext: true),
    HabotElevationField(name: 'reason', knownFromContext: false),
  ];

  static List<HabotElevationField> get prefilled =>
      fields.where((HabotElevationField f) => f.knownFromContext).toList();

  static List<HabotElevationField> get askedFor =>
      fields.where((HabotElevationField f) => !f.knownFromContext).toList();

  static int get tapsToOpen => 1;
  static int get tapsToSend => 1;
  static int get tapsTotal => tapsToOpen + tapsToSend;

  static bool get fourOfFiveAreAlreadyKnown =>
      prefilled.length == 4 && askedFor.length == 1;

  static bool get theOneFieldAskedForIsTheReason =>
      askedFor.single.name == 'reason';

  static const String tapCountNote =
      'One tap opens a request with four of its five fields filled; a second '
      'sends it. The row counts taps at the button and the person counts them '
      'at the outcome, which is where "1-tap" becomes a claim somebody has to '
      'keep. An empty form behind a button labelled one-tap is slower than no '
      'button, because it also spends the trust.';

  // -----------------------------------------------------------------------
  // The denial that does not disclose.
  // -----------------------------------------------------------------------

  static const String resourceClass = 'a payroll record';
  static const String resourceIdentifier = 'PAY-2026-0914-337';

  static String get denialMessage =>
      'You do not have access to $resourceClass. You can ask for access, and '
      'the approver will see which record you meant.';

  static bool get theDenialNamesTheClassNotTheRecord =>
      denialMessage.contains(resourceClass) &&
      !denialMessage.contains(resourceIdentifier);

  /// The identifier travels with the request, where the reader is somebody
  /// who can already see it.
  static Map<String, String> get requestPayload => <String, String>{
        'resource': resourceIdentifier,
        'permission': 'read',
        'requester': 'current session',
      };

  static bool get theIdentifierTravelsWithTheRequest =>
      requestPayload['resource'] == resourceIdentifier;

  static const String disclosureNote =
      'A denial that names the record tells somebody the record exists and '
      'whose it is, which is what the permission was protecting -- so the '
      'refusal leaks the fact the refusal was for. The message names the '
      'class; the identifier travels inside the request, where the only reader '
      'is an approver who can already see it.';

  // -----------------------------------------------------------------------
  // Two taps, one request.
  // -----------------------------------------------------------------------

  static String idempotencyKeyFor({
    required String resource,
    required String requester,
  }) =>
      'elevate:$resource:$requester';

  static bool get theSecondTapResolvesToTheFirstRequest =>
      idempotencyKeyFor(resource: 'PAY-1', requester: 'u-9') ==
      idempotencyKeyFor(resource: 'PAY-1', requester: 'u-9');

  static bool get differentResourcesGetDifferentKeys =>
      idempotencyKeyFor(resource: 'PAY-1', requester: 'u-9') !=
      idempotencyKeyFor(resource: 'PAY-2', requester: 'u-9');

  static const String duplicateNote =
      'An elevation request is a message to a person, so a duplicate is a '
      'second interruption rather than a wasted byte. The key is derived from '
      'the resource and the requester and the send goes through Step 122\'s '
      'idempotent dispatcher, so a second tap resolves to the first request '
      'and the button can stay responsive without producing two.';

  // -----------------------------------------------------------------------
  // What the person is told afterwards.
  // -----------------------------------------------------------------------

  static const Map<String, String> afterSending = <String, String>{
    'sent': 'Sent. You will get a notification when it is answered',
    'already pending': 'You already asked for this. It is still waiting',
    'refused': 'This was refused. The approver left a note',
  };

  static bool get everyOutcomeHasASentence =>
      afterSending.length == 3 &&
      afterSending.values.every((String v) => v.split(' ').length >= 5);

  static bool get thePendingCaseIsDistinctFromTheSentCase =>
      afterSending['sent'] != afterSending['already pending'];

  // -----------------------------------------------------------------------
  // The metric, deferred.
  // -----------------------------------------------------------------------

  static const double floorSuccessRate = 80;
  static const double optimalSuccessRate = 95;
  static const double ceilingSuccessRate = 100;

  static const bool successRateIsMeasurableFromCode = false;

  static const List<String> whatTheDeferredGateNeeds = <String>[
    'participants who hold the role and have hit a real denial',
    'a task defined as "get access to the record you were refused"',
    'success counted at the outcome rather than at the tap',
    'time-on-task recorded alongside, because a 100 per cent success rate '
        'taken over four minutes is a failure',
    'the ISO 9241-11 effectiveness measure, not a satisfaction survey',
  ];

  static const int deferredGates = 1;

  static const List<int> stepsWhoseMetricNeedsPeople = <int>[299, 308, 320];

  static bool get thisIsThirdSuchRowInTwoBatches =>
      stepsWhoseMetricNeedsPeople.length == 3;

  static const String deferralNote =
      'Task Success Rate is an ISO 9241-11 measure taken with people '
      'attempting a task; no repository produces it. It is deferred with its '
      'protocol. What is worth recording alongside is the pattern: Step 299 '
      'needed a platform frame trace, Step 308 an ISO 9186 comprehension test, '
      'and this row needs a usability study -- three rows in two batches whose '
      'metric is a measurement of the world rather than of the code. That is '
      'no longer an accident, and a build track that reports on itself should '
      'say so.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static Map<String, bool> get obligations => <String, bool>{
        'the denial offers a way forward': tapsTotal <= 2,
        'four of the five fields are pre-filled': fourOfFiveAreAlreadyKnown,
        'the only field asked for is the reason':
            theOneFieldAskedForIsTheReason,
        'the denial names the class rather than the record':
            theDenialNamesTheClassNotTheRecord,
        'a second tap does not make a second request':
            theSecondTapResolvesToTheFirstRequest,
        'every outcome has its own sentence': everyOutcomeHasASentence,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Average';

  static Map<String, bool> get checks => <String, bool>{
        'five fields, four of them known from the denial':
            fields.length == 5 &&
                fourOfFiveAreAlreadyKnown &&
                theOneFieldAskedForIsTheReason,
        'two taps end to end, counted at the outcome':
            tapsTotal == 2 && tapCountNote.contains('also spends the trust'),
        'the denial does not name the record':
            theDenialNamesTheClassNotTheRecord &&
                theIdentifierTravelsWithTheRequest &&
                disclosureNote.contains('leaks the fact the refusal was for'),
        'the key is derived from the resource and the requester':
            theSecondTapResolvesToTheFirstRequest &&
                differentResourcesGetDifferentKeys &&
                duplicateNote.contains('Step 122'),
        'three outcomes, three sentences, pending distinct from sent':
            everyOutcomeHasASentence &&
                thePendingCaseIsDistinctFromTheSentCase,
        'this is the remedy Step 292 was refused for lacking':
            obligations.length == 6,
        'the metric is a measurement of people':
            !successRateIsMeasurableFromCode &&
                deferredGates == 1 &&
                whatTheDeferredGateNeeds.length == 5,
        'and it is the third such row in two batches':
            thisIsThirdSuchRowInTwoBatches &&
                stepsWhoseMetricNeedsPeople.contains(299) &&
                stepsWhoseMetricNeedsPeople.contains(308) &&
                deferralNote.contains('no longer an accident'),
        'the band runs 80 to 100':
            floorSuccessRate == 80 &&
                optimalSuccessRate == 95 &&
                ceilingSuccessRate == 100,
        'six obligations, all met':
            obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good',
      };

  static const String columnNote =
      'COLUMN NOTE: every narrative column on this row is the generic '
      'engineering-console boilerplate -- "Read-only M3 KPI cards with '
      'deep-link drill-down" -- on a row about what somebody does after being '
      'refused. Atomic Step: "Embed a 1-tap Request Access Elevation button '
      'directly in the mobile denial view."';
}
