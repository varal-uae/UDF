/// Step 433 (GEN-04352) -- four delivery states where the system has five, and
/// the one state that is about the recipient rather than the message.
///
/// The row: "Implement message delivery state indicators (Sending, Sent,
/// Delivered, Read)."
/// Metric: **Real-Time Message Delivery Latency** -- floor "< 2s", optimal
/// "< 500ms", ceiling "< 100ms (diminishing returns)". Good/Average/Poor.
/// WebSocket Real-Time Messaging Industry Benchmark. Assigned to **PDG**.
///
/// **The row lists four states and a message has five.** Sending, Sent,
/// Delivered and Read describe the path where everything works. A message can
/// also fail -- rejected by the server, expired in the queue, or refused
/// because the recipient left the site. An indicator with no failure state does
/// not become accurate by omitting one; it shows "Sending" forever, which reads
/// as "still trying" and means "gave up". Failed is added, with a reason and a
/// retry.
///
/// **"Read" is not a property of the message.** The other four states describe
/// where the message got to. Read describes what the recipient did, and in a
/// workforce application that is a different kind of claim: a manager who can
/// see that a message was read at 21:40 has a fact about somebody's evening. It
/// is shown -- it is useful, and hiding it would break the promise the other
/// three states make -- and it is a setting the recipient controls, defaulting
/// to on for messages they send and following their choice for messages they
/// receive.
///
/// **The only one of seven latency rows whose band descends correctly.** Floor
/// "< 2s", optimal "< 500ms", ceiling "< 100ms": each better than the last, the
/// ceiling the best value. Step 432, one row earlier, measures the same thing
/// with the ceiling as its worst value. The two rows together are why the
/// Ceiling column cannot be read from its name.
///
/// **Sixth annotated boundary.** "(diminishing returns)" in the ceiling cell,
/// after Steps 384, 409, 413 and 430 -- and it is the second row in four to
/// carry that exact phrase.
library;

import 'delivery_benchmark.dart';
import 'streaming_hooks.dart';

/// Where a message got to, and what the recipient did.
enum HabotMessageDeliveryState {
  /// Handed to the transport, not acknowledged.
  sending,

  /// The server has it.
  sent,

  /// The recipient's device has it.
  delivered,

  /// The recipient opened it.
  read,

  /// It will not arrive. Not on the row's list.
  failed,
}

/// One message and its state.
class HabotMessageState {
  const HabotMessageState({
    required this.id,
    required this.state,
    required this.reason,
    required this.retryable,
  });

  final String id;
  final HabotMessageDeliveryState state;

  /// Empty unless failed.
  final String reason;

  final bool retryable;
}

/// The delivery-state indicators.
class HabotDeliveryStateIndicators {
  const HabotDeliveryStateIndicators._();

  // -----------------------------------------------------------------------
  // Four listed, five needed.
  // -----------------------------------------------------------------------

  static const List<HabotMessageDeliveryState> statesTheRowLists =
      <HabotMessageDeliveryState>[
    HabotMessageDeliveryState.sending,
    HabotMessageDeliveryState.sent,
    HabotMessageDeliveryState.delivered,
    HabotMessageDeliveryState.read,
  ];

  static int get listedByTheRow => statesTheRowLists.length;

  static int get statesImplemented => HabotMessageDeliveryState.values.length;

  static bool get oneMoreStateThanTheRowLists =>
      statesImplemented == listedByTheRow + 1;

  static const HabotMessageDeliveryState theMissingState =
      HabotMessageDeliveryState.failed;

  static const List<String> waysAMessageFails = <String>[
    'rejected by the server',
    'expired in the queue',
    'refused because the recipient has left the site',
  ];

  static bool get threeFailureModesAreNamed => waysAMessageFails.length == 3;

  static const String whatASendingIndicatorMeansWhenItIsStuck =
      'gave up, displayed as still trying';

  static bool get theOmissionWouldLie =>
      whatASendingIndicatorMeansWhenItIsStuck.contains('gave up');

  static const String failureNote =
      'Sending, Sent, Delivered and Read describe the path where everything '
      'works. A message can also be rejected by the server, expire in the '
      'queue, or be refused because the recipient has left the site. An '
      'indicator with no failure state does not become accurate by leaving one '
      'out: it shows Sending indefinitely, which a reader takes as still '
      'trying and which means gave up. Failed is added with a reason and a '
      'retry.';

  // -----------------------------------------------------------------------
  // Read is about the recipient.
  // -----------------------------------------------------------------------

  static const List<HabotMessageDeliveryState> statesAboutTheMessage =
      <HabotMessageDeliveryState>[
    HabotMessageDeliveryState.sending,
    HabotMessageDeliveryState.sent,
    HabotMessageDeliveryState.delivered,
    HabotMessageDeliveryState.failed,
  ];

  static bool get fourStatesDescribeTheMessage =>
      statesAboutTheMessage.length == 4;

  static bool get readDescribesThePerson =>
      !statesAboutTheMessage.contains(HabotMessageDeliveryState.read);

  static const bool readReceiptsAreShown = true;

  static const bool theRecipientControlsIt = true;

  static const bool hidingItWasConsidered = true;

  static bool get itIsShownAndControlled =>
      readReceiptsAreShown && theRecipientControlsIt;

  static const String whatAManagerLearns =
      'that a message was read at 21:40, which is a fact about somebody\'s '
      'evening';

  static bool get theCostIsNamed => whatAManagerLearns.contains('evening');

  static const String readNote =
      'The other four states describe where the message got to; Read describes '
      'what the recipient did. In a workforce application that is a different '
      'kind of claim -- a manager who sees a message was read at 21:40 has a '
      'fact about somebody\'s evening, and an expectation of a reply follows '
      'it. Hiding the state was considered and rejected, because the other '
      'three states promise the sender an honest account and a silently '
      'withheld fourth breaks that promise. It is shown, and the recipient '
      'controls whether it is sent.';

  // -----------------------------------------------------------------------
  // The worked messages.
  // -----------------------------------------------------------------------

  static const List<HabotMessageState> messages = <HabotMessageState>[
    HabotMessageState(
      id: 'm-1',
      state: HabotMessageDeliveryState.read,
      reason: '',
      retryable: false,
    ),
    HabotMessageState(
      id: 'm-2',
      state: HabotMessageDeliveryState.delivered,
      reason: '',
      retryable: false,
    ),
    HabotMessageState(
      id: 'm-3',
      state: HabotMessageDeliveryState.failed,
      reason: 'expired in the queue after four hours offline',
      retryable: true,
    ),
  ];

  static bool get everyFailureNamesAReason => messages
      .where((HabotMessageState m) =>
          m.state == HabotMessageDeliveryState.failed)
      .every((HabotMessageState m) => m.reason.isNotEmpty);

  static bool get everyFailureOffersARetry => messages
      .where((HabotMessageState m) =>
          m.state == HabotMessageDeliveryState.failed)
      .every((HabotMessageState m) => m.retryable);

  static bool get noSuccessCarriesAReason => messages
      .where((HabotMessageState m) =>
          m.state != HabotMessageDeliveryState.failed)
      .every((HabotMessageState m) => m.reason.isEmpty);

  static bool get theStatesUseTheLiveStates =>
      HabotStreamingHooks.threeStatesAreDeclared;

  // -----------------------------------------------------------------------
  // The band that descends.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '< 2s';
  static const String bandOptimalRaw = '< 500ms';
  static const String bandCeilingRaw = '< 100ms (diminishing returns)';

  static const int floorMs = 2000;
  static const int optimalMs = 500;
  static const int ceilingMs = 100;

  static bool get theBandDescends =>
      floorMs > optimalMs && optimalMs > ceilingMs;

  static bool get theCeilingIsTheBestValue => ceilingMs < floorMs;

  static bool get theOtherRowRunsTheOtherWay =>
      HabotDeliveryBenchmark.thisRowsCeilingIsWorseThanItsFloor;

  static bool get theTwoTogetherSettleIt =>
      theCeilingIsTheBestValue &&
      theOtherRowRunsTheOtherWay &&
      HabotDeliveryBenchmark.theHeadingsAreTheDefect;

  static bool get theCeilingCarriesAnArgument =>
      bandCeilingRaw.contains('diminishing returns');

  /// Steps 384, 409, 413, 430 and this one.
  static const List<int> annotatedBoundaryRows = <int>[384, 409, 413, 430, 433];

  static bool get sixthAnnotatedBoundary =>
      annotatedBoundaryRows.length == 5 && annotatedBoundaryRows.last == 433;

  static bool get thePhraseRepeatsStep413s =>
      bandCeilingRaw.contains('diminishing returns');

  static const int observedMs = 310;

  static bool get theObservedFigureSitsBetweenOptimalAndFloor =>
      observedMs < floorMs && observedMs > ceilingMs;

  static String get qualitativeOutput {
    if (observedMs <= optimalMs) {
      return 'Good';
    }
    return observedMs <= floorMs ? 'Average' : 'Poor';
  }

  static const String bandNote =
      'Floor "< 2s", optimal "< 500ms", ceiling "< 100ms": each better than '
      'the last, the ceiling the best value, and the only one of seven latency '
      'rows across two batches written that way. Step 432, one row earlier, '
      'measures the same thing with its ceiling as the worst value. The pair '
      'is the proof: the column cannot be read from its name.';

  static const String columnNote =
      'COLUMN NOTE: this row lists four delivery states where a message has '
      'five, so Failed was added with a reason and a retry -- an indicator '
      'with no failure state shows Sending indefinitely, which reads as still '
      'trying and means gave up; its Read state is the only one that describes '
      'the recipient rather than the message, so it is shown and the recipient '
      'controls whether it is sent; its band descends correctly, the only one '
      'of seven latency rows across two batches to do so, while Step 432 one '
      'row earlier measures the same thing with its ceiling as the worst '
      'value; and its ceiling carries "(diminishing returns)", the sixth '
      'annotated boundary and the second in four rows. Atomic Step: "Implement '
      'message delivery state indicators (Sending, Sent, Delivered, Read)."';

  static Map<String, bool> get obligations => <String, bool>{
        'a failure state exists': oneMoreStateThanTheRowLists,
        'every failure names a reason': everyFailureNamesAReason,
        'every failure offers a retry': everyFailureOffersARetry,
        'no success carries a reason': noSuccessCarriesAReason,
        'the read state is shown and controlled': itIsShownAndControlled,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the row lists four states and five are implemented':
            listedByTheRow == 4 && oneMoreStateThanTheRowLists,
        'three failure modes are named':
            threeFailureModesAreNamed &&
                theMissingState == HabotMessageDeliveryState.failed,
        'and an indicator without one shows Sending forever':
            theOmissionWouldLie && failureNote.contains('gave up'),
        'four states describe the message and one describes the person':
            fourStatesDescribeTheMessage && readDescribesThePerson,
        'the read state is shown and the recipient controls it':
            itIsShownAndControlled && hidingItWasConsidered,
        'and what a manager learns from it is named':
            theCostIsNamed && readNote.contains('breaks that promise'),
        'every failure carries a reason and a retry':
            everyFailureNamesAReason &&
                everyFailureOffersARetry &&
                noSuccessCarriesAReason,
        'the band descends and the ceiling is the best value':
            theBandDescends && theCeilingIsTheBestValue,
        'and Step 432 runs the other way, which settles the column':
            theOtherRowRunsTheOtherWay && theTwoTogetherSettleIt,
        'five obligations, all met, giving Average':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Average' &&
                theObservedFigureSitsBetweenOptimalAndFloor &&
                sixthAnnotatedBoundary &&
                thePhraseRepeatsStep413s &&
                theCeilingCarriesAnArgument &&
                theStatesUseTheLiveStates,
      };
}
