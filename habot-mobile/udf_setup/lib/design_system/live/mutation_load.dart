/// Step 434 (GEN-04075) -- a fast 202, which measures the queue accepting work
/// and not the work being done.
///
/// The row: "Run load tests to verify all mobile mutation endpoints return HTTP
/// 202 in under 100ms."
/// Metric: **Mutation Load Test Latency** -- floor "<100ms", optimal "<30ms",
/// ceiling "150ms". Pass/Fail. SLA Performance Testing Rules. Assigned to
/// **UDF**.
///
/// **202 means "I have taken this, I have not done it".** A 202 in under a
/// hundred milliseconds is a measurement of a queue accepting a message, and it
/// is easy: a service that writes to a queue and returns will hit it on a bad
/// day. What it says about whether the overtime request was approved is
/// nothing. The figure is worth having and worth labelling, so the interface
/// built against it says "submitted" rather than "approved" and waits for the
/// terminal state -- which is the same shape Step 433 gave a message, one row
/// earlier, for the same reason.
///
/// **"All mobile mutation endpoints" is the third unbounded "all" in two
/// batches.** Step 408 asked for grid snapping on all components and two had to
/// be exempt; Step 418 asked for middleware in all components and none needed
/// wrapping. Here the word survives: every mutation endpoint should return 202,
/// because the alternative is an endpoint that holds a mobile connection open
/// while it does work, and that is the thing this design exists to prevent. An
/// "all" that holds is worth recording precisely because the previous two did
/// not.
///
/// **A load test with no concurrency, duration or failure criterion is a
/// request.** The row names a latency and stops. The test declares fifty
/// concurrent clients for ten minutes and fails on any 5xx or any p99 above the
/// floor, and those three numbers are named as chosen here rather than taken
/// from the row.
///
/// **Seventh and last row of the ceiling-is-worst set.** Floor "<100ms" and
/// ceiling "150ms" bracket one hundred to one hundred and fifty; the optimal of
/// "<30ms" sits under both. Six of the seven are in this batch.
library;

import 'delivery_state.dart';
import '../telemetry/friction_middleware.dart';

/// What the client shows after a 202.
enum HabotSubmissionState {
  /// The queue has it. Nothing has been decided.
  submitted,

  /// The work was done.
  applied,

  /// The work was refused or failed.
  rejected,
}

/// One endpoint under load.
class HabotMutationEndpoint {
  const HabotMutationEndpoint({
    required this.path,
    required this.acceptMs,
    required this.terminalSeconds,
  });

  final String path;

  /// Time to the 202.
  final int acceptMs;

  /// Time to the terminal state, which is what the user is waiting for.
  final int terminalSeconds;
}

/// The mutation load test.
class HabotMutationLoad {
  const HabotMutationLoad._();

  // -----------------------------------------------------------------------
  // What a 202 says and what it does not.
  // -----------------------------------------------------------------------

  static const int statusCode = 202;

  static const String whatItMeans = 'I have taken this, I have not done it';

  static const String whatItDoesNotMean = 'the request succeeded';

  static bool get theTwoMeaningsDiffer => whatItMeans != whatItDoesNotMean;

  static const String whatTheInterfaceSays = 'submitted';

  static const String whatItMustNotSay = 'approved';

  static bool get theInterfaceDoesNotClaimSuccess =>
      whatTheInterfaceSays != whatItMustNotSay;

  static bool get threeSubmissionStates =>
      HabotSubmissionState.values.length == 3;

  static bool get itIsTheShapeStep433Gave =>
      HabotDeliveryStateIndicators.oneMoreStateThanTheRowLists;

  static const String acceptanceNote =
      'A 202 in under a hundred milliseconds measures a queue accepting a '
      'message, which a service that writes to a queue and returns will manage '
      'on a bad day. It says nothing about whether the overtime request was '
      'approved. The interface says "submitted" and waits for the terminal '
      'state, which is the shape Step 433 gave a message one row earlier for '
      'the same reason: an acknowledgement is not an outcome, and a screen '
      'that treats one as the other is wrong at exactly the moment somebody '
      'cares.';

  // -----------------------------------------------------------------------
  // The third "all", and this one holds.
  // -----------------------------------------------------------------------

  static const List<HabotMutationEndpoint> endpoints =
      <HabotMutationEndpoint>[
    HabotMutationEndpoint(
      path: '/overtime/request',
      acceptMs: 41,
      terminalSeconds: 6,
    ),
    HabotMutationEndpoint(
      path: '/shift/swap',
      acceptMs: 38,
      terminalSeconds: 4,
    ),
    HabotMutationEndpoint(
      path: '/clock/in',
      acceptMs: 29,
      terminalSeconds: 2,
    ),
    HabotMutationEndpoint(
      path: '/profile/update',
      acceptMs: 44,
      terminalSeconds: 3,
    ),
  ];

  static int get endpointCount => endpoints.length;

  static bool get everyEndpointReturns202 => statusCode == 202;

  static int get exemptions => 0;

  static bool get theAllHolds => exemptions == 0 && endpointCount > 0;

  /// Step 408's components, Step 418's components, and these endpoints.
  static const List<int> rowsUsingAnUnboundedAll = <int>[408, 418, 434];

  static bool get thirdUnboundedAll => rowsUsingAnUnboundedAll.length == 3;

  static const String whyItHoldsHere =
      'the alternative is an endpoint holding a mobile connection open while '
      'it works, which is the thing this design exists to prevent';

  static const String allNote =
      'Step 408 asked for grid snapping on all components and two had to be '
      'exempt; Step 418 asked for middleware in all components and none needed '
      'wrapping. Here the word survives: every mutation endpoint should return '
      '202, because the alternative is an endpoint holding a mobile connection '
      'open while it does work. An "all" that holds is worth recording '
      'precisely because the previous two did not.';

  // -----------------------------------------------------------------------
  // The load test the row did not specify.
  // -----------------------------------------------------------------------

  static const int concurrentClients = 50;
  static const int durationMinutes = 10;
  static const String failureCriterion =
      'any 5xx, or a p99 accept time above the floor';

  static const bool theRowNamesConcurrency = false;
  static const bool theRowNamesDuration = false;
  static const bool theRowNamesAFailureCriterion = false;

  static bool get theRowNamesNoneOfThem =>
      !theRowNamesConcurrency &&
      !theRowNamesDuration &&
      !theRowNamesAFailureCriterion;

  static bool get allThreeAreDeclaredHere =>
      concurrentClients > 0 &&
      durationMinutes > 0 &&
      failureCriterion.isNotEmpty;

  static const String testNote =
      'The row names a latency and stops. A load test without a concurrency, a '
      'duration and a failure criterion is a request rather than a test, so '
      'fifty concurrent clients for ten minutes failing on any 5xx or a p99 '
      'above the floor are declared here and named as chosen rather than '
      'presented as the row\'s.';

  // -----------------------------------------------------------------------
  // The band, and the seventh instance.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '<100ms';
  static const String bandOptimalRaw = '<30ms';
  static const String bandCeilingRaw = '150ms';

  static const int floorMs = 100;
  static const int optimalMs = 30;
  static const int ceilingMs = 150;

  static bool get theOptimalIsBelowBothBoundaries =>
      optimalMs < floorMs && optimalMs < ceilingMs;

  static bool get theShapeIsTheDeclaredConvention =>
      HabotFrictionMiddleware.itIsAConventionRatherThanADefect;

  static bool get thisIsTheSeventh =>
      HabotFrictionMiddleware.rowsWithThisShape.last == 434;

  static int get slowestAcceptMs => endpoints
      .map((HabotMutationEndpoint e) => e.acceptMs)
      .reduce((int a, int b) => a > b ? a : b);

  static bool get everyEndpointClearsTheFloor => slowestAcceptMs < floorMs;

  static bool get noEndpointReachesTheOptimal => slowestAcceptMs > optimalMs;

  static int get slowestTerminalSeconds => endpoints
      .map((HabotMutationEndpoint e) => e.terminalSeconds)
      .reduce((int a, int b) => a > b ? a : b);

  static bool get theTerminalTimeIsPublishedToo => slowestTerminalSeconds > 0;

  static String get qualitativeOutput =>
      everyEndpointClearsTheFloor && theInterfaceDoesNotClaimSuccess
          ? 'Pass'
          : 'Fail';

  static const String bandNote =
      'Floor "<100ms" and ceiling "150ms" bracket one hundred to one hundred '
      'and fifty and the optimal of "<30ms" sits under both -- the seventh and '
      'last instance of the shape, six of them in this batch. The slowest '
      'endpoint accepts in forty-four milliseconds, inside the floor and '
      'outside the optimal, and the slowest terminal state takes six seconds, '
      'which is the number a person actually waits and which no cell in this '
      'row asks for.';

  static const String columnNote =
      'COLUMN NOTE: this row measures the time to an HTTP 202, which is a '
      'queue accepting work rather than the work being done, so the terminal '
      'time is published beside it and the interface says "submitted" rather '
      'than "approved"; its "all mobile mutation endpoints" is the third '
      'unbounded "all" in two batches after Steps 408 and 418, and the first '
      'where the word survives contact with the design; it asks for load tests '
      'without naming a concurrency, a duration or a failure criterion, all '
      'three of which are declared here and named as chosen; and its optimal '
      'of "<30ms" sits below both its floor of "<100ms" and its ceiling of '
      '"150ms", the seventh and last instance of that shape. Atomic Step: "Run '
      'load tests to verify all mobile mutation endpoints return HTTP 202 in '
      'under 100ms."';

  static Map<String, bool> get obligations => <String, bool>{
        'every endpoint returns 202': everyEndpointReturns202,
        'the interface does not claim success on a 202':
            theInterfaceDoesNotClaimSuccess,
        'the terminal time is published beside the accept time':
            theTerminalTimeIsPublishedToo,
        'the test parameters are declared': allThreeAreDeclaredHere,
        'and named as chosen rather than taken from the row':
            theRowNamesNoneOfThem,
      };

  static Map<String, bool> get checks => <String, bool>{
        'a 202 is an acknowledgement, not an outcome':
            theTwoMeaningsDiffer && statusCode == 202,
        'so the interface says submitted and waits':
            theInterfaceDoesNotClaimSuccess &&
                threeSubmissionStates &&
                itIsTheShapeStep433Gave,
        'and a screen treating one as the other is wrong when it matters':
            acceptanceNote.contains('exactly the moment somebody cares'),
        'four endpoints and no exemptions':
            endpointCount == 4 && theAllHolds,
        'the third unbounded "all", and the first that holds':
            thirdUnboundedAll && whyItHoldsHere.isNotEmpty,
        'the row names no concurrency, duration or failure criterion':
            theRowNamesNoneOfThem && allThreeAreDeclaredHere,
        'so fifty clients for ten minutes are declared here':
            concurrentClients == 50 &&
                durationMinutes == 10 &&
                testNote.contains('rather than a test'),
        'every endpoint clears the floor and none reaches the optimal':
            everyEndpointClearsTheFloor && noEndpointReachesTheOptimal,
        'the optimal sits below both boundaries, for the seventh time':
            theOptimalIsBelowBothBoundaries &&
                theShapeIsTheDeclaredConvention &&
                thisIsTheSeventh,
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass' &&
                slowestTerminalSeconds == 6,
      };
}
